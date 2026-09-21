const fs = require('fs');
let code = fs.readFileSync('lib/screens/flash_deals_screen.dart', 'utf8');

// Replace Expanded around StreamBuilder
code = code.replace(
  /Expanded\(\n\s*child: StreamBuilder<QuerySnapshot>\(/,
  `StreamBuilder<QuerySnapshot>(`
);

// We removed two Expandeds at the top, so we need to remove two closing braces at the bottom.
// We can find them by looking at the very end of the file.
// Currently the end is:
//                 ],
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// The original tree was:
// return ValueListenableBuilder (
//   builder: Container(
//     child: Column(
//       children: [
//         FormSection(),
//         Expanded( // We removed this
//           child: Container(
//             child: Column(
//               children: [
//                 Expanded( // We removed this
//                   child: StreamBuilder(

// Since we removed two Expandeds, we need to remove two `),` or `)` at the appropriate places.
// Actually, fixing braces by regex is hard. Let's just write the trailing part explicitly.
code = code.replace(
  /                              \),\n                            \);\n                          },\n                        \);\n                      },\n                    \),\n                  \),\n                \],\n              \),\n            \),\n          \),\n        \],\n      \),\n    \);\n  }\n}/,
  `                              ),
                            );
                          },
                        );
                      },
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}`
);

// We also need to add SingleChildScrollView wrapping the main column.
// return Container(
//   padding: const EdgeInsets.all(24),
//   color: const Color(0xFFf0f1f7),
//   child: Column(

code = code.replace(
  /return Container\(\n\s*padding: const EdgeInsets\.all\(24\),\n\s*color: const Color\(0xFFf0f1f7\),\n\s*child: Column\(/,
  `return Container(
          color: const Color(0xFFf0f1f7),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(`
);

// And we need to add a closing parenthesis for SingleChildScrollView at the very end.
// After the Column closes, before Container closes.
code = code.replace(
  /        \],\n      \),\n    \);\n  }\n}/,
  `        ],
      ),
    ),
  );
}
}`
);

fs.writeFileSync('lib/screens/flash_deals_screen.dart', code);
console.log('Done!');
