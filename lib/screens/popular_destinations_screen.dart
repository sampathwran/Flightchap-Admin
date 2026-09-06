import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

class PopularDestinationsScreen extends StatelessWidget {
  const PopularDestinationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Best Destinations Setup', style: TextStyle(fontWeight: FontWeight.bold)),
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          elevation: 0,
          bottom: const TabBar(
            labelColor: Color(0xFF673AB7),
            unselectedLabelColor: Colors.grey,
            indicatorColor: Color(0xFF673AB7),
            tabs: [
              Tab(icon: Icon(Icons.public), text: 'Countries'),
              Tab(icon: Icon(Icons.location_city), text: 'Cities'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            CountriesTab(),
            CitiesTab(),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// COUNTRIES TAB
// ---------------------------------------------------------------------------
class CountriesTab extends StatefulWidget {
  const CountriesTab({super.key});

  @override
  State<CountriesTab> createState() => _CountriesTabState();
}

class _CountriesTabState extends State<CountriesTab> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final List<Map<String, String>> _countryFlags = [
    {"name": "Sri Lanka", "flag": "🇱🇰"},
    {"name": "United States", "flag": "🇺🇸"},
    {"name": "United Kingdom", "flag": "🇬🇧"},
    {"name": "Australia", "flag": "🇦🇺"},
    {"name": "Canada", "flag": "🇨🇦"},
    {"name": "Maldives", "flag": "🇲🇻"},
    {"name": "India", "flag": "🇮🇳"},
    {"name": "Singapore", "flag": "🇸🇬"},
    {"name": "Malaysia", "flag": "🇲🇾"},
    {"name": "Thailand", "flag": "🇹🇭"},
    {"name": "Japan", "flag": "🇯🇵"},
    {"name": "China", "flag": "🇨🇳"},
    {"name": "France", "flag": "🇫🇷"},
    {"name": "Germany", "flag": "🇩🇪"},
    {"name": "Italy", "flag": "🇮🇹"},
    {"name": "Switzerland", "flag": "🇨🇭"},
    {"name": "United Arab Emirates", "flag": "🇦🇪"},
    {"name": "New Zealand", "flag": "🇳🇿"},
    {"name": "South Korea", "flag": "🇰🇷"},
    {"name": "Brazil", "flag": "🇧🇷"},
    {"name": "Russia", "flag": "🇷🇺"},
    {"name": "Indonesia", "flag": "🇮🇩"},
    {"name": "Vietnam", "flag": "🇻🇳"},
    {"name": "Philippines", "flag": "🇵🇭"},
    {"name": "Turkey", "flag": "🇹🇷"},
    {"name": "Saudi Arabia", "flag": "🇸🇦"},
    {"name": "Qatar", "flag": "🇶🇦"},
    {"name": "Egypt", "flag": "🇪🇬"},
    {"name": "South Africa", "flag": "🇿🇦"},
    {"name": "Other / Custom", "flag": "🏳️"},
  ];

  void _showAddCountryDialog([DocumentSnapshot? document]) {
    final bool isEditing = document != null;
    
    String selectedFlag = isEditing && (document.data() as Map<String, dynamic>).containsKey('flag') ? document['flag'] : '🗺️';
    final nameController = TextEditingController(text: isEditing && (document.data() as Map<String, dynamic>).containsKey('name') ? document['name'] : '');
    
    String? uploadedImageUrl = isEditing && (document.data() as Map<String, dynamic>).containsKey('image') ? document['image'] : null;
    Uint8List? pickedImageBytes;
    bool isUploading = false;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text(isEditing ? 'Edit Country' : 'Add New Country'),
              content: SingleChildScrollView(
                child: SizedBox(
                  width: 400,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      DropdownButtonFormField<String>(
                        decoration: const InputDecoration(labelText: 'Select Country'),
                        value: selectedFlag,
                        items: _countryFlags.map((c) {
                          return DropdownMenuItem(
                            value: c['flag'],
                            child: Text('${c['flag']}  ${c['name']}'),
                          );
                        }).toList(),
                        onChanged: (val) {
                          if (val != null) {
                            setState(() {
                              selectedFlag = val;
                              if (!isEditing && nameController.text.isEmpty) {
                                nameController.text = _countryFlags.firstWhere((e) => e['flag'] == val)['name'] ?? '';
                              }
                            });
                          }
                        },
                      ),
                      TextField(
                        controller: nameController,
                        decoration: const InputDecoration(labelText: 'Country Display Name'),
                      ),
                      const SizedBox(height: 20),
                      Container(
                        height: 150,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey[300]!),
                          image: pickedImageBytes != null 
                            ? DecorationImage(image: MemoryImage(pickedImageBytes!), fit: BoxFit.cover)
                            : (uploadedImageUrl != null && uploadedImageUrl!.isNotEmpty)
                              ? DecorationImage(image: NetworkImage(uploadedImageUrl!), fit: BoxFit.cover)
                              : null
                        ),
                        child: (pickedImageBytes == null && (uploadedImageUrl == null || uploadedImageUrl!.isEmpty))
                            ? const Center(child: Text('No Image Selected'))
                            : null,
                      ),
                      const SizedBox(height: 8),
                      ElevatedButton.icon(
                        onPressed: isUploading ? null : () async {
                          final picker = ImagePicker();
                          final image = await picker.pickImage(source: ImageSource.gallery);
                          if (image != null) {
                            final bytes = await image.readAsBytes();
                            setState(() => pickedImageBytes = bytes);
                          }
                        },
                        icon: const Icon(Icons.upload_file),
                        label: const Text('Select Image'),
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(onPressed: isUploading ? null : () => Navigator.pop(context), child: const Text('Cancel')),
                ElevatedButton(
                  onPressed: isUploading ? null : () async {
                    if (nameController.text.isEmpty) return;
                    setState(() => isUploading = true);
                    try {
                      String finalImageUrl = uploadedImageUrl ?? '';
                      if (pickedImageBytes != null) {
                        final ref = FirebaseStorage.instance.ref().child('countries/${DateTime.now().millisecondsSinceEpoch}.jpg');
                        await ref.putData(pickedImageBytes!, SettableMetadata(contentType: 'image/jpeg'));
                        finalImageUrl = await ref.getDownloadURL();
                      }
                      
                      final data = {
                        'name': nameController.text,
                        'flag': selectedFlag,
                        'image': finalImageUrl,
                        'createdAt': isEditing ? document['createdAt'] : FieldValue.serverTimestamp(),
                      };

                      if (isEditing) {
                        await _firestore.collection('countries').doc(document.id).update(data);
                      } else {
                        await _firestore.collection('countries').add(data);
                      }
                      if (mounted) Navigator.pop(context);
                    } catch (e) {
                      setState(() => isUploading = false);
                    }
                  },
                  child: isUploading ? const CircularProgressIndicator() : Text(isEditing ? 'Update' : 'Save'),
                )
              ],
            );
          }
        );
      }
    );
  }

  void _deleteCountry(String id, String imageUrl) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Country'),
        content: const Text('Are you sure? This will not delete the associated cities automatically.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              if (imageUrl.contains('firebasestorage')) {
                await FirebaseStorage.instance.refFromURL(imageUrl).delete().catchError((e){});
              }
              await _firestore.collection('countries').doc(id).delete();
              if (mounted) Navigator.pop(context);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          )
        ],
      )
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddCountryDialog(),
        icon: const Icon(Icons.add),
        label: const Text('Add Country'),
        backgroundColor: const Color(0xFF673AB7),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore.collection('countries').orderBy('createdAt', descending: true).snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          final docs = snapshot.data!.docs;
          if (docs.isEmpty) return const Center(child: Text('No countries added yet.'));

          return GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4, 
              crossAxisSpacing: 16, 
              mainAxisSpacing: 16, 
              childAspectRatio: 0.8
            ),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final doc = docs[index];
              return Card(
                clipBehavior: Clip.antiAlias,
                child: Column(
                  children: [
                    Expanded(
                      flex: 3,
                      child: Image.network(doc['image'], fit: BoxFit.cover, width: double.infinity,
                        errorBuilder: (c,e,s) => Container(color: Colors.grey[200], child: const Icon(Icons.image_not_supported)),
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(child: Text('${(doc.data() as Map<String, dynamic>).containsKey('flag') ? doc['flag'] : ''} ${(doc.data() as Map<String, dynamic>).containsKey('name') ? doc['name'] : 'Unknown'}', style: const TextStyle(fontWeight: FontWeight.bold), maxLines: 1, overflow: TextOverflow.ellipsis)),
                            Row(
                              children: [
                                IconButton(icon: const Icon(Icons.edit, color: Colors.blue, size: 18), onPressed: () => _showAddCountryDialog(doc)),
                                IconButton(icon: const Icon(Icons.delete, color: Colors.red, size: 18), onPressed: () => _deleteCountry(doc.id, doc['image'])),
                              ],
                            )
                          ],
                        ),
                      ),
                    )
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// CITIES TAB
// ---------------------------------------------------------------------------
class CitiesTab extends StatefulWidget {
  const CitiesTab({super.key});

  @override
  State<CitiesTab> createState() => _CitiesTabState();
}

class _CitiesTabState extends State<CitiesTab> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<DocumentSnapshot> _countries = [];

  @override
  void initState() {
    super.initState();
    _fetchCountries();
  }

  Future<void> _fetchCountries() async {
    final snap = await _firestore.collection('countries').get();
    setState(() {
      _countries = snap.docs;
    });
  }

  void _showAddCityDialog([DocumentSnapshot? document]) {
    final bool isEditing = document != null;
    
    String? selectedCountryId = isEditing && (document.data() as Map<String, dynamic>).containsKey('countryId') ? document['countryId'] : (_countries.isNotEmpty ? _countries.first.id : null);
    
    final nameController = TextEditingController(text: isEditing && (document.data() as Map<String, dynamic>).containsKey('name') ? document['name'] : '');
    final descController = TextEditingController(text: isEditing && (document.data() as Map<String, dynamic>).containsKey('desc') ? document['desc'] : '');
    
    final startingPriceController = TextEditingController(text: isEditing && (document.data() as Map<String, dynamic>).containsKey('startingPrice') ? document['startingPrice'] : '');
    final bestTimeController = TextEditingController(text: isEditing && (document.data() as Map<String, dynamic>).containsKey('bestTime') ? document['bestTime'] : '');
    final tagsController = TextEditingController(text: isEditing && (document.data() as Map<String, dynamic>).containsKey('tags') ? document['tags'] : '');
    final ratingController = TextEditingController(text: isEditing && (document.data() as Map<String, dynamic>).containsKey('rating') ? document['rating'] : '4.8');
    final reviewsController = TextEditingController(text: isEditing && (document.data() as Map<String, dynamic>).containsKey('reviews') ? document['reviews'] : '15k');
    
    String? uploadedImageUrl = isEditing && (document.data() as Map<String, dynamic>).containsKey('image') ? document['image'] : null;
    Uint8List? pickedImageBytes;
    bool isUploading = false;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text(isEditing ? 'Edit City' : 'Add New City'),
              content: SingleChildScrollView(
                child: SizedBox(
                  width: 400,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      DropdownButtonFormField<String>(
                        decoration: const InputDecoration(labelText: 'Select Country'),
                        value: selectedCountryId,
                        items: _countries.map((c) {
                          return DropdownMenuItem(
                            value: c.id,
                            child: Text('${c['flag']} ${c['name']}'),
                          );
                        }).toList(),
                        onChanged: (val) {
                          setState(() => selectedCountryId = val);
                        },
                      ),
                      TextField(controller: nameController, decoration: const InputDecoration(labelText: 'City Name (e.g. Colombo)')),
                      TextField(controller: descController, maxLines: 3, decoration: const InputDecoration(labelText: 'Beautiful Description')),
                      TextField(controller: startingPriceController, decoration: const InputDecoration(labelText: 'Starting Price (\$) (e.g. 50)')),
                      TextField(controller: bestTimeController, decoration: const InputDecoration(labelText: 'Best Time to Visit (e.g. Dec - Mar)')),
                      TextField(controller: tagsController, decoration: const InputDecoration(labelText: 'Tags (comma separated, e.g. 🏖️ Beaches, 🏰 Heritage)')),
                      TextField(controller: ratingController, decoration: const InputDecoration(labelText: 'Rating (e.g. 4.8)')),
                      TextField(controller: reviewsController, decoration: const InputDecoration(labelText: 'Total Reviews (e.g. 15k)')),
                      const SizedBox(height: 20),
                      Container(
                        height: 150,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey[300]!),
                          image: pickedImageBytes != null 
                            ? DecorationImage(image: MemoryImage(pickedImageBytes!), fit: BoxFit.cover)
                            : (uploadedImageUrl != null && uploadedImageUrl!.isNotEmpty)
                              ? DecorationImage(image: NetworkImage(uploadedImageUrl!), fit: BoxFit.cover)
                              : null
                        ),
                        child: (pickedImageBytes == null && (uploadedImageUrl == null || uploadedImageUrl!.isEmpty))
                            ? const Center(child: Text('No City Image Selected'))
                            : null,
                      ),
                      const SizedBox(height: 8),
                      ElevatedButton.icon(
                        onPressed: isUploading ? null : () async {
                          final picker = ImagePicker();
                          final image = await picker.pickImage(source: ImageSource.gallery);
                          if (image != null) {
                            final bytes = await image.readAsBytes();
                            setState(() => pickedImageBytes = bytes);
                          }
                        },
                        icon: const Icon(Icons.upload_file),
                        label: const Text('Select City Image'),
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(onPressed: isUploading ? null : () => Navigator.pop(context), child: const Text('Cancel')),
                ElevatedButton(
                  onPressed: isUploading ? null : () async {
                    if (nameController.text.isEmpty || selectedCountryId == null) return;
                    setState(() => isUploading = true);
                    try {
                      String finalImageUrl = uploadedImageUrl ?? '';
                      if (pickedImageBytes != null) {
                        final ref = FirebaseStorage.instance.ref().child('cities/${DateTime.now().millisecondsSinceEpoch}.jpg');
                        await ref.putData(pickedImageBytes!, SettableMetadata(contentType: 'image/jpeg'));
                        finalImageUrl = await ref.getDownloadURL();
                      }
                      final data = {
                        'name': nameController.text,
                        'countryId': selectedCountryId,
                        'desc': descController.text,
                        'startingPrice': startingPriceController.text,
                        'bestTime': bestTimeController.text,
                        'tags': tagsController.text,
                        'image': finalImageUrl,
                        'rating': ratingController.text,
                        'reviews': reviewsController.text,
                        'createdAt': isEditing ? document['createdAt'] : FieldValue.serverTimestamp(),
                      };
                      if (isEditing) {
                        await _firestore.collection('cities').doc(document.id).update(data);
                      } else {
                        await _firestore.collection('cities').add(data);
                      }
                      if (mounted) Navigator.pop(context);
                    } catch (e) {
                      setState(() => isUploading = false);
                    }
                  },
                  child: isUploading ? const CircularProgressIndicator() : Text(isEditing ? 'Update' : 'Save'),
                )
              ],
            );
          }
        );
      }
    );
  }

  void _deleteCity(String id, String imageUrl) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete City'),
        content: const Text('Are you sure?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              if (imageUrl.contains('firebasestorage')) {
                await FirebaseStorage.instance.refFromURL(imageUrl).delete().catchError((e){});
              }
              await _firestore.collection('cities').doc(id).delete();
              if (mounted) Navigator.pop(context);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          )
        ],
      )
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _countries.isEmpty ? null : () => _showAddCityDialog(),
        icon: const Icon(Icons.add),
        label: const Text('Add City'),
        backgroundColor: _countries.isEmpty ? Colors.grey : const Color(0xFF673AB7),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore.collection('cities').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          final docs = snapshot.data!.docs;
          if (docs.isEmpty) return const Center(child: Text('No cities added yet.'));

          return GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3, 
              crossAxisSpacing: 16, 
              mainAxisSpacing: 16, 
              childAspectRatio: 0.75
            ),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final doc = docs[index];
              String cName = "Unknown";
              try { cName = _countries.firstWhere((c) => c.id == doc['countryId'])['name']; } catch(e){}
              
              return Card(
                clipBehavior: Clip.antiAlias,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 4,
                      child: Image.network(doc['image'], fit: BoxFit.cover, width: double.infinity,
                        errorBuilder: (c,e,s) => Container(color: Colors.grey[200], child: const Icon(Icons.image_not_supported)),
                      ),
                    ),
                    Expanded(
                      flex: 3,
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('${(doc.data() as Map<String, dynamic>).containsKey('name') ? doc['name'] : 'Unknown'} (${cName})', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16), maxLines: 1, overflow: TextOverflow.ellipsis),
                            const SizedBox(height: 4),
                            Expanded(child: Text((doc.data() as Map<String, dynamic>).containsKey('desc') ? doc['desc'] : '', maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 12, color: Colors.grey))),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                IconButton(icon: const Icon(Icons.edit, color: Colors.blue, size: 20), padding: EdgeInsets.zero, constraints: const BoxConstraints(), onPressed: () => _showAddCityDialog(doc)),
                                const SizedBox(width: 12),
                                IconButton(icon: const Icon(Icons.delete, color: Colors.red, size: 20), padding: EdgeInsets.zero, constraints: const BoxConstraints(), onPressed: () => _deleteCity(doc.id, doc['image'])),
                              ],
                            )
                          ],
                        ),
                      ),
                    )
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
