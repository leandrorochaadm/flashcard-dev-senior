import 'package:flutter/material.dart';

import '../../shared/app_scaffold.dart';

/// H13: the target date arrived.
///
/// The app never goes on silently — either a new date is picked on a calendar
/// or the schedule keeps running on the floor of one day, and the choice is
/// recorded so the question stops being asked.
///
/// The ceiling a candidate date would produce comes from
/// `MovingCeiling.forCandidateTarget` through [ceilingFor]. No arithmetic
/// happens here.
class DeadlineBanner extends StatelessWidget {
  const DeadlineBanner({
    required this.targetDate,
    required this.daysToTarget,
    required this.ceilingToday,
    required this.deadlineReached,
    required this.ceilingFor,
    required this.onPickTarget,
    required this.onKeep,
    super.key,
  });

  final DateTime targetDate;
  final int daysToTarget;
  final Duration ceilingToday;

  /// True only while the H13 question is still unanswered.
  final bool deadlineReached;
  final Duration Function(DateTime candidate) ceilingFor;
  final Future<void> Function(DateTime target) onPickTarget;
  final Future<void> Function() onKeep;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (!deadlineReached) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  'Data-alvo: ${formatDate(targetDate)} — faltam '
                  '$daysToTarget dias. Hoje os cartões voltam, no máximo, '
                  'a cada ${formatDays(ceilingToday)}.',
                  style: theme.textTheme.bodyMedium,
                ),
              ),
              TextButton(
                onPressed: () => _pick(context),
                child: const Text('Remarcar'),
              ),
            ],
          ),
        ),
      );
    }

    return Card(
      color: theme.colorScheme.errorContainer,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Chegou a data-alvo', style: theme.textTheme.titleMedium),
            const SizedBox(height: 4),
            Text(
              'A entrevista era ${formatDate(targetDate)}. Quer marcar uma '
              'nova data ou seguir revisando todo dia?',
              style: theme.textTheme.bodySmall,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                FilledButton(
                  onPressed: () => _pick(context),
                  child: const Text('Marcar nova data'),
                ),
                const SizedBox(width: 8),
                OutlinedButton(
                  onPressed: () => onKeep(),
                  child: const Text('Seguir revisando todo dia'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pick(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: targetDate,
      firstDate: targetDate,
      lastDate: targetDate.add(const Duration(days: 365)),
      helpText: 'Nova data-alvo',
    );
    if (picked == null || !context.mounted) return;

    final ceiling = ceilingFor(picked);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text('Nova data: ${formatDate(picked)}'),
        content: Text(
          'Com essa data, os cartões voltam a cada '
          '${formatDays(ceiling)}, no máximo.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Confirmar'),
          ),
        ],
      ),
    );
    if (confirmed ?? false) await onPickTarget(picked);
  }
}
