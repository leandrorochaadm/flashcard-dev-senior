import 'package:flutter/material.dart';

/// The firmness warning of H16.
///
/// It is a warning, never a gate: the percentage is shown and "Importar assim
/// mesmo" carries the same visual weight as cancelling, because the decision
/// belongs to the user.
class IntakeWarning extends StatelessWidget {
  const IntakeWarning({
    required this.firmRatio,
    required this.onImportAnyway,
    required this.onCancel,
    super.key,
  });

  /// Share of released cards that are firm, as computed by the
  /// ContentIntakePolicy.
  final double firmRatio;
  final VoidCallback onImportAnyway;
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final percent = (firmRatio * 100).toStringAsFixed(0);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: scheme.tertiaryContainer,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.info_outline, color: scheme.onTertiaryContainer),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Só $percent% dos cartões liberados estão firmes. '
                  'Importar mais conteúdo agora aumenta a fila de revisão.',
                  style: TextStyle(color: scheme.onTertiaryContainer),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              // Same weight on purpose: the app warns, it does not block.
              TextButton(onPressed: onCancel, child: const Text('Cancelar')),
              const SizedBox(width: 8),
              TextButton(
                onPressed: onImportAnyway,
                child: const Text('Importar assim mesmo'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
