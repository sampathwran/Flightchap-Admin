const fs = require('fs');
let sidebarPath = 'lib/widgets/sidebar.dart';
let sidebarContent = fs.readFileSync(sidebarPath, 'utf8');

sidebarContent = sidebarContent.replace(/_buildMenuCategory\('BOOKINGS'\),/g, '');
sidebarContent = sidebarContent.replace(/\/\/ Customers menu item with live badge count/g, '');

const startStr = 'StreamBuilder<AggregateQuerySnapshot>(';
const endStr = 'return _buildMenuItem(6, Icons.people_outline, \'Customers\', badge: badgeText);\n                    },\n                  ),';
const endStr2 = 'return _buildMenuItem(6, Icons.people_outline, \'Customers\', badge: badgeText);\r\n                    },\r\n                  ),';

let startIndex = sidebarContent.indexOf(startStr);
let endIndex = sidebarContent.indexOf(endStr);
if (endIndex === -1) endIndex = sidebarContent.indexOf(endStr2);

if (startIndex !== -1 && endIndex !== -1) {
  let blockLength = (endIndex !== -1 && sidebarContent.indexOf(endStr) !== -1) ? endStr.length : endStr2.length;
  sidebarContent = sidebarContent.substring(0, startIndex) + sidebarContent.substring(endIndex + blockLength);
}

fs.writeFileSync(sidebarPath, sidebarContent, 'utf8');
console.log('Removed successfully via substring');
