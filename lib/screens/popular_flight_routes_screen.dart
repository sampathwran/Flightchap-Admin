import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

class PopularFlightRoutesScreen extends StatefulWidget {
  const PopularFlightRoutesScreen({super.key});

  @override
  State<PopularFlightRoutesScreen> createState() => _PopularFlightRoutesScreenState();
}

class _PopularFlightRoutesScreenState extends State<PopularFlightRoutesScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final CollectionReference _routesRef = FirebaseFirestore.instance.collection('popular_flight_routes');

  void _showAddEditRouteDialog([DocumentSnapshot? document]) {
    final bool isEditing = document != null;
    
    final fromController = TextEditingController(text: isEditing ? document['from'] : 'Colombo');
    final toController = TextEditingController(text: isEditing ? document['to'] : '');
    final priceController = TextEditingController(text: isEditing ? document['price'] : '\$250');
    
    String? uploadedImageUrl = isEditing ? document['img'] : null;
    Uint8List? pickedImageBytes;
    bool isUploading = false;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            
            Future<void> pickImage() async {
              final ImagePicker picker = ImagePicker();
              final XFile? image = await picker.pickImage(source: ImageSource.gallery);
              if (image != null) {
                final bytes = await image.readAsBytes();
                setStateDialog(() {
                  pickedImageBytes = bytes;
                });
              }
            }

            Future<void> saveRoute() async {
              if (toController.text.isEmpty || fromController.text.isEmpty || priceController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please fill all fields.')));
                return;
              }
              if (!isEditing && pickedImageBytes == null && uploadedImageUrl == null) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select an image.')));
                return;
              }

              setStateDialog(() => isUploading = true);

              try {
                String? finalImageUrl = uploadedImageUrl;

                // Upload image if a new one is selected
                if (pickedImageBytes != null) {
                  final String fileName = 'route_${DateTime.now().millisecondsSinceEpoch}.jpg';
                  final Reference ref = _storage.ref().child('flight_routes/$fileName');
                  final UploadTask uploadTask = ref.putData(pickedImageBytes!);
                  final TaskSnapshot snapshot = await uploadTask;
                  finalImageUrl = await snapshot.ref.getDownloadURL();
                }

                final Map<String, dynamic> data = {
                  'from': fromController.text.trim(),
                  'to': toController.text.trim(),
                  'price': priceController.text.trim(),
                  'img': finalImageUrl,
                  'updatedAt': FieldValue.serverTimestamp(),
                };

                if (isEditing) {
                  await document.reference.update(data);
                } else {
                  data['createdAt'] = FieldValue.serverTimestamp();
                  await _routesRef.add(data);
                }

                if (mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(isEditing ? 'Route updated successfully!' : 'Route added successfully!')),
                  );
                }
              } catch (e) {
                setStateDialog(() => isUploading = false);
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
                }
              }
            }

            return Dialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              child: Container(
                width: 600,
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(isEditing ? 'Edit Flight Route' : 'Add New Flight Route', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 24),
                    
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: fromController,
                            decoration: const InputDecoration(labelText: 'From (Origin)', border: OutlineInputBorder()),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: TextField(
                            controller: toController,
                            decoration: const InputDecoration(labelText: 'To (Destination)', border: OutlineInputBorder()),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: priceController,
                      decoration: const InputDecoration(labelText: 'Price (e.g. \$250)', border: OutlineInputBorder()),
                    ),
                    const SizedBox(height: 24),

                    // Image Picker Section
                    Container(
                      width: double.infinity,
                      height: 150,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade400, style: BorderStyle.solid),
                        borderRadius: BorderRadius.circular(12),
                        color: Colors.grey.shade50,
                      ),
                      child: pickedImageBytes != null
                          ? Stack(
                              fit: StackFit.expand,
                              children: [
                                ClipRRect(borderRadius: BorderRadius.circular(12), child: Image.memory(pickedImageBytes!, fit: BoxFit.cover)),
                                Positioned(
                                  top: 8, right: 8,
                                  child: IconButton(
                                    icon: const Icon(Icons.close, color: Colors.red, size: 30),
                                    onPressed: () => setStateDialog(() => pickedImageBytes = null),
                                  ),
                                ),
                              ],
                            )
                          : uploadedImageUrl != null
                              ? Stack(
                                  fit: StackFit.expand,
                                  children: [
                                    ClipRRect(borderRadius: BorderRadius.circular(12), child: Image.network(uploadedImageUrl!, fit: BoxFit.cover)),
                                    Positioned(
                                      top: 8, right: 8,
                                      child: IconButton(
                                        icon: const Icon(Icons.edit, color: Colors.blue, size: 30),
                                        onPressed: pickImage,
                                      ),
                                    ),
                                  ],
                                )
                              : Center(
                                  child: ElevatedButton.icon(
                                    onPressed: pickImage,
                                    icon: const Icon(Icons.image),
                                    label: const Text('Upload Destination Image'),
                                  ),
                                ),
                    ),

                    const SizedBox(height: 32),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: isUploading ? null : () => Navigator.pop(context),
                          child: const Text('Cancel'),
                        ),
                        const SizedBox(width: 16),
                        ElevatedButton(
                          onPressed: isUploading ? null : saveRoute,
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.blue, padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12)),
                          child: isUploading ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) : const Text('Save Route', style: TextStyle(color: Colors.white)),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _deleteRoute(DocumentSnapshot document) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete Route'),
          content: Text('Are you sure you want to delete ${document['from']} to ${document['to']}?'),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () async {
                await document.reference.delete();
                if (mounted) Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text('Delete', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Popular Flight Routes', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddEditRouteDialog(),
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Add Route', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF673AB7),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _routesRef.orderBy('createdAt', descending: true).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) return Center(child: Text('Error: ${snapshot.error}'));
          if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());

          final docs = snapshot.data?.docs ?? [];
          if (docs.isEmpty) return const Center(child: Text('No popular flight routes found.', style: TextStyle(fontSize: 18, color: Colors.grey)));

          return Padding(
            padding: const EdgeInsets.all(24.0),
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                crossAxisSpacing: 24,
                mainAxisSpacing: 24,
                childAspectRatio: 0.8,
              ),
              itemCount: docs.length,
              itemBuilder: (context, index) {
                final doc = docs[index];
                return Card(
                  clipBehavior: Clip.antiAlias,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                  elevation: 4,
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: Image.network(
                          doc['img'],
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => Container(color: Colors.grey.shade300, child: const Icon(Icons.broken_image, size: 50, color: Colors.grey)),
                        ),
                      ),
                      Positioned.fill(
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [Colors.black.withValues(alpha: 0.9), Colors.black.withValues(alpha: 0.3), Colors.transparent],
                              begin: Alignment.bottomCenter,
                              end: Alignment.topCenter,
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 24,
                        left: 24,
                        right: 24,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              '${doc['from']} to'.toUpperCase(),
                              style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontSize: 14, fontWeight: FontWeight.bold, letterSpacing: 1.2),
                            ),
                            Text(
                              doc['to'],
                              style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.w900),
                            ),
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
                              ),
                              child: Text(
                                'from ${doc['price']}',
                                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Positioned(
                        top: 16,
                        right: 16,
                        child: Row(
                          children: [
                            CircleAvatar(
                              backgroundColor: Colors.white,
                              radius: 20,
                              child: IconButton(
                                icon: const Icon(Icons.edit, size: 18, color: Colors.blue),
                                onPressed: () => _showAddEditRouteDialog(doc),
                              ),
                            ),
                            const SizedBox(width: 8),
                            CircleAvatar(
                              backgroundColor: Colors.white,
                              radius: 20,
                              child: IconButton(
                                icon: const Icon(Icons.delete, size: 18, color: Colors.red),
                                onPressed: () => _deleteRoute(doc),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
