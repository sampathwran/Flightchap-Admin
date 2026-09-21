import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';

class FareAlertsSubscribersScreen extends StatefulWidget {
  const FareAlertsSubscribersScreen({super.key});

  @override
  State<FareAlertsSubscribersScreen> createState() => _FareAlertsSubscribersScreenState();
}

class _FareAlertsSubscribersScreenState extends State<FareAlertsSubscribersScreen> {
  final CollectionReference _subscribersRef = FirebaseFirestore.instance.collection('subscribers');
  
  Set<String> _selectedEmails = {};
  List<String> _allCurrentEmails = [];

  Future<void> _sendEmailToSelected() async {
    if (_selectedEmails.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('No emails selected.')));
      return;
    }

    final String bccList = _selectedEmails.join(',');
    final Uri emailLaunchUri = Uri(
      scheme: 'mailto',
      path: '',
      query: 'bcc=$bccList&subject=Exclusive Flight Deal from Flightchap', 
    );

    try {
      if (await canLaunchUrl(emailLaunchUri)) {
        await launchUrl(emailLaunchUri);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Could not open email client. Please check your default mail app.')));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error launching email client: $e')));
    }
  }

  void _deleteSubscriber(String docId, String email) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete Subscriber'),
          content: Text('Remove $email from the subscriber list?'),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () async {
                await _subscribersRef.doc(docId).delete();
                setState(() {
                  _selectedEmails.remove(email);
                });
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
        title: const Text('Subscribers', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        actions: [
          if (_selectedEmails.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: ElevatedButton.icon(
                onPressed: _sendEmailToSelected,
                icon: const Icon(Icons.email, color: Colors.white),
                label: Text('Email Selected (${_selectedEmails.length})', style: const TextStyle(color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF673AB7),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                ),
              ),
            ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _subscribersRef.orderBy('createdAt', descending: true).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) return Center(child: Text('Error: ${snapshot.error}'));
          if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());

          final docs = snapshot.data?.docs ?? [];
          
          // Update the list of all current emails for the "Select All" functionality
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _allCurrentEmails = docs.map((d) => d['email'].toString()).toList();
            // Cleanup selected emails that might have been deleted elsewhere
            _selectedEmails.removeWhere((email) => !_allCurrentEmails.contains(email));
          });

          if (docs.isEmpty) {
            return const Center(child: Text('No subscribers found.', style: TextStyle(fontSize: 18, color: Colors.grey)));
          }

          final bool isAllSelected = _selectedEmails.length == docs.length && docs.isNotEmpty;

          return ListView(
            padding: const EdgeInsets.all(24.0),
            children: [
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4)),
                  ],
                ),
                clipBehavior: Clip.antiAlias,
                child: DataTable(
                  headingRowColor: WidgetStateProperty.resolveWith((states) => Colors.grey.shade50),
                  columns: [
                    DataColumn(
                      label: Row(
                        children: [
                          Checkbox(
                            value: isAllSelected,
                            activeColor: const Color(0xFF673AB7),
                            onChanged: (bool? value) {
                              setState(() {
                                if (value == true) {
                                  _selectedEmails.addAll(_allCurrentEmails);
                                } else {
                                  _selectedEmails.clear();
                                }
                              });
                            },
                          ),
                          const Text('Select All', style: TextStyle(fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                    const DataColumn(label: Text('Email Address', style: TextStyle(fontWeight: FontWeight.bold))),
                    const DataColumn(label: Text('Source', style: TextStyle(fontWeight: FontWeight.bold))),
                    const DataColumn(label: Text('Subscribed Date', style: TextStyle(fontWeight: FontWeight.bold))),
                    const DataColumn(label: Text('Actions', style: TextStyle(fontWeight: FontWeight.bold))),
                  ],
                  rows: docs.map((doc) {
                    final email = doc['email']?.toString() ?? 'N/A';
                    final isSelected = _selectedEmails.contains(email);
                    final source = (doc.data() as Map).containsKey('source') ? doc['source'].toString() : 'fare_alert';
                    final sourceDisplay = source == 'footer_newsletter' ? 'Newsletter' : 'Fare Alerts';

                    
                    String dateStr = 'Unknown';
                    if (doc['createdAt'] != null) {
                      final dt = (doc['createdAt'] as Timestamp).toDate();
                      dateStr = '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')} ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
                    }

                    return DataRow(
                      selected: isSelected,
                      onSelectChanged: (bool? selected) {
                        setState(() {
                          if (selected == true) {
                            _selectedEmails.add(email);
                          } else {
                            _selectedEmails.remove(email);
                          }
                        });
                      },
                      cells: [
                        DataCell(
                          Checkbox(
                            value: isSelected,
                            activeColor: const Color(0xFF673AB7),
                            onChanged: (bool? selected) {
                              setState(() {
                                if (selected == true) {
                                  _selectedEmails.add(email);
                                } else {
                                  _selectedEmails.remove(email);
                                }
                              });
                            },
                          ),
                        ),
                        DataCell(
                          Text(email, style: const TextStyle(fontWeight: FontWeight.w500)),
                        ),
                        DataCell(
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: source == 'footer_newsletter' ? Colors.blue.shade50 : Colors.orange.shade50,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              sourceDisplay,
                              style: TextStyle(
                                color: source == 'footer_newsletter' ? Colors.blue.shade700 : Colors.orange.shade700,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        DataCell(Text(dateStr, style: TextStyle(color: Colors.grey.shade600))),
                        DataCell(
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _deleteSubscriber(doc.id, email),
                            tooltip: 'Remove Subscriber',
                          ),
                        ),
                      ],
                    );
                  }).toList(),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
