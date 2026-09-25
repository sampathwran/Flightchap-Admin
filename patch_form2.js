const fs = require('fs');
let content = fs.readFileSync('lib/screens/promo_codes_screen.dart', 'utf8');

const startIndex = content.indexOf('// Form Section');
const endIndex = content.indexOf('// List Section');

if (startIndex !== -1 && endIndex !== -1) {
  const newMap = `// Form Section
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
                          decoration: const InputDecoration(labelText: 'Provider / Brand Name', border: OutlineInputBorder()),
                          validator: (v) => v!.isEmpty ? 'Required' : null,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        flex: 2,
                        child: TextFormField(
                          controller: _codeController,
                          decoration: const InputDecoration(labelText: 'Promo Code (e.g. VIP50)', border: OutlineInputBorder()),
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
                  TextFormField(
                    controller: _descriptionController,
                    decoration: const InputDecoration(labelText: 'Description of the offer', border: OutlineInputBorder()),
                    maxLines: 2,
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
                                  Expanded(child: Text('Image Selected: \\${_selectedImageName}', style: const TextStyle(fontWeight: FontWeight.bold))),
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
                    ],
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      ElevatedButton.icon(
                        onPressed: _isSubmitting ? null : _submitDeal,
                        icon: _isSubmitting 
                          ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                          : const Icon(Icons.save),
                        label: Text(_isSubmitting ? 'Saving...' : (_editingDealId != null ? 'Update Deal' : 'Save Deal'), style: const TextStyle(color: Colors.white)),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                          backgroundColor: const Color(0xFF673AB7),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 24),
          
          `;
  
  content = content.substring(0, startIndex) + newMap + content.substring(endIndex);
  fs.writeFileSync('lib/screens/promo_codes_screen.dart', content, 'utf8');
  console.log('Fixed completely');
} else {
  console.log('Not found');
}
