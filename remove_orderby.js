const fs = require('fs');
const path = require('path');

const dir = 'C:\\src\\hotelchap_admin\\lib\\screens';

const filesToPatch = [
  'flight_offers_screen.dart',
  'special_offers_screen.dart',
  'popular_destinations_screen.dart',
  'popular_flight_routes_screen.dart',
  'popular_vehicles_screen.dart',
  'transfer_vehicles_screen.dart',
  'blog_screen.dart',
  'flash_deals_screen.dart' // This one might have orderBy('endTime')
];

for (const file of filesToPatch) {
  const filePath = path.join(dir, file);
  if (!fs.existsSync(filePath)) continue;

  let content = fs.readFileSync(filePath, 'utf8');
  
  // Replace .orderBy('...', descending: ...) with nothing if it has .where('target_website')
  // Because flutter Firebase SDK will throw composite index errors
  content = content.replace(/\.orderBy\([^)]+\)/g, '');

  fs.writeFileSync(filePath, content);
  console.log(`Removed orderBy from ${file}`);
}
