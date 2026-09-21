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

  if (!content.includes("import '../site_state.dart';")) {
    content = content.replace("import 'package:flutter/material.dart';", "import 'package:flutter/material.dart';\nimport '../site_state.dart';");
  }

  // Find all State classes
  // class _CountriesTabState extends State<CountriesTab> {
  // We will split the file by "class _" and process each state block
  
  const parts = content.split(/(?=class _[a-zA-Z0-9]+State extends State<[a-zA-Z0-9]+>\s*\{)/g);
  
  for (let i = 1; i < parts.length; i++) {
     let block = parts[i];
     
     // 1. Inject listener
     if (!block.includes('void _onSiteChanged()')) {
        if (block.includes('void initState() {')) {
           // Inject into existing initState
           block = block.replace(/(void initState\(\)\s*\{\s*super\.initState\(\);)/, "$1\n    SiteState.activeSite.addListener(_onSiteChanged);");
           
           // Inject dispose and _onSiteChanged before the build method
           block = block.replace(/(@override\s*Widget build\(BuildContext context\)\s*\{)/, `  @override
  void dispose() {
    SiteState.activeSite.removeListener(_onSiteChanged);
    super.dispose();
  }

  void _onSiteChanged() {
    if (mounted) setState(() {});
  }

  $1`);
        } else {
           // Inject entirely new initState, dispose, _onSiteChanged
           // Just after the class declaration opening brace
           block = block.replace(/(class _[a-zA-Z0-9]+State extends State<[a-zA-Z0-9]+>\s*\{)/, `$1
  @override
  void initState() {
    super.initState();
    SiteState.activeSite.addListener(_onSiteChanged);
  }

  @override
  void dispose() {
    SiteState.activeSite.removeListener(_onSiteChanged);
    super.dispose();
  }

  void _onSiteChanged() {
    if (mounted) setState(() {});
  }
`);
        }
     }
     
     // 2. Add .where(...) to snapshots
     block = block.replace(/([a-zA-Z0-9_.]+(?:collection|orderBy)[^\n)]*\))\.snapshots\(\)/g, (match, p1) => {
       if (p1.includes("where('target_website'")) return match;
       return `${p1}.where('target_website', isEqualTo: SiteState.activeSite.value).snapshots()`;
     });

     block = block.replace(/\.collection\('([^']+)'\)\.snapshots\(\)/g, (match, p1) => {
       return `.collection('${p1}').where('target_website', isEqualTo: SiteState.activeSite.value).snapshots()`;
     });

     // 3. Remove .orderBy
     block = block.replace(/\.orderBy\([^)]+\)/g, '');

     parts[i] = block;
  }
  
  content = parts.join('');

  // 4. Inject target_website into data before adding/updating
  content = content.replace(/await ([a-zA-Z0-9_]+)\.add\((data|dealData|customerData)\);/g, (match, p1, p2) => {
     return `${p2}['target_website'] = SiteState.activeSite.value; ${match}`;
  });
  content = content.replace(/await ([a-zA-Z0-9_]+)\.doc\(([^)]+)\)\.update\((data|dealData|customerData)\);/g, (match, p1, p2, p3) => {
    return `${p3}['target_website'] = SiteState.activeSite.value; ${match}`;
  });

  fs.writeFileSync(filePath, content);
  console.log(`Patched ${file}`);
}
