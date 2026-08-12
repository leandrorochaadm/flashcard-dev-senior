import 'package:flutter/material.dart';

import '../../../domain/stats/progress_stats.dart';

/// Average time on a card, overall and broken down by subject.
///
/// Times over `TimeOnCardPolicy.ceiling` were already dropped when the log
/// was written, so nothing is filtered here.
class AvgTimeTile extends StatelessWidget {
  const AvgTimeTile({required this.stats, super.key});

  final TimeOnCardStats stats;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final subjects = stats.bySubject.keys.toList()..sort();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Tempo médio por cartão', style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),
            Text(
              _format(stats.overall),
              style: theme.textTheme.headlineMedium,
            ),
            const SizedBox(height: 4),
            Text(
              'Respostas acima de 1 minuto ficam de fora da média.',
              style: theme.textTheme.bodySmall,
            ),
            if (subjects.isNotEmpty) ...[
              const Divider(height: 24),
              for (final subject in subjects)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(subject, style: theme.textTheme.bodyMedium),
                      ),
                      Text(
                        _format(stats.bySubject[subject]),
                        style: theme.textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }

  static String _format(Duration? duration) {
    if (duration == null) return '—';
    final seconds = duration.inMilliseconds / 1000;
    return '${seconds.toStringAsFixed(1)} s';
  }
}
