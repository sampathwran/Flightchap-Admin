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
  'wishlist_screen.dart',
  'customers_screen.dart',
  'fare_alerts_subscribers_screen.dart'
];

for (const file of filesToPatch) {
  const filePath = path.join(dir, file);
  if (!fs.existsSync(filePath)) continue;

  let content = fs.readFileSync(filePath, 'utf8');

  // 1. Add import
  if (!content.includes("import '../site_state.dart';")) {
    content = "import '../site_state.dart';\n" + content;
  }

  // 2. Wrap build method with ValueListenableBuilder if not already done
  if (!content.includes('ValueListenableBuilder<String>')) {
    // Look for `Widget build(BuildContext context) {`
    // followed by `return ...;`
    // We will replace `return ...;` with `return ValueListenableBuilder<String>(valueListenable: SiteState.activeSite, builder: (context, activeSite, _) { return ...; });`

    const buildRegex = /Widget build\(BuildContext context\)\s*\{\s*return\s+/m;
    if (buildRegex.test(content)) {
      content = content.replace(buildRegex, `Widget build(BuildContext context) {\n    return ValueListenableBuilder<String>(\n      valueListenable: SiteState.activeSite,\n      builder: (context, activeSite, _) {\n        return `);
      
      // Now find the very last closing brace of the file to close it
      // Standard structure ends with `  }\n}\n`
      const lastBraceRegex = /  \}\n\}\s*$/;
      if (lastBraceRegex.test(content)) {
        content = content.replace(lastBraceRegex, `    );\n      }\n    );\n  }\n}\n`);
      } else {
         // Alternative fallback for closing brace
         content = content.trimEnd();
         if (content.endsWith('}')) {
             content = content.substring(0, content.length - 1) + '    );\n      }\n    );\n  }\n}\n';
         }
      }
    }
  }

  // 3. Add .where('target_website', isEqualTo: activeSite) to queries
  // Typically looks like `stream: _offersRef.orderBy('createdAt', descending: true).snapshots(),`
  // Or `stream: FirebaseFirestore.instance.collection('customers').snapshots(),`
  // We can do a simple string replace for `.snapshots()` -> `.where('target_website', isEqualTo: activeSite).snapshots()`
  // But some might have multiple snapshots. Let's specifically target standard queries
  
  const streamRegex = /stream:\s*([^\n]+?)\.snapshots\(\)/g;
  content = content.replace(streamRegex, (match, p1) => {
    if (p1.includes("where('target_website'")) return match; // Already patched
    return `stream: ${p1}.where('target_website', isEqualTo: activeSite).snapshots()`;
  });

  // 4. Add target_website to saved data maps
  // e.g. final data = { ... }; or dealData = { ... };
  // Find `{` followed by `'title'` or similar, or just insert it right before `createdAt`
  
  // This is slightly tricky with regex. Let's look for `FieldValue.serverTimestamp()`
  // which is typically added to maps.
  const mapSaveRegex = /'createdAt':[^,]+,?/g;
  content = content.replace(mapSaveRegex, (match) => {
     if (content.includes("'target_website': SiteState.activeSite.value")) return match; // Already patched
     return `'target_website': SiteState.activeSite.value, \n                                ` + match;
  });

  // Also replace `.add(data)` where data doesn't have createdAt but we can inject `target_website` programmatically
  // Or just replace `await _offersRef.add(data);` with `data['target_website'] = SiteState.activeSite.value; await _offersRef.add(data);`
  content = content.replace(/await ([a-zA-Z0-9_]+)\.add\((data|dealData|customerData)\);/g, (match, p1, p2) => {
     return `${p2}['target_website'] = SiteState.activeSite.value; ${match}`;
  });

  content = content.replace(/await ([a-zA-Z0-9_]+)\.doc\(([^)]+)\)\.update\((data|dealData|customerData)\);/g, (match, p1, p2, p3) => {
    return `${p3}['target_website'] = SiteState.activeSite.value; ${match}`;
 });

  fs.writeFileSync(filePath, content);
  console.log(`Patched ${file}`);
}
