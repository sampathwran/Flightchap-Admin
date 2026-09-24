const fs = require('fs');

function makeParsingSafe(file) {
  let content = fs.readFileSync(file, 'utf8');

  // Replace `DateTime endTime = (data['endTime'] as Timestamp).toDate();`
  // with `DateTime endTime = data['endTime'] != null ? (data['endTime'] as Timestamp).toDate() : DateTime.now().add(const Duration(days: 365));`
  
  content = content.replace(/DateTime endTime = \(data\['endTime'\] as Timestamp\)\.toDate\(\);/g, 
    "DateTime endTime = data['endTime'] != null ? (data['endTime'] as Timestamp).toDate() : DateTime.now().add(const Duration(days: 365));");

  fs.writeFileSync(file, content, 'utf8');
}

makeParsingSafe('lib/screens/flash_deals_screen.dart');
makeParsingSafe('lib/screens/member_deals_screen.dart');
makeParsingSafe('lib/screens/promo_codes_screen.dart');
makeParsingSafe('lib/screens/special_offers_screen.dart'); // Just in case
console.log("Made parsing safe");
