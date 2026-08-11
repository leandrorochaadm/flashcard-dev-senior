import 'package:flutter/material.dart';

import '../../../domain/models/enums.dart';
import '../../shared/app_scaffold.dart';

/// The four buttons, in screen order, each showing the interval it would
/// schedule.
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

    return Wrap(
      spacing: 12,
      runSpacing: 12,
      alignment: WrapAlignment.center,
      children: [
        for (final rating in Rating.values)
          SizedBox(
            width: 200,
            child: FilledButton(
              onPressed: () => onRated(rating),
              style: FilledButton.styleFrom(
                backgroundColor: colors[rating],
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    labels[rating]!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _preview(rating),
                    style: Theme.of(context).textTheme.labelSmall,
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  String _preview(Rating rating) {
    final interval = previews[rating];
    return interval == null ? '—' : formatDays(interval);
  }
}
