const fs = require('fs');
let content = fs.readFileSync('lib/screens/blog_screen.dart', 'utf8');

content = content.replace(
  /quill\.QuillSimpleToolbar\(\s*controller: quillController,\s*\),/s,
  `quill.QuillSimpleToolbar(
                              controller: quillController,
                              configurations: const quill.QuillSimpleToolbarConfigurations(
                                showAlignmentButtons: true,
                                showJustifyAlignment: true,
                              ),
                            ),`
);

fs.writeFileSync('lib/screens/blog_screen.dart', content, 'utf8');
console.log('Fixed toolbar');
