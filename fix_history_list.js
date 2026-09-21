const fs = require('fs');
let code = fs.readFileSync('lib/screens/flash_deals_screen.dart', 'utf8');

const regexListSection = /\/\/ List Section\s*Expanded\(\s*child: Container\([\s\S]*?children: \[\s*const Text\('Flash Deals History'[\s\S]*?Expanded\(\s*child: StreamBuilder<QuerySnapshot>\(\s*stream: FirebaseFirestore\.instance\.collection\('flash_deals'\)\.orderBy\('endTime', descending: true\)\.snapshots\(\),\s*builder: \(context, snapshot\) \{[\s\S]*?final docs = snapshot\.data\?\.docs \?\? \[\];\s*if \(docs\.isEmpty\) return const Center\(child: Text\('No flash deals found\.'\)\);\s*return ListView\.builder\(\s*itemCount: docs\.length,/g;

const newSection = `// List Section
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
                      final target = (data.containsKey('target_website') && data['target_website'] != null && data['target_website'] != '') ? data['target_website'] : 'hotelchap';
                      return target == activeSite;
                    }).toList();
                    
                    // Sort descending by endTime since we removed orderBy
                    docs.sort((a, b) {
                      final aTime = (a.data() as Map<String, dynamic>)['endTime'] as Timestamp?;
                      final bTime = (b.data() as Map<String, dynamic>)['endTime'] as Timestamp?;
                      if (aTime == null || bTime == null) return 0;
                      return bTime.compareTo(aTime);
                    });
                    
                    if (docs.isEmpty) return const Center(child: Text('No flash deals found.'));

                    return ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: docs.length,`;

if (regexListSection.test(code)) {
    code = code.replace(regexListSection, newSection);
    
    // Now replace the trailing ) from the removed Expandeds.
    // The very end of the file looks like:
    //                   },
    //                 ),
    //               ),
    //             ],
    //           ),
    //         ),
    //       ),
    //     ],
    //   ),
    //   ), // SingleChildScrollView
    //   );
    //   }
    // ); // ValueListenableBuilder
    
    // So we need to remove two `),`
    code = code.replace(/                  \}\,\n                \)\,\n              \)\,\n/g, '                  },\n');
    code = code.replace(/            \)\,\n          \)\,\n        \]\,\n      \)\,\n/g, '            ),\n        ],\n      ),\n');
    
    fs.writeFileSync('lib/screens/flash_deals_screen.dart', code);
    console.log("Regex patch for list section successful!");
} else {
    console.log("Could not find list section with regex.");
}
