const fs = require('fs');
let code = fs.readFileSync('lib/widgets/sidebar.dart', 'utf8');

const wishlistsBlock = `                // Wishlists menu item with live badge count
                StreamBuilder<AggregateQuerySnapshot>(
                  stream: FirebaseFirestore.instance.collection('wishlists').count().get().asStream(),
                  builder: (context, snapshot) {
                    String? badgeText;
                    if (snapshot.hasData && snapshot.data!.count != null && snapshot.data!.count! > 0) {
                      badgeText = snapshot.data!.count.toString();
                    }
                    return _buildMenuItem(4, Icons.favorite_border, 'Wishlists & Saved', badge: badgeText);
                  },
                ),`;

code = code.replace(wishlistsBlock, '');

fs.writeFileSync('lib/widgets/sidebar.dart', code);
console.log('Removed wishlists from sidebar.dart');
