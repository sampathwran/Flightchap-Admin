const fs = require('fs');
let code = fs.readFileSync('lib/screens/login_screen.dart', 'utf8');

// Add cloud_firestore import
if (!code.includes("cloud_firestore.dart")) {
  code = code.replace(
    "import 'package:firebase_auth/firebase_auth.dart';",
    "import 'package:firebase_auth/firebase_auth.dart';\nimport 'package:cloud_firestore/cloud_firestore.dart';"
  );
}

// Modify _login logic
const loginReplacement = `
    try {
      final userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );
      
      // CHECK IF ADMIN
      if (userCredential.user != null && userCredential.user!.email != null) {
        String email = userCredential.user!.email!;
        
        // Hardcoded super admin check + Firestore check
        bool isAdmin = false;
        if (email == 'admin@hotelchap.com' || email == 'hotelchap@gmail.com') {
          isAdmin = true;
        } else {
          final adminDoc = await FirebaseFirestore.instance.collection('admin_users').doc(email).get();
          if (adminDoc.exists) {
            isAdmin = true;
          }
        }
        
        if (!isAdmin) {
          await FirebaseAuth.instance.signOut();
          setState(() {
            _errorMessage = 'Access Denied: You do not have admin privileges.';
          });
          return;
        }
      }
      
    } on FirebaseAuthException catch (e) {
`;

code = code.replace(
  `    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );
    } on FirebaseAuthException catch (e) {`,
  loginReplacement
);

fs.writeFileSync('lib/screens/login_screen.dart', code);
console.log('Patched login_screen.dart for admin role check');
