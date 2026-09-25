const fs = require('fs');
const files = [
  'lib/screens/flash_deals_screen.dart',
  'lib/screens/member_deals_screen.dart',
  'lib/screens/special_offers_screen.dart'
];

for (const file of files) {
  let content = fs.readFileSync(file, 'utf8');
  content = content.replace(/shrinkWrap: true,\s*physics: const NeverScrollableScrollPhysics\(\),\s*shrinkWrap: true,\s*physics: const NeverScrollableScrollPhysics\(\),/g, "shrinkWrap: true,\nphysics: const NeverScrollableScrollPhysics(),");
  
  content = content.replace(/shrinkWrap: true,\nphysics: const NeverScrollableScrollPhysics\(\),\nshrinkWrap: true,\nphysics: const NeverScrollableScrollPhysics\(\),/g, "shrinkWrap: true,\nphysics: const NeverScrollableScrollPhysics(),");
  
  // also fix promo codes if it got messed up (it wasn't in the array, but just in case)
  
  fs.writeFileSync(file, content, 'utf8');
}
console.log('Fixed exactly duplicates');
