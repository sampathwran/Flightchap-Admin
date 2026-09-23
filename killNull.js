const fs = require('fs');

function killNullCheck(file) {
  let content = fs.readFileSync(file, 'utf8');
  content = content.replace(/if \(_selectedEndTime!\.isBefore\(effectiveStartTime\)\) \{[\s\S]*?return;\s*\}/g, '// no time validation');
  fs.writeFileSync(file, content, 'utf8');
}

killNullCheck('lib/screens/member_deals_screen.dart');
killNullCheck('lib/screens/promo_codes_screen.dart');
