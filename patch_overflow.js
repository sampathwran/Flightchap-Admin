const fs = require('fs');
let content = fs.readFileSync('lib/screens/blog_screen.dart', 'utf8');

content = content.replace(
  /const Spacer\(\),\s*if \(\(doc\.data\(\) as Map\)\.containsKey\('createdAt'\) && doc\['createdAt'\] != null\)/s,
  `const SizedBox(height: 4),
                            if ((doc.data() as Map).containsKey('createdAt') && doc['createdAt'] != null)`
);

// To prevent overflow completely, let's wrap the inner Column in a SingleChildScrollView.
content = content.replace(
  /child: Column\(\s*crossAxisAlignment: CrossAxisAlignment\.start,\s*children: \[/s,
  `child: SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [`
);

// We need to add one more closing parenthesis for SingleChildScrollView.
content = content.replace(
  /\]\,\s*\)\,\s*\)\,\s*\)\,\s*\]\,\s*\)\,\s*\)\;\s*\}\,\s*\)\;/s,
  `],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          );`
);

fs.writeFileSync('lib/screens/blog_screen.dart', content, 'utf8');
console.log('Fixed overflow');
