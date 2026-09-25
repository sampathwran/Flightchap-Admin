const fs = require('fs');
const files = [
  'lib/screens/member_deals_screen.dart',
  'lib/screens/special_offers_screen.dart',
  'lib/screens/promo_codes_screen.dart'
];

for (const file of files) {
  let content = fs.readFileSync(file, 'utf8');
  
  // We need to fix the end of the file.
  // There is one extra `),`
  
  content = content.replace(
    /                      \},\r?\n                    \),\r?\n                  \),\r?\n                \],\r?\n              \),\r?\n            \),\r?\n          \),\r?\n        \],\r?\n      \),\r?\n    \);\r?\n  \}\r?\n\}/,
    `                      },\n                    ),\n                ],\n              ),\n            ),\n        ],\n        ),\n      ),\n    );\n  }\n}`
  );
  
  fs.writeFileSync(file, content, 'utf8');
}
console.log('Fixed closing brackets');
