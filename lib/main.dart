import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'screens/splash_screen.dart';
import 'theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Enable runtime font fetching so GoogleFonts can download any weight that
  // isn't bundled.  This avoids crashes when a font file is missing from
  // assets (e.g. outfit-semiBold) and is convenient during development.
  // In production you can still bundle the fonts yourself and set this to
  // false if you prefer offline operation.
  GoogleFonts.config.allowRuntimeFetching = true;

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
