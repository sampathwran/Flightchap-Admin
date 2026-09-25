const fs = require('fs');
let sidebarPath = 'lib/widgets/sidebar.dart';
let sidebarContent = fs.readFileSync(sidebarPath, 'utf8');

sidebarContent = sidebarContent.replace(/_buildMenuItem\(10,\s*Icons\.directions_car,\s*'Popular Vehicles'\),\s*/g, '');
sidebarContent = sidebarContent.replace(/_buildMenuItem\(11,\s*Icons\.airport_shuttle,\s*'Transfer Fleet'\),\s*/g, '');

fs.writeFileSync(sidebarPath, sidebarContent, 'utf8');

let layoutPath = 'lib/screens/main_layout.dart';
let layoutContent = fs.readFileSync(layoutPath, 'utf8');

// Optional: remove imports and routes, but it's not strictly necessary. We can just leave them in case they want it back, or clean them up.
layoutContent = layoutContent.replace(/10:\s*'\/popular-vehicles',\s*/g, '');
layoutContent = layoutContent.replace(/11:\s*'\/transfer-vehicles',\s*/g, '');

layoutContent = layoutContent.replace(
  /\s*\} else if \(_selectedIndex == 10\) \{\s*return const PopularVehiclesScreen\(\);\s*\}/g,
  ''
);
layoutContent = layoutContent.replace(
  /\s*\} else if \(_selectedIndex == 11\) \{\s*return const TransferVehiclesScreen\(\);\s*\}/g,
  ''
);

fs.writeFileSync(layoutPath, layoutContent, 'utf8');
console.log('Removed vehicle menus from admin sidebar');
