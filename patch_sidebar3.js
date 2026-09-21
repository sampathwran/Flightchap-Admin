const fs = require('fs');
let code = fs.readFileSync('lib/widgets/sidebar.dart', 'utf8');

// Replace using regex so line endings are ignored
const regex = /\s*\/\/\s*Wishlists menu item with live badge count[\s\S]*?return _buildMenuItem\(4, Icons\.favorite_border, 'Wishlists & Saved', badge: badgeText\);\s*},\s*\),/g;

code = code.replace(regex, '');

fs.writeFileSync('lib/widgets/sidebar.dart', code);
console.log('Removed wishlists from sidebar.dart');
