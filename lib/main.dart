import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'screens/splash_screen.dart';
import 'theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Disable runtime font fetching to fix SocketException
  // and use the fonts bundled in assets instead.
  GoogleFonts.config.allowRuntimeFetching = false;

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const QgetPortalApp());
}

class QgetPortalApp extends StatelessWidget {
  const QgetPortalApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Qget Alumni Portal',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: const SplashScreen(),
    );
  }
}
