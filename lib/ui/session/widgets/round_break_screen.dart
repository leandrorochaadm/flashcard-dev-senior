import 'package:flutter/material.dart';

/// The turn of the round: silent, on purpose — no sound, no auto-advance.
///
/// It names the subject that ended and the one that starts, and waits for a
/// confirmation. When cards are still due in the subject that ended, it offers
/// another full round on the same subject.
class RoundBreakScreen extends StatelessWidget {
  const RoundBreakScreen({
    required this.finished,
    required this.next,
    required this.remainingDueCards,
    required this.onContinue,
    required this.onExtend,
    super.key,
  });

  final String finished;

  /// `null` on the last round: what follows is the scoreboard.
  final String? next;

  final int remainingDueCards;
  final VoidCallback onContinue;
  final VoidCallback onExtend;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final upcoming = next;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Fim do round', style: theme.textTheme.headlineSmall),
          const SizedBox(height: 12),
          Text('Terminou: $finished', style: theme.textTheme.titleMedium),
          const SizedBox(height: 4),
          Text(
            upcoming == null
                ? 'Foi o último round da sessão.'
                : 'Começa agora: $upcoming',
            style: theme.textTheme.titleMedium,
          ),
          if (remainingDueCards > 0) ...[
            const SizedBox(height: 24),
            Text(
              'Ainda restam $remainingDueCards cartões vencidos em $finished.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 8),
            OutlinedButton(
              onPressed: onExtend,
              child: Text('Estender o round de $finished'),
            ),
          ],
          const SizedBox(height: 24),
          FilledButton(
            onPressed: onContinue,
            child: Text(upcoming == null ? 'Ver o resultado' : 'Continuar'),
          ),
        ],
      ),
    );
  }
}
