const fs = require('fs');
let code = fs.readFileSync('lib/screens/admin_profile_screen.dart', 'utf8');

// Replace the return Container child from Column to SingleChildScrollView > Column
code = code.replace(
  'child: Column(',
  'child: SingleChildScrollView(\n        child: Column('
);

// We also need to close the SingleChildScrollView at the end.
// Look for the last '      ),'
code = code.replace(
  /      \),\n    \);\n  \}\n\}/,
  '        ],\n      ),\n      ),\n    );\n  }\n}'
);

// Replace const Spacer() with SizedBox
code = code.replace(
  'const Spacer(),',
  'const SizedBox(height: 64),'
);

// Wait, the Column closing ']' might be messy if we just replace the end. Let's do a more precise replacement for the end.
fs.writeFileSync('patch.js', code);
