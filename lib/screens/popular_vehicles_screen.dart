import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

class PopularVehiclesScreen extends StatefulWidget {
  const PopularVehiclesScreen({super.key});

  @override
  State<PopularVehiclesScreen> createState() => _PopularVehiclesScreenState();
}

class _PopularVehiclesScreenState extends State<PopularVehiclesScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  void _showAddVehicleDialog([DocumentSnapshot? document]) {
    final bool isEditing = document != null;
    
    final nameController = TextEditingController(text: isEditing && (document.data() as Map<String, dynamic>).containsKey('name') ? document['name'] : '');
    final descController = TextEditingController(text: isEditing && (document.data() as Map<String, dynamic>).containsKey('desc') ? document['desc'] : '');
    final priceController = TextEditingController(text: isEditing && (document.data() as Map<String, dynamic>).containsKey('price') ? document['price'] : '');
    
    String? uploadedImageUrl = isEditing && (document.data() as Map<String, dynamic>).containsKey('img') ? document['img'] : null;
    Uint8List? pickedImageBytes;
    bool isUploading = false;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              title: Text(isEditing ? 'Edit Vehicle' : 'Add Vehicle'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: nameController,
                      decoration: const InputDecoration(labelText: 'Vehicle Name (e.g. Economy Car)', border: OutlineInputBorder()),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: descController,
                      decoration: const InputDecoration(labelText: 'Description (e.g. Perfect for city driving)', border: OutlineInputBorder()),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: priceController,
                      decoration: const InputDecoration(labelText: 'Price (e.g. \$25/day)', border: OutlineInputBorder()),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      height: 150,
                      width: 250,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: pickedImageBytes != null 
                        ? Stack(
                            fit: StackFit.expand,
                            children: [
                              Image.memory(pickedImageBytes!, fit: BoxFit.cover),
                              Positioned(
                                top: 4, right: 4, 
                                child: IconButton(
                                  icon: const Icon(Icons.close, color: Colors.red), 
                                  onPressed: () => setStateDialog(()=> pickedImageBytes = null)
                                )
                              ),
                            ],
                          )
                        : uploadedImageUrl != null
                          ? Stack(
                              fit: StackFit.expand,
                              children: [
                                Image.network(uploadedImageUrl!, fit: BoxFit.cover),
                                Positioned(
                                  top: 4, right: 4, 
                                  child: IconButton(
                                    icon: const Icon(Icons.edit, color: Colors.blue), 
                                    onPressed: () async {
                                      final picker = ImagePicker();
                                      final image = await picker.pickImage(source: ImageSource.gallery);
                                      if (image != null) {
                                        final bytes = await image.readAsBytes();
                                        setStateDialog(() => pickedImageBytes = bytes);
                                      }
                                    }
                                  )
                                ),
                              ],
                            )
                          : Center(
                              child: ElevatedButton.icon(
                                icon: const Icon(Icons.upload),
                                label: const Text('Upload Image'),
                                onPressed: () async {
                                  final picker = ImagePicker();
                                  final image = await picker.pickImage(source: ImageSource.gallery);
                                  if (image != null) {
                                    final bytes = await image.readAsBytes();
                                    setStateDialog(() => pickedImageBytes = bytes);
                                  }
                                },
                              ),
                            ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: isUploading ? null : () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: isUploading ? null : () async {
                    if (nameController.text.isEmpty || priceController.text.isEmpty) return;
                    if (pickedImageBytes == null && uploadedImageUrl == null) return;

                    setStateDialog(() => isUploading = true);

                    try {
                      String finalImageUrl = uploadedImageUrl ?? '';

                      if (pickedImageBytes != null) {
                        final ref = FirebaseStorage.instance.ref().child('vehicles/${DateTime.now().millisecondsSinceEpoch}.jpg');
                        await ref.putData(pickedImageBytes!, SettableMetadata(contentType: 'image/jpeg'));
                        finalImageUrl = await ref.getDownloadURL();
                      }

                      final data = {
                        'name': nameController.text,
                        'desc': descController.text,
                        'price': priceController.text,
                        'img': finalImageUrl,
                        'createdAt': isEditing ? (document.data() as Map<String, dynamic>).containsKey('createdAt') ? document['createdAt'] : FieldValue.serverTimestamp() : FieldValue.serverTimestamp(),
                      };

                      if (isEditing) {
                        await _firestore.collection('popular_vehicles').doc(document.id).update(data);
                      } else {
                        await _firestore.collection('popular_vehicles').add(data);
                      }

                      if (mounted) Navigator.pop(context);
                    } catch (e) {
                      setStateDialog(() => isUploading = false);
                    }
                  },
                  child: isUploading 
                      ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                      : const Text('Save'),
                ),
              ],
            );
          }
        );
      }
    );
  }

  void _deleteVehicle(String id, String imageUrl) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Vehicle'),
        content: const Text('Are you sure you want to delete this vehicle?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              if (imageUrl.contains('firebasestorage')) {
                await FirebaseStorage.instance.refFromURL(imageUrl).delete().catchError((e){});
              }
              await _firestore.collection('popular_vehicles').doc(id).delete();
              if (mounted) Navigator.pop(context);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Popular Vehicles Setup', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore.collection('popular_vehicles').orderBy('createdAt', descending: true).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) return Center(child: Text('Error: ${snapshot.error}'));
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

          final docs = snapshot.data!.docs;

          if (docs.isEmpty) {
            return const Center(child: Text('No vehicles added yet. Click + to add one.'));
          }

          return GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              childAspectRatio: 0.8,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
            ),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final doc = docs[index];
              final data = doc.data() as Map<String, dynamic>;
              
              return Card(
                clipBehavior: Clip.antiAlias,
                elevation: 4,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 5,
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          Image.network(
                            data['img'] ?? '', 
                            fit: BoxFit.cover,
                            errorBuilder: (c,e,s) => Container(color: Colors.grey[200], child: const Icon(Icons.directions_car, size: 40, color: Colors.grey)),
                          ),
                          Positioned(
                            top: 8, right: 8,
                            child: Row(
                              children: [
                                CircleAvatar(
                                  backgroundColor: Colors.white, radius: 16,
                                  child: IconButton(icon: const Icon(Icons.edit, size: 16, color: Colors.blue), padding: EdgeInsets.zero, onPressed: () => _showAddVehicleDialog(doc)),
                                ),
                                const SizedBox(width: 8),
                                CircleAvatar(
                                  backgroundColor: Colors.white, radius: 16,
                                  child: IconButton(icon: const Icon(Icons.delete, size: 16, color: Colors.red), padding: EdgeInsets.zero, onPressed: () => _deleteVehicle(doc.id, data['img'] ?? '')),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      flex: 4,
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: SingleChildScrollView(
                          child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(data['name'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16), maxLines: 1, overflow: TextOverflow.ellipsis),
                            const SizedBox(height: 4),
                            Text(data['desc'] ?? '', style: const TextStyle(color: Colors.grey, fontSize: 12), maxLines: 2, overflow: TextOverflow.ellipsis),
                            const SizedBox(height: 8),
                            Text(data['price'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF673AB7), fontSize: 16)),
                          ],
                        ),
                      ),
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddVehicleDialog(),
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Add Vehicle', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF673AB7),
      ),
    );
  }
}
