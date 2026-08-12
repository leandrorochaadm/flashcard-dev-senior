import 'package:flutter/material.dart';

import '../../../domain/stats/progress_stats.dart';
import '../../shared/app_scaffold.dart';

/// "Quanto vem pela frente": one point per day of the next seven.
///
/// The points arrive from `ProgressStats.loadForecast`, which reads
/// `DueCardsPolicy.forecast`. [average] arrives from
/// `ProgressStats.averageLoad`: an average of scheduled load is an indicator,
/// and no average is born inside a `CustomPainter`. Scaling the series to its
/// tallest point, on the other hand, is drawing.
///
/// The type stays `LoadBar` — it is the domain type, and renaming it because
/// the screen changed shape would invert the dependency. The parameter does
/// not: a widget that draws no bars talking about "bars" is where an outdated
/// comment starts.
class LoadForecastChart extends StatelessWidget {
  const LoadForecastChart({
    required this.points,
    required this.average,
    super.key,
  });

  final List<LoadBar> points;
  final double average;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final empty = points.every((point) => point.cards == 0);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Carga dos próximos 7 dias',
                style: theme.textTheme.titleMedium),
            const SizedBox(height: 4),
            Text(
              'Quantos cartões estão marcados para cada dia.',
              style: theme.textTheme.bodySmall,
            ),
            const SizedBox(height: 16),
            if (empty)
              Text(
                'Nenhum cartão marcado para os próximos 7 dias.',
                style: theme.textTheme.bodyMedium,
              )
            else ...[
              SizedBox(
                height: 180,
                child: CustomPaint(
                  size: Size.infinite,
                  painter: _LoadLinePainter(
                    values: [for (final point in points) point.cards],
                    average: average,
                    line: colors.primary,
                    axis: colors.outlineVariant,
                    label: theme.textTheme.labelSmall ?? const TextStyle(),
                    todayLabel: (theme.textTheme.labelSmall ?? const TextStyle())
                        .copyWith(
                      color: colors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 6),
              // The date labels live outside the painter, each inside an
              // `Expanded`, so they land under their point without a second
              // `TextPainter`.
              Row(
                children: [
                  for (final point in points)
                    Expanded(
                      child: Text(
                        formatDate(point.day),
                        textAlign: TextAlign.center,
                        style: theme.textTheme.labelSmall,
                      ),
                    ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _LoadLinePainter extends CustomPainter {
  const _LoadLinePainter({
    required this.values,
    required this.average,
    required this.line,
    required this.axis,
    required this.label,
    required this.todayLabel,
  });

  final List<int> values;
  final double average;
  final Color line;
  final Color axis;
  final TextStyle label;
  final TextStyle todayLabel;

  @override
  void paint(Canvas canvas, Size size) {
    if (values.isEmpty) return;

    const topPadding = 18.0;
    final baseline = size.height - 1;
    final tallest = values.fold(0, (max, value) => value > max ? value : max);
    // Each point sits at the centre of its column, which is where the date
    // labels of the `Row` below also sit.
    final column = size.width / values.length;
    double xOf(int index) => column * index + column / 2;
    double yOf(num value) => tallest == 0
        ? baseline
        : baseline - (value / tallest) * (baseline - topPadding);

    canvas.drawLine(
      Offset(0, baseline),
      Offset(size.width, baseline),
      Paint()
        ..color = axis
        ..strokeWidth = 1,
    );

    // The reference line, at the value that came from the domain.
    _drawDashed(canvas, size, yOf(average));

    final path = Path()..moveTo(xOf(0), yOf(values.first));
    for (var i = 1; i < values.length; i++) {
      path.lineTo(xOf(i), yOf(values[i]));
    }

    // Area under the line: volume without turning back into a bar.
    final area = Path.from(path)
      ..lineTo(xOf(values.length - 1), baseline)
      ..lineTo(xOf(0), baseline)
      ..close();
    canvas.drawPath(area, Paint()..color = line.withValues(alpha: 0.12));

    canvas.drawPath(
      path,
      Paint()
        ..color = line
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..strokeJoin = StrokeJoin.round,
    );

    for (var i = 0; i < values.length; i++) {
      // Index 0 is today: `loadForecast` starts on `dateOnly(now)`.
      final isToday = i == 0;
      canvas.drawCircle(
        Offset(xOf(i), yOf(values[i])),
        isToday ? 4.5 : 3,
        Paint()
          ..color = line
          ..style = isToday ? PaintingStyle.fill : PaintingStyle.stroke
          ..strokeWidth = 2,
      );
      _drawValue(canvas, '${values[i]}', xOf(i), yOf(values[i]) - 14,
          isToday ? todayLabel : label);
    }
  }

  void _drawDashed(Canvas canvas, Size size, double y) {
    final paint = Paint()
      ..color = axis
      ..strokeWidth = 1;
    for (var x = 0.0; x < size.width; x += 8) {
      canvas.drawLine(Offset(x, y), Offset(x + 4, y), paint);
    }
  }

  void _drawValue(
    Canvas canvas,
    String text,
    double centerX,
    double top,
    TextStyle style,
  ) {
    final painter = TextPainter(
      text: TextSpan(text: text, style: style),
      textDirection: TextDirection.ltr,
    )..layout();
    painter.paint(canvas, Offset(centerX - painter.width / 2, top));
  }

  @override
  bool shouldRepaint(_LoadLinePainter old) =>
      old.average != average ||
      old.line != line ||
      !_sameValues(old.values, values);

  static bool _sameValues(List<int> a, List<int> b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}
