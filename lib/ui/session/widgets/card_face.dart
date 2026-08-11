import 'package:flutter/material.dart';

import '../../../domain/models/card.dart' as domain;
import '../../shared/rich_text_body.dart';

/// The question, and the answer only once it has been revealed.
///
/// Laid out the way a flashcard reviewer is: the question sits centered in the
/// empty screen, and revealing pushes a horizontal rule down with the answer
/// under it. Nothing competes with the card for attention.
///
/// When [revealed] is false the answer is not built at all — it is never in
/// the tree behind an `Opacity` or a `Visibility`, because "not revealed yet"
/// has to be true of the widget tree, not only of the pixels.
class CardFace extends StatelessWidget {
  const CardFace({required this.card, required this.revealed, super.key});

  final domain.Card card;
  final bool revealed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SingleChildScrollView(
      child: ConstrainedBox(
        // Fills the free space so the unrevealed question centers vertically,
        // then grows past it once the answer arrives.
        constraints: BoxConstraints(
          minHeight: MediaQuery.sizeOf(context).height * 0.4,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              card.subject,
              textAlign: TextAlign.center,
              style: theme.textTheme.labelMedium?.copyWith(
                color: theme.colorScheme.primary,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 24),
            SelectableText(
              card.question,
              textAlign: TextAlign.center,
              style: theme.textTheme.headlineSmall?.copyWith(height: 1.35),
            ),
            if (revealed) ...[
              const SizedBox(height: 24),
              const Divider(thickness: 1),
              const SizedBox(height: 24),
              DefaultTextStyle.merge(
                textAlign: TextAlign.center,
                child: RichTextBody(text: card.answer),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
