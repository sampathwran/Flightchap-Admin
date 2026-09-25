const fs = require('fs');
let content = fs.readFileSync('lib/screens/promo_codes_screen.dart', 'utf8');

content = content.replace("decoration: const InputDecoration(labelText: 'Paste Image URL (or upload image)', border: OutlineInputBorder()),", "decoration: const InputDecoration(labelText: 'Paste Image URL (or upload image)', border: OutlineInputBorder(), isDense: true, contentPadding: EdgeInsets.all(12)),");

content = content.replace("padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),\n                          backgroundColor: Colors.blueGrey,", "padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),\n                          backgroundColor: Colors.blueGrey,");

fs.writeFileSync('lib/screens/promo_codes_screen.dart', content, 'utf8');
