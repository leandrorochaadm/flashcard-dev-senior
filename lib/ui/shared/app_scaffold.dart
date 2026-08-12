import 'package:flutter/material.dart';

import '../../core/router.dart';
// Re-exported so every screen that already imports the scaffold keeps getting
// `formatDate` and friends; the widgets that need only formatting import
// `formatting.dart` directly and stay off the router.
export 'formatting.dart';

/// Shared chrome: title, back arrow and the navigation the four windows use.
class AppScaffold extends StatelessWidget {
  const AppScaffold({
    required this.title,
    required this.child,
    this.actions,
    this.showNavigation = false,
    super.key,
  });

  final String title;
  final Widget child;
  final List<Widget>? actions;
  final bool showNavigation;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title), actions: actions),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 880),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: child,
            ),
          ),
        ),
      ),
      bottomNavigationBar: showNavigation ? const _AppNavigation() : null,
    );
  }
}

class _AppNavigation extends StatelessWidget {
  const _AppNavigation();

  @override
  Widget build(BuildContext context) {
    final current = ModalRoute.of(context)?.settings.name;
    void go(String route) {
      if (route != current) Navigator.of(context).pushNamed(route);
    }

    return NavigationBar(
      selectedIndex: switch (current) {
        AppRoutes.session => 1,
        AppRoutes.import => 2,
        AppRoutes.cards => 3,
        _ => 0,
      },
      onDestinationSelected: (index) => go(switch (index) {
        1 => AppRoutes.session,
        2 => AppRoutes.import,
        3 => AppRoutes.cards,
        _ => AppRoutes.dashboard,
      }),
      destinations: const [
        NavigationDestination(icon: Icon(Icons.insights), label: 'Painel'),
        NavigationDestination(icon: Icon(Icons.play_arrow), label: 'Estudar'),
        NavigationDestination(icon: Icon(Icons.file_download), label: 'Importar'),
        NavigationDestination(icon: Icon(Icons.style), label: 'Cartões'),
      ],
    );
  }
}
