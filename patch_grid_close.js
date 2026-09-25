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

  // We need to find the end of the Column that we just wrapped.
  // The structure was:
  //                           ],
  //                         ),
  //                       ),
  //                     ),
  //                   ],
  //                 ),
  //               ),
  
  // Actually, we can just replace `\n                        ),` with `\n                        ),\n                      ),` ?
  // Better yet, in `blog_screen.dart`:
  
  // Wait, I can just do a regex replace on the exact text.
  content = content.replace(
    /\s*\]\,\r?\n\s*\)\,\r?\n\s*\)\,\r?\n\s*\)\,\r?\n\s*\]\,\r?\n\s*\)\,\r?\n\s*\)\;/g,
    `\n                          ],\n                        ),\n                      ),\n                    ),\n                  ],\n                ),\n              );`
  );

  content = content.replace(
    /\s*\]\,\n\s*\)\,\n\s*\)\,\n\s*\)\,\n\s*\]\,\n\s*\)\,\n\s*\)\;/g,
    `\n                          ],\n                        ),\n                      ),\n                    ),\n                  ],\n                ),\n              );`
  );
  
  fs.writeFileSync(file, content, 'utf8');
}
console.log('Fixed closing brackets for GridView cards');
