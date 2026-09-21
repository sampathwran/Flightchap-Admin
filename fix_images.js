const fs = require('fs');
const path = require('path');

const dir = 'C:\\src\\hotelchap_admin\\lib\\screens';

const filesToPatch = [
  'popular_destinations_screen.dart',
  'flash_deals_screen.dart',
  'blog_screen.dart',
  'popular_flight_routes_screen.dart',
  'special_offers_screen.dart'
];

for (const file of fs.readdirSync(dir)) {
  if (!file.endsWith('.dart')) continue;
  const filePath = path.join(dir, file);
  let content = fs.readFileSync(filePath, 'utf8');

  // Replace `child: Image.network(data['image'] ?? '',`
  content = content.replace(/child:\s*Image\.network\(\s*([^\s]+)\s*\?\?\s*'',/g, (match, p1) => {
    return `child: (${p1}?.toString().trim().isEmpty ?? true) ? Container(color: Colors.grey[200], child: const Icon(Icons.image_not_supported)) : Image.network(${p1},`;
  });

  // For data['image'] ?? '' without child:
  content = content.replace(/Image\.network\(\s*([^\s]+)\s*\?\?\s*'',/g, (match, p1) => {
    return `(${p1}?.toString().trim().isEmpty ?? true) ? Container(color: Colors.grey[200], child: const Icon(Icons.image_not_supported)) : Image.network(${p1},`;
  });

  fs.writeFileSync(filePath, content);
}
console.log('Fixed Image.network calls');
