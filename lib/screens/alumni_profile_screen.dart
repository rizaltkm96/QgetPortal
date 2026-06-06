import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:qget_portal/models/alumni_model.dart';
import 'package:qget_portal/providers/app_providers.dart';
import 'package:qget_portal/screens/alumni_member_form_screen.dart';
import 'package:qget_portal/widgets/member_avatar.dart';
import 'package:qget_portal/widgets/app_gradient_background.dart';
import 'package:qget_portal/widgets/glass.dart';

class AlumniProfileScreen extends ConsumerWidget {
  const AlumniProfileScreen({super.key, required this.alumni});

  final AlumniModel alumni;

  AlumniModel _resolveAlumni(AsyncValue<List<AlumniModel>> async) {
    return async.maybeWhen(
      data: (all) {
        for (final member in all) {
          if (member.id == alumni.id) return member;
        }
        return alumni;
      },
      orElse: () => alumni,
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final alumniAsync = ref.watch(alumniStreamProvider);
    final current = _resolveAlumni(alumniAsync);

    return AppGradientBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: Text(
            current.memberName.isNotEmpty ? current.memberName : 'Alumni',
          ),
          actions: [
            IconButton(
              tooltip: 'Edit member',
              icon: const Icon(Icons.edit_rounded),
              onPressed: () async {
                await Navigator.of(context).push<void>(
                  MaterialPageRoute<void>(
                    builder: (_) =>
                        AlumniMemberFormScreen(editingAlumni: current),
                  ),
                );
              },
            ),
          ],
        ),
        body: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            GlassPanel(
              borderRadius: 24,
              padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
              child: Column(
                children: [
                  MemberAvatar(alumni: current, radius: 48),
                  const SizedBox(height: 16),
                  Text(
                    current.memberName.isNotEmpty
                        ? current.memberName
                        : current.email,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  if (current.displaySubtitle.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(
                      current.displaySubtitle,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color:
                                Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 20),
            _row(context, 'Email', current.email),
            _row(context, 'Company', current.companyName),
            _row(context, 'Position', current.position),
            _row(context, 'Phone', current.contactNumber),
            _row(context, 'WhatsApp', current.whatsappNumber),
            _row(context, 'Blood group', current.bloodGroup),
            _row(context, 'Social / website', current.socialMediaLink),
            _row(context, 'Spouse', current.spouseName),
            _row(context, 'Spouse is member', current.spouseIsMember),
            _row(context, 'UID', current.uidField),
            _row(context, 'EF number', current.efNumber),
            _row(context, 'Image file', current.imageName),
            _rowSelectableUrl(context, 'Photo URL', current.imgUrl),
            ..._childRows(context, current),
            _row(context, 'Created', current.createdAt),
            _row(context, 'Last updated', current.updatedAtFormatted),
          ],
        ),
      ),
    );
  }

  List<Widget> _childRows(BuildContext context, AlumniModel member) {
    final out = <Widget>[];
    const pairs = [
      (1, 'Child 1 name', 'Child 1 DOB'),
      (2, 'Child 2 name', 'Child 2 DOB'),
      (3, 'Child 3 name', 'Child 3 DOB'),
      (4, 'Child 4 name', 'Child 4 DOB'),
    ];
    String nameFor(int n) {
      switch (n) {
        case 1:
          return member.child1Name;
        case 2:
          return member.child2Name;
        case 3:
          return member.child3Name;
        case 4:
          return member.child4Name;
        default:
          return '';
      }
    }

    String dobFor(int n) {
      switch (n) {
        case 1:
          return member.child1Dob;
        case 2:
          return member.child2Dob;
        case 3:
          return member.child3Dob;
        case 4:
          return member.child4Dob;
        default:
          return '';
      }
    }

    for (final p in pairs) {
      final name = nameFor(p.$1);
      final dob = dobFor(p.$1);
      if (name.isEmpty && dob.isEmpty) continue;
      if (name.isNotEmpty) {
        out.add(_row(context, p.$2, name));
      }
      if (dob.isNotEmpty) {
        out.add(_row(context, p.$3, dob));
      }
    }
    return out;
  }

  Widget _row(BuildContext context, String k, String v) {
    if (v.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: GlassCard(
        borderRadius: 14,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 130,
                child: Text(
                  k,
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                ),
              ),
              Expanded(child: Text(v)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _rowSelectableUrl(BuildContext context, String k, String v) {
    if (v.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: GlassCard(
        borderRadius: 14,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                k,
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),
              const SizedBox(height: 8),
              SelectableText(
                v,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontFamily: 'monospace',
                    ),
              ),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton.icon(
                  onPressed: () async {
                    await Clipboard.setData(ClipboardData(text: v));
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('URL copied')),
                      );
                    }
                  },
                  icon: const Icon(Icons.copy_rounded, size: 18),
                  label: const Text('Copy URL'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
