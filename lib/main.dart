import "package:flutter/material.dart";
import "package:firebase_core/firebase_core.dart";
import "package:flutter_localizations/flutter_localizations.dart";
import "package:flutter_quill/flutter_quill.dart";
import "firebase_options.dart";
import "screens/main_layout.dart";
import "screens/login_screen.dart";
import "package:firebase_auth/firebase_auth.dart";
import "package:flutter/foundation.dart";
import "dart:io";

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback = (X509Certificate cert, String host, int port) => true;
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (!kIsWeb) {
    HttpOverrides.global = MyHttpOverrides();
  }
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const FlightchapAdminApp());
}

class FlightchapAdminApp extends StatelessWidget {
  const FlightchapAdminApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Flightchap Admin",
      debugShowCheckedModeBanner: false,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        FlutterQuillLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en', 'US'),
      ],
      theme: ThemeData(
        primaryColor: const Color(0xFF007bff),
        scaffoldBackgroundColor: const Color(0xFFf0f1f7),
        fontFamily: "Segoe UI",
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF007bff)),
      ),
      home: StreamBuilder<User?>(
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
      ),
    );
  }
}
