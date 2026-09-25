const fs = require('fs');
let sidebarPath = 'lib/widgets/sidebar.dart';
let sidebarContent = fs.readFileSync(sidebarPath, 'utf8');

sidebarContent = sidebarContent.replace(/import 'package:cloud_firestore\/cloud_firestore\.dart';\r?\n/g, '');

fs.writeFileSync(sidebarPath, sidebarContent, 'utf8');
console.log('Removed unused import');
