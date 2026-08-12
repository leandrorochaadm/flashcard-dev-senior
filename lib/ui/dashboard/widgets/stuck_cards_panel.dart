import 'package:flutter/material.dart';

// The alias is not optional: this file imports `material.dart` to draw a
// `Card`, and `List<Card>` without it would resolve to the Material widget.
import '../../../domain/models/card.dart' as domain;

/// The stuck cards, listed on the dashboard for the first time.
///
/// `ProgressStats.problemCards()` has existed since the first version and no
/// screen consumed it. The list arrives filtered by the domain — cutting it at
/// five lines is a display decision (how many rows fit a phone), not a rule.
class StuckCardsPanel extends StatelessWidget {
  const StuckCardsPanel({
    required this.cards,
    required this.controller,
    required this.onOpenCards,
    super.key,
  });

  final List<domain.Card> cards;

  /// Who opens this panel from the outside is the next-action card.
  /// `initiallyExpanded` is read once, in `initState`, so passing `true` after
  /// the tile exists would open nothing — the button would scroll to a closed
  /// panel. `ExpansibleController.expand()` is a no-op on an open tile, so it
  /// needs no guard.
  final ExpansibleController controller;

  final VoidCallback onOpenCards;

  /// How many rows fit before the panel starts pushing the dashboard down.
  static const _visibleRows = 5;

  @override
  Widget build(BuildContext context) {
    // With no stuck card, an empty card in the middle of the dashboard is
    // noise.
    if (cards.isEmpty) return const SizedBox.shrink();

    final theme = Theme.of(context);
    final shown = cards.take(_visibleRows).toList();
    final hidden = cards.length - shown.length;

    return Card(
      child: ExpansionTile(
        controller: controller,
        initiallyExpanded: false,
        shape: const Border(),
        collapsedShape: const Border(),
        title: Text('Cartões travados', style: theme.textTheme.titleMedium),
        trailing: Text(
          '${cards.length}',
          style: theme.textTheme.titleMedium
              ?.copyWith(color: theme.colorScheme.error),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Você errou cada um deles 4 vezes ou mais.',
                  style: theme.textTheme.bodySmall,
                ),
                const SizedBox(height: 8),
                for (final card in shown)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                card.question,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: theme.textTheme.bodyMedium,
                              ),
                              Text(
                                card.subject,
                                style: theme.textTheme.bodySmall,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          card.lapses == 1
                              ? '1 erro'
                              : '${card.lapses} erros',
                          style: theme.textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                if (hidden > 0)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      hidden == 1 ? 'e mais 1…' : 'e mais $hidden…',
                      style: theme.textTheme.bodySmall,
                    ),
                  ),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: onOpenCards,
                    child: const Text('Ver todos os cartões'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
