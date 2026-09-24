const fs = require('fs');

let content = fs.readFileSync('lib/screens/main_layout.dart', 'utf8');

// Replace the buildBody if-else chain
const oldBlock = `    } else if (_selectedIndex == 12) {
      return const SpecialOffersScreen();
    } else if (_selectedIndex == 99) {
      return const AdminProfileScreen();
    } else {
      return Center(child: Text('Module Under Construction', style: TextStyle(fontSize: 24, color: Colors.grey)));
    }`;
    
const newBlock = `    } else if (_selectedIndex == 12) {
      return const SpecialOffersScreen();
    } else if (_selectedIndex == 13) {
      return const MemberDealsScreen();
    } else if (_selectedIndex == 14) {
      return const PromoCodesScreen();
    } else if (_selectedIndex == 99) {
      return const AdminProfileScreen();
    } else {
      return Center(child: Text('Module Under Construction', style: TextStyle(fontSize: 24, color: Colors.grey)));
    }`;

content = content.replace(oldBlock, newBlock);
fs.writeFileSync('lib/screens/main_layout.dart', content, 'utf8');
