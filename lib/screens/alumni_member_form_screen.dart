import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:qget_portal/models/alumni_model.dart';
import 'package:qget_portal/providers/ui_state_providers.dart';
import 'package:qget_portal/widgets/app_gradient_background.dart';
import 'package:qget_portal/widgets/glass.dart';

class AlumniMemberFormScreen extends StatelessWidget {
  const AlumniMemberFormScreen({super.key, this.editingAlumni});

  final AlumniModel? editingAlumni;

  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      overrides: [
        if (editingAlumni != null)
          memberFormAlumniProvider.overrideWithValue(editingAlumni),
      ],
      child: const _AlumniMemberFormBody(),
    );
  }
}

class _AlumniMemberFormBody extends ConsumerWidget {
  const _AlumniMemberFormBody();

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

  static Widget _dateField(
    BuildContext context, {
    required TextEditingController controller,
    required String label,
    required Future<void> Function() onPick,
  }) {
    return TextFormField(
      controller: controller,
      readOnly: true,
      decoration: InputDecoration(
        labelText: label,
        hintText: 'dd-MM-yyyy',
        suffixIcon: IconButton(
          icon: const Icon(Icons.calendar_today_outlined),
          onPressed: onPick,
        ),
      ),
      onTap: onPick,
    );
  }

  static Widget _spouseMemberRadios(
    BuildContext context,
    MemberFormUi ui,
    MemberFormNotifier n,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Is your spouse a QGET member?',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        RadioListTile<bool>(
          title: const Text('Yes'),
          value: true,
          groupValue: ui.spouseIsQgetMember,
          contentPadding: EdgeInsets.zero,
          onChanged: n.setSpouseIsQgetMember,
        ),
        RadioListTile<bool>(
          title: const Text('No'),
          value: false,
          groupValue: ui.spouseIsQgetMember,
          contentPadding: EdgeInsets.zero,
          onChanged: n.setSpouseIsQgetMember,
        ),
      ],
    );
  }

  static Widget _standaloneSuccess(
    BuildContext context,
    MemberFormNotifier n,
  ) {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        GlassPanel(
          borderRadius: 24,
          padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
          child: Column(
            children: [
              Icon(
                Icons.check_circle_rounded,
                size: 72,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(height: 20),
              Text(
                'Registration successful',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 12),
              Text(
                'Your details have been submitted to the QGET alumni directory. '
                'Thank you for registering.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),
              const SizedBox(height: 28),
              GradientFilledButton(
                onPressed: n.resetStandaloneForm,
                label: 'Submit another registration',
              ),
            ],
          ),
        ),
      ],
    );
  }

  static Widget _standaloneErrorBanner(BuildContext context, String message) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: GlassPanel(
        borderRadius: 16,
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              Icons.error_outline_rounded,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Registration failed',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          color: Theme.of(context).colorScheme.error,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(message, style: Theme.of(context).textTheme.bodySmall),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ui = ref.watch(memberFormNotifierProvider);
    final n = ref.read(memberFormNotifierProvider.notifier);
    final imageNamePreview = n.previewImageName();
    final isEditing = ref.watch(memberFormAlumniProvider) != null;
    final standalone = ref.watch(memberFormStandaloneProvider);

    final title = standalone
        ? 'Join QGET Alumni'
        : isEditing
            ? 'Edit member'
            : 'Add directory member';
    final submitLabel = standalone
        ? 'Submit registration'
        : isEditing
            ? 'Save changes'
            : 'Save to roster';

    return AppGradientBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          automaticallyImplyLeading: !standalone,
          title: Text(title),
        ),
        body: standalone && ui.submitSuccess
            ? _standaloneSuccess(context, n)
            : Form(
          key: n.formKey,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
            children: [
              if (standalone) ...[
                Text(
                  'New members — please fill in your details below.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                ),
                const SizedBox(height: 16),
              ],
              if (standalone && ui.submitError != null)
                _standaloneErrorBanner(context, ui.submitError!),
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
                        helperText:
                            'Use semicolon to separate multiple media links',
                      ),
                    ),
                    const SizedBox(height: 16),
                    OutlinedButton.icon(
                      onPressed: ui.busy ? null : () => n.pickPhoto(context),
                      icon: const Icon(Icons.upload_file_outlined),
                      label: const Text('Choose photo'),
                    ),
                    if (ui.pickedPhotoLabel != null) ...[
                      const SizedBox(height: 8),
                      Text(
                        'Selected: ${ui.pickedPhotoLabel}',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                    if (imageNamePreview != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        'Image name: $imageNamePreview',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context).colorScheme.primary,
                            ),
                      ),
                    ],
                    const SizedBox(height: 4),
                    Text(
                      'Photo is not uploaded yet. Only the image file name is saved.',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withValues(alpha: 0.7),
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
                    _spouseMemberRadios(context, ui, n),
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
                    _dateField(
                      context,
                      controller: n.child1Dob,
                      label: 'Child 1 DOB',
                      onPick: () => n.pickChildDob(context, n.child1Dob),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: n.child2Name,
                      decoration: const InputDecoration(
                        labelText: 'Child 2 name',
                      ),
                    ),
                    const SizedBox(height: 8),
                    _dateField(
                      context,
                      controller: n.child2Dob,
                      label: 'Child 2 DOB',
                      onPick: () => n.pickChildDob(context, n.child2Dob),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: n.child3Name,
                      decoration: const InputDecoration(
                        labelText: 'Child 3 name',
                      ),
                    ),
                    const SizedBox(height: 8),
                    _dateField(
                      context,
                      controller: n.child3Dob,
                      label: 'Child 3 DOB',
                      onPick: () => n.pickChildDob(context, n.child3Dob),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: n.child4Name,
                      decoration: const InputDecoration(
                        labelText: 'Child 4 name',
                      ),
                    ),
                    const SizedBox(height: 8),
                    _dateField(
                      context,
                      controller: n.child4Dob,
                      label: 'Child 4 DOB',
                      onPick: () => n.pickChildDob(context, n.child4Dob),
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
                    _sectionTitle(context, 'Membership (optional)'),
                    TextFormField(
                      controller: n.efNumber,
                      decoration: const InputDecoration(
                        labelText: 'EF membership number',
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              GradientFilledButton(
                onPressed: ui.busy ? null : () => n.submit(context),
                busy: ui.busy,
                label: submitLabel,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
