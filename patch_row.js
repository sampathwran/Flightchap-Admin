const fs = require('fs');
let content = fs.readFileSync('lib/screens/promo_codes_screen.dart', 'utf8');

const oldFormLayout = `                  Row(
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
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: _descriptionController,
                    decoration: const InputDecoration(labelText: 'Description of the offer', border: OutlineInputBorder()),
                    maxLines: 1,
                  ),`;

const newFormLayout = `                  Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: TextFormField(
                          controller: _titleController,
                          decoration: const InputDecoration(labelText: 'Provider / Brand Name', border: OutlineInputBorder(), isDense: true, contentPadding: EdgeInsets.all(12)),
                          validator: (v) => v!.isEmpty ? 'Required' : null,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        flex: 2,
                        child: TextFormField(
                          controller: _descriptionController,
                          decoration: const InputDecoration(labelText: 'Description of the offer', border: OutlineInputBorder(), isDense: true, contentPadding: EdgeInsets.all(12)),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        flex: 2,
                        child: TextFormField(
                          controller: _codeController,
                          decoration: const InputDecoration(labelText: 'Promo Code (e.g. VIP50)', border: OutlineInputBorder(), isDense: true, contentPadding: EdgeInsets.all(12)),
                          validator: (v) => v!.isEmpty ? 'Required' : null,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        flex: 1,
                        child: TextFormField(
                          controller: _discountController,
                          decoration: const InputDecoration(labelText: 'Discount', border: OutlineInputBorder(), isDense: true, contentPadding: EdgeInsets.all(12)),
                        ),
                      ),
                    ],
                  ),`;

content = content.replace(oldFormLayout, newFormLayout);
fs.writeFileSync('lib/screens/promo_codes_screen.dart', content, 'utf8');
console.log('Fixed row layout');
