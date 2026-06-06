import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:qget_portal/firebase_options.dart';
import 'package:qget_portal/screens/splash_screen.dart';
import 'package:qget_portal/theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  GoogleFonts.config.allowRuntimeFetching = true;
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } on Object catch (e, st) {
    debugPrint('Firebase.initializeApp failed (expected until FlutterFire): $e $st');
  }
  runApp(
    const ProviderScope(
      child: QgetAlumniApp(),
    ),
  );
}

class QgetAlumniApp extends StatelessWidget {
  const QgetAlumniApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Qget Alumni Portal',
      theme: AppTheme.dark(),
      home: const SplashScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
