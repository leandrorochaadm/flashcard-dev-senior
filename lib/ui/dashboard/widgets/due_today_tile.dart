import 'package:flutter/material.dart';

/// "Vencendo hoje": the fourth tile of the compact strip.
///
/// Public, and not a private class inside the View, because the overflow test
/// at 360 points mounts the four tiles on their own — a private widget would
/// only be reachable by building the whole dashboard, with every repository
/// fake that implies.
///
/// Both numbers arrive ready from `CollectionOverview`; the widget neither
/// filters nor counts anything.
class DueTodayTile extends StatelessWidget {
  const DueTodayTile({required this.cards, required this.subjects, super.key});

  final int cards;
  final int subjects;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Vencendo hoje', style: theme.textTheme.labelLarge),
            const SizedBox(height: 8),
            Text('$cards', style: theme.textTheme.displaySmall),
            const SizedBox(height: 4),
            Text(
              cards == 0
                  ? 'Nada vencendo hoje.'
                  : subjects == 1
                      ? '1 assunto com fila'
                      : '$subjects assuntos com fila',
              style: theme.textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}
