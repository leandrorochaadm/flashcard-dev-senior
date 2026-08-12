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
                height: 220,
                width: double.infinity,
                child: CustomPaint(
                  painter: _CalibrationPainter(
                    series: series,
                    previousSeries: previousSeries,
                    predictedColor: scheme.primary,
                    actualColor: scheme.tertiary,
                    previousColor: scheme.outline,
                    gridColor: scheme.outlineVariant,
                    labelStyle:
                        theme.textTheme.labelSmall?.copyWith(
                          color: scheme.onSurfaceVariant,
                        ) ??
                        TextStyle(fontSize: 11, color: scheme.onSurfaceVariant),
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

enum _Align { rightMiddle, centerTop, centerBottom }

class _CalibrationPainter extends CustomPainter {
  _CalibrationPainter({
    required this.series,
    required this.previousSeries,
    required this.predictedColor,
    required this.actualColor,
    required this.previousColor,
    required this.gridColor,
    required this.labelStyle,
  });

  final List<CalibrationPoint> series;
  final List<CalibrationPoint>? previousSeries;
  final Color predictedColor;
  final Color actualColor;
  final Color previousColor;
  final Color gridColor;
  final TextStyle labelStyle;

  /// Set on every paint; the labels of the first and last day are centred on
  /// points that sit on the edges, so they need the full width to clamp against.
  double _width = 0;

  @override
  void paint(Canvas canvas, Size size) {
    _width = size.width;
    // The plot area leaves room for the axis labels: the vertical rates on the
    // left, the days underneath, and one line above the plot for the value
    // printed over the highest point.
    const gutter = 38.0;
    const bottom = 20.0;
    const top = 12.0;
    final plot = Rect.fromLTRB(gutter, top, size.width, size.height - bottom);
    if (plot.width <= 0 || plot.height <= 0) return;

    final grid = Paint()
      ..color = gridColor
      ..strokeWidth = 1;
    // The vertical axis is a rate: always the full 0..1, so two charts drawn
    // on different days stay comparable.
    for (var i = 0; i <= 4; i++) {
      final y = plot.top + plot.height * i / 4;
      canvas.drawLine(Offset(plot.left, y), Offset(plot.right, y), grid);
      _paintText(
        canvas,
        '${(100 - i * 25)}%',
        Offset(gutter - 6, y),
        align: _Align.rightMiddle,
      );
    }

    final stride = _labelStride(plot.width);
    for (var i = 0; i < series.length; i++) {
      if (i % stride != 0 && i != series.length - 1) continue;
      _paintText(
        canvas,
        formatDate(series[i].day),
        Offset(_x(plot, i), plot.bottom + 4),
        align: _Align.centerTop,
      );
    }

    final previous = previousSeries;
    if (previous != null) {
      _drawLine(canvas, plot, previous, (p) => p.predicted, previousColor, 1.5);
    }
    _drawLine(canvas, plot, series, (p) => p.predicted, predictedColor, 2.5);
    _drawLine(canvas, plot, series, (p) => p.actual, actualColor, 2.5);

    for (var i = 0; i < series.length; i++) {
      if (i % stride != 0 && i != series.length - 1) continue;
      final point = series[i];
      // Whichever value is on top gets its label above the line, so the two
      // never land on the same pixels.
      final predictedOnTop = point.predicted >= point.actual;
      _paintValue(
        canvas,
        plot,
        i,
        point.predicted,
        predictedColor,
        above: predictedOnTop,
      );
      _paintValue(
        canvas,
        plot,
        i,
        point.actual,
        actualColor,
        above: !predictedOnTop,
      );
    }
  }

  /// How many days to skip between labels so they do not overlap: each label is
  /// about 32 px wide ("12/08" plus breathing room).
  int _labelStride(double width) {
    if (series.length < 2) return 1;
    final fits = (width / 44).floor().clamp(1, series.length);
    return (series.length / fits).ceil();
  }

  double _x(Rect plot, int index) => series.length == 1
      ? plot.center.dx
      : plot.left + plot.width * index / (series.length - 1);

  void _paintValue(
    Canvas canvas,
    Rect plot,
    int index,
    double value,
    Color color, {
    required bool above,
  }) {
    final y = plot.top + plot.height * (1 - value.clamp(0.0, 1.0));
    _paintText(
      canvas,
      '${(value * 100).round()}%',
      Offset(_x(plot, index), above ? y - 6 : y + 6),
      align: above ? _Align.centerBottom : _Align.centerTop,
      color: color,
    );
  }

  void _paintText(
    Canvas canvas,
    String text,
    Offset anchor, {
    required _Align align,
    Color? color,
  }) {
    final painter = TextPainter(
      text: TextSpan(
        text: text,
        style: color == null ? labelStyle : labelStyle.copyWith(color: color),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    final offset = switch (align) {
      _Align.rightMiddle => Offset(
        anchor.dx - painter.width,
        anchor.dy - painter.height / 2,
      ),
      _Align.centerTop => Offset(anchor.dx - painter.width / 2, anchor.dy),
      _Align.centerBottom => Offset(
        anchor.dx - painter.width / 2,
        anchor.dy - painter.height,
      ),
    };
    final maxLeft = (_width - painter.width).clamp(0.0, double.infinity);
    painter.paint(canvas, Offset(offset.dx.clamp(0.0, maxLeft), offset.dy));
  }

  void _drawLine(
    Canvas canvas,
    Rect plot,
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
          ? plot.center.dx
          : plot.left + plot.width * i / (points.length - 1);
      final y = plot.top + plot.height * (1 - value(points[i]).clamp(0.0, 1.0));
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
