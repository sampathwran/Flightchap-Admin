const fs = require('fs');

function fix(file) {
  let content = fs.readFileSync(file, 'utf8');

  // We find the SizedBox(width: 16) before the START TIME PICKER
  // And replace it with `],), const SizedBox(height: 16), Row(children: [`
  
  const searchStr = `                        const SizedBox(width: 16),
                        
                        // START TIME PICKER`;
                        
  const replaceStr = `                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        // START TIME PICKER`;
                        
  content = content.replace(searchStr, replaceStr);
  fs.writeFileSync(file, content, 'utf8');
}

fix('lib/screens/member_deals_screen.dart');
fix('lib/screens/promo_codes_screen.dart');
console.log("Fixed safely");
