const fs = require('fs');
const files = [
  'lib/screens/flash_deals_screen.dart',
  'lib/screens/member_deals_screen.dart',
  'lib/screens/special_offers_screen.dart'
];

for (const file of files) {
  if (!fs.existsSync(file)) continue;
  let content = fs.readFileSync(file, 'utf8');

  // Shrink the form layout to fit better on smaller screens (similar to what we did for promo codes)
  content = content.replace("padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),", "padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),");
  content = content.replace("padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),", "padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),");
  content = content.replace(/padding: const EdgeInsets\.symmetric\(vertical: 18, horizontal: 8\),/g, "padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),");
  content = content.replace(/padding: const EdgeInsets\.symmetric\(horizontal: 24, vertical: 20\),/g, "padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),");
  
  // Wrap entire content in SingleChildScrollView and remove Expanded from list
  // 1. Change the main Column wrap
  content = content.replace(
`    return Container(
      padding: const EdgeInsets.all(24),
      color: const Color(0xFFf0f1f7),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [`, 
`    return Container(
      color: const Color(0xFFf0f1f7),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [`);
          
  // 2. Remove Expanded from List Section
  content = content.replace(
`          // List Section
          Expanded(
            child: Container(`,
`          // List Section
          Container(`);

  // 3. The inner Expanded for StreamBuilder needs to go or become a Container with fixed height?
  // If we remove Expanded around StreamBuilder, ListView.builder needs shrinkWrap: true.
  content = content.replace(
`                  Expanded(
                    child: StreamBuilder<QuerySnapshot>(`,
`                  StreamBuilder<QuerySnapshot>(`);

  // Fix the closing tags for the removed Expanded wrappers
  // The first Expanded is closed right after StreamBuilder's closing tag
  content = content.replace(
`                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );`,
`                      },
                    ),
                ],
              ),
            ),
        ],
        ),
      ),
    );`);

  // In ListView.builder, add shrinkWrap and physics
  if (content.includes("ListView.builder(")) {
    content = content.replace(
      "ListView.builder(",
      "ListView.builder(\n                      shrinkWrap: true,\n                      physics: const NeverScrollableScrollPhysics(),\n"
    );
  }

  // Remove duplicate shrinkWrap/physics if we accidentally inserted it multiple times
  content = content.replace(/(shrinkWrap: true,\s*physics: const NeverScrollableScrollPhysics(),\s*){2,}/g, "shrinkWrap: true,\n                      physics: const NeverScrollableScrollPhysics(),\n");

  fs.writeFileSync(file, content, 'utf8');
}
console.log('Fixed deals pages');
