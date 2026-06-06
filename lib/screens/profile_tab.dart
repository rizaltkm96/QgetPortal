import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:qget_portal/providers/app_providers.dart';
import 'package:qget_portal/services/firebase_service.dart';
import 'package:qget_portal/screens/login_screen.dart';
import 'package:qget_portal/screens/alumni_member_form_screen.dart';
import 'package:qget_portal/widgets/member_avatar.dart';
import 'package:qget_portal/widgets/glass.dart';

class ProfileTab extends ConsumerWidget {
  const ProfileTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final alumAsync = ref.watch(currentAlumniProvider);

    if (user == null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: GlassPanel(
            strongBlur: true,
            borderRadius: 24,
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.person_outline_rounded,
                  size: 48,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(height: 16),
                Text(
                  'Not signed in',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 20),
                FilledButton(
                  onPressed: () {
                    Navigator.of(context).push<void>(
                      MaterialPageRoute<void>(
                        builder: (_) => const LoginScreen(),
                      ),
                    );
                  },
                  child: const Text('Sign in'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return alumAsync.when(
      data: (alum) {
        if (alum == null) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: GlassPanel(
                strongBlur: true,
                borderRadius: 24,
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.info_outline, size: 48),
                    const SizedBox(height: 16),
                    const Text(
                      'No alumni record matches your email yet.',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    OutlinedButton.icon(
                      onPressed: () {
                        Navigator.of(context).push<void>(
                          MaterialPageRoute<void>(
                            builder: (_) => const AlumniMemberFormScreen(),
                          ),
                        );
                      },
                      icon: const Icon(Icons.person_add_alt_1_rounded),
                      label: const Text('Suggest member form'),
                    ),
                    const SizedBox(height: 12),
                    FilledButton(
                      onPressed: () async {
                        await FirebaseService.signOut();
                        if (!context.mounted) return;
                        Navigator.of(context).pushAndRemoveUntil(
                          MaterialPageRoute<void>(
                            builder: (_) => const LoginScreen(),
                          ),
                          (r) => false,
                        );
                      },
                      child: const Text('Sign out'),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        return ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 88),
          children: [
            GlassCard(
              borderRadius: 20,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    MemberAvatar(alumni: alum, radius: 40),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            alum.memberName,
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          Text(
                            user.email ?? '',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                          if (alum.displaySubtitle.isNotEmpty)
                            Text(
                              alum.displaySubtitle,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurfaceVariant,
                                  ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            GlassCard(
              borderRadius: 20,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _ProfileTile(
                      Icons.business_rounded,
                      'Company',
                      alum.companyName,
                    ),
                    _ProfileTile(Icons.badge_rounded, 'Role', alum.position),
                    _ProfileTile(
                      Icons.phone_rounded,
                      'Phone',
                      alum.contactNumber,
                    ),
                    _ProfileTile(Icons.email_rounded, 'Listed email', alum.email),
                    const SizedBox(height: 16),
                    FilledButton.icon(
                      onPressed: () {
                        Navigator.of(context).push<void>(
                          MaterialPageRoute<void>(
                            builder: (_) =>
                                AlumniMemberFormScreen(editingAlumni: alum),
                          ),
                        );
                      },
                      icon: const Icon(Icons.edit_rounded),
                      label: const Text('Edit profile'),
                    ),
                    const SizedBox(height: 12),
                    OutlinedButton.icon(
                      onPressed: () {
                        Navigator.of(context).push<void>(
                          MaterialPageRoute<void>(
                            builder: (_) => const AlumniMemberFormScreen(),
                          ),
                        );
                      },
                      icon: const Icon(Icons.group_add_rounded),
                      label: const Text('Add directory member'),
                    ),
                    const SizedBox(height: 12),
                    TextButton(
                      onPressed: () async {
                        await FirebaseService.signOut();
                        if (!context.mounted) return;
                        Navigator.of(context).pushAndRemoveUntil(
                          MaterialPageRoute<void>(
                            builder: (_) => const LoginScreen(),
                          ),
                          (r) => false,
                        );
                      },
                      child: const Text('Sign out'),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Profile error: $e')),
    );
  }
}

class _ProfileTile extends StatelessWidget {
  const _ProfileTile(this.icon, this.label, this.value);

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    if (value.isEmpty) return const SizedBox.shrink();
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, size: 22),
      title: Text(label, style: Theme.of(context).textTheme.labelMedium),
      subtitle: Text(value),
    );
  }
}
