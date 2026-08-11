import 'package:freezed_annotation/freezed_annotation.dart';

part 'backup_state.freezed.dart';

/// Screen state of the backup window (H14).
@freezed
sealed class BackupState with _$BackupState {
  /// [daysSinceLastBackup] is `null` when there has never been one.
  const factory BackupState.ready({
    required DateTime? lastBackupAt,
    required int? daysSinceLastBackup,
    required int cardCount,
    required int reviewCount,
  }) = BackupReady;

  const factory BackupState.working() = BackupWorking;

  const factory BackupState.exported(String fileName) = BackupExported;

  const factory BackupState.restored() = BackupRestored;

  const factory BackupState.error(String message) = BackupError;
}

/// The file the browser is asked to download.
final class BackupFile {
  const BackupFile({required this.fileName, required this.contents});

  final String fileName;
  final String contents;
}
