import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

import 'package:qget_portal/theme/app_colors.dart';
import 'package:qget_portal/widgets/glass.dart';

class ExploreTab extends StatelessWidget {
  const ExploreTab({super.key});

  static const _tiles = [
    _ExploreTile('Events', Icons.event_available_rounded, 0),
    _ExploreTile('Chapters', Icons.groups_2_rounded, 1),
    _ExploreTile('Jobs', Icons.work_outline_rounded, 2),
    _ExploreTile('Memories', Icons.photo_library_outlined, 3),
    _ExploreTile('Give back', Icons.volunteer_activism_outlined, 4),
    _ExploreTile('Resources', Icons.menu_book_rounded, 5),
  ];

  static Color _accentFor(int i) {
    const colors = [
      AppColors.instagramBluePurple,
      AppColors.instagramOrange,
      AppColors.instagramPink,
      AppColors.instagramPurple,
      AppColors.instagramOrange,
      AppColors.instagramBluePurple,
    ];
    return colors[i % colors.length];
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: MasonryGridView.count(
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        itemCount: _tiles.length,
        itemBuilder: (context, index) {
          final t = _tiles[index];
          final accent = _accentFor(t.paletteIndex);
          final h = index % 3 == 0 ? 140.0 : 100.0;
          return GlassCard(
            borderRadius: 18,
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('${t.title} — coming soon')),
              );
            },
            child: SizedBox(
              height: h,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(t.icon, color: accent, size: 32),
                    const Spacer(),
                    Text(
                      t.title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _ExploreTile {
  const _ExploreTile(this.title, this.icon, this.paletteIndex);
  final String title;
  final IconData icon;
  final int paletteIndex;
}
