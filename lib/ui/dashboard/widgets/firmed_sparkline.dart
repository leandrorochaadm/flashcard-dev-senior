import 'package:flutter/material.dart';

import '../../../domain/stats/collection_overview.dart';

/// The last seven days of firmed cards, as one small line.
///
/// The series arrives from `ProgressStats.firmedSummary`, already one point per
/// day and already ending today. Scaling it to the tallest point is drawing,
/// not a rule — no average and no ratio is computed here.
class FirmedSparkline extends StatelessWidget {
  const FirmedSparkline({required this.series, super.key});

  final List<FirmedDay> series;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return SizedBox(
      height: 32,
      width: double.infinity,
      child: CustomPaint(
        painter: _SparklinePainter(
          values: [for (final point in series) point.cards],
          color: colors.primary,
        ),
      ),
    );
  }
}

class _SparklinePainter extends CustomPainter {
  const _SparklinePainter({required this.values, required this.color});

  final List<int> values;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    if (values.isEmpty) return;

    final tallest = values.fold(0, (max, value) => value > max ? value : max);
    final step = values.length == 1 ? 0.0 : size.width / (values.length - 1);
    // An all-zero series draws a straight line on the baseline instead of
    // dividing by zero.
    double yOf(int value) =>
        tallest == 0 ? size.height - 1 : size.height - 1 - (value / tallest) * (size.height - 2);

    final path = Path()..moveTo(0, yOf(values.first));
    for (var i = 1; i < values.length; i++) {
      path.lineTo(step * i, yOf(values[i]));
    }

    canvas.drawPath(
      path,
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..strokeJoin = StrokeJoin.round,
    );
    canvas.drawCircle(
      Offset(step * (values.length - 1), yOf(values.last)),
      3,
      Paint()..color = color,
    );
  }

  @override
  bool shouldRepaint(_SparklinePainter old) =>
      old.color != color || !_sameValues(old.values, values);

  static bool _sameValues(List<int> a, List<int> b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}
