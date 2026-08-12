import 'package:flutter/material.dart';

import '../../core/router.dart';

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

/// Small helpers shared by the screens; formatting is a View concern.
String formatDays(Duration duration) {
  final days = duration.inMinutes / 1440;
  if (days >= 1) return '${days.toStringAsFixed(1)} dia${days >= 2 ? 's' : ''}';
  final hours = duration.inMinutes / 60;
  if (hours >= 1) return '${hours.toStringAsFixed(0)} h';
  return '${duration.inMinutes} min';
}

/// A time on a card, or an em dash when there is nothing measured yet. Shared
/// by the average-time tile and the expanded subject map, so the two never
/// print the same duration differently.
String formatSeconds(Duration? duration) {
  if (duration == null) return '—';
  return '${(duration.inMilliseconds / 1000).toStringAsFixed(1)} s';
}

String formatDate(DateTime date) =>
    '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}';

String formatClock(Duration duration) {
  final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
  final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
  return '$minutes:$seconds';
}
