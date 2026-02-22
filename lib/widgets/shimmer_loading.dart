import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../theme/app_theme.dart';

class ShimmerCircle extends StatelessWidget {
  final double size;

  const ShimmerCircle({super.key, required this.size});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColors.elevatedDark,
      highlightColor: AppColors.borderDark,
      child: Container(
        width: size,
        height: size,
        decoration: const BoxDecoration(
          color: AppColors.elevatedDark,
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}

class ShimmerBox extends StatelessWidget {
  final double? width;
  final double? height;
  final double borderRadius;

  const ShimmerBox({
    super.key,
    this.width,
    this.height,
    this.borderRadius = 8,
  });

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColors.elevatedDark,
      highlightColor: AppColors.borderDark,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: AppColors.elevatedDark,
          borderRadius: BorderRadius.circular(borderRadius),
        ),
      ),
    );
  }
}

class ShimmerPostCard extends StatelessWidget {
  const ShimmerPostCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColors.elevatedDark,
      highlightColor: AppColors.borderDark,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: Row(
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: const BoxDecoration(
                      color: AppColors.elevatedDark,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 120,
                        height: 12,
                        decoration: BoxDecoration(
                          color: AppColors.elevatedDark,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        width: 80,
                        height: 10,
                        decoration: BoxDecoration(
                          color: AppColors.elevatedDark,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            // Image
            Container(
              width: double.infinity,
              height: 300,
              color: AppColors.elevatedDark,
            ),
            const SizedBox(height: 10),
            // Actions
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: Row(
                children: List.generate(
                  3,
                  (i) => Padding(
                    padding: const EdgeInsets.only(right: 14),
                    child: Container(
                      width: 26,
                      height: 26,
                      decoration: BoxDecoration(
                        color: AppColors.elevatedDark,
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: Container(
                width: 200,
                height: 12,
                decoration: BoxDecoration(
                  color: AppColors.elevatedDark,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
