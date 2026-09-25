const fs = require('fs');

// 1. Remove from sidebar.dart
let sidebarPath = 'lib/widgets/sidebar.dart';
let sidebarContent = fs.readFileSync(sidebarPath, 'utf8');

sidebarContent = sidebarContent.replace(
  /                  const SizedBox\(height: 12\),\r?\n                  _buildMenuCategory\('BOOKINGS'\),\r?\n                  \r?\n                  \/\/ Customers menu item with live badge count\r?\n                  StreamBuilder<AggregateQuerySnapshot>\([\s\S]*?return _buildMenuItem\(6, Icons\.people_outline, 'Customers', badge: badgeText\);\r?\n                    \},\r?\n                  \),\r?\n                  \r?\n                  const SizedBox\(height: 12\),\r?\n/g,
  ''
);

fs.writeFileSync(sidebarPath, sidebarContent, 'utf8');

// 2. Remove from main_layout.dart
let layoutPath = 'lib/screens/main_layout.dart';
let layoutContent = fs.readFileSync(layoutPath, 'utf8');

layoutContent = layoutContent.replace(/import 'customers_screen\.dart';\r?\n/g, '');
layoutContent = layoutContent.replace(/\s*6:\s*'\/customers',\r?\n/g, '\n');
layoutContent = layoutContent.replace(/\s*\} else if \(_selectedIndex == 6\) \{\r?\n\s*return const CustomersScreen\(\);\r?\n/g, '\n');

fs.writeFileSync(layoutPath, layoutContent, 'utf8');
console.log('Removed BOOKINGS and Customers menu from admin panel');
