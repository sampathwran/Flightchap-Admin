const fs = require('fs');
let layoutPath = 'lib/screens/main_layout.dart';
let layoutContent = fs.readFileSync(layoutPath, 'utf8');

layoutContent = layoutContent.replace(/import 'popular_vehicles_screen\.dart';\r?\n/g, '');
layoutContent = layoutContent.replace(/import 'transfer_vehicles_screen\.dart';\r?\n/g, '');

fs.writeFileSync(layoutPath, layoutContent, 'utf8');
console.log('Removed unused imports');
