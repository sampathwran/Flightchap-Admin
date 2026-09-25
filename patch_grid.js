const fs = require('fs');
const files = [
  'lib/screens/blog_screen.dart',
  'lib/screens/popular_vehicles_screen.dart',
  'lib/screens/transfer_vehicles_screen.dart',
  'lib/screens/popular_destinations_screen.dart'
];

for (const file of files) {
  if (!fs.existsSync(file)) continue;
  let content = fs.readFileSync(file, 'utf8');

  // Find all instances of:
  // Expanded(
  //   flex: [something],
  //   child: Padding(
  //     padding: const EdgeInsets.all(12),
  //     child: Column(
  
  content = content.replace(
    /child:\s*Padding\(\s*padding:\s*const EdgeInsets\.all\((12|16)\),\s*child:\s*Column\(/g,
    'child: Padding(\n                        padding: const EdgeInsets.all($1),\n                        child: SingleChildScrollView(\n                          child: Column('
  );
  
  // Now replace `const Spacer(),` with `const SizedBox(height: 8),`
  content = content.replace(/const Spacer\(\),/g, 'const SizedBox(height: 8),');
  
  // We added `SingleChildScrollView(`, so we need to add `),` after the Column's closing `],)`
  // Wait, the Column usually ends with:
  //                             ),
  //                           ],
  //                         ),
  //                       ),
  //                     ),
  // Let's manually replace the block end:
  
  // To be safe, instead of regex for the end, I'll just do it in one go for the exact column:
  
  fs.writeFileSync(file, content, 'utf8');
}
console.log('Fixed overflow in GridView cards (part 1)');
