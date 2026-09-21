import os
import re

SCREENS_DIR = r"C:\src\hotelchap_admin\lib\screens"

for filename in os.listdir(SCREENS_DIR):
    if not filename.endswith('.dart') or filename in ['main_layout.dart', 'flash_deals_screen.dart']:
        continue
        
    filepath = os.path.join(SCREENS_DIR, filename)
    with open(filepath, 'r', encoding='utf-8') as f:
        content = f.read()
        
    if "import '../site_state.dart';" in content:
        continue
        
    # 1. Add import
    content = "import '../site_state.dart';\n" + content
    
    # 2. Wrap build method
    build_pattern = r"(Widget build\(BuildContext context\) \{\s+return )"
    replacement = r"\1ValueListenableBuilder<String>(\n      valueListenable: SiteState.activeSite,\n      builder: (context, activeSite, _) {\n        return "
    
    if re.search(build_pattern, content):
        content = re.sub(build_pattern, replacement, content, count=1)
        
        # Find the last closing brace of the build method
        # A simple hack: replace the last `  }\n}` with the closed builder
        last_brace_idx = content.rfind("  }\n}")
        if last_brace_idx != -1:
            content = content[:last_brace_idx] + "    }\n    );\n  }\n}" + content[last_brace_idx+5:]
            
    # 3. Add target_website filter
    lines = content.split('\n')
    for i, line in enumerate(lines):
        if 'FirebaseFirestore.instance.collection' in line and '.snapshots(' in line:
            lines[i] = re.sub(r"(FirebaseFirestore\.instance\.collection\('[^']+'\))", r"\1.where('target_website', isEqualTo: activeSite)", line)
            
    content = '\n'.join(lines)
            
    with open(filepath, 'w', encoding='utf-8') as f:
        f.write(content)
        
print("Patching complete.")
