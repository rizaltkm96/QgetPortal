import 'package:flutter/material.dart';

import 'package:qget_portal/theme/theme_extensions.dart';

/// Soft full-screen gradient behind glass UI.
class AppGradientBackground extends StatelessWidget {
  const AppGradientBackground({
    super.key,
    required this.child,
  });

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final grad = context.appStyle.backgroundGradient;
    return Stack(
      fit: StackFit.expand,
      children: [
        DecoratedBox(decoration: BoxDecoration(gradient: grad)),
        child,
      ],
    );
  }
}
