const fs = require('fs');
let code = fs.readFileSync('lib/screens/flash_deals_screen.dart', 'utf8');

const oldFilter = `                    final docs = allDocs.where((doc) {
                      final data = doc.data() as Map<String, dynamic>;
                      final target = data.containsKey('target_website') ? data['target_website'] : null;
                      if (activeSite == 'hotelchap') {
                        return target == 'hotelchap' || target == null || target == '';
                      } else {
                        return target == activeSite || target == null || target == '';
                      }
                    }).toList();`;

const newFilter = `                    final docs = allDocs.where((doc) {
                      final data = doc.data() as Map<String, dynamic>;
                      final target = (data.containsKey('target_website') && data['target_website'] != null && data['target_website'] != '') ? data['target_website'] : 'hotelchap';
                      return target == activeSite;
                    }).toList();`;

if (code.includes(oldFilter)) {
    code = code.replace(oldFilter, newFilter);
    fs.writeFileSync('lib/screens/flash_deals_screen.dart', code);
    console.log("Updated history filter successfully!");
} else {
    console.log("Could not find the old filter string.");
}
