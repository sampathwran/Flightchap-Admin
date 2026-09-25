const fs = require('fs');
let content = fs.readFileSync('lib/screens/main_layout.dart', 'utf8');

const regex = /\} else if \(_selectedIndex == 12\) \{\s*return const SpecialOffersScreen\(\);\s*\} else if \(_selectedIndex == 99\) \{/;
const replacement = `} else if (_selectedIndex == 12) {
      return const SpecialOffersScreen();
    } else if (_selectedIndex == 13) {
      return const MemberDealsScreen();
    } else if (_selectedIndex == 14) {
      return const PromoCodesScreen();
    } else if (_selectedIndex == 99) {`;

content = content.replace(regex, replacement);
fs.writeFileSync('lib/screens/main_layout.dart', content, 'utf8');
console.log('Fixed');
