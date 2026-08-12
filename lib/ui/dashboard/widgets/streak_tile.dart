import 'package:flutter/material.dart';

import '../../../domain/stats/collection_overview.dart';

/// "Estou mantendo o ritmo?", answered without opening anything.
///
/// One of the four compact tiles of the metric strip, so it is born with a
/// padding of 12 and short labels: at 390 points, two tiles side by side with
/// padding 16 and `displaySmall` overflow on the word "Sequência".
///
/// There is no day-by-day strip of squares: `StudyStreak` hands over counts,
/// not which of the last seven days had study, and drawing it from the firmed
/// series would swap "days with an answer" for "days with a firmed card" —
/// another indicator, with another meaning.
class StreakTile extends StatelessWidget {
  const StreakTile({required this.streak, super.key});

  final StudyStreak streak;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Sequência', style: theme.textTheme.labelLarge),
            const SizedBox(height: 8),
            Text('${streak.current}', style: theme.textTheme.displaySmall),
            Text(
              streak.current == 1 ? 'dia seguido' : 'dias seguidos',
              style: theme.textTheme.bodySmall,
            ),
            const SizedBox(height: 8),
            Text(
              'melhor ${streak.longest} · ${streak.daysStudiedLastSeven} de 7 dias',
              style: theme.textTheme.bodySmall,
            ),
            const SizedBox(height: 4),
            Text(
              streak.studiedToday
                  ? streak.answeredToday == 1
                      ? '1 resposta hoje.'
                      : '${streak.answeredToday} respostas hoje.'
                  : 'Você ainda não respondeu nada hoje.',
              style: theme.textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}
