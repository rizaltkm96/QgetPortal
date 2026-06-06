import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:qget_portal/providers/ui_state_providers.dart';
import 'package:qget_portal/widgets/app_gradient_background.dart';
import 'package:qget_portal/widgets/glass.dart';

class AlumniMemberFormScreen extends ConsumerWidget {
  const AlumniMemberFormScreen({super.key});

  static Widget _sectionTitle(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, top: 4),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w700,
              color: Theme.of(context).colorScheme.primary,
            ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ui = ref.watch(memberFormNotifierProvider);
    final n = ref.read(memberFormNotifierProvider.notifier);

    return AppGradientBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(title: const Text('Add directory member')),
        body: Form(
          key: n.formKey,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
            children: [
              GlassPanel(
                borderRadius: 22,
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _sectionTitle(context, 'Identity & work'),
                    TextFormField(
                      controller: n.name,
                      textCapitalization: TextCapitalization.words,
                      decoration: const InputDecoration(
                        labelText: 'Member name *',
                      ),
                      validator: (v) =>
                          (v == null || v.trim().isEmpty) ? 'Required' : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: n.email,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                        labelText: 'Email *',
                      ),
                      validator: (v) => (v == null || !v.contains('@'))
                          ? 'Valid email required'
                          : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: n.year,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Graduation year',
                        hintText: 'e.g. 1990',
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: n.branch,
                      textCapitalization: TextCapitalization.words,
                      decoration: const InputDecoration(
                        labelText: 'Branch / department',
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: n.company,
                      textCapitalization: TextCapitalization.words,
                      decoration: const InputDecoration(
                        labelText: 'Company',
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: n.position,
                      textCapitalization: TextCapitalization.words,
                      decoration: const InputDecoration(
                        labelText: 'Position / role',
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              GlassPanel(
                borderRadius: 22,
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _sectionTitle(context, 'Contact & photo'),
                    TextFormField(
                      controller: n.contact,
                      keyboardType: TextInputType.phone,
                      decoration: const InputDecoration(
                        labelText: 'Contact number',
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: n.whatsapp,
                      keyboardType: TextInputType.phone,
                      decoration: const InputDecoration(
                        labelText: 'WhatsApp number',
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: n.blood,
                      decoration: const InputDecoration(
                        labelText: 'Blood group',
                        hintText: 'e.g. O positive',
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: n.social,
                      keyboardType: TextInputType.url,
                      decoration: const InputDecoration(
                        labelText: 'Social / website link',
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: n.imgUrl,
                      keyboardType: TextInputType.url,
                      maxLines: 2,
                      decoration: const InputDecoration(
                        labelText: 'Photo URL (ImgURL)',
                        alignLabelWithHint: true,
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: n.imageName,
                      decoration: const InputDecoration(
                        labelText: 'Image file name',
                        hintText: 'e.g. Photo.jpeg',
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              GlassPanel(
                borderRadius: 22,
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _sectionTitle(context, 'Spouse'),
                    TextFormField(
                      controller: n.spouseName,
                      textCapitalization: TextCapitalization.words,
                      decoration: const InputDecoration(
                        labelText: 'Spouse name',
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: n.spouseIsMember,
                      decoration: const InputDecoration(
                        labelText: 'Spouse is alum member?',
                        hintText: 'yes / no (optional)',
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              GlassPanel(
                borderRadius: 22,
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _sectionTitle(context, 'Children'),
                    TextFormField(
                      controller: n.child1Name,
                      decoration: const InputDecoration(
                        labelText: 'Child 1 name',
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: n.child1Dob,
                      decoration: const InputDecoration(
                        labelText: 'Child 1 DOB',
                        hintText: 'yyyy-mm-dd',
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: n.child2Name,
                      decoration: const InputDecoration(
                        labelText: 'Child 2 name',
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: n.child2Dob,
                      decoration: const InputDecoration(
                        labelText: 'Child 2 DOB',
                        hintText: 'yyyy-mm-dd',
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: n.child3Name,
                      decoration: const InputDecoration(
                        labelText: 'Child 3 name',
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: n.child3Dob,
                      decoration: const InputDecoration(
                        labelText: 'Child 3 DOB',
                        hintText: 'yyyy-mm-dd',
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: n.child4Name,
                      decoration: const InputDecoration(
                        labelText: 'Child 4 name',
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: n.child4Dob,
                      decoration: const InputDecoration(
                        labelText: 'Child 4 DOB',
                        hintText: 'yyyy-mm-dd',
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              GlassPanel(
                borderRadius: 22,
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _sectionTitle(context, 'IDs (optional)'),
                    TextFormField(
                      controller: n.uid,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'UID',
                        hintText: 'Numeric ID if used',
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: n.efNumber,
                      decoration: const InputDecoration(
                        labelText: 'EF number',
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              GradientFilledButton(
                onPressed: ui.busy ? null : () => n.submit(context),
                busy: ui.busy,
                label: 'Save to roster',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
