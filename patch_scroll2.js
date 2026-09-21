const fs = require('fs');
let code = fs.readFileSync('lib/screens/admin_profile_screen.dart', 'utf8');

const oldBuild = `  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(32),
      color: const Color(0xFFf0f1f7),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [`;

const newBuild = `  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFf0f1f7),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [`;

code = code.replace(oldBuild, newBuild);
code = code.replace('const Spacer(),', 'const SizedBox(height: 64),');
code = code.replace('        ],\n      ),\n    );\n  }\n}', '        ],\n      ),\n      ),\n    );\n  }\n}');

fs.writeFileSync('lib/screens/admin_profile_screen.dart', code);
console.log('Fixed overflow in admin_profile_screen.dart');
