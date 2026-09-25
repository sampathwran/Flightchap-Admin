const fs = require('fs');
let sidebarPath = 'lib/widgets/sidebar.dart';
let lines = fs.readFileSync(sidebarPath, 'utf8').split('\n');

// We want to delete lines from 72 to 85 (0-indexed 71 to 84).
// Wait, the lines output from `Select-Object` might be slightly different.
// Let's just remove the block:
//                StreamBuilder<AggregateQuerySnapshot>(
// ...
//                ),
//                
//                const SizedBox(height: 12),

let content = fs.readFileSync(sidebarPath, 'utf8');

const regex = /\s*StreamBuilder<AggregateQuerySnapshot>\([\s\S]*?return _buildMenuItem\(6, Icons\.people_outline, 'Customers', badge: badgeText\);\r?\n\s*\},\r?\n\s*\),\r?\n\s*const SizedBox\(height: 12\),/g;

content = content.replace(regex, '');

fs.writeFileSync(sidebarPath, content, 'utf8');
console.log('Removed StreamBuilder block for Customers');
