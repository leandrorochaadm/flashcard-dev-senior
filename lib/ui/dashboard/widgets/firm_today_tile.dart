import 'package:flutter/material.dart';

/// "Quantos cartões você firmou hoje" — the number that moves every day and
/// carries the sense of progress in real time.
///
/// The count arrives from `ProgressStats.firmedToday`: this widget never
/// inspects `stability`.
class FirmTodayTile extends StatelessWidget {
  const FirmTodayTile({required this.firmedToday, super.key});

  final int firmedToday;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Firmaram hoje', style: theme.textTheme.labelLarge),
            const SizedBox(height: 8),
            Text('$firmedToday', style: theme.textTheme.displaySmall),
            const SizedBox(height: 4),
            Text(
              firmedToday == 1
                  ? 'cartão que você lembraria daqui a uma semana'
                  : 'cartões que você lembraria daqui a uma semana',
              style: theme.textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}
