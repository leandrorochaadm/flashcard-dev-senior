import 'package:flutter/material.dart';

import '../../../domain/import/import_preview.dart';
import '../../../domain/import/import_service.dart';
import '../../../domain/models/card.dart' as domain;
import '../../../domain/models/enums.dart';
import '../../shared/app_scaffold.dart';

/// What was understood and what was not, before anything is written.
///
/// The parser hands over [ImportPreview] as plain data and [ImportOutcome]
/// carries the cards with their first review date already scheduled — the
/// list only paints. Showing that date here is the acceptance criterion of
/// H5: the dates must not all be the same.
class PreviewList extends StatelessWidget {
  const PreviewList({
    required this.preview,
    required this.outcome,
    super.key,
  });

  final ImportPreview preview;
  final ImportOutcome outcome;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return ListView(
      children: [
        Text('Serão importados', style: text.titleMedium),
        const SizedBox(height: 4),
        Text(
          '${outcome.created.length} novo(s) · '
          '${outcome.updated.length} atualizado(s)',
          style: text.bodyMedium,
        ),
        const SizedBox(height: 12),
        for (final card in outcome.created)
          _ValidTile(card: card, label: 'novo'),
        for (final card in outcome.updated)
          _ValidTile(card: card, label: 'atualiza um cartão existente'),
        if (preview.invalid.isNotEmpty) ...[
          const SizedBox(height: 20),
          Text('Não foi possível ler', style: text.titleMedium),
          const SizedBox(height: 4),
          Text(
            'Os demais cartões são importados normalmente.',
            style: text.bodySmall,
          ),
          const SizedBox(height: 8),
          for (final block in preview.invalid) _InvalidTile(block: block),
        ],
      ],
    );
  }
}

class _ValidTile extends StatelessWidget {
  const _ValidTile({required this.card, required this.label});

  final domain.Card card;
  final String label;

  @override
  Widget build(BuildContext context) {
    final dueAt = card.dueAt;
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        title: Text(card.question, maxLines: 2, overflow: TextOverflow.ellipsis),
        subtitle: Text(
          '${card.subject} · ${difficultyLabel(card.difficulty)} · $label',
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            const Text('1ª revisão'),
            Text(
              dueAt == null ? '—' : formatDate(dueAt),
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ],
        ),
      ),
    );
  }
}

class _InvalidTile extends StatelessWidget {
  const _InvalidTile({required this.block});

  final InvalidBlock block;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      color: scheme.errorContainer,
      child: ListTile(
        leading: Icon(Icons.report_problem_outlined, color: scheme.error),
        title: Text('Bloco ${block.blockIndex + 1}'),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(block.issues.map(issueLabel).join(' · ')),
            const SizedBox(height: 4),
            Text(
              block.rawText,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}

String difficultyLabel(Difficulty difficulty) => switch (difficulty) {
      Difficulty.basic => 'básico',
      Difficulty.intermediate => 'intermediário',
      Difficulty.advanced => 'avançado',
    };

String issueLabel(ImportIssue issue) => switch (issue) {
      ImportIssue.missingSubject => 'sem assunto',
      ImportIssue.unknownDifficulty => 'dificuldade não reconhecida',
      ImportIssue.missingQuestion => 'sem pergunta',
      ImportIssue.missingAnswer => 'sem resposta',
    };
