import 'package:flutter/material.dart';

import '../../../domain/stats/progress_stats.dart';

/// The subject map: where you are strong and where you are weak.
///
/// The list arrives sorted worst-first from `ProgressStats.subjectMap` — this
/// widget never sorts, counts or divides.
class SubjectMap extends StatelessWidget {
  const SubjectMap({
    required this.subjects,
    required this.onSubjectTap,
    super.key,
  });

  final List<SubjectProgress> subjects;
  final void Function(String subject) onSubjectTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Mapa por assunto', style: theme.textTheme.titleMedium),
            const SizedBox(height: 4),
            Text(
              'Do mais fraco para o mais forte.',
              style: theme.textTheme.bodySmall,
            ),
            const SizedBox(height: 12),
            if (subjects.isEmpty)
              const Text('Nenhum assunto liberado para estudo ainda.')
            else
              for (final subject in subjects)
                _SubjectRow(
                  progress: subject,
                  onTap: () => onSubjectTap(subject.subject),
                ),
          ],
        ),
      ),
    );
  }
}

class _SubjectRow extends StatelessWidget {
  const _SubjectRow({required this.progress, required this.onTap});

  final SubjectProgress progress;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(progress.subject,
                      style: theme.textTheme.bodyLarge),
                ),
                Text(
                  '${progress.ready}/${progress.total} prontos',
                  style: theme.textTheme.bodySmall,
                ),
              ],
            ),
            const SizedBox(height: 6),
            LinearProgressIndicator(value: progress.readyRatio),
            const SizedBox(height: 4),
            Text(
              '${progress.firm} firmes · ${progress.stuck} travados',
              style: theme.textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}
