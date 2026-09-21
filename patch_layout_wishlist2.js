const fs = require('fs');
let code = fs.readFileSync('lib/screens/main_layout.dart', 'utf8');

// Use regex to remove import and route properly
code = code.replace(/import 'wishlist_screen\.dart';\r?\n/, '');
code = code.replace(/    4: '\/wishlist',\r?\n/, '');
code = code.replace(/    } else if \(_selectedIndex == 4\) \{\r?\n      return const WishlistScreen\(\);\r?\n/, '');

fs.writeFileSync('lib/screens/main_layout.dart', code);
