import 'package:flutter/material.dart';

/// Real accuracy against the 0.90 the algorithm aims at.
///
/// Both numbers come ready: [accuracy] from `Calibration.accuracy` and
/// [target] from the FSRS adapter's `desiredRetention`.
///
/// One of the four compact tiles of the metric strip: padding 12 and short
/// supporting text, so two tiles fit side by side on a 360-point phone.
class AccuracyVsTargetTile extends StatelessWidget {
  const AccuracyVsTargetTile({
    required this.accuracy,
    required this.target,
    super.key,
  });

  /// `null` while nothing has been reviewed in a session yet.
  final double? accuracy;
  final double target;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final value = accuracy;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Acerto real × alvo', style: theme.textTheme.labelLarge),
            const SizedBox(height: 8),
            Text(
              value == null ? '—' : _percent(value),
              style: theme.textTheme.displaySmall,
            ),
            const SizedBox(height: 4),
            Text('alvo do método: ${_percent(target)}',
                style: theme.textTheme.bodySmall),
            const SizedBox(height: 12),
            LinearProgressIndicator(value: value ?? 0),
            const SizedBox(height: 8),
            Text(
              value == null
                  ? 'Sem respostas de sessão ainda.'
                  : value >= target
                      ? 'No ritmo previsto.'
                      : 'Abaixo do previsto — os intervalos encurtam sozinhos.',
              style: theme.textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }

  static String _percent(double value) =>
      '${(value * 100).toStringAsFixed(0)}%';
}
