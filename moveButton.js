const fs = require('fs');

function extractButton(file) {
  let content = fs.readFileSync(file, 'utf8');

  // We want to pull the ElevatedButton OUT of the Row and put it BELOW the Row.
  const buttonRegex = /const SizedBox\(width: 16\),\s*ElevatedButton\([\s\S]*?Text\(_editingDealId != null \? 'Update Deal' : 'Add Deal', style: const TextStyle\(color: Colors\.white, fontWeight: FontWeight\.bold\)\),\s*\),/g;
  
  const match = content.match(buttonRegex);
  if (match) {
    const buttonCode = match[0].replace('const SizedBox(width: 16),', '').trim();
    
    // Remove it from the Row
    content = content.replace(buttonRegex, '');
    
    // Find the end of the Row
    // The Row ends with:
    /*
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
    */
    const anchor = `                              ),
                            ),
                          ),
                        ),
                      ],
                    ),`;
                    
    const replacement = `                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Align(
                      alignment: Alignment.centerRight,
                      child: ${buttonCode}
                    ),`;
                    
    content = content.replace(anchor, replacement);
    fs.writeFileSync(file, content, 'utf8');
    console.log("Fixed " + file);
  } else {
    console.log("Could not find button in " + file);
  }
}

extractButton('lib/screens/member_deals_screen.dart');
extractButton('lib/screens/promo_codes_screen.dart');
