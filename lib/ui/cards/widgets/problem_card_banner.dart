import 'package:flutter/material.dart';

/// Marks the problem cards and says what to do about them (H7): a card missed
/// four times is usually asking too much at once, and the way out is to
/// rewrite it as smaller questions.
class ProblemCardBanner extends StatelessWidget {
  const ProblemCardBanner({required this.problemCount, super.key});

  final int problemCount;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: scheme.errorContainer,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(Icons.priority_high, color: scheme.onErrorContainer),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              '$problemCount cartão(ões)-problema. Vale reescrever cada um '
              'como duas ou três perguntas menores — errar sempre costuma ser '
              'sinal de pergunta grande demais, não de falta de memória.',
              style: TextStyle(color: scheme.onErrorContainer),
            ),
          ),
        ],
      ),
    );
  }
}

/// Inline mark on the card that is a problem card.
class ProblemCardTag extends StatelessWidget {
  const ProblemCardTag({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: scheme.error,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        'cartão-problema',
        style: TextStyle(color: scheme.onError, fontSize: 12),
      ),
    );
  }
}
