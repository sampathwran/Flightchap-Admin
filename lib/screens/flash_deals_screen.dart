import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'dart:typed_data';

class FlashDealsScreen extends StatefulWidget {
  const FlashDealsScreen({super.key});

  @override
  State<FlashDealsScreen> createState() => _FlashDealsScreenState();
}

class _FlashDealsScreenState extends State<FlashDealsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _imageUrlController = TextEditingController();
  final _targetUrlController = TextEditingController();
  final _discountController = TextEditingController(); 
  
  DateTime? _selectedStartTime;
  DateTime? _selectedEndTime;
  
  Uint8List? _selectedImageBytes;
  String? _selectedImageName;
  bool _isSubmitting = false;
  
  String? _editingDealId; 

  Future<void> _selectDateTime(BuildContext context, bool isStart) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: isStart ? (_selectedStartTime ?? DateTime.now()) : (_selectedEndTime ?? DateTime.now()),
      firstDate: DateTime.now().subtract(const Duration(days: 365)), 
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (pickedDate != null) {
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );
      if (pickedTime != null) {
        setState(() {
          DateTime finalDateTime = DateTime(
            pickedDate.year,
            pickedDate.month,
            pickedDate.day,
            pickedTime.hour,
            pickedTime.minute,
          );
          if (isStart) {
            _selectedStartTime = finalDateTime;
          } else {
            _selectedEndTime = finalDateTime;
          }
        });
      }
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      final bytes = await image.readAsBytes();
      setState(() {
        _selectedImageBytes = bytes;
        _selectedImageName = image.name;
        _imageUrlController.clear();
      });
    }
  }

  void _startEditing(String id, Map<String, dynamic> data) {
    setState(() {
      _editingDealId = id;
      _titleController.text = data['title'] ?? '';
      _imageUrlController.text = data['imageUrl'] ?? '';
      _targetUrlController.text = data['targetUrl'] ?? '';
      _discountController.text = data['discountBadge'] ?? '';
      _selectedStartTime = data['startTime'] != null ? (data['startTime'] as Timestamp).toDate() : null;
      _selectedEndTime = data['endTime'] != null ? (data['endTime'] as Timestamp).toDate() : null;
      _selectedImageBytes = null;
      _selectedImageName = null;
    });
  }

  void _cancelEditing() {
    setState(() {
      _editingDealId = null;
      _titleController.clear();
      _imageUrlController.clear();
      _targetUrlController.clear();
      _discountController.clear();
      _selectedStartTime = null;
      _selectedEndTime = null;
      _selectedImageBytes = null;
      _selectedImageName = null;
    });
  }

  Future<void> _submitDeal() async {
    bool hasImage = _selectedImageBytes != null || _imageUrlController.text.trim().isNotEmpty;
    DateTime effectiveStartTime = _selectedStartTime ?? DateTime.now();
    
    if (_formKey.currentState!.validate() && _selectedEndTime != null && hasImage) {
      if (_selectedEndTime!.isBefore(effectiveStartTime)) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('End Time must be after Start Time.')));
        return;
      }
      
      // SHOW CONFIRMATION DIALOG
      bool? confirm = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(_editingDealId != null ? 'Confirm Update' : 'Confirm Deal'),
          content: Text(_editingDealId != null 
            ? 'Are you sure you want to update this flash deal?' 
            : 'Are you sure you want to add this new flash deal to the website?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              style: ElevatedButton.styleFrom(backgroundColor: _editingDealId != null ? Colors.orange : Colors.green),
              child: Text(_editingDealId != null ? 'Yes, Update' : 'Yes, Add It', style: const TextStyle(color: Colors.white)),
            ),
          ],
        ),
      );

      if (confirm != true) return; // User cancelled
      
      setState(() => _isSubmitting = true);
      try {
        String finalImageUrl = _imageUrlController.text.trim();
        
        if (_selectedImageBytes != null) {
          final storageRef = FirebaseStorage.instance.ref().child('flash_deals/${DateTime.now().millisecondsSinceEpoch}_${_selectedImageName}');
          final uploadTask = await storageRef.putData(_selectedImageBytes!);
          finalImageUrl = await uploadTask.ref.getDownloadURL();
        }

        final dealData = {
          'title': _titleController.text.trim(),
          'imageUrl': finalImageUrl,
          'targetUrl': _targetUrlController.text.trim(),
          'discountBadge': _discountController.text.trim(),
          'startTime': Timestamp.fromDate(effectiveStartTime),
          'endTime': Timestamp.fromDate(_selectedEndTime!),
          'updatedAt': FieldValue.serverTimestamp(),
        };

        if (_editingDealId != null) {
          await FirebaseFirestore.instance.collection('flash_deals').doc(_editingDealId).update(dealData);
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Flash Deal Updated Successfully!')));
        } else {
          dealData['createdAt'] = FieldValue.serverTimestamp();
          await FirebaseFirestore.instance.collection('flash_deals').add(dealData);
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Flash Deal Scheduled Successfully!')));
        }
        
        _cancelEditing();
        
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
      setState(() => _isSubmitting = false);
    } else {
      if (_selectedEndTime == null) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select an end time.')));
      } else if (!hasImage) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please provide an Image.')));
      }
    }
  }

  Future<void> _confirmDelete(String id, String title) async {
    bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Deal'),
        content: Text('Are you sure you want to permanently delete "$title"?\n\nThis will instantly remove it from the website.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Yes, Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await FirebaseFirestore.instance.collection('flash_deals').doc(id).delete();
      if (_editingDealId == id) {
        _cancelEditing();
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Deal Deleted.')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      color: const Color(0xFFf0f1f7),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Manage Flash Deals',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF333333)),
          ),
          const SizedBox(height: 24),
          
          // Form Section
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _editingDealId != null ? 'Edit Deal' : 'Add / Schedule New Deal', 
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: _editingDealId != null ? Colors.orange : Colors.black)
                      ),
                      if (_editingDealId != null)
                        TextButton.icon(
                          onPressed: _cancelEditing,
                          icon: const Icon(Icons.close, size: 16),
                          label: const Text('Cancel Edit'),
                          style: TextButton.styleFrom(foregroundColor: Colors.red),
                        )
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: TextFormField(
                          controller: _titleController,
                          decoration: const InputDecoration(labelText: 'Title / Hotel Name', border: OutlineInputBorder()),
                          validator: (v) => v!.isEmpty ? 'Required' : null,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        flex: 2,
                        child: TextFormField(
                          controller: _targetUrlController,
                          decoration: const InputDecoration(labelText: 'Target URL (Link to open)', border: OutlineInputBorder()),
                          validator: (v) => v!.isEmpty ? 'Required' : null,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        flex: 1,
                        child: TextFormField(
                          controller: _discountController,
                          decoration: const InputDecoration(labelText: 'Discount (e.g. 50% OFF)', border: OutlineInputBorder()),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        flex: 2,
                        child: _selectedImageBytes != null 
                          ? Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(border: Border.all(color: Colors.green), borderRadius: BorderRadius.circular(4), color: Colors.green.withOpacity(0.1)),
                              child: Row(
                                children: [
                                  const Icon(Icons.check_circle, color: Colors.green),
                                  const SizedBox(width: 8),
                                  Expanded(child: Text('Image Selected: $_selectedImageName', style: const TextStyle(fontWeight: FontWeight.bold))),
                                  IconButton(
                                    icon: const Icon(Icons.close, color: Colors.red),
                                    onPressed: () => setState(() => _selectedImageBytes = null),
                                  )
                                ],
                              ),
                            )
                          : TextFormField(
                              controller: _imageUrlController,
                              decoration: const InputDecoration(labelText: 'Paste Image URL (or upload image)', border: OutlineInputBorder()),
                            ),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton.icon(
                        onPressed: _pickImage,
                        icon: const Icon(Icons.upload_file),
                        label: const Text('Upload'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                          backgroundColor: Colors.blueGrey,
                          foregroundColor: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 16),
                      
                      // START TIME PICKER
                      Expanded(
                        flex: 1,
                        child: InkWell(
                          onTap: () => _selectDateTime(context, true),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 8),
                            decoration: BoxDecoration(border: Border.all(color: Colors.green.shade400), borderRadius: BorderRadius.circular(4)),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Starts At (Optional)', style: TextStyle(fontSize: 10, color: Colors.green, fontWeight: FontWeight.bold)),
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(_selectedStartTime == null ? 'Starts Now' : DateFormat('MMM d, h:mm a').format(_selectedStartTime!), style: const TextStyle(fontSize: 12), overflow: TextOverflow.ellipsis),
                                    ),
                                    const Icon(Icons.play_circle_outline, size: 16, color: Colors.green),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      
                      // END TIME PICKER
                      Expanded(
                        flex: 1,
                        child: InkWell(
                          onTap: () => _selectDateTime(context, false),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 8),
                            decoration: BoxDecoration(border: Border.all(color: Colors.red.shade400), borderRadius: BorderRadius.circular(4)),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Ends At (Required)', style: TextStyle(fontSize: 10, color: Colors.red, fontWeight: FontWeight.bold)),
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(_selectedEndTime == null ? 'Select Time' : DateFormat('MMM d, h:mm a').format(_selectedEndTime!), style: const TextStyle(fontSize: 12), overflow: TextOverflow.ellipsis),
                                    ),
                                    const Icon(Icons.stop_circle_outlined, size: 16, color: Colors.red),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      
                      ElevatedButton(
                        onPressed: _isSubmitting ? null : _submitDeal,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _editingDealId != null ? Colors.orange : const Color(0xFF007bff),
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                        ),
                        child: _isSubmitting 
                          ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                          : Text(_editingDealId != null ? 'Update Deal' : 'Add Deal', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 24),
          
          // List Section
          Expanded(
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Flash Deals History', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  Expanded(
                    child: StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance.collection('flash_deals').snapshots(),
                      builder: (context, snapshot) {
                        if (snapshot.hasError) return const Center(child: Text('Error loading deals'));
                        if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
                        
                        
                    final docs = snapshot.data?.docs ?? [];
                    docs.sort((a, b) {
                      final aTime = (a.data() as Map<String, dynamic>)['endTime'] as Timestamp?;
                      final bTime = (b.data() as Map<String, dynamic>)['endTime'] as Timestamp?;
                      if (aTime == null || bTime == null) return 0;
                      return bTime.compareTo(aTime);
                    });
                    if (docs.isEmpty) return const Center(child: Text('No flash deals found.'));


                        return ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: docs.length,
                          itemBuilder: (context, index) {
                            var data = docs[index].data() as Map<String, dynamic>;
                            DateTime endTime = (data['endTime'] as Timestamp).toDate();
                            DateTime? startTime = data['startTime'] != null ? (data['startTime'] as Timestamp).toDate() : null;
                            
                            bool isExpired = endTime.isBefore(DateTime.now());
                            bool isScheduled = startTime != null && startTime.isAfter(DateTime.now());
                            String badge = data['discountBadge'] ?? '';
                            
                            String statusText = isExpired ? 'Expired' : (isScheduled ? 'Scheduled' : 'Active');
                            Color statusColor = isExpired ? Colors.red : (isScheduled ? Colors.orange : Colors.green);

                            return Card(
                              margin: const EdgeInsets.only(bottom: 12),
                              elevation: 2,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                                side: BorderSide(color: _editingDealId == docs[index].id ? Colors.orange : Colors.transparent, width: 2)
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: ListTile(
                                  leading: (data['imageUrl'] != null && data['imageUrl'].toString().trim().isNotEmpty)
                                    ? ClipRRect(
                                        borderRadius: BorderRadius.circular(8),
                                        child: Image.network(
                                          data['imageUrl'], 
                                          width: 70, 
                                          height: 70, 
                                          fit: BoxFit.cover,
                                          errorBuilder: (c, e, s) => Container(
                                            width: 70, height: 70, color: Colors.grey.shade200, 
                                            child: const Icon(Icons.image_not_supported, color: Colors.grey)
                                          )
                                        ),
                                      )
                                    : Container(
                                        width: 70, height: 70, 
                                        decoration: BoxDecoration(color: Colors.grey.shade200, borderRadius: BorderRadius.circular(8)),
                                        child: const Icon(Icons.local_offer, color: Colors.grey)
                                      ),
                                  title: Row(
                                    children: [
                                      Expanded(child: Text(data['title'] ?? 'Unnamed Deal', style: const TextStyle(fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis)),
                                      if (badge.isNotEmpty) ...[
                                        const SizedBox(width: 8),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                          decoration: BoxDecoration(color: Colors.red, borderRadius: BorderRadius.circular(4)),
                                          child: Text(badge, style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                                        )
                                      ]
                                    ]
                                  ),
                                  subtitle: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      if (startTime != null) Text('Starts: ${DateFormat('MMM d, yyyy - h:mm a').format(startTime)}', style: const TextStyle(fontSize: 12, color: Colors.orange)),
                                      Text('Expires: ${DateFormat('MMM d, yyyy - h:mm a').format(endTime)}', style: const TextStyle(fontSize: 12)),
                                    ],
                                  ),
                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: statusColor.withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: Text(
                                          statusText,
                                          style: TextStyle(color: statusColor, fontSize: 12, fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      IconButton(
                                        icon: const Icon(Icons.edit, color: Colors.blue),
                                        tooltip: 'Edit Deal',
                                        onPressed: () => _startEditing(docs[index].id, data),
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.delete, color: Colors.red),
                                        tooltip: 'Delete Deal',
                                        onPressed: () => _confirmDelete(docs[index].id, data['title'] ?? 'Unnamed Deal'),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
