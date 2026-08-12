import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../core/clock.dart';
import '../../data/repositories/card_repository.dart';
import '../../data/repositories/review_log_repository.dart';
import '../../data/repositories/session_repository.dart';
import '../../data/repositories/settings_repository.dart';
import '../../domain/models/card.dart';
import '../../domain/models/enums.dart';
import '../../domain/models/review_log.dart';
import '../../domain/models/study_session.dart';
import '../../domain/policies/due_cards_policy.dart';
import '../../domain/policies/session_policy.dart';
import '../../domain/policies/time_on_card_policy.dart';
import '../../domain/scheduling/card_scheduler.dart';
import '../../domain/scheduling/fsrs_gateway.dart';
import 'session_state.dart';

/// Sequences the study screen. It decides nothing about scheduling: the
/// scheduler places the card, the policies own the round, the ceiling and the
/// time-on-card cut. What lives here is the 1-second `Timer`, the notifiers and
/// the translation of domain results into [SessionState].
class SessionViewModel {
  SessionViewModel(
    this._scheduler,
    this._sessionPolicy,
    this._duePolicy,
    this._timeOnCardPolicy,
    this._cards,
    this._logs,
    this._sessions,
    this._settings,
    this._fsrs,
    this._clock,
  );

  final CardScheduler _scheduler;
  final SessionPolicy _sessionPolicy;
  final DueCardsPolicy _duePolicy;
  final TimeOnCardPolicy _timeOnCardPolicy;
  final CardRepository _cards;
  final ReviewLogRepository _logs;
  final SessionRepository _sessions;
  final SettingsRepository _settings;
  final FsrsGateway _fsrs;
  final Clock _clock;

  final state = ValueNotifier<SessionState>(const SessionState.loading());
  final roundRemaining = ValueNotifier<Duration>(SessionPolicy.roundDuration);
  final elapsedOnCard = ValueNotifier<Duration>(Duration.zero);

  /// The stopwatch is opt-in: seeing the seconds run adds pressure some days
  /// and helps on others, so the user turns it on and off.
  final stopwatchVisible = ValueNotifier<bool>(false);
  final paused = ValueNotifier<bool>(false);

  static const _tick = Duration(seconds: 1);

  Timer? _timer;
  StudySession? _session;
  Card? _currentCard;

  /// Cards already answered in this round. Handed to [DueCardsPolicy] as its
  /// `skip` argument, which is the policy's own knob for "do not serve this
  /// one again" — the ViewModel never filters the collection itself.
  final _answeredThisRound = <String>{};

  StudySession? get session => _session;

  /// Resumes an unfinished session — same round, same time left — or asks for
  /// the five subjects. An empty day short-circuits to the idle screen (H12).
  Future<void> init() async {
    state.value = const SessionState.loading();
    try {
      final resumed = await _sessions.unfinished();
      if (resumed != null) {
        _session = resumed;
        _beginRound(resetAnswered: true);
        return;
      }
      final now = _clock.now();
      if (_duePolicy.isDayCleared(now)) {
        state.value = const SessionState.dayCleared();
        return;
      }
      state.value =
          SessionState.chooseSubjects(_duePolicy.studiableSubjects(now));
    } on Object catch (error) {
      state.value = SessionState.error('$error');
    }
  }

  Future<void> start(List<String> subjects) async {
    final now = _clock.now();
    _session = _sessionPolicy.start(_newSessionId(now), now, subjects);
    await _persist();
    _beginRound(resetAnswered: true);
  }

  void reveal() {
    final card = _currentCard;
    final current = _session;
    if (card == null || current == null) return;
    final now = _clock.now();
    state.value = SessionState.showingAnswer(
      card,
      _scheduler.previewIntervals(card, now),
      current.currentRound,
      current.subjects.length,
      current.currentSubject,
      _remainingInRound(now, current.currentSubject),
    );
  }

  Future<void> answer(Rating rating) async {
    final card = _currentCard;
    final current = _session;
    if (card == null || current == null) return;

    // The card on screen is a snapshot taken when the round served it. It can
    // be gone by now: the collection screen and the mirroring import erase
    // cards while this session sits on the navigation stack. Saving the
    // snapshot would resurrect an erased card and log a review for it, so the
    // answer is dropped and the round moves on.
    if (_cards.byId(card.id) == null) {
      _answeredThisRound.add(card.id);
      _showNextCard();
      return;
    }

    final now = _clock.now();

    // Read before applying: afterwards the card already carries the new
    // stability, and the calibration chart compares prediction with outcome.
    final predictedRetention = _fsrs.retrievability(card.memory, now);
    final stabilityBefore = card.stability;
    final elapsedDays = card.observedIntervalDays(now);

    final updated = _scheduler.apply(card, rating, now);
    await _cards.save(updated);
    await _logs.append(
      ReviewLog(
        cardId: card.id,
        reviewedAt: now,
        rating: rating,
        elapsedDays: elapsedDays,
        predictedRetention: predictedRetention,
        stabilityBefore: stabilityBefore,
        timeOnCard: _timeOnCardPolicy.timeToRecord(elapsedOnCard.value),
        source: ReviewSource.session,
      ),
    );
    await _settings.countReview();

    _answeredThisRound.add(card.id);
    _session = _sessionPolicy.registerAnswer(current, rating);
    await _persist();

    if (_sessionPolicy.isRoundOver(_session!)) {
      _toRoundBreak();
    } else {
      _showNextCard();
    }
  }

  /// "Encerrar o round": stops the round before the five minutes run out. What
  /// was answered is already saved card by card, so nothing is lost — the
  /// screen just goes to the turn of the round.
  Future<void> endRound() async {
    if (await _updateSession(_sessionPolicy.endRound) == null) return;
    _toRoundBreak();
  }

  /// "Encerrar a sessão": gives up on the rounds that were still to come and
  /// goes straight to the scoreboard.
  Future<void> endSession() async {
    final updated = await _updateSession(_sessionPolicy.endSession);
    if (updated == null) return;
    _stopTimer();
    _currentCard = null;
    state.value = SessionState.scoreboard(updated);
  }

  /// "Estender o round": same subject, another full round.
  Future<void> extendRound() async {
    if (await _updateSession(_sessionPolicy.extendRound) == null) return;
    // The extension is a fresh pass over what is still due in the subject,
    // including the cards that went back to the 15-minute rung.
    _beginRound(resetAnswered: true);
  }

  Future<void> nextRound() async {
    final updated = await _updateSession(_sessionPolicy.advanceRound);
    if (updated == null) return;
    if (updated.finished) {
      _stopTimer();
      state.value = SessionState.scoreboard(updated);
      return;
    }
    _beginRound(resetAnswered: true);
  }

  /// Every round command is the same three steps: refuse to run without a
  /// session, hand it to the policy, save what came back. Returns the new
  /// session, or `null` when there was none to change.
  Future<StudySession?> _updateSession(
    StudySession Function(StudySession) change,
  ) async {
    final current = _session;
    if (current == null) return null;
    _session = change(current);
    await _persist();
    return _session;
  }

  /// Pausing simply stops ticking, which freezes the card stopwatch, the round
  /// and the session at once — the remaining time is state, not a wall-clock
  /// difference.
  void togglePause() => paused.value = !paused.value;

  void toggleStopwatch() => stopwatchVisible.value = !stopwatchVisible.value;

  void dispose() {
    _stopTimer();
    state.dispose();
    roundRemaining.dispose();
    elapsedOnCard.dispose();
    stopwatchVisible.dispose();
    paused.dispose();
  }

  void _beginRound({required bool resetAnswered}) {
    // A resumed session can carry a round that is already over — that is what
    // ending one early leaves in the database. Serving a card here would put a
    // clickable question on a 00:00 clock until the next tick noticed.
    if (_sessionPolicy.isRoundOver(_session!)) {
      _toRoundBreak();
      return;
    }
    if (resetAnswered) _answeredThisRound.clear();
    // A round always starts running. Without this, ending a paused round early
    // would carry the pause into the next one, whose clock would then sit
    // frozen at 5:00 while the timer discards every tick.
    paused.value = false;
    roundRemaining.value = _session!.remainingInRound;
    _startTimer();
    _showNextCard();
  }

  void _showNextCard() {
    final current = _session!;
    final now = _clock.now();
    final next = _duePolicy.nextDueCard(
      now,
      current.currentSubject,
      skip: _answeredThisRound,
    );
    if (next == null) {
      _toRoundBreak();
      return;
    }
    _currentCard = next;
    elapsedOnCard.value = Duration.zero;
    state.value = SessionState.showingQuestion(
      next,
      current.currentRound,
      current.subjects.length,
      current.currentSubject,
      _remainingInRound(now, current.currentSubject),
    );
  }

  /// The counter next to the clock. Counting is the policy's job — the
  /// ViewModel only hands it the set of cards already answered.
  int _remainingInRound(DateTime now, String subject) =>
      _duePolicy.studiableCount(now, subject, skip: _answeredThisRound);

  void _toRoundBreak() {
    final current = _session!;
    _stopTimer();
    _currentCard = null;
    state.value = SessionState.roundBreak(
      current.currentSubject,
      current.nextSubject,
      _duePolicy.dueNow(_clock.now(), subject: current.currentSubject).length,
      // The session carries it, so a reload still tells the two endings
      // apart — the round that ran out and the one the user stopped.
      endedEarly: current.roundEndedEarly,
    );
  }

  void _startTimer() {
    _stopTimer();
    _timer = Timer.periodic(_tick, (_) => _onTick());
  }

  void _stopTimer() {
    _timer?.cancel();
    _timer = null;
  }

  void _onTick() {
    if (paused.value) return;
    final current = _session;
    if (current == null) return;

    _session = _sessionPolicy.tick(current, _tick);
    roundRemaining.value = _session!.remainingInRound;
    if (_currentCard != null) {
      elapsedOnCard.value = elapsedOnCard.value + _tick;
    }
    if (_sessionPolicy.isRoundOver(_session!)) {
      unawaited(_persist());
      _toRoundBreak();
    }
  }

  Future<void> _persist() async {
    final current = _session;
    if (current != null) await _sessions.save(current);
  }

  String _newSessionId(DateTime now) =>
      'session-${now.microsecondsSinceEpoch}';
}
