const fs = require('fs');
const files = [
  'lib/screens/flash_deals_screen.dart',
  'lib/screens/member_deals_screen.dart',
  'lib/screens/special_offers_screen.dart'
];

for (const file of files) {
  let content = fs.readFileSync(file, 'utf8');
  content = content.replace(/(shrinkWrap:\s*true,\s*)+/g, "shrinkWrap: true,\n");
  content = content.replace(/(physics:\s*const NeverScrollableScrollPhysics\(\),\s*)+/g, "physics: const NeverScrollableScrollPhysics(),\n");
  fs.writeFileSync(file, content, 'utf8');
}
console.log('Fixed duplicates');
