import 'package:flutter/material.dart';

import '../../shared/app_scaffold.dart';

/// Round clock, optional card stopwatch, pause and round number.
class RoundTimer extends StatelessWidget {
  const RoundTimer({
    required this.roundRemaining,
    required this.roundIndex,
    required this.roundCount,
    required this.remaining,
    required this.paused,
    required this.stopwatchVisible,
    required this.elapsedOnCard,
    required this.onTogglePause,
    required this.onToggleStopwatch,
    super.key,
  });

  final Duration roundRemaining;
  final int roundIndex;
  final int roundCount;

  /// Cards still to come in this round, the current one included.
  final int remaining;
  final bool paused;
  final bool stopwatchVisible;
  final Duration elapsedOnCard;
  final VoidCallback onTogglePause;
  final VoidCallback onToggleStopwatch;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        // A `Wrap` inside an `Expanded`, not a plain `Row`: on a 390-point
        // phone the four readings plus the two buttons overflow by ~80 pixels,
        // and the round header is the last place that should steal attention
        // with a yellow stripe. Here they wrap to a second line instead.
        Expanded(
          child: Wrap(
            spacing: 12,
            runSpacing: 4,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Text(
                'Round ${roundIndex + 1}/$roundCount',
                style: theme.textTheme.labelLarge,
              ),
              Text(
                formatClock(roundRemaining),
                style: theme.textTheme.titleMedium?.copyWith(
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
              Text(
                '$remaining ${remaining == 1 ? 'cartão' : 'cartões'}',
                style: theme.textTheme.bodySmall,
              ),
              if (stopwatchVisible)
                Text(
                  'cartão ${formatClock(elapsedOnCard)}',
                  style: theme.textTheme.bodySmall,
                ),
            ],
          ),
        ),
        IconButton(
          onPressed: onToggleStopwatch,
          tooltip: stopwatchVisible
              ? 'Esconder cronômetro do cartão'
              : 'Mostrar cronômetro do cartão',
          icon: Icon(stopwatchVisible ? Icons.timer_off : Icons.timer),
        ),
        IconButton(
          onPressed: onTogglePause,
          tooltip: paused ? 'Continuar' : 'Pausar',
          icon: Icon(paused ? Icons.play_arrow : Icons.pause),
        ),
      ],
    );
  }
}
