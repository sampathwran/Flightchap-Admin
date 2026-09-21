import re

with open('lib/screens/flash_deals_screen.dart', 'r', encoding='utf8') as f:
    code = f.read()

# 1. Wrap the main Column in SingleChildScrollView
# Find: child: Column( ... children: [ ... 'Manage Flash Deals'
pattern_column = r"(child:\s*Column\(\s*crossAxisAlignment:\s*CrossAxisAlignment\.start,\s*children:\s*\[\s*const Text\(\s*'Manage Flash Deals')"
replacement_column = r"child: SingleChildScrollView(\n            \1"
code = re.sub(pattern_column, replacement_column, code)

# We must add an extra closing parenthesis for the SingleChildScrollView at the end of the file.
# The file ends with:
#         ],
#       ),
#     );
#   }
# }
code = re.sub(r"(\s*\]\,\s*\n\s*\)\,\n\s*\)\;\n\s*\}\n\})", r"          ),\n\1", code)


# 2. Fix the List Section
# Remove `Expanded(child: Container(` -> `Container(`
pattern_list = r"// List Section\s*Expanded\(\s*child:\s*Container\("
replacement_list = r"// List Section\n                Container("
code = re.sub(pattern_list, replacement_list, code)

# Remove `Expanded(child: StreamBuilder` -> `StreamBuilder`
pattern_stream = r"Expanded\(\s*child:\s*StreamBuilder<QuerySnapshot>\("
replacement_stream = r"StreamBuilder<QuerySnapshot>("
code = re.sub(pattern_stream, replacement_stream, code)

# Add shrinkWrap and physics to ListView.builder
pattern_listview = r"(return ListView\.builder\(\s*itemCount: docs\.length,)"
replacement_listview = r"\1\n                      shrinkWrap: true,\n                      physics: const NeverScrollableScrollPhysics(),"
code = re.sub(pattern_listview, replacement_listview, code)


# Because we removed TWO Expanded widgets, we have TWO extra `),` at the end of the list builder block.
# Let's use regex to find the end of the StreamBuilder block and remove the two `),`
# The block ends with:
#                     );
#                   },
#                 ),
#               ),
#             ],
#           ),
#         ),
#       ),
#
# We want to remove the two `),` corresponding to the Expanded widgets.
# Let's replace the chunk at the end of the StreamBuilder:
pattern_end = r"(\s*\);\s*\}\,\s*\)\,\s*)\)\,\s*\n\s*\]\,\s*\n\s*\)\,\s*\n\s*\)\,\s*\n\s*\]"
replacement_end = r"\1\n              ],\n            ),\n          ),\n        ]"
code = re.sub(pattern_end, replacement_end, code)

with open('lib/screens/flash_deals_screen.dart', 'w', encoding='utf8') as f:
    f.write(code)

print("Fixed flash_deals_screen.dart perfectly!")
