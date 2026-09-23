const fs = require('fs');
let content = fs.readFileSync('lib/screens/promo_codes_screen.dart', 'utf8');

// The Promo Code schema we expect:
// provider (string), discount (string), code (string), color (string)
// In the cloned file, we have: _titleController (-> provider), _discountController (-> discount), _codeController (-> code)
// The UI labels need changing.
content = content.replace(/'Title'/g, "'Provider (e.g. Agoda VIP)'");
content = content.replace(/'Code'/g, "'Promo Code (e.g. FLIGHTCHAP10)'");
content = content.replace(/'Discount'/g, "'Description / Discount'");

// We don't strictly need to upload an image for promo codes, but it's fine if they want to. We can leave image logic or remove it. 
// I will just leave the image logic so they can add a small logo, and we can use it on the website later.
// We just need to make sure the save payload uses the right keys.
// 'title': _titleController.text, 'discount': _discountController.text, 'targetUrl': _codeController.text
// But the web app expects: 'provider', 'code', 'discount'
content = content.replace(/'title': _titleController.text/g, "'provider': _titleController.text, 'color': 'bg-blue-50 text-blue-600'");
content = content.replace(/'targetUrl': _codeController.text/g, "'code': _codeController.text");
content = content.replace(/deal\['title'\]/g, "deal['provider']");
content = content.replace(/deal\['targetUrl'\]/g, "deal['code']");

fs.writeFileSync('lib/screens/promo_codes_screen.dart', content, 'utf8');
