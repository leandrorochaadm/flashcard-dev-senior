import 'package:flutter/material.dart';

import '../../../domain/models/card.dart' as domain;
import '../../shared/rich_text_body.dart';

/// The question, and the answer only once it has been revealed.
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            card.subject,
            style: theme.textTheme.labelLarge?.copyWith(
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(height: 8),
          SelectableText(card.question, style: theme.textTheme.headlineSmall),
          if (revealed) ...[
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 16),
            RichTextBody(text: card.answer),
          ],
        ],
      ),
    );
  }
}
