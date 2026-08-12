import 'package:flutter/foundation.dart';

import '../../core/clock.dart';
import '../../data/repositories/card_repository.dart';
import '../../domain/cards/card_deletion_service.dart';
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
    this._deletion,
  );

  final MarkdownParser _parser;
  final ImportService _importService;
  final ContentIntakePolicy _intake;
  final CardRepository _cards;
  final Clock _clock;
  final CardDeletionService _deletion;

  final state = ValueNotifier<ImportState>(const ImportState.idle());

  /// Mirror mode: the file is the whole truth and whatever it omits is erased.
  /// Off by default — an import that quietly deletes is the worst possible
  /// default for a screen used every day.
  final mirror = ValueNotifier<bool>(false);

  /// Release on import: the cards become studiable the moment they are saved,
  /// instead of entering the ~20-a-day ramp. On by default — it is what the
  /// user asks for on the common path; turning it off restores the ramp of H16.
  final releaseNow = ValueNotifier<bool>(true);

  /// The text last parsed, so toggling the mirror switch recomputes the
  /// preview instead of showing a removal list from the previous setting.
  String _lastText = '';

  void setMirror({required bool enabled}) {
    if (mirror.value == enabled) return;
    mirror.value = enabled;
    if (state.value is ImportPreviewing) parse(_lastText);
  }

  void setReleaseNow({required bool enabled}) {
    if (releaseNow.value == enabled) return;
    releaseNow.value = enabled;
    // The preview shows the first review dates, and they change with this
    // switch — recompute instead of leaving stale dates on screen.
    if (state.value is ImportPreviewing) parse(_lastText);
  }

  /// The text of the "copiar template" button (H15).
  String get template => importTemplate;

  /// Builds the preview. The first review dates come computed from the domain
  /// so the spread of H5 can be checked right here, on the import screen.
  void parse(String text) {
    _lastText = text;
    try {
      final preview = _parser.parse(text);
      if (preview.isEmpty) {
        state.value = const ImportState.error(
          'Nenhum cartão encontrado no texto. Confira se os cartões estão '
          'separados por uma linha com três traços.',
        );
        return;
      }
      final outcome = _importService.resolve(
        preview,
        _clock.now(),
        mirror: mirror.value,
        releaseNow: releaseNow.value,
      );
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

  /// Writes the cards. With the release switch off, releasing them is not part
  /// of importing — the [ContentIntakePolicy] does that on its own schedule
  /// (H16). With it on, importing releases, and this is where that happens.
  Future<void> confirm() async {
    final current = state.value;
    if (current is! ImportPreviewing) return;

    final outcome = current.outcome;
    state.value = const ImportState.importing();
    try {
      // The preview may sit on screen for a while — the day the card enters the
      // study is the day it is saved. The outcome only carries the intention,
      // and it is read from there, not from the notifier: what the user
      // confirmed is what the preview showed.
      //
      // One `now` for the whole batch, read before the loop: the cards go in
      // together and the intake queue already leans on a shared `importedAt` to
      // break ties. A per-card clock read would scatter `introducedAt` across
      // milliseconds for no reason.
      final now = _clock.now();
      final created = outcome.releasedOnImport
          ? [for (final card in outcome.created) _intake.releasedNow(card, now)]
          : outcome.created;
      await _cards.saveAll([...created, ...outcome.updated]);
      // Writes first, erases second: an interruption in between leaves the
      // collection with extra cards, never with the file's cards missing.
      final removed = await _deletion.delete(
        CardDeletionSelection.exactly(outcome.removed),
      );
      state.value = ImportState.done(
        created: outcome.created.length,
        updated: outcome.updated.length,
        removed: removed,
        released: outcome.releasedOnImport,
      );
    } on Object catch (error) {
      state.value = ImportState.error('Não foi possível salvar: $error');
    }
  }

  void reset() => state.value = const ImportState.idle();

  void dispose() {
    state.dispose();
    mirror.dispose();
    releaseNow.dispose();
  }
}
