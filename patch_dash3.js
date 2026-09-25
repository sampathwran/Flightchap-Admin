const fs = require('fs');
let file = 'lib/screens/dashboard_screen.dart';
let content = fs.readFileSync(file, 'utf8');

const startStr = "_buildStatCard('Total Visits'";
const endStr = "_buildStatCard('Wishlist Saves', NumberFormat.compact().format(totalWishlist), '', const Color(0xFF26bf94), Icons.favorite),";
const endStr2 = "_buildStatCard('Wishlist Saves', NumberFormat.compact().format(totalWishlist), '', const Color(0xFF26bf94), Icons.favorite),";

const startIndex = content.indexOf(startStr);
const endIndex = content.indexOf(endStr);

if (startIndex !== -1 && endIndex !== -1) {
  const replacement = `_buildStatCard('Website Visits', NumberFormat.compact().format(totalVisits), '', const Color(0xFF007bff), Icons.visibility),
                    _buildStatCard('Total Clicks', NumberFormat.compact().format(totalClicks), '', const Color(0xFFf5b849), Icons.touch_app),
                    _buildStatCard('Registered / Subscribed', NumberFormat.compact().format(totalRegistered), '', const Color(0xFF23b7e5), Icons.person_add),`;
                    
  content = content.substring(0, startIndex) + replacement + content.substring(endIndex + endStr.length);
} else {
  console.log("Could not find blocks!");
}

content = content.replace(/width: 180,/g, 'width: 320,');

fs.writeFileSync(file, content, 'utf8');
console.log('Fixed dashboard cards with precision');
