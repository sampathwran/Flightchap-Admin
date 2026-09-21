const fs = require('fs');
let code = fs.readFileSync('lib/screens/flash_deals_screen.dart', 'utf8');

if (!code.includes("import '../site_state.dart';")) {
    code = code.replace("import 'package:flutter/material.dart';", "import 'package:flutter/material.dart';\nimport '../site_state.dart';");
}

code = code.replace(
`  Widget build(BuildContext context) {
    return Container(`,
`  Widget build(BuildContext context) {
    return ValueListenableBuilder<String>(
      valueListenable: SiteState.activeSite,
      builder: (context, activeSite, _) {
        return Container(`
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
`                  Expanded(
                    child: StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance.collection('flash_deals').orderBy('endTime', descending: true).snapshots(),
                      builder: (context, snapshot) {
                        if (snapshot.hasError) return const Center(child: Text('Error loading deals'));
                        if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
                        
                        final docs = snapshot.data?.docs ?? [];
                        if (docs.isEmpty) return const Center(child: Text('No flash deals found.'));`,
`                  Expanded(
                    child: StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance.collection('flash_deals').snapshots(),
                      builder: (context, snapshot) {
                        if (snapshot.hasError) return const Center(child: Text('Error loading deals'));
                        if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
                        
                        final allDocs = snapshot.data?.docs ?? [];
                        final docs = allDocs.where((doc) {
                          final data = doc.data() as Map<String, dynamic>;
                          final target = (data.containsKey('target_website') && data['target_website'] != null && data['target_website'].toString().trim().isNotEmpty) ? data['target_website'] : 'hotelchap';
                          return target == activeSite;
                        }).toList();
                        
                        docs.sort((a, b) {
                          final aTime = (a.data() as Map<String, dynamic>)['endTime'] as Timestamp?;
                          final bTime = (b.data() as Map<String, dynamic>)['endTime'] as Timestamp?;
                          if (aTime == null || bTime == null) return 0;
                          return bTime.compareTo(aTime);
                        });
                        
                        if (docs.isEmpty) return const Center(child: Text('No flash deals found.'));`
);

const old_end = `        ],
      ),
    );
  }
}`;

const new_end = `        ],
      ),
    );
    });
  }
}`;

code = code.replace(old_end, new_end);

fs.writeFileSync('lib/screens/flash_deals_screen.dart', code);
console.log("Successfully patched flash_deals_screen.dart cleanly.");
