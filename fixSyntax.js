const fs = require('fs');

function fix(file) {
  let content = fs.readFileSync(file, 'utf8');
  content = content.replace(/\/\/ bool\? confirm = await showDialog/g, 'bool? confirm = await showDialog');
  
  // also clean up any dangling else at the bottom of _submitDeal
  // Let me just look at the bottom of _submitDeal
  fs.writeFileSync(file, content, 'utf8');
}
fix('lib/screens/member_deals_screen.dart');
fix('lib/screens/promo_codes_screen.dart');
