import 'package:flutter/material.dart';

/// H12: the day is cleared. Nothing is due and nothing may be anticipated —
/// `DueCardsPolicy.isDayCleared` decided that, not this widget.
///
/// The three ways out are stacked, because the requirement is that the app
/// offers something to do instead of a blank screen — and on the 390-point
/// phone this targets, three buttons sharing one row broke every label across
/// three lines ("Importa / r mais / pergunt / as"). The empty state of the
/// study screen already stacks the same three, so this also stops the two
/// screens disagreeing about what the way out looks like.
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
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: onImportMore,
                child: const Text('Importar mais perguntas'),
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: FilledButton.tonal(
                onPressed: onMockInterview,
                child: const Text('Fazer um simulado'),
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: onWeakSubjects,
                child: const Text('Ver os assuntos fracos'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
