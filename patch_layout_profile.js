const fs = require('fs');
let layoutCode = fs.readFileSync('lib/screens/main_layout.dart', 'utf8');

if (!layoutCode.includes('admin_profile_screen.dart')) {
  layoutCode = layoutCode.replace(
    "import 'special_offers_screen.dart';",
    "import 'special_offers_screen.dart';\nimport 'admin_profile_screen.dart';"
  );

  // Add 99: '/profile' to _routes if not present
  if (!layoutCode.includes("99: '/profile'")) {
    layoutCode = layoutCode.replace(
      "12: '/special-offers',",
      "12: '/special-offers',\n    99: '/profile',"
    );
  }

  // Pass callback to Topbar
  layoutCode = layoutCode.replace(
    'const Topbar(),',
    `Topbar(onProfileTap: () {
                  setState(() {
                    _selectedIndex = 99;
                    setUrl('/#profile');
                  });
                }),`
  );

  // Add rendering for _selectedIndex == 99
  layoutCode = layoutCode.replace(
    "} else {",
    "} else if (_selectedIndex == 99) {\n      return const AdminProfileScreen();\n    } else {"
  );

  fs.writeFileSync('lib/screens/main_layout.dart', layoutCode);
  console.log('Patched main_layout.dart for Profile routing');
}
