const fs = require('fs');

let code = fs.readFileSync('lib/screens/customers_screen.dart', 'utf8');

if (!code.includes("import '../site_state.dart';")) {
    code = code.replace("import 'package:flutter/material.dart';", "import 'package:flutter/material.dart';\nimport '../site_state.dart';");
}

code = code.replace(
    /\.collection\('users'\)\s*\.snapshots\(\)/g,
    ".collection('users').where('target_website', isEqualTo: SiteState.activeSite.value).snapshots()"
);

fs.writeFileSync('lib/screens/customers_screen.dart', code);
console.log("Patched customers_screen.dart");
