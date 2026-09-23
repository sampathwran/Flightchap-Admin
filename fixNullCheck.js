const fs = require('fs');
let content = fs.readFileSync('lib/screens/member_deals_screen.dart', 'utf8');

const oldCheck = `if (_selectedEndTime!.isBefore(effectiveStartTime)) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('End Time must be after Start Time.')));
        return;
      }`;
      
content = content.replace(oldCheck, `// Time validation removed`);
fs.writeFileSync('lib/screens/member_deals_screen.dart', content, 'utf8');
