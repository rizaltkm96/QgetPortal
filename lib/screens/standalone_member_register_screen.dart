import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:qget_portal/providers/ui_state_providers.dart';
import 'package:qget_portal/screens/alumni_member_form_screen.dart';

/// Public entry point: form only, no portal navigation.
/// Web URL: `/QgetPortal/register` or `/QgetPortal/add-member`
class StandaloneMemberRegisterScreen extends StatelessWidget {
  const StandaloneMemberRegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      overrides: [
        memberFormStandaloneProvider.overrideWithValue(true),
      ],
      child: const AlumniMemberFormScreen(),
    );
  }
}
