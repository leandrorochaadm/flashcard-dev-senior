import 'package:flutter/material.dart';

import '../../../domain/stats/collection_overview.dart';
import 'firmed_sparkline.dart';

/// "Quantos cartões você firmou hoje" — the number that moves every day and
/// carries the sense of progress in real time.
///
/// The count arrives from `ProgressStats.firmedSummary`: this widget never
/// inspects `stability`. Neither does it compute the average it compares
/// against — [average] arrives ready from the same call, because an average is
/// an indicator. Comparing two finished numbers is display; computing the
/// second one would not be.
class FirmTodayTile extends StatelessWidget {
  const FirmTodayTile({
    required this.firmedToday,
    required this.series,
    required this.average,
    super.key,
  });

  final int firmedToday;
  final List<FirmedDay> series;
  final double average;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
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
            const SizedBox(height: 8),
            FirmedSparkline(series: series),
            const SizedBox(height: 4),
            Text(_comparison, style: theme.textTheme.bodySmall),
          ],
        ),
      ),
    );
  }

  String get _comparison {
    if (firmedToday > average) return 'acima da média dos últimos 7 dias';
    if (firmedToday < average) return 'abaixo da média dos últimos 7 dias';
    return 'na média dos últimos 7 dias';
  }
}
