import 'package:flutter/material.dart';

import '../../../domain/models/enums.dart';
import '../../shared/formatting.dart';

/// The four buttons, in screen order, each showing the interval it would
/// schedule.
///
/// One row across the bottom of the screen, the four sharing the width evenly
/// — the shape a flashcard reviewer has on a phone, where the thumb reaches
/// the bottom edge and the buttons never reflow between cards.
///
/// The labels are the client's own words and are fixed by the requirements —
/// they are the only pt-BR strings that must never be reworded.
class RatingButtons extends StatelessWidget {
  const RatingButtons({
    required this.previews,
    required this.onRated,
    super.key,
  });

  final Map<Rating, Duration> previews;
  final ValueChanged<Rating> onRated;

  static const labels = <Rating, String>{
    Rating.again: 'Errei',
    Rating.hard: 'Lembrei só uma parte',
    Rating.good: 'Lembrei com esforço',
    Rating.easy: 'Sabia de cor',
  };

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final colors = <Rating, Color>{
      Rating.again: scheme.error,
      Rating.hard: scheme.tertiary,
      Rating.good: scheme.primary,
      Rating.easy: scheme.secondary,
    };

    // Fixed height, never `stretch`: the row sits in a `Column`, which hands
    // its children unbounded height, and stretching against infinity is a
    // layout assertion.
    return SizedBox(
      height: 68,
      child: Row(
        children: [
          for (final rating in Rating.values)
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 3),
                child: _RatingButton(
                  label: labels[rating]!,
                  preview: _preview(rating),
                  color: colors[rating]!,
                  onPressed: () => onRated(rating),
                ),
              ),
            ),
        ],
      ),
    );
  }

  String _preview(Rating rating) {
    final interval = previews[rating];
    return interval == null ? '—' : formatDays(interval);
  }
}

class _RatingButton extends StatelessWidget {
  const _RatingButton({
    required this.label,
    required this.preview,
    required this.color,
    required this.onPressed,
  });

  final String label;
  final String preview;
  final Color color;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return FilledButton(
      onPressed: onPressed,
      style: FilledButton.styleFrom(
        backgroundColor: color,
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
        minimumSize: const Size(0, 68),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(10)),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            preview,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 11, height: 1.1),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 12,
              height: 1.15,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
