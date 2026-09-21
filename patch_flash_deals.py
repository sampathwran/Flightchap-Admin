import re
import os

path = 'lib/screens/flash_deals_screen.dart'
with open(path, 'r', encoding='utf8') as f:
    content = f.read()

# Fix activeSite filter block
pattern = r"final allDocs = snapshot\.data\?\.docs \?\? \[\];\s*final docs = allDocs\.where\(\(doc\) \{[\s\S]*?return target == activeSite;\s*\}\)\.toList\(\);"
replacement = "final docs = snapshot.data?.docs ?? [];"
content = re.sub(pattern, replacement, content)

# Try to find the syntax error at the end of the file
# It seems there are too many closing brackets or missing brackets.
# Wait, let's just use `git checkout lib/screens/flash_deals_screen.dart` and re-apply ONLY the scrolling and history list fixes!
