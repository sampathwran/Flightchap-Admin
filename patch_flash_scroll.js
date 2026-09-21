const fs = require('fs');

let code = fs.readFileSync('lib/screens/flash_deals_screen.dart', 'utf8');

// 1. Wrap the main Column in SingleChildScrollView
const pattern_column = /(child:\s*Column\(\s*crossAxisAlignment:\s*CrossAxisAlignment\.start,\s*children:\s*\[\s*const Text\(\s*'Manage Flash Deals')/;
const replacement_column = "child: SingleChildScrollView(\n            $1";
code = code.replace(pattern_column, replacement_column);

code = code.replace(/(\s*\]\,\s*\n\s*\)\,\n\s*\)\;\n\s*\}\n\})/, "          ),\n$1");

// 2. Fix the List Section
const pattern_list = /\/\/ List Section\s*Expanded\(\s*child:\s*Container\(/;
const replacement_list = "// List Section\n                Container(";
code = code.replace(pattern_list, replacement_list);

const pattern_stream = /Expanded\(\s*child:\s*StreamBuilder<QuerySnapshot>\(/;
const replacement_stream = "StreamBuilder<QuerySnapshot>(";
code = code.replace(pattern_stream, replacement_stream);

// Add shrinkWrap and physics to ListView.builder
const pattern_listview = /(return ListView\.builder\(\s*itemCount: docs\.length,)/;
const replacement_listview = "$1\n                      shrinkWrap: true,\n                      physics: const NeverScrollableScrollPhysics(),";
code = code.replace(pattern_listview, replacement_listview);

const pattern_end = /(\s*\);\s*\}\,\s*\)\,\s*)\)\,\s*\n\s*\]\,\s*\n\s*\)\,\s*\n\s*\)\,\s*\n\s*\]/;
const replacement_end = "$1\n              ],\n            ),\n          ),\n        ]";
code = code.replace(pattern_end, replacement_end);

fs.writeFileSync('lib/screens/flash_deals_screen.dart', code);
console.log("Fixed flash_deals_screen.dart perfectly!");
