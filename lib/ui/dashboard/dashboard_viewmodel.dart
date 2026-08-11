import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';

import '../../core/clock.dart';
import '../../core/daily_release.dart';
import '../../data/repositories/review_log_repository.dart';
import '../../data/repositories/session_repository.dart';
import '../../data/repositories/settings_repository.dart';
import '../../domain/models/schedule_window.dart';
import '../../domain/policies/content_intake_policy.dart';
import '../../domain/policies/due_cards_policy.dart';
import '../../domain/scheduling/fsrs_adapter.dart' show desiredRetention;
import '../../domain/scheduling/fsrs_gateway.dart';
import '../../domain/scheduling/moving_ceiling.dart';
import '../../domain/scheduling/optimizer/fsrs_optimizer.dart';
import '../../domain/stats/calibration.dart';
import '../../domain/stats/progress_stats.dart';
import 'dashboard_state.dart';

/// Sequences the dashboard. It computes nothing: every number it publishes was
/// produced by a domain class, because an indicator that audits the app cannot
/// be testable only through a widget.
class DashboardViewModel {
  DashboardViewModel(
    this._stats,
    this._calibration,
    this._dueCards,
    this._release,
    this._ceiling,
    this._optimizer,
    this._fsrs,
    this._logs,
    this._sessions,
    this._settings,
    this._clock,
  );

  final ProgressStats _stats;
  final Calibration _calibration;
  final DueCardsPolicy _dueCards;
  final DailyRelease _release;
  final MovingCeiling _ceiling;
  final FsrsOptimizer _optimizer;
  final FsrsGateway _fsrs;
  final ReviewLogRepository _logs;
  final SessionRepository _sessions;
  final SettingsRepository _settings;
  final Clock _clock;

  final state = ValueNotifier<DashboardState>(const DashboardState.loading());

  /// Message of the last tuning attempt, kept between reloads.
  String? _tuningMessage;

  /// The dashboard no longer releases anything — `DailyRelease` did it at
  /// startup, and on every resume. It reads the day's outcome, so the intake
  /// notice still explains a batch that was held or reduced.
  Future<void> load() async {
    try {
      // Covers the PWA reopened on a new day: the resume listener may not have
      // fired yet, and `run()` is idempotent once today's batch has gone out.
      // It returns the day's real reason — including a held or reduced batch —
      // so the notice survives every reopening of the dashboard.
      await _publish(await _release.run());
    } on Object catch (error) {
      state.value = DashboardState.error('Não foi possível abrir o painel: $error');
    }
  }

  /// H13: the target date is a datum, re-picked on a calendar. Re-picking it
  /// re-anchors nothing — the ceiling counts the days that remain.
  Future<void> setTargetDate(DateTime target) async {
    await _settings.setTargetDate(target);
    await load();
  }

  /// Sticks with the current target and lets the schedule run on the floor of
  /// one day, but records the answer so the question stops being asked.
  Future<void> keepDeadline() async {
    await _settings.setDeadlineAnswered(true);
    await load();
  }

  /// "Faltando N dias, os cartões voltam a cada ~X" — the number comes from
  /// the domain, never from arithmetic in the View.
  Duration ceilingForCandidateTarget(DateTime candidateTarget) =>
      _ceiling.forCandidateTarget(_clock.now(), candidateTarget);

  /// Self-tuning. Only outside a session, because it runs in slices on the
  /// main thread — there is no isolate in Flutter Web.
  Future<void> runTuningIfDue() async {
    final now = _clock.now();
    final due = _optimizer.shouldTune(
      totalReviews: _logs.sessionOnly.length,
      daysOfUse: _settings.window.dayOfUse(now),
      reviewsSinceLastTuning: _settings.reviewsSinceTuning,
      hasTunedBefore: _settings.activeParameters != null,
    );
    if (!due) return;

    try {
      final result = await _optimizer.optimize(_logs.all);
      switch (result) {
        case TuningApplied(:final parameters):
          await _settings.applyParameters(parameters, now);
          // The gateway adopts the weights in place: the next answer is
          // already scheduled with them.
          _fsrs.useParameters(parameters);
          _tuningMessage =
              'Ajuste aplicado sobre as suas respostas. Já vale a partir '
              'da próxima resposta.';
        case TuningSkipped(:final reason):
          // Keeping the previous weights in silence is the designed outcome:
          // the app has to work entirely on them.
          _tuningMessage = 'Ajuste não aplicado ($reason). '
              'Os parâmetros anteriores continuam valendo.';
      }
    } on Object catch (error) {
      _tuningMessage = 'O ajuste automático falhou ($error). '
          'Os parâmetros anteriores continuam valendo.';
    }
    await load();
  }

  /// Undo of the self-tuning. The button is hidden when there is nothing to
  /// go back to.
  Future<void> revertTuning() async {
    final reverted = await _settings.revertParameters();
    if (reverted != null) _fsrs.useParameters(reverted);
    _tuningMessage = reverted == null
        ? null
        : 'Voltamos aos parâmetros anteriores. Já vale a partir da '
            'próxima resposta.';
    await load();
  }

  Future<void> _publish(IntakeRelease release) async {
    final now = _clock.now();
    final logs = _logs.all;
    final window = _settings.window;
    final previous = _settings.previousParams();
    final lastBackup = _settings.lastBackupAt;

    state.value = DashboardState.ready(
      firmedToday: _stats.firmedToday(now, logs),
      accuracy: _calibration.accuracy(logs),
      targetRetention: desiredRetention,
      subjects: _stats.subjectMap(now),
      lastSession: (await _sessions.all()).firstOrNull,
      calibration: _calibration.series(logs),
      previousCalibration: previous == null
          ? null
          : _calibration.seriesWithParameters(logs, previous.parameters),
      load: _stats.loadForecast(now),
      timeOnCard: _stats.timeOnCard(logs),
      ceilingToday: _ceiling.forDate(now),
      daysToTarget: window.daysRemainingFrom(now),
      targetDate: window.targetDate,
      // Display formatting of an age, not a scheduling rule.
      daysSinceBackup: lastBackup == null
          ? null
          : dateOnly(now).difference(dateOnly(lastBackup)).inDays,
      dayCleared: _dueCards.isDayCleared(now),
      deadlineReached:
          window.isPastDeadline(now) && !_settings.deadlineAnswered,
      intake: release,
      canRevertTuning: previous != null,
      tuningMessage: _tuningMessage,
    );
  }

  /// The weights in force, for the tuning panel.
  List<double> get parameters => _fsrs.parameters;

  void dispose() => state.dispose();
}
