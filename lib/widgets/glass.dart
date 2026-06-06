import 'dart:ui';

import 'package:flutter/material.dart';

import 'package:qget_portal/theme/app_colors.dart';
import 'package:qget_portal/theme/theme_extensions.dart';

/// Blurred frosted panel for static chrome (login card, sheets). Avoid on list items.
class GlassPanel extends StatelessWidget {
  const GlassPanel({
    super.key,
    required this.child,
    this.borderRadius = 24,
    this.strongBlur = false,
    this.padding = EdgeInsets.zero,
  });

  final Widget child;
  final double borderRadius;
  final bool strongBlur;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final style = context.appStyle;
    final sigma =
        strongBlur ? style.glassBlurSigma * 1.25 : style.glassBlurSigma;

    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: sigma, sigmaY: sigma),
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(borderRadius),
            color: style.glassFill,
            border: Border.all(color: style.glassBorder, width: 1),
          ),
          child: Padding(
            padding: padding,
            child: child,
          ),
        ),
      ),
    );
  }
}

/// Translucent “glass” without blur for scrolling lists.
class GlassCard extends StatelessWidget {
  const GlassCard({
    super.key,
    required this.child,
    this.borderRadius = 16,
    this.clipBehavior = Clip.antiAlias,
    this.onTap,
    this.margin,
  });

  final Widget child;
  final double borderRadius;
  final Clip clipBehavior;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry? margin;

  @override
  Widget build(BuildContext context) {
    final style = context.appStyle;
    return Container(
      margin: margin,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        color: style.imitationGlassFill,
        border: Border.all(color: style.imitationGlassBorder, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.18),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      clipBehavior: clipBehavior,
      child: onTap != null
          ? Material(
              type: MaterialType.transparency,
              child: InkWell(
                onTap: onTap,
                borderRadius: BorderRadius.circular(borderRadius),
                child: child,
              ),
            )
          : child,
    );
  }
}

/// FAB-sized control with Instagram-style gradient rim and dark glass center.
class InstagramGradientFab extends StatelessWidget {
  const InstagramGradientFab({
    super.key,
    required this.child,
    required this.onPressed,
    this.size = 56,
    this.outerRadius = 18,
  });

  final Widget child;
  final VoidCallback? onPressed;
  final double size;
  final double outerRadius;

  @override
  Widget build(BuildContext context) {
    final gradient = context.appStyle.instagramGradient;
    const stroke = 2.5;
    final innerRadius = outerRadius - stroke * 0.9;

    return SizedBox(
      width: size,
      height: size,
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          onTap: onPressed,
          customBorder: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(outerRadius),
          ),
          child: Ink(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(outerRadius),
              gradient: gradient,
              boxShadow: [
                BoxShadow(
                  color: AppColors.instagramPink.withValues(alpha: 0.35),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(stroke),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(innerRadius),
                  color: Theme.of(context).colorScheme.surface,
                ),
                child: Center(child: child),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Primary CTA with full brand gradient fill.
class GradientFilledButton extends StatelessWidget {
  const GradientFilledButton({
    super.key,
    required this.onPressed,
    required this.label,
    this.busy = false,
  });

  final VoidCallback? onPressed;
  final String label;
  final bool busy;

  @override
  Widget build(BuildContext context) {
    final gradient = context.appStyle.instagramGradient;

    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: AppColors.instagramPink.withValues(alpha: 0.28),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(14),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
            child: Center(
              child: busy
                  ? const SizedBox(
                      height: 22,
                      width: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Text(
                      label,
                      style: Theme.of(context)
                          .textTheme
                          .labelLarge
                          ?.copyWith(color: Colors.white, fontWeight: FontWeight.w600),
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
