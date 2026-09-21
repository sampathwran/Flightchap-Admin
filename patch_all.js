const fs = require('fs');
const path = require('path');

const screensDir = 'lib/screens';
const files = fs.readdirSync(screensDir).filter(f => f.endsWith('.dart') && f !== 'main_layout.dart' && f !== 'dashboard_screen.dart');

for (const file of files) {
    const filePath = path.join(screensDir, file);
    let code = fs.readFileSync(filePath, 'utf8');
    
    // Add import if missing
    if (!code.includes("import '../site_state.dart';")) {
        code = code.replace("import 'package:flutter/material.dart';", "import 'package:flutter/material.dart';\nimport '../site_state.dart';");
    }

    // 1. Inject target_website into maps before `.add` or `.update` or `.set`
    // Looking for `data['target_website']` to see if already patched
    if (!code.includes("target_website")) {
        // We need to inject target_website.
        // It's hard to dynamically inject into every `data = {}`.
        // A safer way is to find `add(` or `update(` or `set(` that takes a Map and inject it there? No, Dart is typed.
        // Let's do it manually for the files.
    }
}
