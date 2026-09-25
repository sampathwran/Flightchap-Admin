const fs = require('fs');
const files = [
  'lib/screens/blog_screen.dart',
  'lib/screens/popular_vehicles_screen.dart',
  'lib/screens/transfer_vehicles_screen.dart'
];

for (const file of files) {
  let content = fs.readFileSync(file, 'utf8');
  
  // Since the file has Windows CRLF, let's normalize
  content = content.replace(/\r\n/g, '\n');
  
  content = content.replace(
    /                          \],\n                        \),\n                      \),\n                    \),\n                  \],\n                \),\n              \);/g,
    '                          ],\n                        ),\n                      ),\n                    ),\n                  ],\n                ),\n              );'
  );
  
  // Wait, right now it is:
  //                           ],
  //                         ),
  //                       ),
  //                     ),
  //                   ],
  //                 ),
  //               );
  
  content = content.replace(
    /\n                          \],\n                        \),\n                      \),\n                    \),\n                  \],\n                \),\n              \);/g,
    '\n                          ],\n                        ),\n                      ),\n                      ),\n                    ),\n                  ],\n                ),\n              );'
  );
  
  // Actually, wait, my patch output in `git diff` shows the end of the block wasn't even touched!
  // I will just use regex to add the extra `),` after the column.
  content = content.replace(
    /                          \],\n                        \),\n                      \),\n                    \),/g,
    '                          ],\n                        ),\n                      ),\n                      ),\n                    ),'
  );

  content = content.replace(/\n/g, '\r\n');
  fs.writeFileSync(file, content, 'utf8');
}
console.log('Added missing bracket for SingleChildScrollView');
