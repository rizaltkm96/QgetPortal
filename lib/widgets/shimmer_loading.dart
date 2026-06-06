import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

import 'package:qget_portal/theme/theme_extensions.dart';

class ShimmerLoading extends StatelessWidget {
  const ShimmerLoading({
    super.key,
    this.count = 6,
  });

  final int count;

  @override
  Widget build(BuildContext context) {
    final style = context.appStyle;
    final base = style.imitationGlassFill.withValues(alpha: 0.65);
    final hi = style.imitationGlassBorder.withValues(alpha: 0.9);

    return Shimmer.fromColors(
      baseColor: base,
      highlightColor: hi,
      child: Column(
        children: List.generate(
          count,
          (i) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        height: 14,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        height: 12,
                        width: 160,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
