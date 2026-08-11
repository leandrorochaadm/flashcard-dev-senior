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

  const factory ImportState.done({
    required int created,
    required int updated,
  }) = ImportDone;

  const factory ImportState.error(String message) = ImportError;
}
