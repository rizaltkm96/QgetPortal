import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:qget_portal/providers/ui_state_providers.dart';
import 'package:qget_portal/widgets/app_gradient_background.dart';
import 'package:qget_portal/widgets/glass.dart';

class CreatePostScreen extends ConsumerWidget {
  const CreatePostScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ui = ref.watch(createPostNotifierProvider);
    final n = ref.read(createPostNotifierProvider.notifier);

    return AppGradientBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(title: const Text('New post')),
        body: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            GlassPanel(
              borderRadius: 22,
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextField(
                    controller: n.content,
                    maxLines: 6,
                    decoration: const InputDecoration(
                      labelText: 'What\'s on your mind?',
                      alignLabelWithHint: true,
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: n.imageUrl,
                    decoration: const InputDecoration(
                      labelText: 'Image URL (optional)',
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            GradientFilledButton(
              onPressed: ui.busy ? null : () => n.submit(context),
              busy: ui.busy,
              label: 'Publish',
            ),
          ],
        ),
      ),
    );
  }
}
