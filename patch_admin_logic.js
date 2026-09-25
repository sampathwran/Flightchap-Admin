const fs = require('fs');
let content = fs.readFileSync('lib/screens/promo_codes_screen.dart', 'utf8');

content = content.replace("final _titleController = TextEditingController();", "final _titleController = TextEditingController();\n  final _descriptionController = TextEditingController();");

content = content.replace("_titleController.text = data['title'] ?? '';", "_titleController.text = data['provider'] ?? '';\n      _descriptionController.text = data['description'] ?? '';");
content = content.replace("_codeController.text = data['targetUrl'] ?? '';", "_codeController.text = data['code'] ?? '';");

content = content.replace("_titleController.clear();\n      _imageUrlController.clear();", "_titleController.clear();\n      _descriptionController.clear();\n      _imageUrlController.clear();");

content = content.replace("'provider': _titleController.text, 'color': 'bg-blue-50 text-blue-600'.trim(),", "'provider': _titleController.text, 'color': 'bg-blue-50 text-blue-600'.trim(),\n          'description': _descriptionController.text,");

// Update the UI labels
content = content.replace("labelText: 'Title / Hotel Name'", "labelText: 'Provider / Brand Name'");
content = content.replace("labelText: 'Target URL (Link to open)'", "labelText: 'Promo Code (e.g. VIP50)'");

// Add description text field in UI
content = content.replace("flex: 2,\n                          child: TextFormField(\n                            controller: _codeController,", "flex: 2,\n                          child: TextFormField(\n                            controller: _codeController,\n                            decoration: const InputDecoration(labelText: 'Promo Code (e.g. VIP50)', border: OutlineInputBorder()),\n                            validator: (v) => v!.isEmpty ? 'Required' : null,\n                          ),\n                        ),\n                        const SizedBox(width: 16),\n                        Expanded(\n                          flex: 3,\n                          child: TextFormField(\n                            controller: _descriptionController,");

// Make sure we didn't duplicate the code controller definition
fs.writeFileSync('lib/screens/promo_codes_screen.dart', content, 'utf8');
console.log('Fixed logic');
