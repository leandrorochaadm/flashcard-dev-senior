import 'package:flutter/material.dart';

import '../../../domain/stats/progress_stats.dart';
import '../../shared/app_scaffold.dart';

/// "Quanto vem pela frente": one bar per day of the next seven.
///
/// The bars arrive from `ProgressStats.loadForecast`, which reads
/// `DueCardsPolicy.forecast`. The widget only scales them to the tallest one.
class LoadForecastChart extends StatelessWidget {
  const LoadForecastChart({required this.bars, super.key});

  final List<LoadBar> bars;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tallest = bars.fold(0, (max, bar) => bar.cards > max ? bar.cards : max);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Carga dos próximos 7 dias',
                style: theme.textTheme.titleMedium),
            const SizedBox(height: 4),
            Text(
              'Quantos cartões estão marcados para cada dia.',
              style: theme.textTheme.bodySmall,
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 160,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  for (final bar in bars)
                    Expanded(
                      child: _Bar(
                        bar: bar,
                        // Scaling to the tallest bar is drawing, not a rule.
                        fraction: tallest == 0 ? 0 : bar.cards / tallest,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Bar extends StatelessWidget {
  const _Bar({required this.bar, required this.fraction});

  final LoadBar bar;
  final double fraction;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Text('${bar.cards}', style: theme.textTheme.labelSmall),
          const SizedBox(height: 4),
          Expanded(
            child: FractionallySizedBox(
              alignment: Alignment.bottomCenter,
              heightFactor: fraction.clamp(0.02, 1.0),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(4),
                  ),
                ),
                child: const SizedBox.expand(),
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(formatDate(bar.day), style: theme.textTheme.labelSmall),
        ],
      ),
    );
  }
}
