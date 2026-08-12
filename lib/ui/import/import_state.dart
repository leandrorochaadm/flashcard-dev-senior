import 'package:freezed_annotation/freezed_annotation.dart';

import '../../domain/import/import_preview.dart';
import '../../domain/import/import_service.dart';

part 'import_state.freezed.dart';

/// Screen state of the import window (H3, H15, H16).
///
/// A union instead of a pile of booleans: "previewing" always carries the
/// preview and the outcome together, so the screen can never paint a
/// confirmation button with nothing to confirm.
@freezed
sealed class ImportState with _$ImportState {
  const factory ImportState.idle() = ImportIdle;

  /// The text was read. [outcome] already carries the first review dates the
  /// preview has to show, and [firmRatio] is the number the 80% warning
  /// displays.
  const factory ImportState.previewing({
    required ImportPreview preview,
    required ImportOutcome outcome,
    required double firmRatio,
    required bool warnBelowThreshold,
  }) = ImportPreviewing;

  const factory ImportState.importing() = ImportImporting;

  /// [released] says the new cards went straight into today's review queue,
  /// instead of waiting for the daily ramp — the success screen has to say
  /// which of the two happened.
  const factory ImportState.done({
    required int created,
    required int updated,
    @Default(0) int removed,
    @Default(false) bool released,
  }) = ImportDone;

  const factory ImportState.error(String message) = ImportError;
}
