import 'package:flutter/material.dart';
import '../screens/splash_screen.dart';
import 'seed_data.dart';

class DevModeService {
  static final DevModeService _instance = DevModeService._internal();
  factory DevModeService() => _instance;
  DevModeService._internal();

  final ValueNotifier<bool> isDevMode = ValueNotifier<bool>(false);

  Future<void> toggleDevMode(BuildContext context) async {
    isDevMode.value = !isDevMode.value;

    if (isDevMode.value) {
      // Show loading indicator or toast
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Entering Dev Mode: Seeding data...'),
          backgroundColor: Colors.blueGrey[900],
          behavior: SnackBarBehavior.floating,
        ),
      );

      try {
        // Seed data
        await SeedData.seedAll();

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Data seeded successfully! Reloading...'),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
              duration: Duration(seconds: 1),
            ),
          );
        }

        // Reload application by going to Splash
        Future.delayed(const Duration(seconds: 1), () {
          if (context.mounted) {
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (_) => const SplashScreen()),
              (route) => false,
            );
          }
        });
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error seeding data: $e'),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
        isDevMode.value = false;
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Exiting Dev Mode.'),
          behavior: SnackBarBehavior.floating,
          duration: Duration(seconds: 1),
        ),
      );
    }
  }
}
