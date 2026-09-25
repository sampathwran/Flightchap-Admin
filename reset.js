const fs = require('fs');
const files = [
  'lib/screens/blog_screen.dart',
  'lib/screens/popular_vehicles_screen.dart',
  'lib/screens/transfer_vehicles_screen.dart',
  'lib/screens/popular_destinations_screen.dart'
];

for (const file of files) {
  if (!fs.existsSync(file)) continue;
  let content = fs.readFileSync(file, 'utf8');

  // We are missing one `),\n` in the nested structure
  // Replace exactly:
  //                           ],
  //                         ),
  //                       ),
  //                     ),
  //                   ],
  
  content = content.replace(
    /\n\s*\]\,\r?\n\s*\)\,\r?\n\s*\)\,\r?\n\s*\)\,\r?\n\s*\]\,/g,
    `\n                          ],\n                        ),\n                      ),\n                    ),\n                  ],\n`
  );
  
  // Wait, right now it is:
  //                           ],
  //                         ),
  //                       ),
  //                     ),
  //                   ],
  // Wait, no, earlier I replaced:
  // `\n                          ],\n                        ),\n                      ),\n                    ),\n                  ],\n                ),\n              );`
  
  // Let's just fix it by resetting to the commit BEFORE I broke it, and doing it properly.
  
