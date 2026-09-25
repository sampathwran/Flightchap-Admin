const fs = require('fs');
let file = 'lib/screens/main_layout.dart';
let content = fs.readFileSync(file, 'utf8');

if (!content.includes('social_media_screen.dart')) {
  content = content.replace(
    \"import 'package:flutter/material.dart';\",
    \"import 'package:flutter/material.dart';\\nimport 'package:flightchap_admin/screens/social_media_screen.dart';\"
  );
}

// Add case to switch statement
content = content.replace(
  \"default:\\n        return const DashboardScreen();\",
  \"case 'social':\\n        return const SocialMediaScreen();\\n      default:\\n        return const DashboardScreen();\"
);

fs.writeFileSync(file, content, 'utf8');
console.log('Updated main_layout.dart');
