const fs = require('fs');
const file = 'lib/screens/promo_codes_screen.dart';
let content = fs.readFileSync(file, 'utf8');

// Wrap entire content in SingleChildScrollView and remove Expanded from list
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
          
content = content.replace(
`          // List Section
          Expanded(
            child: Container(`,
`          // List Section
          Container(`);

content = content.replace(
`                  Expanded(
                    child: StreamBuilder<QuerySnapshot>(`,
`                  StreamBuilder<QuerySnapshot>(`);

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

fs.writeFileSync(file, content, 'utf8');
console.log('Fixed promo codes layout');
