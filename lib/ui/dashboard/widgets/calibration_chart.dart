import 'package:flutter/material.dart';

import '../../../domain/stats/calibration.dart';
import '../../shared/formatting.dart';

/// The only indicator that audits the app: what it predicted against what
/// actually happened, day by day.
///
/// A line chart drawn by hand — no chart package, because the first offline
/// load has to stay small. Every point comes from `Calibration.series`; the
/// painter only maps numbers to pixels.
class CalibrationChart extends StatelessWidget {
  const CalibrationChart({
    required this.series,
    required this.previousSeries,
    required this.canRevert,
    required this.onRevert,
    this.tuningMessage,
    super.key,
  });

  final List<CalibrationPoint> series;

  /// The same days recomputed with the weights in force before the tuning.
  /// `null` hides the "voltar ao anterior" button — there is nothing to go
  /// back to.
  final List<CalibrationPoint>? previousSeries;
  final bool canRevert;
  final Future<void> Function() onRevert;
  final String? tuningMessage;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Previsto × real', style: theme.textTheme.titleMedium),
            const SizedBox(height: 4),
            Text(
              'Quanto o app achou que você lembraria, e quanto você lembrou.',
              style: theme.textTheme.bodySmall,
            ),
            const SizedBox(height: 12),
            if (series.isEmpty)
              const Text('Ainda não há dias de estudo para comparar.')
            else
              SizedBox(
                height: 200,
                width: double.infinity,
                child: CustomPaint(
                  painter: _CalibrationPainter(
                    series: series,
                    previousSeries: previousSeries,
                    predictedColor: scheme.primary,
                    actualColor: scheme.tertiary,
                    previousColor: scheme.outline,
                    gridColor: scheme.outlineVariant,
                  ),
                ),
              ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 16,
              runSpacing: 8,
              children: [
                _Legend(color: scheme.primary, label: 'Previsto (agora)'),
                _Legend(color: scheme.tertiary, label: 'Real'),
                if (previousSeries != null)
                  _Legend(
                    color: scheme.outline,
                    label: 'Previsto (antes do reajuste)',
                  ),
              ],
            ),
            if (series.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                'De ${formatDate(series.first.day)} a '
                '${formatDate(series.last.day)}.',
                style: theme.textTheme.bodySmall,
              ),
            ],
            if (tuningMessage != null) ...[
              const SizedBox(height: 12),
              Text(tuningMessage!, style: theme.textTheme.bodySmall),
            ],
            if (canRevert) ...[
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton.icon(
                  onPressed: () => onRevert(),
                  icon: const Icon(Icons.undo),
                  label: const Text('Voltar ao anterior'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _Legend extends StatelessWidget {
  const _Legend({required this.color, required this.label});

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(width: 16, height: 3, color: color),
        const SizedBox(width: 6),
        Text(label, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }
}

class _CalibrationPainter extends CustomPainter {
  _CalibrationPainter({
    required this.series,
    required this.previousSeries,
    required this.predictedColor,
    required this.actualColor,
    required this.previousColor,
    required this.gridColor,
  });

  final List<CalibrationPoint> series;
  final List<CalibrationPoint>? previousSeries;
  final Color predictedColor;
  final Color actualColor;
  final Color previousColor;
  final Color gridColor;

  @override
  void paint(Canvas canvas, Size size) {
    final grid = Paint()
      ..color = gridColor
      ..strokeWidth = 1;
    // The vertical axis is a rate: always the full 0..1, so two charts drawn
    // on different days stay comparable.
    for (var i = 0; i <= 4; i++) {
      final y = size.height * i / 4;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), grid);
    }

    _drawLine(canvas, size, series, (p) => p.predicted, predictedColor, 2.5);
    _drawLine(canvas, size, series, (p) => p.actual, actualColor, 2.5);
    final previous = previousSeries;
    if (previous != null) {
      _drawLine(canvas, size, previous, (p) => p.predicted, previousColor, 1.5);
    }
  }

  void _drawLine(
    Canvas canvas,
    Size size,
    List<CalibrationPoint> points,
    double Function(CalibrationPoint) value,
    Color color,
    double width,
  ) {
    if (points.isEmpty) return;
    final paint = Paint()
      ..color = color
      ..strokeWidth = width
      ..style = PaintingStyle.stroke
      ..strokeJoin = StrokeJoin.round;

    final path = Path();
    for (var i = 0; i < points.length; i++) {
      final x = points.length == 1
          ? size.width / 2
          : size.width * i / (points.length - 1);
      final y = size.height * (1 - value(points[i]).clamp(0.0, 1.0));
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
      canvas.drawCircle(Offset(x, y), width, Paint()..color = color);
    }
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_CalibrationPainter oldDelegate) =>
      oldDelegate.series != series ||
      oldDelegate.previousSeries != previousSeries;
}
