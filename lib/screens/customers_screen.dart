import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class CustomersScreen extends StatelessWidget {
  const CustomersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      color: const Color(0xFFf0f1f7),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Registered Customers',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF333333),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'View details of all users who have created an account on the platform.',
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
                stream: FirebaseFirestore.instance
                    .collection('users')
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Center(child: Text('Error loading users.'));
                  }
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  var docs = snapshot.data?.docs.toList() ?? [];
                  
                  // Sort in memory to avoid Firestore excluding docs without createdAt
                  docs.sort((a, b) {
                    var dataA = a.data() as Map<String, dynamic>;
                    var dataB = b.data() as Map<String, dynamic>;
                    Timestamp? timeA = dataA['createdAt'] as Timestamp?;
                    Timestamp? timeB = dataB['createdAt'] as Timestamp?;
                    if (timeA == null && timeB == null) return 0;
                    if (timeA == null) return 1;
                    if (timeB == null) return -1;
                    return timeB.compareTo(timeA); // descending
                  });

                  if (docs.isEmpty) {
                    return const Center(
                      child: Text(
                        'No registered users found.',
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
                          DataColumn(label: Text('Name', style: TextStyle(fontWeight: FontWeight.bold))),
                          DataColumn(label: Text('Email', style: TextStyle(fontWeight: FontWeight.bold))),
                          DataColumn(label: Text('Joined Date', style: TextStyle(fontWeight: FontWeight.bold))),
                          DataColumn(label: Text('Last Login', style: TextStyle(fontWeight: FontWeight.bold))),
                        ],
                        rows: docs.map((doc) {
                          var data = doc.data() as Map<String, dynamic>;
                          
                          // Format Dates safely
                          String joinedDate = 'N/A';
                          if (data['createdAt'] != null) {
                            DateTime dt = (data['createdAt'] as Timestamp).toDate();
                            joinedDate = DateFormat('MMM d, yyyy - h:mm a').format(dt);
                          }

                          String lastLogin = 'N/A';
                          if (data['lastLoginAt'] != null) {
                            DateTime dt = (data['lastLoginAt'] as Timestamp).toDate();
                            lastLogin = DateFormat('MMM d, yyyy - h:mm a').format(dt);
                          }

                          return DataRow(
                            cells: [
                              DataCell(Text(data['name'] ?? 'No Name', style: const TextStyle(fontWeight: FontWeight.w500))),
                              DataCell(Text(data['email'] ?? 'N/A', style: const TextStyle(color: Colors.blue))),
                              DataCell(Text(joinedDate, style: const TextStyle(color: Colors.grey))),
                              DataCell(Text(lastLogin, style: const TextStyle(color: Colors.grey))),
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
