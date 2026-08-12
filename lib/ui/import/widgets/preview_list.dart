import 'package:flutter/material.dart';

import '../../../domain/import/import_preview.dart';
import '../../../domain/import/import_service.dart';
import '../../../domain/models/card.dart' as domain;
import '../../../domain/models/enums.dart';
import '../../shared/formatting.dart';

/// What was understood and what was not, before anything is written.
///
/// The parser hands over [ImportPreview] as plain data and [ImportOutcome]
/// carries the cards with their first review date already scheduled — the
/// list only paints. Showing that date here is the acceptance criterion of
/// H5: the dates must not all be the same.
///
/// With [ImportOutcome.releasedOnImport] the new cards say "hoje" instead: the
/// card is still born with the projected date, but confirming throws it away,
/// and painting a date that will not happen is worse than painting none.
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
          _ValidTile(
            card: card,
            label: 'novo',
            dueToday: outcome.releasedOnImport,
          ),
        // The release option never reaches a card that already exists: a
        // held-back one stays held back, with the date it already had.
        for (final card in outcome.updated)
          _ValidTile(card: card, label: 'atualiza um cartão existente'),
        if (outcome.mirrorHeldBack) ...[
          const SizedBox(height: 20),
          Card(
            color: Theme.of(context).colorScheme.errorContainer,
            child: const ListTile(
              leading: Icon(Icons.shield_outlined),
              title: Text('Nada será apagado desta vez'),
              subtitle: Text(
                'O texto tem blocos que não deu para ler. Um cartão com erro '
                'de digitação parece um cartão que saiu do arquivo — corrija '
                'os blocos abaixo e importe de novo para apagar.',
              ),
            ),
          ),
        ],
        if (outcome.removed.isNotEmpty) ...[
          const SizedBox(height: 20),
          Text('Serão apagados', style: text.titleMedium),
          const SizedBox(height: 4),
          Text(
            '${outcome.removed.length} cartão(ões) fora do texto, junto com o '
            'histórico de estudo deles.',
            style: text.bodySmall,
          ),
          const SizedBox(height: 8),
          for (final card in outcome.removed) _RemovedTile(card: card),
        ],
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
  const _ValidTile({
    required this.card,
    required this.label,
    this.dueToday = false,
  });

  final domain.Card card;
  final String label;

  /// The card will be released the moment the import is confirmed, so the date
  /// it carries now is not the one it will have.
  final bool dueToday;

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
              dueToday
                  ? 'hoje'
                  : dueAt == null
                      ? '—'
                      : formatDate(dueAt),
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ],
        ),
      ),
    );
  }
}

class _RemovedTile extends StatelessWidget {
  const _RemovedTile({required this.card});

  final domain.Card card;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      color: scheme.errorContainer,
      child: ListTile(
        leading: Icon(Icons.delete_outline, color: scheme.error),
        title: Text(card.question, maxLines: 2, overflow: TextOverflow.ellipsis),
        subtitle: Text(
          '${card.subject} · ${difficultyLabel(card.difficulty)}',
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
      // Syntax, not compilation: the formatter parses, it does not resolve
      // names. Saying "não compila" would promise a check the app cannot do.
      ImportIssue.unparsableDartCode => 'erro de sintaxe no código Dart',
    };
