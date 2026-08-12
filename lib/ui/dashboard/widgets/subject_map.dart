import 'package:flutter/material.dart';

import '../../../domain/stats/progress_stats.dart';
import '../../shared/app_scaffold.dart';
import 'dashboard_metric_line.dart';

/// The subject map: where you are strong and where you are weak.
///
/// The list arrives sorted worst-first from `ProgressStats.subjectMap` — this
/// widget never sorts, counts or divides. Each line opens in place; the
/// `/assunto` route still exists for the accuracy history and the mock, which
/// do not fit here.
class SubjectMap extends StatelessWidget {
  const SubjectMap({
    required this.subjects,
    required this.controllerOf,
    required this.onSubjectTap,
    super.key,
  });

  final List<SubjectProgress> subjects;

  /// The controller of each subject's tile, created and kept by the View — it
  /// is how "Ver os assuntos fracos" opens the worst one without taking anybody
  /// off the screen.
  final ExpansibleController Function(String subject) controllerOf;

  final void Function(String subject) onSubjectTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Mapa por assunto', style: theme.textTheme.titleMedium),
            const SizedBox(height: 4),
            Text(
              'Do mais fraco para o mais forte. Toque para abrir o detalhe.',
              style: theme.textTheme.bodySmall,
            ),
            const SizedBox(height: 4),
            if (subjects.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: Text('Nenhum assunto liberado para estudo ainda.'),
              )
            else
              for (final subject in subjects)
                _SubjectTile(
                  progress: subject,
                  controller: controllerOf(subject.subject),
                  onOpen: () => onSubjectTap(subject.subject),
                ),
          ],
        ),
      ),
    );
  }
}

class _SubjectTile extends StatelessWidget {
  const _SubjectTile({
    required this.progress,
    required this.controller,
    required this.onOpen,
  });

  final SubjectProgress progress;
  final ExpansibleController controller;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final nextDue = progress.nextDueAt;

    return ExpansionTile(
      controller: controller,
      // No `initiallyExpanded: true` from the outside and no `PageStorageKey`:
      // both are read over the controller and would make the programmatic
      // opening unpredictable.
      initiallyExpanded: false,
      shape: const Border(),
      collapsedShape: const Border(),
      tilePadding: EdgeInsets.zero,
      childrenPadding: const EdgeInsets.only(bottom: 8),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(progress.subject, style: theme.textTheme.bodyLarge),
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
      children: [
        DashboardMetricLine(
          label: 'Vencendo hoje',
          value: '${progress.dueToday}',
        ),
        DashboardMetricLine(
          label: 'Nunca respondidos',
          value: '${progress.neverAnswered}',
        ),
        DashboardMetricLine(
          label: 'Firmes',
          value: '${progress.firm} de ${progress.total}',
        ),
        DashboardMetricLine(
          label: 'Prontos para a data-alvo',
          value: '${progress.ready} de ${progress.total}',
        ),
        DashboardMetricLine(
          label: 'Travados',
          value: '${progress.stuck}',
          valueColor:
              progress.stuck > 0 ? theme.colorScheme.error : null,
        ),
        DashboardMetricLine(
          label: 'Tempo médio',
          value: formatSeconds(progress.averageTime),
        ),
        DashboardMetricLine(
          label: 'Próximo vencimento',
          // A subject whose cards are all overdue has no "next"; the domain
          // said so with a null, and nothing is computed from the date here
          // beyond formatting it.
          value: nextDue == null ? 'tudo vencido' : formatDate(nextDue),
        ),
        Align(
          alignment: Alignment.centerRight,
          child: TextButton(
            onPressed: onOpen,
            child: const Text('Abrir o assunto'),
          ),
        ),
      ],
    );
  }
}
