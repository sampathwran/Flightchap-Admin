const fs = require('fs');
let content = fs.readFileSync('lib/screens/popular_destinations_screen.dart', 'utf8');
content = content.replace(/'target_website': SiteState\.activeSite\.value,\s*/g, '');
content = content.replace(/\.where\('target_website', isEqualTo: SiteState\.activeSite\.value\)/g, '');
fs.writeFileSync('lib/screens/popular_destinations_screen.dart', content, 'utf8');
console.log('Fixed destinations admin panel!');
