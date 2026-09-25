const fs = require('fs');
let content = fs.readFileSync('lib/screens/promo_codes_screen.dart', 'utf8');

// Reduce vertical paddings
content = content.replace("padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),", "padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),");
content = content.replace("padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),", "padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),"); // in case there's multiple

// Time pickers
content = content.replace(/padding: const EdgeInsets\.symmetric\(vertical: 18, horizontal: 8\),/g, "padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),");

// Submit button
content = content.replace("padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),", "padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),");

// Form container padding
content = content.replace("Container(\n            padding: const EdgeInsets.all(20),\n            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),\n            child: Form(", "Container(\n            padding: const EdgeInsets.all(12),\n            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),\n            child: Form(");

// Spacing between form rows
content = content.replace(/const SizedBox\(height: 16\),/g, "const SizedBox(height: 10),");

// Spacing between Form and Title / Form and List
content = content.replace(/const SizedBox\(height: 24\),/g, "const SizedBox(height: 12),");

// Make description 1 line
content = content.replace("maxLines: 2,", "maxLines: 1,");

// Wrap the whole Form Column in a SingleChildScrollView so it doesn't push the list out if the screen is too small? 
// No, the list is in an Expanded. If the Form gets too tall for the screen, the Expanded will throw an overflow error.
// The user complained the list is not visible, which means the form took 100% of the screen and Expanded got 0 height, or threw an error.
// Let's actually change the whole screen layout from:
// Column [ Form, Expanded[List] ] 
// to 
// SingleChildScrollView [ Column [ Form, List (shrinkWrap) ] ]
// OR we just keep Expanded, since we shrank the form. But wait! The list might be better in a SingleChildScrollView for the whole page.
// Let's stick to making the form compact first.

fs.writeFileSync('lib/screens/promo_codes_screen.dart', content, 'utf8');
console.log('Fixed paddings');
