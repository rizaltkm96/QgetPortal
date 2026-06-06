import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:qget_portal/providers/app_providers.dart';
import 'package:qget_portal/providers/ui_state_providers.dart';
import 'package:qget_portal/screens/alumni_directory_tab.dart';
import 'package:qget_portal/screens/explore_tab.dart';
import 'package:qget_portal/screens/feed_tab.dart';
import 'package:qget_portal/screens/profile_tab.dart';
import 'package:qget_portal/screens/create_post_screen.dart';
import 'package:qget_portal/widgets/app_gradient_background.dart';
import 'package:qget_portal/widgets/glass.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  static const _titles = ['Feed', 'Explore', 'Directory', 'Profile'];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final page = ref.watch(homeTabIndexProvider);
    final pc = ref.watch(homePageControllerProvider);
    final signedIn = ref.watch(currentUserProvider) != null;

    return AppGradientBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        extendBody: true,
        appBar: AppBar(
          title: Text(_titles[page]),
        ),
        body: PageView(
          controller: pc,
          onPageChanged: (i) =>
              ref.read(homeTabIndexProvider.notifier).state = i,
          physics: const NeverScrollableScrollPhysics(),
          children: const [
            FeedTab(),
            ExploreTab(),
            AlumniDirectoryTab(),
            ProfileTab(),
          ],
        ),
        floatingActionButton: page == 0 && signedIn
            ? InstagramGradientFab(
                onPressed: () async {
                  await Navigator.of(context).push<void>(
                    MaterialPageRoute<void>(
                      builder: (_) => const CreatePostScreen(),
                    ),
                  );
                },
                child: Icon(
                  Icons.post_add_rounded,
                  color: Theme.of(context).colorScheme.primary,
                ),
              )
            : null,
        bottomNavigationBar: NavigationBar(
          selectedIndex: page,
          onDestinationSelected: (i) {
            ref.read(homeTabIndexProvider.notifier).state = i;
            pc.jumpToPage(i);
          },
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.density_medium_outlined),
              selectedIcon: Icon(Icons.dynamic_feed_rounded),
              label: 'Feed',
            ),
            NavigationDestination(
              icon: Icon(Icons.explore_outlined),
              selectedIcon: Icon(Icons.explore_rounded),
              label: 'Explore',
            ),
            NavigationDestination(
              icon: Icon(Icons.people_outline_rounded),
              selectedIcon: Icon(Icons.people_rounded),
              label: 'Directory',
            ),
            NavigationDestination(
              icon: Icon(Icons.person_outline_rounded),
              selectedIcon: Icon(Icons.person_rounded),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}
