const fs = require('fs');

function addStorageTimeout(file) {
  let content = fs.readFileSync(file, 'utf8');
  content = content.replace(/final uploadTask = await storageRef.putData\(_selectedImageBytes!\);/g, 
    `final uploadTask = await storageRef.putData(_selectedImageBytes!).timeout(const Duration(seconds: 10), onTimeout: () { throw Exception("Image upload timed out! Check Firebase Storage rules."); });`);
  fs.writeFileSync(file, content, 'utf8');
}

addStorageTimeout('lib/screens/member_deals_screen.dart');
addStorageTimeout('lib/screens/promo_codes_screen.dart');
console.log("Added storage timeout");
