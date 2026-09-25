const fs = require('fs');
let sidebarPath = 'lib/widgets/sidebar.dart';
let sidebarContent = fs.readFileSync(sidebarPath, 'utf8');

// Replace the line that builds the SYSTEM category
sidebarContent = sidebarContent.replace(/_buildMenuCategory\('SYSTEM'\),\r?\n/g, '');

fs.writeFileSync(sidebarPath, sidebarContent, 'utf8');
console.log('Removed SYSTEM category text');
