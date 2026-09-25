const fs = require('fs');
let file = 'lib/screens/dashboard_screen.dart';
let content = fs.readFileSync(file, 'utf8');

// 1. Remove Searches and Wishlist from the Wrap children
const targetCards = `                    _buildStatCard('Total Visits', NumberFormat.compact().format(totalVisits), '', const Color(0xFF007bff), Icons.visibility),
                    _buildStatCard('Total Registered', NumberFormat.compact().format(totalRegistered), '', const Color(0xFF23b7e5), Icons.person_add),
                    _buildStatCard('Total Clicks', NumberFormat.compact().format(totalClicks), '', const Color(0xFFf5b849), Icons.touch_app),
                    _buildStatCard('Total Searches', NumberFormat.compact().format(totalSearches), '', const Color(0xFFe6533c), Icons.search),
                    _buildStatCard('Wishlist Saves', NumberFormat.compact().format(totalWishlist), '', const Color(0xFF26bf94), Icons.favorite),`;

const replacementCards = `                    _buildStatCard('Website Visits', NumberFormat.compact().format(totalVisits), '', const Color(0xFF007bff), Icons.visibility),
                    _buildStatCard('Total Clicks', NumberFormat.compact().format(totalClicks), '', const Color(0xFF23b7e5), Icons.touch_app),
                    _buildStatCard('Registered / Subscribed', NumberFormat.compact().format(totalRegistered), '', const Color(0xFFf5b849), Icons.person_add),`;

// Normalize line endings for replacement
content = content.replace(/\r\n/g, '\n');
content = content.replace(targetCards.replace(/\r\n/g, '\n'), replacementCards);

// 2. Change the width of the stat cards to make them wider since there are only 3 now
// find `width: 180,` and change to `width: 320,`
content = content.replace(/width: 180,/g, 'width: 300,');

// Restore CRLF
content = content.replace(/\n/g, '\r\n');

fs.writeFileSync(file, content, 'utf8');
console.log('Updated dashboard cards');
