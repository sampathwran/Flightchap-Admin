const fs = require('fs');
let code = fs.readFileSync('lib/screens/main_layout.dart', 'utf8');

// Remove wishlist import
code = code.replace("import 'wishlist_screen.dart';\n", "");

// Remove from routes
code = code.replace("    4: '/wishlist',\n", "");

// Remove from _buildBody()
code = code.replace("    } else if (_selectedIndex == 4) {\n      return const WishlistScreen();\n", "");

fs.writeFileSync('lib/screens/main_layout.dart', code);
console.log('Removed wishlist from main_layout.dart');
