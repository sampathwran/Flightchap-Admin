const fs = require('fs');
let file = 'lib/screens/dashboard_screen.dart';
let content = fs.readFileSync(file, 'utf8');

content = content.replace(/width: 320,/g, 'width: 220,');

fs.writeFileSync(file, content, 'utf8');
console.log('Made stat cards smaller');
