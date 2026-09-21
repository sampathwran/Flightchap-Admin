const fs = require('fs');
let code = fs.readFileSync('lib/screens/flash_deals_screen.dart', 'utf8');

if (!code.includes("import '../site_state.dart';")) {
    code = code.replace("import 'package:flutter/material.dart';", "import 'package:flutter/material.dart';\nimport '../site_state.dart';");
}

code = code.replace(
`  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      color: const Color(0xFFf0f1f7),
      child: Column(`,
`  Widget build(BuildContext context) {
    return ValueListenableBuilder<String>(
      valueListenable: SiteState.activeSite,
      builder: (context, activeSite, _) {
        return Container(
          color: const Color(0xFFf0f1f7),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(`
);

code = code.replace(
`          'endTime': Timestamp.fromDate(_selectedEndTime!),
          'updatedAt': FieldValue.serverTimestamp(),
        };`,
`          'endTime': Timestamp.fromDate(_selectedEndTime!),
          'updatedAt': FieldValue.serverTimestamp(),
          'target_website': SiteState.activeSite.value,
        };`
);

code = code.replace(
`          // List Section
          Expanded(
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Flash Deals History', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  Expanded(
                    child: StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance.collection('flash_deals').orderBy('endTime', descending: true).snapshots(),
                      builder: (context, snapshot) {
                        if (snapshot.hasError) return const Center(child: Text('Error loading deals'));
                        if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
                        
                        final docs = snapshot.data?.docs ?? [];
                        if (docs.isEmpty) return const Center(child: Text('No flash deals found.'));

                        return ListView.builder(
                          itemCount: docs.length,`,
`          // List Section
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Flash Deals History', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance.collection('flash_deals').snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.hasError) return const Center(child: Text('Error loading deals'));
                    if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
                    
                    final allDocs = snapshot.data?.docs ?? [];
                    final docs = allDocs.where((doc) {
                      final data = doc.data() as Map<String, dynamic>;
                      final target = data.containsKey('target_website') ? data['target_website'] : null;
                      if (activeSite == 'hotelchap') {
                        return target == 'hotelchap' || target == null || target == '';
                      } else {
                        return target == activeSite || target == null || target == '';
                      }
                    }).toList();
                    
                    if (docs.isEmpty) return const Center(child: Text('No flash deals found.'));

                    return ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: docs.length,`
);

// We need to replace the last 15 lines which are the closing braces.
// Let's use regex for the end to be safe, but only replacing from the bottom.
const lines = code.split('\n');
let replacedEnd = false;
for (let i = lines.length - 1; i >= 0; i--) {
    if (lines[i].includes(');')) {
        // Find the block of closing braces
        let blockStr = lines.slice(i - 15, i + 1).join('\n');
        if (blockStr.includes('    );') && blockStr.includes('  }')) {
             let newBlock = blockStr
                .replace(/                    \),\n                  \),\n/g, '')
                .replace(/          \),\n/g, '')
                + '\n      ), // SingleChildScrollView\n      );\n      }\n    ); // ValueListenableBuilder';
             // actually it's easier to just do a precise replace!
             break;
        }
    }
}
// Actually, let's just use exact string replace for the end because we know exactly what it looks like!
const old_end = `                            );
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}`;

const new_end = `                            );
                          },
                        );
                      },
                    // Expanded removed
                ],
              ),
            ),
          // Expanded removed
        ],
      ),
      ), // SingleChildScrollView
      );
      }
    ); // ValueListenableBuilder
  }
}`;
code = code.replace(old_end, new_end);

fs.writeFileSync('lib/screens/flash_deals_screen.dart', code);
console.log("Successfully replaced exact strings!");
