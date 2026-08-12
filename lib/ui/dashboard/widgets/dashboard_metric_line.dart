import 'package:flutter/material.dart';

/// One "label → value" line.
///
/// It was the private `_Line` of the subject detail screen until the funnel and
/// the expanded subject map needed the same shape: three copies of a row is how
/// three screens start disagreeing about what a metric looks like.
class DashboardMetricLine extends StatelessWidget {
  const DashboardMetricLine({
    required this.label,
    required this.value,
    this.valueColor,
    super.key,
  });

  final String label;
  final String value;

  /// Used to mark a number that is bad news — stuck cards, and nothing else so
  /// far. Deciding *when* it is bad news is the caller's, never this widget's.
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(child: Text(label)),
          Text(
            value,
            style: Theme.of(context)
                .textTheme
                .titleSmall
                ?.copyWith(color: valueColor),
          ),
        ],
      ),
    );
  }
}
