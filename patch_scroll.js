const fs = require('fs');
const files = [
  'lib/screens/flash_deals_screen.dart',
  'lib/screens/member_deals_screen.dart',
  'lib/screens/special_offers_screen.dart',
  'lib/screens/promo_codes_screen.dart'
];

for (const file of files) {
  if (!fs.existsSync(file)) continue;
  let content = fs.readFileSync(file, 'utf8');

  // We want to wrap the top-level Column in SingleChildScrollView.
  // We'll use regex to make it robust.
  
  if (content.includes('return Container(\n      padding: const EdgeInsets.all(24),\n      color: const Color(0xFFf0f1f7),\n      child: Column(')) {
    content = content.replace(
      'return Container(\n      padding: const EdgeInsets.all(24),\n      color: const Color(0xFFf0f1f7),\n      child: Column(',
      'return Container(\n      color: const Color(0xFFf0f1f7),\n      child: SingleChildScrollView(\n        padding: const EdgeInsets.all(24),\n        child: Column('
    );
  } else if (content.includes('return Container(\n      padding: EdgeInsets.all(24),\n      color: Color(0xFFf0f1f7),\n      child: Column(')) {
    content = content.replace(
      'return Container(\n      padding: EdgeInsets.all(24),\n      color: Color(0xFFf0f1f7),\n      child: Column(',
      'return Container(\n      color: const Color(0xFFf0f1f7),\n      child: SingleChildScrollView(\n        padding: const EdgeInsets.all(24),\n        child: Column('
    );
  }

  // Remove `Expanded(` around `Container` in the List section
  content = content.replace(
    /\/\/\s*List Section\s*Expanded\(\s*child:\s*Container\(/,
    '// List Section\n          Container('
  );
  
  // Remove `Expanded(` around `StreamBuilder`
  content = content.replace(
    /Expanded\(\s*child:\s*StreamBuilder<QuerySnapshot>\(/,
    'StreamBuilder<QuerySnapshot>('
  );

  // Since we removed two `Expanded` wrappers, we need to remove two closing `),` at the end of the file.
  // The structure is usually:
  //               ),
  //             ),
  //           ),
  //         ],
  //       ),
  //     );
  //   }
  // }
  
  // Let's just fix the closing brackets using regex
  // It looks like:
  //                       },
  //                     ),
  //                   ),
  //                 ],
  //               ),
  //             ),
  //           ),
  //         ],
  //       ),
  //     );
  
  content = content.replace(
    /                      \},\n                    \),\n                  \),\n                \],\n              \),\n            \),\n          \),\n        \],\n      \),\n    \);/,
    `                      },\n                    ),\n                ],\n              ),\n            ),\n        ],\n        ),\n      ),\n    );`
  );
  
  // Also account for slight variations:
  content = content.replace(
    /                      \},\n                    \),\n                  \),\n                \],\n              \),\n            \),\n          \),\n        \],\n      \),\n    \);/g,
    `                      },\n                    ),\n                ],\n              ),\n            ),\n        ],\n        ),\n      ),\n    );`
  );

  fs.writeFileSync(file, content, 'utf8');
}
console.log('Fixed scrolling layouts');
