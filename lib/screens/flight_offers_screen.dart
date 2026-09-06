import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../widgets/flight_offer_card.dart';

class FlightOffersScreen extends StatefulWidget {
  const FlightOffersScreen({super.key});

  @override
  State<FlightOffersScreen> createState() => _FlightOffersScreenState();
}

class _FlightOffersScreenState extends State<FlightOffersScreen> {
  final CollectionReference _offersRef = FirebaseFirestore.instance.collection('flight_offers');

  void _showAddEditOfferDialog([DocumentSnapshot? document]) {
    final bool isEdit = document != null;
    
    final titleController = TextEditingController(text: isEdit && (document.data() as Map<String, dynamic>).containsKey('title') ? document['title'] : '');
    final badgeController = TextEditingController(text: isEdit && (document.data() as Map<String, dynamic>).containsKey('badgeText') ? document['badgeText'] : 'SPECIAL OFFER');
    final descController = TextEditingController(text: isEdit && (document.data() as Map<String, dynamic>).containsKey('description') ? document['description'] : '');
    final btnTextController = TextEditingController(text: isEdit && (document.data() as Map<String, dynamic>).containsKey('buttonText') ? document['buttonText'] : 'Book Now');
    final btnLinkController = TextEditingController(text: isEdit && (document.data() as Map<String, dynamic>).containsKey('buttonLink') ? document['buttonLink'] : '');
    
    // Using ValueNotifier to instantly update the live preview without calling setState on the whole screen
    final selectedDesignId = ValueNotifier<int>(isEdit && (document.data() as Map<String, dynamic>).containsKey('designId') ? document['designId'] : 1);
    final ScrollController designScrollController = ScrollController();

    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Container(
            constraints: BoxConstraints(
              maxWidth: 1000, 
              maxHeight: MediaQuery.of(context).size.height * 0.9,
            ),
            padding: const EdgeInsets.all(24),
            child: Row(
              children: [
                // Form Section (Left)
                Expanded(
                  flex: 1,
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isEdit ? 'Edit Flight Offer' : 'Add New Flight Offer',
                          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 24),
                        TextField(
                          controller: titleController,
                          decoration: const InputDecoration(labelText: 'Title (e.g., Up to 20% Off to Dubai)', border: OutlineInputBorder()),
                          onChanged: (v) => selectedDesignId.value = selectedDesignId.value, // trigger rebuild of preview
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: badgeController,
                          decoration: const InputDecoration(labelText: 'Badge Text (e.g., SPECIAL OFFER)', border: OutlineInputBorder()),
                          onChanged: (v) => selectedDesignId.value = selectedDesignId.value,
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: descController,
                          maxLines: 3,
                          decoration: const InputDecoration(labelText: 'Description', border: OutlineInputBorder()),
                          onChanged: (v) => selectedDesignId.value = selectedDesignId.value,
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: btnTextController,
                                decoration: const InputDecoration(labelText: 'Button Text', border: OutlineInputBorder()),
                                onChanged: (v) => selectedDesignId.value = selectedDesignId.value,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: TextField(
                                controller: btnLinkController,
                                decoration: const InputDecoration(labelText: 'Button Link (URL)', border: OutlineInputBorder()),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        const Text('Select Design Template:', style: TextStyle(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 12),
                        Scrollbar(
                          controller: designScrollController,
                          thumbVisibility: true,
                          thickness: 6,
                          radius: const Radius.circular(10),
                          child: SizedBox(
                            height: 90,
                            child: ListView.builder(
                              controller: designScrollController,
                              scrollDirection: Axis.horizontal,
                              padding: const EdgeInsets.only(bottom: 15),
                              itemCount: 10,
                              itemBuilder: (context, index) {
                              final id = index + 1;
                              return ValueListenableBuilder<int>(
                                valueListenable: selectedDesignId,
                                builder: (context, currentId, child) {
                                  final isSelected = currentId == id;
                                  return GestureDetector(
                                    onTap: () => selectedDesignId.value = id,
                                    child: Container(
                                      width: 60,
                                      margin: const EdgeInsets.only(right: 12),
                                      decoration: BoxDecoration(
                                        border: Border.all(color: isSelected ? Colors.blue : Colors.grey.shade300, width: isSelected ? 3 : 1),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Center(
                                        child: Text(
                                          'D$id',
                                          style: TextStyle(fontWeight: isSelected ? FontWeight.bold : FontWeight.normal, color: isSelected ? Colors.blue : Colors.black),
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              );
                            },
                          ),
                        ),
                        ),
                      ],
                    ),
                  ),
                ),
                
                const VerticalDivider(width: 48, thickness: 1),
                
                // Live Preview Section (Right)
                Expanded(
                  flex: 1,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Live Web Preview', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey)),
                      const SizedBox(height: 24),
                      ValueListenableBuilder<int>(
                        valueListenable: selectedDesignId,
                        builder: (context, id, child) {
                          return Center(
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              child: FlightOfferCardWidget(
                              title: titleController.text.isEmpty ? 'Sample Title Here' : titleController.text,
                              badgeText: badgeController.text.isEmpty ? 'BADGE' : badgeController.text,
                              description: descController.text.isEmpty ? 'Your description will appear here on the web.' : descController.text,
                              buttonText: btnTextController.text.isEmpty ? 'Button' : btnTextController.text,
                              designId: id,
                              width: 380,
                            ),
                            ),
                          );
                        },
                      ),
                      const Spacer(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Cancel'),
                          ),
                          const SizedBox(width: 16),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                            ),
                            onPressed: () async {
                              final data = {
                                'title': titleController.text,
                                'badgeText': badgeController.text,
                                'description': descController.text,
                                'buttonText': btnTextController.text,
                                'buttonLink': btnLinkController.text,
                                'designId': selectedDesignId.value,
                                'createdAt': isEdit ? (document.data() as Map<String, dynamic>).containsKey('createdAt') ? document['createdAt'] : FieldValue.serverTimestamp() : FieldValue.serverTimestamp(),
                              };
                              
                              if (isEdit) {
                                await _offersRef.doc(document.id).update(data);
                              } else {
                                await _offersRef.add(data);
                              }
                              
                              if (context.mounted) Navigator.pop(context);
                            },
                            child: Text(isEdit ? 'Update Offer' : 'Publish Offer'),
                          ),
                        ],
                      )
                    ],
                  ),
                )
              ],
            ),
          ),
        );
      },
    );
  }

  void _deleteOffer(String id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Offer?'),
        content: const Text('This will remove the offer from the website immediately.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            onPressed: () {
              _offersRef.doc(id).delete();
              Navigator.pop(context);
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Flight Offers (Dynamic Web Slider)'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _offersRef.orderBy('createdAt', descending: true).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) return const Center(child: Text('Error loading offers'));
          if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
          
          final docs = snapshot.data!.docs;
          
          if (docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.flight_outlined, size: 64, color: Colors.grey.shade400),
                  const SizedBox(height: 16),
                  const Text('No flight offers found.', style: TextStyle(fontSize: 18, color: Colors.grey)),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: _showAddEditOfferDialog,
                    icon: const Icon(Icons.add),
                    label: const Text('Create First Offer'),
                  )
                ],
              ),
            );
          }

          return Padding(
            padding: const EdgeInsets.all(24.0),
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 24,
                mainAxisSpacing: 24,
                childAspectRatio: 1.2,
              ),
              itemCount: docs.length,
              itemBuilder: (context, index) {
                final doc = docs[index];
                return Stack(
                  children: [
                    FlightOfferCardWidget(
                      title: doc['title'],
                      badgeText: doc['badgeText'],
                      description: doc['description'],
                      buttonText: doc['buttonText'],
                      designId: doc['designId'],
                      width: double.infinity,
                    ),
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit, color: Colors.white),
                            onPressed: () => _showAddEditOfferDialog(doc),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.redAccent),
                            onPressed: () => _deleteOffer(doc.id),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddEditOfferDialog(),
        icon: const Icon(Icons.add),
        label: const Text('Add New Offer'),
        backgroundColor: Colors.blue,
      ),
    );
  }
}
