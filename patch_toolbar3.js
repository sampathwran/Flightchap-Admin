const fs = require('fs');
let content = fs.readFileSync('lib/screens/blog_screen.dart', 'utf8');

content = content.replace(
  /configurations: const quill\.QuillSimpleToolbarConfigurations\(/g,
  `config: const quill.QuillSimpleToolbarConfig(`
);

fs.writeFileSync('lib/screens/blog_screen.dart', content, 'utf8');
console.log('Fixed toolbar');
