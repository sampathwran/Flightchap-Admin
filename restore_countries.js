const fs = require('fs');

let content = fs.readFileSync('lib/screens/popular_destinations_screen.dart', 'utf8');

const replacement = `class _CountriesTabState extends State<CountriesTab> {
  @override
  void initState() {
    super.initState();
    SiteState.activeSite.addListener(_onSiteChanged);
  }

  @override
  void dispose() {
    SiteState.activeSite.removeListener(_onSiteChanged);
    super.dispose();
  }

  void _onSiteChanged() {
    if (mounted) setState(() {});
  }

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
    
    String selectedName = isEditing && (document.data() as Map<String, dynamic>).containsKey('name') ? document['name'] : _countryFlags[0]['name']!;
    String selectedFlag = isEditing && (document.data() as Map<String, dynamic>).containsKey('flag') ? document['flag'] : _countryFlags[0]['flag']!;
    final nameController = TextEditingController(text: selectedName);
    
    String? uploadedImageUrl = isEditing && (document.data() as Map<String, dynamic>).containsKey('image') ? document['image'] : null;
    Uint8List? pickedImageBytes;
    bool isUploading = false;

    // ensure selectedName is valid in the dropdown
    if (!_countryFlags.any((c) => c['name'] == selectedName)) {
      selectedName = _countryFlags[0]['name']!;
      selectedFlag = _countryFlags[0]['flag']!;
      nameController.text = selectedName;
    }

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
                        value: selectedName,
                        items: _countryFlags.map((c) {
                          return DropdownMenuItem(
                            value: c['name'],
                            child: Text('\${c['flag']}  \${c['name']}'),
                          );
                        }).toList(),
                        onChanged: (val) {
                          if (val != null) {
                            setState(() {
                              selectedName = val;
                              selectedFlag = _countryFlags.firstWhere((e) => e['name'] == val)['flag']!;
                              nameController.text = val;
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
                        final ref = FirebaseStorage.instance.ref().child('countries/\${DateTime.now().millisecondsSinceEpoch}.jpg');
                        await ref.putData(pickedImageBytes!, SettableMetadata(contentType: 'image/jpeg'));
                        finalImageUrl = await ref.getDownloadURL();
                      }
                      
                      final data = {
                        'name': nameController.text,
                        'flag': selectedFlag,
                        'image': finalImageUrl,
                        'target_website': SiteState.activeSite.value,
                        'createdAt': isEditing && (document.data() as Map<String, dynamic>).containsKey('createdAt') ? document['createdAt'] : FieldValue.serverTimestamp(),
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
        stream: _firestore.collection('countries').where('target_website', isEqualTo: SiteState.activeSite.value).snapshots(),
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
              final data = doc.data() as Map<String, dynamic>? ?? {};
              return Card(
                clipBehavior: Clip.antiAlias,
                child: Column(
                  children: [
                    Expanded(
                      flex: 3,
                      child: (data['image']?.toString().trim().isEmpty ?? true) ? Container(color: Colors.grey[200], child: const Icon(Icons.image_not_supported)) : Image.network(data['image'], fit: BoxFit.cover, width: double.infinity,
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
                            Expanded(child: Text('\${data['flag'] ?? ''} \${data['name'] ?? 'Unknown'}', style: const TextStyle(fontWeight: FontWeight.bold), maxLines: 1, overflow: TextOverflow.ellipsis)),
                            Row(
                              children: [
                                IconButton(icon: const Icon(Icons.edit, color: Colors.blue, size: 18), onPressed: () => _showAddCountryDialog(doc)),
                                IconButton(icon: const Icon(Icons.delete, color: Colors.red, size: 18), onPressed: () => _deleteCountry(doc.id, data['image'] ?? '')),
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
`;

const startIndex = content.indexOf('class _CountriesTabState extends State<CountriesTab> {');
const endIndex = content.indexOf('class CitiesTab extends StatefulWidget {');
if (startIndex !== -1 && endIndex !== -1) {
  content = content.substring(0, startIndex) + replacement + "\n// ---------------------------------------------------------------------------\n// CITIES TAB\n// ---------------------------------------------------------------------------\n" + content.substring(endIndex);
  fs.writeFileSync('lib/screens/popular_destinations_screen.dart', content, 'utf8');
}
