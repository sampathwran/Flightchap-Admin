const fs = require('fs');

function patchFlashDeals() {
    let code = fs.readFileSync('lib/screens/flash_deals_screen.dart', 'utf8');
    if (!code.includes("import '../site_state.dart';")) {
        code = code.replace("import 'package:flutter/material.dart';", "import 'package:flutter/material.dart';\nimport '../site_state.dart';");
    }
    
    // Fix target_website insertion using regex
    code = code.replace(
        /'updatedAt': FieldValue.serverTimestamp\(\),/g,
        `'updatedAt': FieldValue.serverTimestamp(),\n          'target_website': SiteState.activeSite.value,`
    );

    // Filter snapshots
    code = code.replace(
        /\.collection\('flash_deals'\)\.orderBy\('endTime', descending: true\)\.snapshots\(\)/g,
        `.collection('flash_deals').where('target_website', isEqualTo: SiteState.activeSite.value).snapshots()`
    );

    // To prevent sort issues because of .where(), we might just need to sort locally or create an index.
    // If it fails with index error, the console will show it. But they are using standard listview.
    fs.writeFileSync('lib/screens/flash_deals_screen.dart', code);
}

function patchPopularDestinations() {
    let code = fs.readFileSync('lib/screens/popular_destinations_screen.dart', 'utf8');
    if (!code.includes("import '../site_state.dart';")) {
        code = code.replace("import 'package:flutter/material.dart';", "import 'package:flutter/material.dart';\nimport '../site_state.dart';");
    }

    // Add target_website to countries
    code = code.replace(
        /await _firestore\.collection\('countries'\)\.add\(data\);/g,
        `data['target_website'] = SiteState.activeSite.value;\n                        await _firestore.collection('countries').add(data);`
    );
    code = code.replace(
        /await _firestore\.collection\('countries'\)\.doc\(document\.id\)\.update\(data\);/g,
        `data['target_website'] = SiteState.activeSite.value;\n                          await _firestore.collection('countries').doc(document.id).update(data);`
    );
    
    // Add target_website to cities
    code = code.replace(
        /await _firestore\.collection\('cities'\)\.add\(data\);/g,
        `data['target_website'] = SiteState.activeSite.value;\n                        await _firestore.collection('cities').add(data);`
    );
    code = code.replace(
        /await _firestore\.collection\('cities'\)\.doc\(document\.id\)\.update\(data\);/g,
        `data['target_website'] = SiteState.activeSite.value;\n                          await _firestore.collection('cities').doc(document.id).update(data);`
    );

    // Filter snapshots (countries)
    code = code.replace(
        /stream: FirebaseFirestore\.instance\.collection\('countries'\)\.snapshots\(\),/g,
        `stream: FirebaseFirestore.instance.collection('countries').where('target_website', isEqualTo: SiteState.activeSite.value).snapshots(),`
    );

    // Filter snapshots (cities)
    code = code.replace(
        /stream: FirebaseFirestore\.instance\.collection\('cities'\)\.snapshots\(\),/g,
        `stream: FirebaseFirestore.instance.collection('cities').where('target_website', isEqualTo: SiteState.activeSite.value).snapshots(),`
    );

    fs.writeFileSync('lib/screens/popular_destinations_screen.dart', code);
}

function patchWishlist() {
    let code = fs.readFileSync('lib/screens/wishlist_screen.dart', 'utf8');
    if (!code.includes("import '../site_state.dart';")) {
        code = code.replace("import 'package:flutter/material.dart';", "import 'package:flutter/material.dart';\nimport '../site_state.dart';");
    }

    // Add target_website to wishlist updates? Wishlists are usually user generated, admin might just view or delete.
    // Let's just filter snapshots
    code = code.replace(
        /stream: FirebaseFirestore\.instance\.collection\('wishlists'\)\.snapshots\(\),/g,
        `stream: FirebaseFirestore.instance.collection('wishlists').where('target_website', isEqualTo: SiteState.activeSite.value).snapshots(),`
    );

    fs.writeFileSync('lib/screens/wishlist_screen.dart', code);
}

function patchCustomers() {
    let code = fs.readFileSync('lib/screens/customers_screen.dart', 'utf8');
    if (!code.includes("import '../site_state.dart';")) {
        code = code.replace("import 'package:flutter/material.dart';", "import 'package:flutter/material.dart';\nimport '../site_state.dart';");
    }

    code = code.replace(
        /stream: FirebaseFirestore\.instance\.collection\('users'\)\.snapshots\(\),/g,
        `stream: FirebaseFirestore.instance.collection('users').where('target_website', isEqualTo: SiteState.activeSite.value).snapshots(),`
    );

    fs.writeFileSync('lib/screens/customers_screen.dart', code);
}

patchFlashDeals();
patchPopularDestinations();
patchWishlist();
patchCustomers();
console.log("All patches applied.");
