const fs = require('fs');
let code = fs.readFileSync('lib/screens/flash_deals_screen.dart', 'utf8');

// 1. Remove orderBy
code = code.replace(
  /\.collection\('flash_deals'\)\.orderBy\('endTime', descending: true\)\.snapshots\(\)/g,
  ".collection('flash_deals').snapshots()"
);

// We need to add the in-memory sort inside the builder.
// The builder looks like:
// builder: (context, snapshot) {
//   if (snapshot.hasError) return const Center(child: Text('Error loading deals'));
//   if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
//   final docs = snapshot.data?.docs ?? [];
//   if (docs.isEmpty) return const Center(child: Text('No flash deals found.'));

const sortLogic = `
                    final docs = snapshot.data?.docs ?? [];
                    docs.sort((a, b) {
                      final aTime = (a.data() as Map<String, dynamic>)['endTime'] as Timestamp?;
                      final bTime = (b.data() as Map<String, dynamic>)['endTime'] as Timestamp?;
                      if (aTime == null || bTime == null) return 0;
                      return bTime.compareTo(aTime);
                    });
                    if (docs.isEmpty) return const Center(child: Text('No flash deals found.'));
`;
code = code.replace(
  /final docs = snapshot\.data\?\.docs \?\? \[\];\s*if \(docs\.isEmpty\) return const Center\(child: Text\('No flash deals found\.'\)\);/g,
  sortLogic
);

// 2. Make it scrollable
// Wrap the Column with SingleChildScrollView
code = code.replace(
  /child: Column\(\n\s*crossAxisAlignment: CrossAxisAlignment\.start,\n\s*children: \[\n\s*const Text\(\n\s*'Manage Flash Deals',/g,
  `child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Manage Flash Deals',`
);

// We need to close SingleChildScrollView at the very end.
// The original file ended with:
//         ],
//       ),
//     );
//   }
// }
code = code.replace(
  /        \],\n      \),\n    \);\n  \}\n\}/g,
  `        ],\n      ),\n    ),\n    );\n  }\n}`
);

// Remove Expanded around List Section Container
code = code.replace(
  /\/\/ List Section\n\s*Expanded\(\n\s*child: Container\(/g,
  `// List Section
          Container(`
);

// Remove the matching parenthesis for Expanded(child: Container(
// It is at the end of the StreamBuilder block:
//                     );
//                   },
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     ],
//   ),
// 
code = code.replace(
  /                  \},\n                \),\n              \),\n            \],\n          \),\n        \),\n      \),\n    \],\n  \),\n/g,
  `                  },\n                ),\n              ],\n            ),\n          ),\n        ],\n      ),\n`
);

// Remove Expanded around StreamBuilder
code = code.replace(
  /Expanded\(\n\s*child: StreamBuilder<QuerySnapshot>\(/g,
  `StreamBuilder<QuerySnapshot>(`
);

// Add shrinkWrap and physics to ListView.builder
code = code.replace(
  /return ListView\.builder\(\s*itemCount: docs\.length,/g,
  `return ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: docs.length,`
);


fs.writeFileSync('lib/screens/flash_deals_screen.dart', code);
console.log("Patched flash deals perfectly");
