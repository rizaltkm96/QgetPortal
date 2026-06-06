import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:qget_portal/providers/app_providers.dart';
import 'package:qget_portal/providers/ui_state_providers.dart';
import 'package:qget_portal/screens/home_screen.dart';
import 'package:qget_portal/screens/login_screen.dart';
import 'package:qget_portal/theme/app_colors.dart';
import 'package:qget_portal/widgets/app_gradient_background.dart';
import 'package:qget_portal/widgets/glass.dart';

class SplashScreen extends ConsumerWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen<AsyncValue<User?>>(authStateChangesProvider, (previous, next) {
      if (ref.read(splashNavigationHandledProvider)) return;
      next.whenOrNull(
        data: (user) {
          ref.read(splashNavigationHandledProvider.notifier).state = true;
          final dest =
              user == null ? const LoginScreen() : const HomeScreen();
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!context.mounted) return;
            Navigator.of(context).pushReplacement(
              MaterialPageRoute<void>(builder: (_) => dest),
            );
          });
        },
        error: (_, __) {
          ref.read(splashNavigationHandledProvider.notifier).state = true;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!context.mounted) return;
            Navigator.of(context).pushReplacement(
              MaterialPageRoute<void>(builder: (_) => const LoginScreen()),
            );
          });
        },
      );
    });

    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: AppGradientBackground(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              GlassPanel(
                strongBlur: true,
                borderRadius: 28,
                padding: const EdgeInsets.all(20),
                child: Icon(
                  Icons.school_rounded,
                  size: 72,
                  color: theme.colorScheme.primary,
                ),
              ),
              const SizedBox(height: 28),
              Text(
                'Qget Alumni Portal',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppColors.onCanvasPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Alumni network',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: AppColors.onCanvasMuted,
                ),
              ),
              const SizedBox(height: 36),
              const CircularProgressIndicator(),
            ],
          ),
        ),
      ),
    );
  }
}
