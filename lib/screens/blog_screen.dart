import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;
import 'package:vsc_quill_delta_to_html/vsc_quill_delta_to_html.dart';
import 'package:flutter_quill_delta_from_html/flutter_quill_delta_from_html.dart';

class BlogScreen extends StatelessWidget {
  const BlogScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Travel Blog & Articles', style: TextStyle(fontWeight: FontWeight.bold)),
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          elevation: 0,
          bottom: const TabBar(
            labelColor: Color(0xFF673AB7),
            unselectedLabelColor: Colors.grey,
            indicatorColor: Color(0xFF673AB7),
            tabs: [
              Tab(icon: Icon(Icons.hotel), text: 'Hotel & General Blogs'),
              Tab(icon: Icon(Icons.flight_takeoff), text: 'Flight Tips & Guides'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            BlogListTab(blogType: 'hotel'),
            BlogListTab(blogType: 'flight'),
          ],
        ),
      ),
    );
  }
}

class BlogListTab extends StatefulWidget {
  final String blogType;
  const BlogListTab({super.key, required this.blogType});

  @override
  State<BlogListTab> createState() => _BlogListTabState();
}

class _BlogListTabState extends State<BlogListTab> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  void _showAddBlogDialog([DocumentSnapshot? document]) {
    final isEditing = document != null;
    final titleController = TextEditingController(text: isEditing ? document['title'] : '');
    final categoryController = TextEditingController(text: isEditing ? document['category'] : 'Guides');
    final readTimeController = TextEditingController(text: isEditing ? document['readTime'] : '5 min read');
    
    // SEO Fields
    final seoTitleController = TextEditingController(text: isEditing && (document.data() as Map<String, dynamic>).containsKey('seoTitle') ? document['seoTitle'] : '');
    final metaDescController = TextEditingController(text: isEditing && (document.data() as Map<String, dynamic>).containsKey('metaDescription') ? document['metaDescription'] : '');
    final keywordsController = TextEditingController(text: isEditing && (document.data() as Map<String, dynamic>).containsKey('keywords') ? document['keywords'] : '');
    
    // Rich Text Editor Initialization
    quill.QuillController quillController;
    if (isEditing && document['content'] != null && document['content'].toString().isNotEmpty) {
      try {
        final delta = HtmlToDelta().convert(document['content']);
        quillController = quill.QuillController(
          document: quill.Document.fromDelta(delta),
          selection: const TextSelection.collapsed(offset: 0),
        );
      } catch (e) {
        quillController = quill.QuillController.basic()..document.insert(0, document['content']);
      }
    } else {
      quillController = quill.QuillController.basic();
    }

    String? uploadedImageUrl = isEditing ? document['image'] : null;
    Uint8List? pickedImageBytes;
    bool isUploading = false;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              contentPadding: const EdgeInsets.all(24),
              title: Text(isEditing ? 'Edit ${widget.blogType == 'flight' ? 'Flight Tip' : 'Blog'}' : 'Write New ${widget.blogType == 'flight' ? 'Flight Tip' : 'Blog'}', style: const TextStyle(fontWeight: FontWeight.bold)),
              content: Container(
                width: MediaQuery.of(context).size.width * 0.8,
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.7,
                ),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            flex: 2,
                            child: TextField(
                              controller: titleController,
                              decoration: const InputDecoration(labelText: 'Article Title', border: OutlineInputBorder()),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextField(
                              controller: categoryController,
                              decoration: const InputDecoration(labelText: 'Category (e.g. Tips)', border: OutlineInputBorder()),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextField(
                              controller: readTimeController,
                              decoration: const InputDecoration(labelText: 'Read Time (e.g. 5 min)', border: OutlineInputBorder()),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      
                      // Cover Image Section
                      const Text('Cover Image', style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      Container(
                        height: 150,
                        width: 300,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: pickedImageBytes != null 
                          ? Stack(
                              fit: StackFit.expand,
                              children: [
                                Image.memory(pickedImageBytes!, fit: BoxFit.cover),
                                Positioned(top: 4, right: 4, child: IconButton(icon: const Icon(Icons.close, color: Colors.red), onPressed: () => setStateDialog(()=> pickedImageBytes = null))),
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
                                  label: const Text('Upload Cover Image'),
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
                      const SizedBox(height: 16),

                      // Rich Text Editor (Quill)
                      const Text('Article Content', style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      Container(
                        height: 400,
                        decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade300), borderRadius: BorderRadius.circular(8)),
                        child: Column(
                          children: [
                            quill.QuillSimpleToolbar(
                              controller: quillController,
                            ),
                            const Divider(height: 1),
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: quill.QuillEditor.basic(
                                  controller: quillController,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      const SizedBox(height: 24),
                      const Text('SEO & Meta Data', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                      const SizedBox(height: 12),
                      TextField(
                        controller: seoTitleController,
                        decoration: const InputDecoration(labelText: 'SEO Title (Optional)', border: OutlineInputBorder()),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: metaDescController,
                        maxLines: 2,
                        decoration: const InputDecoration(labelText: 'Meta Description', border: OutlineInputBorder()),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: keywordsController,
                        decoration: const InputDecoration(labelText: 'Target Keywords (comma separated)', border: OutlineInputBorder()),
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: isUploading ? null : () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: isUploading ? null : () async {
                    if (titleController.text.isEmpty || quillController.document.isEmpty()) return;
                    setStateDialog(() => isUploading = true);
                    try {
                      // Convert Delta to HTML
                      final deltaJson = quillController.document.toDelta().toJson();
                      final htmlConverter = QuillDeltaToHtmlConverter(
                        List.castFrom(deltaJson), 
                        ConverterOptions(
                          converterOptions: OpConverterOptions(inlineStylesFlag: true)
                        )
                      );
                      final htmlContent = htmlConverter.convert();

                      String finalImageUrl = uploadedImageUrl ?? '';
                      if (pickedImageBytes != null) {
                        final ref = FirebaseStorage.instance.ref().child('blogs/${DateTime.now().millisecondsSinceEpoch}.jpg');
                        await ref.putData(pickedImageBytes!, SettableMetadata(contentType: 'image/jpeg'));
                        finalImageUrl = await ref.getDownloadURL();
                      }
                      
                      final data = {
                        'title': titleController.text,
                        'category': categoryController.text,
                        'readTime': readTimeController.text,
                        'content': htmlContent,
                        'seoTitle': seoTitleController.text,
                        'metaDescription': metaDescController.text,
                        'keywords': keywordsController.text,
                        'image': finalImageUrl,
                        'type': widget.blogType, // Save the specific type
                        'createdAt': isEditing ? document['createdAt'] : FieldValue.serverTimestamp(),
                      };
                      
                      if (isEditing) {
                        await _firestore.collection('blogs').doc(document.id).update(data);
                      } else {
                        await _firestore.collection('blogs').add(data);
                      }
                      if (mounted) Navigator.pop(context);
                    } catch (e) {
                      setStateDialog(() => isUploading = false);
                    }
                  },
                  child: isUploading 
                      ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                      : const Text('Save', style: TextStyle(color: Colors.white)),
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF673AB7)),
                ),
              ],
            );
          }
        );
      }
    );
  }

  void _deleteBlog(String id, String imageUrl) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Blog Post'),
        content: const Text('Are you sure you want to delete this article?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              if (imageUrl.contains('firebasestorage')) {
                await FirebaseStorage.instance.refFromURL(imageUrl).delete().catchError((e){});
              }
              await _firestore.collection('blogs').doc(id).delete();
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
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore.collection('blogs').orderBy('createdAt', descending: true).snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          
          // Filter in dart to avoid missing index or field issues for older records
          final docs = snapshot.data!.docs.where((d) {
            final dataMap = d.data() as Map<String, dynamic>;
            final docType = dataMap.containsKey('type') ? dataMap['type'] : 'hotel';
            return docType == widget.blogType;
          }).toList();
          
          if (docs.isEmpty) {
            return Center(child: Text('No ${widget.blogType == 'flight' ? 'flight tips' : 'articles'} written yet. Click + to add one.'));
          }

          return GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              childAspectRatio: 0.85,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
            ),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final doc = docs[index];
              return Card(
                clipBehavior: Clip.antiAlias,
                elevation: 4,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 4,
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          Image.network(doc['image'], fit: BoxFit.cover, width: double.infinity,
                            errorBuilder: (c,e,s) => Container(color: Colors.grey[200], child: const Icon(Icons.image_not_supported)),
                          ),
                          Positioned(
                            top: 8, right: 8,
                            child: Row(
                              children: [
                                CircleAvatar(
                                  backgroundColor: Colors.white, radius: 16,
                                  child: IconButton(icon: const Icon(Icons.edit, size: 16, color: Colors.blue), padding: EdgeInsets.zero, onPressed: () => _showAddBlogDialog(doc)),
                                ),
                                const SizedBox(width: 8),
                                CircleAvatar(
                                  backgroundColor: Colors.white, radius: 16,
                                  child: IconButton(icon: const Icon(Icons.delete, size: 16, color: Colors.red), padding: EdgeInsets.zero, onPressed: () => _deleteBlog(doc.id, doc['image'])),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      flex: 5,
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(color: Colors.blue.shade50, borderRadius: BorderRadius.circular(4)),
                              child: Text(doc['category'], style: const TextStyle(fontSize: 10, color: Colors.blue, fontWeight: FontWeight.bold)),
                            ),
                            const SizedBox(height: 8),
                            Text(doc['title'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16), maxLines: 2, overflow: TextOverflow.ellipsis),
                            const SizedBox(height: 4),
                            Text(doc['readTime'], style: const TextStyle(color: Colors.grey, fontSize: 12)),
                            const Spacer(),
                            if ((doc.data() as Map).containsKey('createdAt') && doc['createdAt'] != null)
                              Text(
                                (doc['createdAt'] as Timestamp).toDate().toString().split(' ')[0],
                                style: const TextStyle(color: Colors.grey, fontSize: 11),
                              ),
                          ],
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
        onPressed: () => _showAddBlogDialog(),
        icon: const Icon(Icons.add, color: Colors.white),
        label: Text('Add ${widget.blogType == 'flight' ? 'Tip' : 'Article'}', style: const TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF673AB7),
      ),
    );
  }
}
