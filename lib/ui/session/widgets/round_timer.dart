import 'package:flutter/material.dart';

import '../../shared/app_scaffold.dart';

/// Round clock, optional card stopwatch, pause and round number.
class RoundTimer extends StatelessWidget {
  const RoundTimer({
    required this.roundRemaining,
    required this.roundIndex,
    required this.roundCount,
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
        Text(
          'Round ${roundIndex + 1}/$roundCount',
          style: theme.textTheme.labelLarge,
        ),
        const SizedBox(width: 12),
        Text(
          formatClock(roundRemaining),
          style: theme.textTheme.titleMedium?.copyWith(
            fontFeatures: const [FontFeature.tabularFigures()],
          ),
        ),
        if (stopwatchVisible) ...[
          const SizedBox(width: 12),
          Text(
            'cartão ${formatClock(elapsedOnCard)}',
            style: theme.textTheme.bodySmall,
          ),
        ],
        const Spacer(),
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
