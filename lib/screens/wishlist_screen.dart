import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class WishlistScreen extends StatelessWidget {
  const WishlistScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      color: const Color(0xFFf0f1f7),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'User Wishlists & Saved Items',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF333333),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'View all hotels and destinations saved by users.',
            style: TextStyle(color: Colors.grey, fontSize: 14),
          ),
          const SizedBox(height: 24),
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance.collection('wishlists').snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Center(child: Text('Error loading wishlists.'));
                  }
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  var docs = snapshot.data?.docs.toList() ?? [];
                  
                  // Sort in memory to avoid indexing issues
                  docs.sort((a, b) {
                    var dataA = a.data() as Map<String, dynamic>;
                    var dataB = b.data() as Map<String, dynamic>;
                    Timestamp? timeA = dataA['createdAt'] as Timestamp?;
                    Timestamp? timeB = dataB['createdAt'] as Timestamp?;
                    if (timeA == null && timeB == null) return 0;
                    if (timeA == null) return 1;
                    if (timeB == null) return -1;
                    return timeB.compareTo(timeA);
                  });

                  if (docs.isEmpty) {
                    return const Center(
                      child: Text(
                        'No wishlist items found.',
                        style: TextStyle(color: Colors.grey, fontSize: 16),
                      ),
                    );
                  }

                  return SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: SingleChildScrollView(
                      child: DataTable(
                        headingRowColor: MaterialStateProperty.all(const Color(0xFFf8f9fa)),
                        columns: const [
                          DataColumn(label: Text('Saved Date', style: TextStyle(fontWeight: FontWeight.bold))),
                          DataColumn(label: Text('User Email', style: TextStyle(fontWeight: FontWeight.bold))),
                          DataColumn(label: Text('Hotel Name', style: TextStyle(fontWeight: FontWeight.bold))),
                          DataColumn(label: Text('Price', style: TextStyle(fontWeight: FontWeight.bold))),
                        ],
                        rows: docs.map((doc) {
                          var data = doc.data() as Map<String, dynamic>;
                          
                          String savedDate = 'N/A';
                          if (data['createdAt'] != null) {
                            DateTime dt = (data['createdAt'] as Timestamp).toDate();
                            savedDate = DateFormat('MMM d, yyyy - h:mm a').format(dt);
                          }

                          return DataRow(
                            cells: [
                              DataCell(Text(savedDate, style: const TextStyle(color: Colors.grey))),
                              DataCell(Text(data['userEmail'] ?? 'N/A', style: const TextStyle(color: Colors.blue))),
                              DataCell(Text(data['hotelName'] ?? 'Unknown', style: const TextStyle(fontWeight: FontWeight.w500))),
                              DataCell(Text('\$${data['price'] ?? 0}', style: const TextStyle(color: Colors.green))),
                            ],
                          );
                        }).toList(),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
