const fs = require('fs');

function fix(file) {
  let content = fs.readFileSync(file, 'utf8');

  // Look for the Add Deal button
  const buttonRegex = /ElevatedButton\(\s*onPressed: _isSubmitting \? null : _submitDeal,[\s\S]*?Text\(_editingDealId != null \? 'Update Deal' : 'Add Deal', style: const TextStyle\(color: Colors\.white, fontWeight: FontWeight\.bold\)\),\s*\),/g;
  
  const match = content.match(buttonRegex);
  if (match) {
    const buttonCode = match[0];
    // Remove the button and its preceding SizedBox from the Row
    content = content.replace(/const SizedBox\(width: 16\),\s*ElevatedButton\(\s*onPressed: _isSubmitting \? null : _submitDeal,[\s\S]*?Text\(_editingDealId != null \? 'Update Deal' : 'Add Deal', style: const TextStyle\(color: Colors\.white, fontWeight: FontWeight\.bold\)\),\s*\),/g, '');
    
    // Now insert it AFTER the Row closes!
    // The Row ends right before `], \n ), \n ), \n const SizedBox(height: 24), \n // List Section`
    const insertAnchor = `                      ],\n                    ),\n                  ],\n                ),\n              ),\n            ),\n            \n            const SizedBox(height: 24),\n            \n            // List Section`;
    
    // Let's just find `// List Section` and insert it a bit above that, inside the Form Column!
    // The Form Column ends with:
    /*
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
    */
    const formAnchor = `                      ],\n                    ),\n                  ],\n                ),\n              ),`;
    
    const replacement = `                      ],\n                    ),\n                    const SizedBox(height: 16),\n                    Align(\n                      alignment: Alignment.centerRight,\n                      child: ${buttonCode}\n                    ),\n                  ],\n                ),\n              ),`;
    
    content = content.replace(formAnchor, replacement);
    fs.writeFileSync(file, content, 'utf8');
    console.log("Success on " + file);
  } else {
    console.log("Could not find button code in " + file);
  }
}

fix('lib/screens/member_deals_screen.dart');
fix('lib/screens/promo_codes_screen.dart');
