const fs = require('fs');

function fixPayload(file) {
  let content = fs.readFileSync(file, 'utf8');
  
  content = content.replace(/'startTime': Timestamp.fromDate\(_selectedStartTime!\)/g, 
    "'startTime': Timestamp.fromDate(_selectedStartTime ?? DateTime.now())");
    
  content = content.replace(/'endTime': Timestamp.fromDate\(_selectedEndTime!\)/g, 
    "'endTime': Timestamp.fromDate(_selectedEndTime ?? DateTime.now().add(const Duration(days: 365)))");
    
  fs.writeFileSync(file, content, 'utf8');
}

fixPayload('lib/screens/member_deals_screen.dart');
fixPayload('lib/screens/promo_codes_screen.dart');
console.log("Fixed payload");
