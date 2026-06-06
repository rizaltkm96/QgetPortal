import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:qget_portal/models/alumni_model.dart';
import 'package:qget_portal/widgets/member_avatar.dart';
import 'package:qget_portal/widgets/app_gradient_background.dart';
import 'package:qget_portal/widgets/glass.dart';

class AlumniProfileScreen extends StatelessWidget {
  const AlumniProfileScreen({super.key, required this.alumni});

  final AlumniModel alumni;

  @override
  Widget build(BuildContext context) {
    return AppGradientBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: Text(alumni.memberName.isNotEmpty ? alumni.memberName : 'Alumni'),
        ),
        body: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            GlassPanel(
              borderRadius: 24,
              padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
              child: Column(
                children: [
                  MemberAvatar(alumni: alumni, radius: 48),
                  const SizedBox(height: 16),
                  Text(
                    alumni.memberName.isNotEmpty ? alumni.memberName : alumni.email,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  if (alumni.displaySubtitle.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(
                      alumni.displaySubtitle,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 20),
            _row(context, 'Email', alumni.email),
            _row(context, 'Company', alumni.companyName),
            _row(context, 'Position', alumni.position),
            _row(context, 'Phone', alumni.contactNumber),
            _row(context, 'WhatsApp', alumni.whatsappNumber),
            _row(context, 'Blood group', alumni.bloodGroup),
            _row(context, 'Social / website', alumni.socialMediaLink),
            _row(context, 'Spouse', alumni.spouseName),
            _row(context, 'Spouse is member', alumni.spouseIsMember),
            _row(context, 'UID', alumni.uidField),
            _row(context, 'EF number', alumni.efNumber),
            _row(context, 'Image file', alumni.imageName),
            _rowSelectableUrl(context, 'Photo URL', alumni.imgUrl),
            ..._childRows(context),
            _row(context, 'Created', alumni.createdAt),
            _row(context, 'Last updated', alumni.updatedAtFormatted),
          ],
        ),
      ),
    );
  }

  List<Widget> _childRows(BuildContext context) {
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
          return alumni.child1Name;
        case 2:
          return alumni.child2Name;
        case 3:
          return alumni.child3Name;
        case 4:
          return alumni.child4Name;
        default:
          return '';
      }
    }

    String dobFor(int n) {
      switch (n) {
        case 1:
          return alumni.child1Dob;
        case 2:
          return alumni.child2Dob;
        case 3:
          return alumni.child3Dob;
        case 4:
          return alumni.child4Dob;
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
