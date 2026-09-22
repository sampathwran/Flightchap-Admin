const fs = require('fs');
const path = require('path');

const mainPath = path.join(__dirname, 'lib/main.dart');
let code = fs.readFileSync(mainPath, 'utf8');

// Add import if not exists
if (!code.includes('package:google_fonts/google_fonts.dart')) {
  code = code.replace(
    /import "dart:io";/,
    `import "dart:io";\nimport "package:google_fonts/google_fonts.dart";`
  );
}

// Replace Segoe UI with Noto Sans Sinhala
code = code.replace(
  /fontFamily: "Segoe UI",/,
  `fontFamily: GoogleFonts.notoSansSinhala().fontFamily,`
);

fs.writeFileSync(mainPath, code);
console.log('Font updated');
