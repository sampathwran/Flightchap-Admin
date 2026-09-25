const fs = require('fs');
const file = 'lib/screens/flash_deals_screen.dart';
let content = fs.readFileSync(file, 'utf8');

// The bottom has an extra bracket due to the layout changes!
content = content.replace(
  /                      \},\r?\n                    \),\r?\n                  \),\r?\n                \],\r?\n              \),\r?\n            \),\r?\n          \),\r?\n        \],\r?\n      \),\r?\n    \);\r?\n  \}\r?\n\}/,
  `                      },\n                    ),\n                ],\n              ),\n            ),\n        ],\n        ),\n      ),\n    );\n  }\n}`
);

fs.writeFileSync(file, content, 'utf8');
console.log('Fixed flash deals brackets');
