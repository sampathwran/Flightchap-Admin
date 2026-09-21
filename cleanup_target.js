const fs = require('fs');
const path = require('path');

const screensDir = 'lib/screens';
const files = fs.readdirSync(screensDir).filter(f => f.endsWith('.dart'));

for (const file of files) {
    const filePath = path.join(screensDir, file);
    let code = fs.readFileSync(filePath, 'utf8');
    
    // Remove SiteState imports
    code = code.replace(/import '\.\.\/site_state\.dart';\n?/g, '');
    
    // Remove target_website injection
    code = code.replace(/data\['target_website'\] = [^;]+;\n?/g, '');
    code = code.replace(/'target_website': [^,]+,\n?/g, '');
    
    // Remove .where('target_website' ...)
    code = code.replace(/\.where\('target_website',\s*isEqualTo:\s*SiteState\.activeSite\.value\)/g, '');
    
    // Some files might have `activeSite` references manually, e.g. flash_deals_screen.dart had custom logic
    fs.writeFileSync(filePath, code);
}
console.log("Cleaned screens");
