const fs = require('fs');

function fixLayout(file) {
  let content = fs.readFileSync(file, 'utf8');

  // We have a Row containing Image URL, Upload, Start Time, End Time, Add Deal.
  // I will just use regex to move the Add Deal button out of the Row and into a new Row below it.
  
  // Find the Add Deal button part
  const buttonRegex = /const SizedBox\(width: 16\),\s*ElevatedButton\(\s*onPressed: _isSubmitting \? null : _submitDeal,[\s\S]*?Text\(_editingDealId != null \? 'Update Deal' : 'Add Deal', style: const TextStyle\(color: Colors\.white, fontWeight: FontWeight\.bold\)\),\s*\),/g;
  
  const match = content.match(buttonRegex);
  if (match) {
    const buttonCode = match[0].replace('const SizedBox(width: 16),', '').trim();
    // Remove the button from its current location
    content = content.replace(buttonRegex, '');
    
    // Add it after the Row ends.
    // The Row ends with `],),` and then `],),` (Wait, let's just find the end of that Row)
    // The Row has `Expanded(flex: 1, child: InkWell( onTap: () => _selectDateTime(context, false), ...`
    
    // Let's do a simpler replacement using a known anchor.
    const anchor = `],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],`;
                  
    const replacement = `],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Align(
                      alignment: Alignment.centerRight,
                      child: ${buttonCode}
                    ),
                  ],`;
                  
    content = content.replace(anchor, replacement);
    fs.writeFileSync(file, content, 'utf8');
  }
}

fixLayout('lib/screens/member_deals_screen.dart');
fixLayout('lib/screens/promo_codes_screen.dart');
console.log("Fixed layout");
