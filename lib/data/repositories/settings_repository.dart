import '../../domain/models/schedule_window.dart';
import '../../domain/ports.dart';
import '../database/app_database.dart';

/// One tuning of the FSRS weights, with the date it started to apply.
///
/// The date is what lets the calibration curve be recomputed retroactively:
/// the "before" line applies the previous weights to the same reviews.
final class ParameterSnapshot {
  const ParameterSnapshot({required this.parameters, required this.appliedAt});

  factory ParameterSnapshot.fromJson(Map<String, Object?> json) =>
      ParameterSnapshot(
        parameters: [
          for (final value in json['parameters']! as List) (value as num).toDouble(),
        ],
        appliedAt: DateTime.parse(json['appliedAt']! as String),
      );

  final List<double> parameters;
  final DateTime appliedAt;

  Map<String, Object?> toJson() => {
        'parameters': parameters,
        'appliedAt': appliedAt.toIso8601String(),
      };
}

/// Everything that is a datum and not a constant: the window, the weights and
/// the counters that drive the self-tuning.
final class SettingsRepository implements ScheduleWindowView {
  SettingsRepository(this._db);

  static const _keyStartDate = 'startDate';
  static const _keyTargetDate = 'targetDate';
  static const _keyParameters = 'fsrsParameters';
  static const _keyParameterHistory = 'fsrsParameterHistory';
  static const _keyReviewsSinceTuning = 'reviewsSinceTuning';
  static const _keyLastBackupAt = 'lastBackupAt';
  static const _keyDeadlineAnswered = 'deadlineAnswered';

  final AppDatabase _db;

  ScheduleWindow? _window;
  List<double>? _activeParameters;
  final _history = <ParameterSnapshot>[];
  int _reviewsSinceTuning = 0;
  DateTime? _lastBackup;
  bool _deadlineAnswered = false;

  @override
  ScheduleWindow get window {
    final window = _window;
    if (window == null) {
      throw StateError('SettingsRepository.load() has not run yet.');
    }
    return window;
  }

  /// Reads everything and, on the very first opening, anchors the window.
  ///
  /// `startDate` is written once and never again: re-anchoring on every
  /// opening would keep the ceiling on day 1 forever.
  Future<void> load(DateTime now) async {
    final storedStart = await _db.readSetting(_keyStartDate) as String?;
    if (storedStart == null) {
      final fresh = ScheduleWindow.forFirstOpening(now);
      await _db.writeSetting(_keyStartDate, fresh.startDate.toIso8601String());
      await _db.writeSetting(_keyTargetDate, fresh.targetDate.toIso8601String());
      _window = fresh;
    } else {
      final storedTarget = await _db.readSetting(_keyTargetDate) as String?;
      final start = DateTime.parse(storedStart);
      _window = ScheduleWindow(
        startDate: start,
        targetDate: storedTarget == null
            ? ScheduleWindow.forFirstOpening(
                start.add(const Duration(days: 1)),
              ).targetDate
            : DateTime.parse(storedTarget),
      );
    }

    final parameters = await _db.readSetting(_keyParameters) as List?;
    _activeParameters = parameters == null
        ? null
        : [for (final value in parameters) (value as num).toDouble()];

    final history = await _db.readSetting(_keyParameterHistory) as List?;
    _history
      ..clear()
      ..addAll([
        for (final entry in history ?? const [])
          ParameterSnapshot.fromJson(Map<String, Object?>.from(entry as Map)),
      ]);

    _reviewsSinceTuning = (await _db.readSetting(_keyReviewsSinceTuning) as int?) ?? 0;
    final backup = await _db.readSetting(_keyLastBackupAt) as String?;
    _lastBackup = backup == null ? null : DateTime.parse(backup);
    _deadlineAnswered =
        (await _db.readSetting(_keyDeadlineAnswered) as bool?) ?? false;
  }

  /// Re-picking the target re-anchors nothing: the ceiling counts the days
  /// that remain, so it follows the real urgency on its own.
  Future<void> setTargetDate(DateTime target) async {
    _window = window.withTarget(target);
    await _db.writeSetting(_keyTargetDate, window.targetDate.toIso8601String());
    await setDeadlineAnswered(true);
  }

  /// `null` = the app still runs on the package's default weights.
  List<double>? get activeParameters => _activeParameters;

  List<ParameterSnapshot> get parameterHistory => List.unmodifiable(_history);

  /// `null` = there has never been a tuning → hide the "voltar ao anterior"
  /// button.
  ParameterSnapshot? previousParams() => _history.isEmpty ? null : _history.last;

  Future<void> applyParameters(List<double> parameters, DateTime now) async {
    final current = _activeParameters;
    if (current != null) {
      _history.add(ParameterSnapshot(parameters: current, appliedAt: now));
      await _db.writeSetting(_keyParameterHistory,
        [for (final snapshot in _history) snapshot.toJson()],
      );
    }
    _activeParameters = parameters;
    await _db.writeSetting(_keyParameters, parameters);
    await resetReviewsSinceTuning();
  }

  /// Undo: goes back to the weights that were in force before the last tuning.
  Future<List<double>?> revertParameters() async {
    if (_history.isEmpty) return null;
    final previous = _history.removeLast();
    _activeParameters = previous.parameters;
    await _db.writeSetting(_keyParameters, previous.parameters);
    await _db.writeSetting(_keyParameterHistory,
      [for (final snapshot in _history) snapshot.toJson()],
    );
    return previous.parameters;
  }

  int get reviewsSinceTuning => _reviewsSinceTuning;

  Future<void> countReview() async {
    _reviewsSinceTuning++;
    await _db.writeSetting(_keyReviewsSinceTuning, _reviewsSinceTuning);
  }

  Future<void> resetReviewsSinceTuning() async {
    _reviewsSinceTuning = 0;
    await _db.writeSetting(_keyReviewsSinceTuning, 0);
  }

  DateTime? get lastBackupAt => _lastBackup;

  Future<void> markBackup(DateTime now) async {
    _lastBackup = now;
    await _db.writeSetting(_keyLastBackupAt, now.toIso8601String());
  }

  /// Whether the deadline question of H13 has already been answered, so the
  /// app does not ask again every opening.
  bool get deadlineAnswered => _deadlineAnswered;

  Future<void> setDeadlineAnswered(bool value) async {
    _deadlineAnswered = value;
    await _db.writeSetting(_keyDeadlineAnswered, value);
  }
}
