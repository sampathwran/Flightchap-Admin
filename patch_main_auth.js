const fs = require('fs');
let mainCode = fs.readFileSync('lib/main.dart', 'utf8');

if (!mainCode.includes('firebase_auth.dart')) {
  mainCode = mainCode.replace(
    'import "screens/main_layout.dart";',
    'import "screens/main_layout.dart";\nimport "screens/login_screen.dart";\nimport "package:firebase_auth/firebase_auth.dart";'
  );

  mainCode = mainCode.replace(
    'home: const MainLayout(),',
    `home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(body: Center(child: CircularProgressIndicator()));
          }
          if (snapshot.hasData) {
            return const MainLayout();
          }
          return const LoginScreen();
        },
      ),`
  );
  
  fs.writeFileSync('lib/main.dart', mainCode);
  console.log('Patched main.dart');
}
