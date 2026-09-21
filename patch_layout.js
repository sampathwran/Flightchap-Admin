const fs = require('fs');

let layoutCode = fs.readFileSync('lib/screens/main_layout.dart', 'utf8');

// Add import
if (!layoutCode.includes('url_helper.dart')) {
  layoutCode = layoutCode.replace(
    "import 'special_offers_screen.dart';",
    "import 'special_offers_screen.dart';\nimport '../helpers/url_helper.dart';"
  );
}

// Create a mapping
const mappingCode = `
  final Map<int, String> _routes = {
    0: '/dashboard',
    1: '/popular-destinations',
    2: '/flash-deals',
    3: '/blog',
    4: '/wishlist',
    6: '/customers',
    9: '/fare-alerts',
    10: '/popular-vehicles',
    11: '/transfer-vehicles',
    12: '/special-offers',
  };

  @override
  void initState() {
    super.initState();
    String currentUrl = getUrl();
    if (currentUrl != '/' && currentUrl.isNotEmpty) {
      int initialIndex = _routes.entries
          .firstWhere((entry) => entry.value == currentUrl, orElse: () => const MapEntry(0, '/dashboard'))
          .key;
      _selectedIndex = initialIndex;
    }
  }
`;

// Insert the mapping and initState inside _MainLayoutState
if (!layoutCode.includes('void initState()')) {
  layoutCode = layoutCode.replace(
    'int _selectedIndex = 0;',
    'int _selectedIndex = 0;\n' + mappingCode
  );
}

// Update the setState in Sidebar's onItemSelected
layoutCode = layoutCode.replace(
  /setState\(\(\) \{\s*_selectedIndex = index;\s*\}\);/,
  `setState(() {
                _selectedIndex = index;
                if (_routes.containsKey(index)) {
                  setUrl('/#' + _routes[index]!);
                }
              });`
);

fs.writeFileSync('lib/screens/main_layout.dart', layoutCode);
console.log('Patched main_layout.dart');
