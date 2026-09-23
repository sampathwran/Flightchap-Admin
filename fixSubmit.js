const fs = require('fs');

let content = fs.readFileSync('lib/screens/promo_codes_screen.dart', 'utf8');

// Replace the strict if condition
content = content.replace(
  /if \(_formKey\.currentState!\.validate\(\) && _selectedEndTime != null && hasImage\) \{/g,
  `if (_formKey.currentState!.validate()) {`
);

// We don't even care about start time / end time for Promo Codes right now. 
// Let's remove the time validation inside too.
content = content.replace(
  /if \(_selectedEndTime!\.isBefore\(effectiveStartTime\)\) \{[\s\S]*?return;\s*\}/g,
  `// Time validation removed for promo codes`
);

fs.writeFileSync('lib/screens/promo_codes_screen.dart', content, 'utf8');
