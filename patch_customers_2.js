const fs = require('fs');
let sidebarPath = 'lib/widgets/sidebar.dart';
let sidebarContent = fs.readFileSync(sidebarPath, 'utf8');

// Use string replacement for the chunks
sidebarContent = sidebarContent.replace(/_buildMenuCategory\('BOOKINGS'\),\r?\n/g, '');
sidebarContent = sidebarContent.replace(/\/\/ Customers menu item with live badge count/g, '');

sidebarContent = sidebarContent.replace(
  /                  StreamBuilder<AggregateQuerySnapshot>\([\s\S]*?return _buildMenuItem\(6, Icons\.people_outline, 'Customers', badge: badgeText\);\r?\n                    \},\r?\n                  \),/g,
  ''
);

fs.writeFileSync(sidebarPath, sidebarContent, 'utf8');
console.log('Removed BOOKINGS and Customers menu from admin panel (second try)');
