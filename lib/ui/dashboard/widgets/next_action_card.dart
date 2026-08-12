import 'package:flutter/material.dart';

import '../../../domain/policies/next_action_policy.dart';

/// "Agora": the single thing to do, at the top of the dashboard.
///
/// Which of the seven sentences appears was decided by `NextActionPolicy` —
/// there is no `if` over numbers here, only a `switch` over the kind and the
/// plural, which is formatting.
class NextActionCard extends StatelessWidget {
  const NextActionCard({
    required this.action,
    required this.onStudy,
    required this.onBackup,
    required this.onImport,
    required this.onMockInterview,
    required this.onShowStuck,
    super.key,
  });

  final NextAction action;
  final VoidCallback onStudy;
  final VoidCallback onBackup;
  final VoidCallback onImport;
  final VoidCallback onMockInterview;
  final VoidCallback onShowStuck;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    final sentence = switch (action.kind) {
      NextActionKind.study =>
        'Você tem ${_cards(action.count)} vencendo hoje.',
      NextActionKind.backup => 'Seu histórico está sem cópia de segurança.',
      NextActionKind.attackStuck =>
        'Você está em dia, mas ${_cards(action.count)} '
            '${action.count == 1 ? 'está travado' : 'estão travados'}.',
      NextActionKind.awaitRelease =>
        'Seus primeiros cartões entram na próxima liberação — hoje não há '
            'nada para estudar.',
      NextActionKind.mockInterview =>
        'Você está em dia. Bom momento para um simulado.',
      NextActionKind.importMore =>
        'Sua coleção está vazia — importe as primeiras perguntas.',
      // The deadline banner sits right below with the same question and the
      // calendar; the dashboard does not paint this card in that case.
      NextActionKind.answerDeadline => '',
    };

    // `awaitRelease` is the one branch with no button: offering an action would
    // contradict the sentence, since importing more does not help while cards
    // are already held waiting.
    final button = switch (action.kind) {
      NextActionKind.study => _button('Estudar', onStudy),
      NextActionKind.backup => _button('Fazer a cópia', onBackup),
      NextActionKind.attackStuck => _button('Ver os travados', onShowStuck),
      NextActionKind.mockInterview =>
        _button('Fazer um simulado', onMockInterview),
      NextActionKind.importMore => _button('Importar perguntas', onImport),
      NextActionKind.awaitRelease || NextActionKind.answerDeadline => null,
    };

    if (action.kind == NextActionKind.answerDeadline) {
      return const SizedBox.shrink();
    }

    return Card(
      color: colors.primaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Agora',
              style: theme.textTheme.labelLarge
                  ?.copyWith(color: colors.onPrimaryContainer),
            ),
            const SizedBox(height: 8),
            Text(
              sentence,
              style: theme.textTheme.titleMedium
                  ?.copyWith(color: colors.onPrimaryContainer),
            ),
            if (button != null) ...[
              const SizedBox(height: 16),
              SizedBox(width: double.infinity, child: button),
            ],
          ],
        ),
      ),
    );
  }

  static Widget _button(String label, VoidCallback onPressed) =>
      FilledButton(onPressed: onPressed, child: Text(label));

  static String _cards(int count) =>
      count == 1 ? '1 cartão' : '$count cartões';
}
