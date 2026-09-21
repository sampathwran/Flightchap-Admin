const fs = require('fs');
const content = fs.readFileSync('lib/screens/flash_deals_screen.dart', 'utf8');

const buildStart = content.indexOf('@override\n  Widget build(BuildContext context) {');
if (buildStart === -1) throw new Error("Could not find build method");

const newBuild = `@override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String>(
      valueListenable: SiteState.activeSite,
      builder: (context, activeSite, _) {
        bool isFlightChap = activeSite == 'flightchap';
        return Container(
          color: const Color(0xFFf0f1f7),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
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
                        
                        if (isFlightChap) ...[
                          Row(
                            children: [
                              Expanded(
                                flex: 1,
                                child: DropdownButtonFormField<String>(
                                  value: _selectedCategory,
                                  decoration: const InputDecoration(labelText: 'Category', border: OutlineInputBorder()),
                                  items: ['Flights', 'Transfers', 'Cars', 'e-SIMs']
                                      .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                                      .toList(),
                                  onChanged: (val) => setState(() => _selectedCategory = val!),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                flex: 2,
                                child: TextFormField(
                                  controller: _titleController,
                                  decoration: const InputDecoration(labelText: 'Deal Title (e.g. Dubai Getaway)', border: OutlineInputBorder()),
                                  validator: (val) => val == null || val.trim().isEmpty ? 'Required' : null,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                flex: 1,
                                child: TextFormField(
                                  controller: _discountController,
                                  decoration: const InputDecoration(labelText: 'Discount Badge (Optional)', hintText: '-20%', border: OutlineInputBorder()),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: TextFormField(
                                  controller: _fromController,
                                  decoration: const InputDecoration(labelText: 'From (Origin)', border: OutlineInputBorder()),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: TextFormField(
                                  controller: _toController,
                                  decoration: const InputDecoration(labelText: 'To (Destination)', border: OutlineInputBorder()),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: TextFormField(
                                  controller: _priceController,
                                  decoration: const InputDecoration(labelText: 'New Price (e.g. $199)', border: OutlineInputBorder()),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: TextFormField(
                                  controller: _originalPriceController,
                                  decoration: const InputDecoration(labelText: 'Original Price (e.g. $249)', border: OutlineInputBorder()),
                                ),
                              ),
                            ],
                          ),
                        ] else ...[
                          Row(
                            children: [
                              Expanded(
                                flex: 2,
                                child: TextFormField(
                                  controller: _titleController,
                                  decoration: const InputDecoration(labelText: 'Deal Title (e.g. 50% Off Luxury Suites)', border: OutlineInputBorder()),
                                  validator: (val) => val == null || val.trim().isEmpty ? 'Required' : null,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                flex: 2,
                                child: TextFormField(
                                  controller: _targetUrlController,
                                  decoration: const InputDecoration(labelText: 'Target URL', border: OutlineInputBorder()),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                flex: 1,
                                child: TextFormField(
                                  controller: _discountController,
                                  decoration: const InputDecoration(labelText: 'Discount Badge (Optional)', hintText: '-50%', border: OutlineInputBorder()),
                                ),
                              ),
                            ],
                          ),
                        ],
                        
                        const SizedBox(height: 16),
                        
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Expanded(
                              flex: 2,
                              child: _selectedImageBytes != null 
                                ? Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(border: Border.all(color: Colors.green), borderRadius: BorderRadius.circular(8), color: Colors.green.shade50),
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
                                : OutlinedButton.icon(
                                    onPressed: _pickImage,
                                    icon: const Icon(Icons.image),
                                    label: const Text('Upload Deal Image (Required)'),
                                    style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
                                  ),
                            ),
                            
                            const SizedBox(width: 16),
                            
                            // START TIME PICKER
                            Expanded(
                              flex: 1,
                              child: InkWell(
                                onTap: () => _selectDateTime(context, true),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                                  decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade400), borderRadius: BorderRadius.circular(4)),
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
                              )
                            ),
                            
                            const SizedBox(width: 8),
                            
                            // END TIME PICKER
                            Expanded(
                              flex: 1,
                              child: InkWell(
                                onTap: () => _selectDateTime(context, false),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                                  decoration: BoxDecoration(
                                    border: Border.all(color: _selectedEndTime == null ? Colors.red : Colors.grey.shade400, width: _selectedEndTime == null ? 2 : 1), 
                                    borderRadius: BorderRadius.circular(4)
                                  ),
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
                              )
                            ),
                          ],
                        ),
                        
                        const SizedBox(height: 24),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _isUploading ? null : _saveDeal,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _editingDealId != null ? Colors.orange : const Color(0xFF673AB7),
                              padding: const EdgeInsets.symmetric(vertical: 16),
                            ),
                            child: _isUploading 
                              ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                              : Text(_editingDealId != null ? 'Update Flash Deal' : 'Save Flash Deal', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                          ),
                        )
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // List Section (Scrolls with the rest of the page)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Flash Deals History', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 16),
                      StreamBuilder<QuerySnapshot>(
                        stream: FirebaseFirestore.instance.collection('flash_deals').snapshots(),
                        builder: (context, snapshot) {
                          if (snapshot.hasError) return const Center(child: Text('Error loading deals'));
                          if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
                          
                          final allDocs = snapshot.data?.docs ?? [];
                          
                          final docs = allDocs.where((doc) {
                            final data = doc.data() as Map<String, dynamic>;
                            final target = data.containsKey('target_website') ? data['target_website'] : null;
                            if (activeSite == 'hotelchap') {
                              return target == 'hotelchap' || target == null || target == '';
                            } else {
                              return target == activeSite || target == null || target == '';
                            }
                          }).toList();
                          
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
                                        if (isFlightChap && data['category'] != null) ...[
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                            decoration: BoxDecoration(color: Colors.blue.shade100, borderRadius: BorderRadius.circular(4)),
                                            child: Text(data['category'], style: TextStyle(color: Colors.blue.shade800, fontSize: 10, fontWeight: FontWeight.bold)),
                                          ),
                                          const SizedBox(width: 8),
                                        ],
                                        if (badge.isNotEmpty) ...[
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
                                        if (isFlightChap) ...[
                                          Text('\${data['from'] ?? ''} to \${data['to'] ?? ''} - \${data['price'] ?? ''}', style: const TextStyle(fontSize: 12, color: Colors.blueGrey)),
                                        ],
                                        if (startTime != null) Text('Starts: \${DateFormat('MMM d, yyyy - h:mm a').format(startTime)}', style: const TextStyle(fontSize: 12, color: Colors.orange)),
                                        Text('Expires: \${DateFormat('MMM d, yyyy - h:mm a').format(endTime)}', style: const TextStyle(fontSize: 12)),
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
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      }
    );
  }
}
`;

fs.writeFileSync('lib/screens/flash_deals_screen.dart', content.substring(0, buildStart) + newBuild);
console.log('Successfully rewrote flash_deals_screen.dart');
