const fs = require('fs');

// 1. Update sidebar.dart
let sidebarPath = 'lib/widgets/sidebar.dart';
let sidebarContent = fs.readFileSync(sidebarPath, 'utf8');

sidebarContent = sidebarContent.replace(/_buildMenuItem\(12,\s*Icons\.local_offer_outlined,\s*'Special Offers'\),\r?\n\s*/g, '');

fs.writeFileSync(sidebarPath, sidebarContent, 'utf8');

// 2. Update main_layout.dart
let layoutPath = 'lib/screens/main_layout.dart';
let layoutContent = fs.readFileSync(layoutPath, 'utf8');

layoutContent = layoutContent.replace(/import 'special_offers_screen\.dart';\r?\n/g, '');
layoutContent = layoutContent.replace(/\s*12:\s*'\/special-offers',\r?\n/g, '\n');
layoutContent = layoutContent.replace(/\s*\} else if \(_selectedIndex == 12\) \{\r?\n\s*return const SpecialOffersScreen\(\);\r?\n/g, '\n');

fs.writeFileSync(layoutPath, layoutContent, 'utf8');
console.log('Removed special offers from admin panel');
