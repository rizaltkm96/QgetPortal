import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:qget_portal/providers/ui_state_providers.dart';
import 'package:qget_portal/screens/home_screen.dart';
import 'package:qget_portal/services/firebase_service.dart';
import 'package:qget_portal/widgets/app_gradient_background.dart';
import 'package:qget_portal/widgets/glass.dart';

class LoginScreen extends ConsumerWidget {
  const LoginScreen({super.key});

  Future<void> _submit(BuildContext context, WidgetRef ref) async {
    final formKey = ref.read(loginFormKeyProvider);
    if (!formKey.currentState!.validate()) return;
    ref.read(loginBusyProvider.notifier).state = true;
    try {
      final registerMode = ref.read(loginRegisterModeProvider);
      final email = ref.read(loginEmailControllerProvider).text;
      final password = ref.read(loginPasswordControllerProvider).text;
      if (registerMode) {
        await FirebaseService.signUpWithEmailPassword(
          email: email,
          password: password,
        );
      } else {
        await FirebaseService.signInWithEmailPassword(
          email: email,
          password: password,
        );
      }
      if (!context.mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute<void>(builder: (_) => const HomeScreen()),
      );
    } on FirebaseAuthException catch (e) {
      if (!context.mounted) return;
      final msg = e.code == kNoAlumniEmailCode
          ? 'This email is not in the alumni directory. Ask an admin to add you first.'
          : e.message ?? e.code;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
    } on Object catch (_) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Something went wrong')),
      );
    } finally {
      if (context.mounted) {
        ref.read(loginBusyProvider.notifier).state = false;
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formKey = ref.watch(loginFormKeyProvider);
    final emailCtrl = ref.watch(loginEmailControllerProvider);
    final passwordCtrl = ref.watch(loginPasswordControllerProvider);
    final registerMode = ref.watch(loginRegisterModeProvider);
    final obscure = ref.watch(loginObscurePasswordProvider);
    final busy = ref.watch(loginBusyProvider);

    return AppGradientBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(title: const Text('Sign in')),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: GlassPanel(
              strongBlur: true,
              borderRadius: 28,
              padding: const EdgeInsets.all(22),
              child: Form(
                key: formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      registerMode ? 'Create account' : 'Welcome back',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      registerMode
                          ? 'Your email must already exist in the alumni roster.'
                          : 'Use your alumni email and password.',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context)
                                .colorScheme
                                .onSurfaceVariant,
                          ),
                    ),
                    const SizedBox(height: 28),
                    TextFormField(
                      controller: emailCtrl,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                        labelText: 'Email',
                      ),
                      validator: (v) =>
                          (v == null || v.trim().isEmpty) ? 'Enter email' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: passwordCtrl,
                      obscureText: obscure,
                      decoration: InputDecoration(
                        labelText: 'Password',
                        suffixIcon: IconButton(
                          onPressed: () => ref
                                  .read(loginObscurePasswordProvider.notifier)
                                  .state =
                              !obscure,
                          icon: Icon(
                            obscure ? Icons.visibility_off : Icons.visibility,
                          ),
                        ),
                      ),
                      validator: (v) => (v == null || v.length < 6)
                          ? 'Min 6 characters'
                          : null,
                    ),
                    const SizedBox(height: 24),
                    GradientFilledButton(
                      onPressed: busy ? null : () => _submit(context, ref),
                      busy: busy,
                      label: registerMode ? 'Register' : 'Sign in',
                    ),
                    const SizedBox(height: 12),
                    TextButton(
                      onPressed: busy
                          ? null
                          : () => ref
                                  .read(loginRegisterModeProvider.notifier)
                                  .state =
                              !registerMode,
                      child: Text(
                        registerMode
                            ? 'Already have an account? Sign in'
                            : 'New here? Create account',
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextButton(
                      onPressed: busy
                          ? null
                          : () {
                              Navigator.of(context).pushReplacement(
                                MaterialPageRoute<void>(
                                  builder: (_) => const HomeScreen(),
                                ),
                              );
                            },
                      child: const Text('Skip for now'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
