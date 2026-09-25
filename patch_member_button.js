const fs = require('fs');
const file = 'lib/screens/member_deals_screen.dart';
let content = fs.readFileSync(file, 'utf8');

// The end of the end-time picker looks like this:
//                             ),
//                           ),
//                         ),
//                       ),
//                       
//                     ],
//                   ),

const targetString = `                            ),
                          ),
                        ),
                      ),
                      
                    ],
                  ),`;

const replacementString = `                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      
                      ElevatedButton(
                        onPressed: _isSubmitting ? null : _submitDeal,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _editingDealId != null ? Colors.orange : const Color(0xFF007bff),
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        ),
                        child: _isSubmitting 
                          ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                          : Text(_editingDealId != null ? 'Update Deal' : 'Add Deal', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),`;

content = content.replace(/\r\n/g, '\n');
content = content.replace(targetString, replacementString);
content = content.replace(/\n/g, '\r\n');

fs.writeFileSync(file, content, 'utf8');
console.log('Added submit button to member_deals_screen.dart');
