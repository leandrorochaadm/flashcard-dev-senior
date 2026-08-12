import 'package:flutter/material.dart';

import '../../../domain/policies/time_on_card_policy.dart';
import '../../../domain/stats/progress_stats.dart';
import '../../shared/app_scaffold.dart';

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
              formatSeconds(stats.overall),
              style: theme.textTheme.headlineMedium,
            ),
            const SizedBox(height: 4),
            // Derived from the policy, not written by hand: the ceiling moved
            // from 60 s to 120 s and this line kept saying "1 minuto".
            // Importing a policy constant is reading, not deciding — the
            // discarding happens in `TimeOnCardPolicy.timeToRecord`, when the
            // log is written.
            Text(
              'Respostas acima de ${TimeOnCardPolicy.ceiling.inSeconds} s '
              'ficam de fora da média.',
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
                        formatSeconds(stats.bySubject[subject]),
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
}
