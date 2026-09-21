const fs = require('fs');
let code = fs.readFileSync('lib/screens/flash_deals_screen.dart', 'utf8');

// 1. Change Container to SingleChildScrollView for the whole page
// The structure is:
// return Container(
//   padding: const EdgeInsets.all(24),
//   color: const Color(0xFFf0f1f7),
//   child: Column(

code = code.replace(
  /return Container\(\n\s*padding: const EdgeInsets\.all\(24\),\n\s*color: const Color\(0xFFf0f1f7\),\n\s*child: Column\(/g,
  `return SingleChildScrollView(
            child: Container(
              padding: const EdgeInsets.all(24),
              color: const Color(0xFFf0f1f7),
              child: Column(`
);

// We need to add one more closing bracket at the very end of the builder if we wrapped it, but we can just wrap the Column inside SingleChildScrollView instead!
// Let's revert that and just wrap the Column.
code = code.replace(
  /child: Column\(\n\s*crossAxisAlignment: CrossAxisAlignment\.start,\n\s*children: \[\n\s*const Text\(\n\s*'Manage Flash Deals',/g,
  `child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Manage Flash Deals',`
);

// We need to add a closing parenthesis for SingleChildScrollView. 
// However, the child of Container is exactly the Column.
// Wait, instead of regex, let's just do it directly.

// 2. Remove the first Expanded from List Section
code = code.replace(
  /\/\/ List Section\n\s*Expanded\(\n\s*child: Container\(/g,
  `// List Section
                Container(`
);

// Remove the matching closing bracket for the first Expanded
// It's tricky to find it with regex. Let's do a simple manual replace by counting or just doing a simpler trick.
