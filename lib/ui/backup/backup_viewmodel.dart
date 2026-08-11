import 'package:flutter/foundation.dart';

import '../../core/clock.dart';
import '../../data/repositories/backup_repository.dart';
import '../../data/repositories/card_repository.dart';
import '../../data/repositories/review_log_repository.dart';
import '../../data/repositories/settings_repository.dart';
import '../../domain/models/schedule_window.dart';
import 'backup_state.dart';

/// The backup window (H14): the only real protection against the browser
/// evicting IndexedDB, so the screen also has to say how long it has been
/// since the last one.
class BackupViewModel {
  BackupViewModel(
    this._backups,
    this._settings,
    this._cards,
    this._reviews,
    this._clock,
  );

  final BackupRepository _backups;
  final SettingsRepository _settings;
  final CardRepository _cards;
  final ReviewLogRepository _reviews;
  final Clock _clock;

  late final state = ValueNotifier<BackupState>(_readyState());

  BackupState _readyState() {
    final last = _settings.lastBackupAt;
    return BackupState.ready(
      lastBackupAt: last,
      daysSinceLastBackup: last == null
          ? null
          : dateOnly(_clock.now()).difference(dateOnly(last)).inDays,
      cardCount: _cards.all.length,
      reviewCount: _reviews.count,
    );
  }

  void refresh() => state.value = _readyState();

  /// Produces the file. Handing it to the browser is the View's job — writing
  /// a file is not something a ViewModel can do on Flutter Web.
  Future<BackupFile?> export() async {
    state.value = const BackupState.working();
    try {
      final now = _clock.now();
      final contents = await _backups.export(now);
      final fileName = _backups.fileNameFor(now);
      await _settings.markBackup(now);
      state.value = BackupState.exported(fileName);
      return BackupFile(fileName: fileName, contents: contents);
    } on Object catch (error) {
      state.value =
          BackupState.error('Não foi possível gerar a cópia: $error');
      return null;
    }
  }

  /// Destructive: replaces everything that is in the database today. The View
  /// must have confirmed with the user before calling this.
  Future<void> restore(String contents) async {
    state.value = const BackupState.working();
    try {
      await _backups.restore(contents);
      // The in-memory caches are stale after a restore.
      await _cards.load();
      await _reviews.load();
      await _settings.load(_clock.now());
      state.value = const BackupState.restored();
    } on Object catch (error) {
      state.value =
          BackupState.error('Não foi possível restaurar: $error');
    }
  }

  void dispose() => state.dispose();
}
