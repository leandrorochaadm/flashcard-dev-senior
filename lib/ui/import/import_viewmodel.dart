import 'package:flutter/foundation.dart';

import '../../core/clock.dart';
import '../../data/repositories/card_repository.dart';
import '../../domain/import/import_service.dart';
import '../../domain/import/import_template.dart';
import '../../domain/import/markdown_parser.dart';
import '../../domain/policies/content_intake_policy.dart';
import 'import_state.dart';

/// Sequences the import screen. Every decision it forwards comes from the
/// domain: the parser reads the text, [ImportService] says what would be
/// created or updated (with the first review dates already spread), and
/// [ContentIntakePolicy] owns both the firm ratio and the 80% threshold.
class ImportViewModel {
  ImportViewModel(
    this._parser,
    this._importService,
    this._intake,
    this._cards,
    this._clock,
  );

  final MarkdownParser _parser;
  final ImportService _importService;
  final ContentIntakePolicy _intake;
  final CardRepository _cards;
  final Clock _clock;

  final state = ValueNotifier<ImportState>(const ImportState.idle());

  /// The text of the "copiar template" button (H15).
  String get template => importTemplate;

  /// Builds the preview. The first review dates come computed from the domain
  /// so the spread of H5 can be checked right here, on the import screen.
  void parse(String text) {
    try {
      final preview = _parser.parse(text);
      if (preview.isEmpty) {
        state.value = const ImportState.error(
          'Nenhum cartão encontrado no texto. Confira se os cartões estão '
          'separados por uma linha com três traços.',
        );
        return;
      }
      final outcome = _importService.resolve(preview, _clock.now());
      state.value = ImportState.previewing(
        preview: preview,
        outcome: outcome,
        firmRatio: _intake.firmRatio(),
        warnBelowThreshold: _intake.shouldWarnBeforeImport(),
      );
    } on Object catch (error) {
      state.value = ImportState.error('Não foi possível ler o texto: $error');
    }
  }

  /// Writes the cards. Releasing them is not part of importing — the
  /// [ContentIntakePolicy] does that on its own schedule (H16).
  Future<void> confirm() async {
    final current = state.value;
    if (current is! ImportPreviewing) return;

    final outcome = current.outcome;
    state.value = const ImportState.importing();
    try {
      await _cards.saveAll([...outcome.created, ...outcome.updated]);
      state.value = ImportState.done(
        created: outcome.created.length,
        updated: outcome.updated.length,
      );
    } on Object catch (error) {
      state.value = ImportState.error('Não foi possível salvar: $error');
    }
  }

  void reset() => state.value = const ImportState.idle();

  void dispose() => state.dispose();
}
