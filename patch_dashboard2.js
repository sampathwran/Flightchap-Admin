const fs = require('fs');
let file = 'lib/screens/dashboard_screen.dart';
let content = fs.readFileSync(file, 'utf8');

// 1. Remove the old stat cards
content = content.replace(/_buildStatCard\('Total Visits'[\s\S]*?_buildStatCard\('Wishlist Saves'[\s\S]*?\),/g, 
`_buildStatCard('Website Visits', NumberFormat.compact().format(totalVisits), '', const Color(0xFF007bff), Icons.visibility),
                    _buildStatCard('Total Clicks', NumberFormat.compact().format(totalClicks), '', const Color(0xFFf5b849), Icons.touch_app),
                    _buildStatCard('Registered / Subscribed', NumberFormat.compact().format(totalRegistered), '', const Color(0xFF23b7e5), Icons.person_add),`);

// 2. Adjust card width so it's beautifully wide since there's only 3 cards
content = content.replace(/width: 180,/g, 'width: 320,'); // 320 looks great on a desktop

fs.writeFileSync(file, content, 'utf8');
console.log('Fixed dashboard cards');
