const fs = require('fs');
const files = [
  'lib/screens/flash_deals_screen.dart',
  'lib/screens/member_deals_screen.dart',
  'lib/screens/special_offers_screen.dart',
  'lib/screens/promo_codes_screen.dart'
];

for (const file of files) {
  let content = fs.readFileSync(file, 'utf8');
  
  // Convert CRLF to LF for reliable regex matching
  content = content.replace(/\r\n/g, '\n');
  
  // Wrap top-level column
  content = content.replace(
    /return Container\(\s*padding: const EdgeInsets\.all\(24\),\s*color: const Color\(0xFFf0f1f7\),\s*child: Column\(/g,
    'return Container(\n      color: const Color(0xFFf0f1f7),\n      child: SingleChildScrollView(\n        padding: const EdgeInsets.all(24),\n        child: Column('
  );
  
  // Convert LF back to CRLF
  content = content.replace(/\n/g, '\r\n');
  
  fs.writeFileSync(file, content, 'utf8');
}
console.log('Fixed top-level layout wrapper');
