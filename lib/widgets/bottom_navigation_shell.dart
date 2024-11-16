import 'package:flutter/material.dart';

import 'package:go_router/go_router.dart';

import 'package:mood_n_habbits/utils/get_l10n.dart';

class BottomNavigationShell extends StatelessWidget {
  final List<String> pathSegments;
  final Widget child;
  const BottomNavigationShell({
    required this.pathSegments,
    required this.child,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: pathSegments.length < 2
            ? 0
            : switch (pathSegments[1]) {
                'today' => 0,
                'habbits' => 1,
                'todos' => 2,
                'settings' => 3,
                _ => 0,
              },
        onDestinationSelected: (index) {
          switch (index) {
            case 1:
              context.go('/habbits');
            case 2:
              context.go('/todos');
            case 3:
              context.go('/settings');
            default:
              context.go('/');
          }
        },
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.today_outlined),
            selectedIcon: const Icon(Icons.today),
            label: context.l10n.today,
          ),
          NavigationDestination(
            icon: const Icon(Icons.sports_score_outlined),
            selectedIcon: const Icon(Icons.sports_score),
            label: context.l10n.habbits,
          ),
          NavigationDestination(
            icon: const Icon(Icons.check_circle_outlined),
            selectedIcon: const Icon(Icons.list),
            label: context.l10n.todos,
          ),
          NavigationDestination(
            icon: const Icon(Icons.settings_outlined),
            selectedIcon: const Icon(Icons.settings),
            label: context.l10n.settings,
          ),
        ],
      ),
    );
  }
}
