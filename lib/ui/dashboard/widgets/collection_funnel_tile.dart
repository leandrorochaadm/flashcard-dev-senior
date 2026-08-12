import 'package:flutter/material.dart';

import '../../../domain/stats/collection_overview.dart';
import 'dashboard_metric_line.dart';

/// "De onde vêm os números": the collection funnel, from what was imported to
/// what is already ready.
///
/// It is born collapsed, because this is a lookup and not a daily reading —
/// open by default it would push the rest of the dashboard down. Every count
/// and both ratios arrive from `CollectionOverview`; nothing here divides.
class CollectionFunnelTile extends StatelessWidget {
  const CollectionFunnelTile({required this.overview, super.key});

  final CollectionOverview overview;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Card(
      child: ExpansionTile(
        // `Border()` and not the default: the tile's own divider drawn against
        // the card's edge reads as a double rule.
        shape: const Border(),
        collapsedShape: const Border(),
        initiallyExpanded: false,
        title: Text('De onde vêm os números',
            style: theme.textTheme.titleMedium),
        subtitle: Text(
          '${overview.released} liberados · ${overview.held} retidos',
          style: theme.textTheme.bodySmall,
        ),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Todos os cartões da coleção, por situação.',
                  style: theme.textTheme.bodySmall,
                ),
                const SizedBox(height: 8),
                DashboardMetricLine(
                  label: 'Importados',
                  value: '${overview.total}',
                ),
                DashboardMetricLine(
                  label: 'Ainda retidos',
                  value: '${overview.held}',
                ),
                Text(
                  'Entram aos poucos, para o volume diário não explodir.',
                  style: theme.textTheme.bodySmall,
                ),
                DashboardMetricLine(
                  label: 'Liberados',
                  value: '${overview.released}',
                ),
                if (overview.released == 0)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      'Nenhum cartão liberado ainda — os primeiros entram na '
                      'próxima abertura do app.',
                      style: theme.textTheme.bodySmall,
                    ),
                  )
                else ...[
                  DashboardMetricLine(
                    label: 'Nunca respondidos',
                    value: '${overview.neverAnswered}',
                  ),
                  DashboardMetricLine(
                    label: 'No ciclo curto',
                    value: '${overview.inShortCycle}',
                  ),
                  DashboardMetricLine(
                    label: 'Em revisão',
                    value: '${overview.inReview}',
                  ),
                  DashboardMetricLine(
                    label: 'Vencendo hoje',
                    value: '${overview.dueToday}',
                  ),
                  DashboardMetricLine(
                    label: 'Firmes',
                    value: '${overview.firm}',
                  ),
                  DashboardMetricLine(
                    label: 'Prontos para a data-alvo',
                    value: '${overview.ready}',
                  ),
                  DashboardMetricLine(
                    label: 'Travados',
                    value: '${overview.stuck}',
                    valueColor: overview.stuck > 0 ? colors.error : null,
                  ),
                  const SizedBox(height: 12),
                  _Ratio(
                    label: 'Firmes',
                    value: overview.firmRatio,
                    caption: '${overview.firm} de ${overview.released}',
                  ),
                  const SizedBox(height: 8),
                  _Ratio(
                    label: 'Prontos para a data-alvo',
                    value: overview.readyRatio,
                    caption: '${overview.ready} de ${overview.released}',
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Ratio extends StatelessWidget {
  const _Ratio({
    required this.label,
    required this.value,
    required this.caption,
  });

  final String label;

  /// Already a ratio, computed by `CollectionOverview`.
  final double value;
  final String caption;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(child: Text(label, style: theme.textTheme.bodySmall)),
            Text(caption, style: theme.textTheme.bodySmall),
          ],
        ),
        const SizedBox(height: 4),
        LinearProgressIndicator(value: value),
      ],
    );
  }
}
