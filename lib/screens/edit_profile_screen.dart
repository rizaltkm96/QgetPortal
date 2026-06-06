import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:qget_portal/models/alumni_model.dart';
import 'package:qget_portal/providers/ui_state_providers.dart';
import 'package:qget_portal/widgets/app_gradient_background.dart';
import 'package:qget_portal/widgets/glass.dart';

class EditProfileScreen extends StatelessWidget {
  const EditProfileScreen({super.key, required this.alumni});

  final AlumniModel alumni;

  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      overrides: [
        editProfileAlumniProvider.overrideWithValue(alumni),
      ],
      child: const _EditProfileBody(),
    );
  }
}

class _EditProfileBody extends ConsumerWidget {
  const _EditProfileBody();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ui = ref.watch(editProfileNotifierProvider);
    final n = ref.read(editProfileNotifierProvider.notifier);

    return AppGradientBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(title: const Text('Edit profile')),
        body: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            GlassPanel(
              borderRadius: 22,
              padding: const EdgeInsets.all(18),
              child: Column(
                children: [
                  TextField(
                    controller: n.name,
                    decoration: const InputDecoration(labelText: 'Name'),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: n.company,
                    decoration: const InputDecoration(labelText: 'Company'),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: n.position,
                    decoration: const InputDecoration(labelText: 'Position'),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: n.phone,
                    decoration: const InputDecoration(
                      labelText: 'Contact number',
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: n.img,
                    decoration: const InputDecoration(labelText: 'Photo URL'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            GradientFilledButton(
              onPressed: ui.busy ? null : () => n.save(context),
              busy: ui.busy,
              label: 'Save',
            ),
          ],
        ),
      ),
    );
  }
}
