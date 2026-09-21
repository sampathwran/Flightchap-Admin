const fs = require('fs');
let code = fs.readFileSync('lib/widgets/sidebar.dart', 'utf8');

// 1. Remove Wishlists & Saved block
code = code.replace(
  /\s*\/\/\s*Wishlists menu item with live badge count[\s\S]*?return _buildMenuItem\(4, Icons\.favorite_border, 'Wishlists & Saved', badge: badgeText\);\n\s*},\n\s*\),/,
  ''
);

// 2. Remove All Bookings
code = code.replace(
  /\s*_buildMenuItem\(5, Icons\.book_online_outlined, 'All Bookings'\),/,
  ''
);

// 3. Remove Settings
code = code.replace(
  /\s*_buildMenuItem\(7, Icons\.settings_outlined, 'Settings'\),/,
  ''
);

fs.writeFileSync('lib/widgets/sidebar.dart', code);
console.log('Removed menu items from sidebar.dart');
