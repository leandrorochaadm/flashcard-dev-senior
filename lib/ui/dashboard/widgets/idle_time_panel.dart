import 'package:flutter/material.dart';

/// H12: the day is cleared. Nothing is due and nothing may be anticipated —
/// `DueCardsPolicy.isDayCleared` decided that, not this widget.
///
/// The three ways out sit side by side, because the requirement is that the
/// app offers something to do instead of a blank screen.
class IdleTimePanel extends StatelessWidget {
  const IdleTimePanel({
    required this.onImportMore,
    required this.onMockInterview,
    required this.onWeakSubjects,
    super.key,
  });

  final VoidCallback onImportMore;
  final VoidCallback onMockInterview;
  final VoidCallback onWeakSubjects;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      color: theme.colorScheme.secondaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Você está em dia', style: theme.textTheme.titleMedium),
            const SizedBox(height: 4),
            Text(
              'Não há cartões esperando por hoje. Adiantar os de amanhã '
              'desmontaria o espaçamento, então escolha um dos três:',
              style: theme.textTheme.bodySmall,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: FilledButton(
                    onPressed: onImportMore,
                    child: const Text('Importar mais perguntas'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: FilledButton.tonal(
                    onPressed: onMockInterview,
                    child: const Text('Fazer um simulado'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton(
                    onPressed: onWeakSubjects,
                    child: const Text('Ver os assuntos fracos'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
