const fs = require('fs');
let code = fs.readFileSync('lib/screens/flash_deals_screen.dart', 'utf8');

// 1. Wrap the entire outer Column in SingleChildScrollView.
// Look for `return Container(` inside `Widget build(BuildContext context)`.
// The file has:
//       return ValueListenableBuilder<String>(
//         valueListenable: SiteState.activeSite,
//         builder: (context, activeSite, _) {
//           bool isFlightChap = activeSite == 'flightchap';
//           return Container(
//             padding: const EdgeInsets.all(24),
//             color: const Color(0xFFf0f1f7),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [

const oldOuterColumn = `          return Container(
            padding: const EdgeInsets.all(24),
            color: const Color(0xFFf0f1f7),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Manage Flash Deals',`;

const newOuterColumn = `          return Container(
            color: const Color(0xFFf0f1f7),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Manage Flash Deals',`;

code = code.replace(oldOuterColumn, newOuterColumn);

// 2. Remove Expanded from List Section.
// The code has:
//           // List Section
//           Container(
//             width: double.infinity,
//             padding: const EdgeInsets.all(20),
//             decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   const Text('Flash Deals History', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
//                   const SizedBox(height: 16),
//                   Expanded(
//                     child: StreamBuilder<QuerySnapshot>(

// Wait, earlier I DID successfully remove the first Expanded! (It changed from Expanded(child: Container( to Container( with an extra closing brace at the bottom).
// BUT then I tried to fix it and ran `git restore`? No, wait! I never ran `git restore` AFTER doing the second `replace_file_content` that successfully fixed the `where` clause. Wait, I DID run `git restore` at 23:58:27, and then I successfully applied the `where` clause replacement. But I did NOT apply the scrolling replacement again yet!

// So the code currently looks like:
//           // List Section
//           Expanded(
//             child: Container(
//               width: double.infinity,
//               padding: const EdgeInsets.all(20),
//               decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   const Text('Flash Deals History', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
//                   const SizedBox(height: 16),
//                   Expanded(
//                     child: StreamBuilder<QuerySnapshot>(

const oldListSection = `          // List Section
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
                    child: StreamBuilder<QuerySnapshot>(`;

const newListSection = `          // List Section
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Flash Deals History', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                StreamBuilder<QuerySnapshot>(`;

code = code.replace(oldListSection, newListSection);

// 3. Add shrinkWrap to ListView.builder
const oldListView = `                        if (docs.isEmpty) return const Center(child: Text('No flash deals found.'));

                        return ListView.builder(
                          itemCount: docs.length,
                          itemBuilder: (context, index) {`;

const newListView = `                        if (docs.isEmpty) return const Center(child: Text('No flash deals found.'));

                        return ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: docs.length,
                          itemBuilder: (context, index) {`;

code = code.replace(oldListView, newListView);

// 4. Remove the two extra closing braces from the bottom since we removed 2 Expanded widgets.
const oldEnding = `                          },
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

const newEnding = `                          },
                        );
                      },
                    // ), this was Expanded
                  // ), this was Expanded
                ],
              ),
            ),
          // ), this was Expanded 1
        ],
      ),
    ), // SingleChildScrollView closing
    );
  }
}`;

// Actually wait, let's look at the exact braces.
// StreamBuilder closes with:
//                         );
//                       },
//                     ),

// So if we remove the Expanded around it, the `),` closing the Expanded goes away.
// And the `Expanded` around `Container` goes away, so its `),` goes away.
// And we need to add `),` for `SingleChildScrollView` after the main `Column` closes.

code = code.replace(oldEnding, `                          },
                        );
                      },
                    // ),
                ],
              ),
            ),
          // ),
        ],
      ),
      ),
    );
  }
}`);

fs.writeFileSync('lib/screens/flash_deals_screen.dart', code);
console.log('Fixed dart file successfully');
