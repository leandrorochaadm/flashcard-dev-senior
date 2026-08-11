import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../core/clock.dart';
import '../../data/repositories/card_repository.dart';
import '../../data/repositories/review_log_repository.dart';
import '../../domain/mock_interview/mock_interview_service.dart';
import '../../domain/models/card.dart';
import '../../domain/models/enums.dart';
import '../../domain/models/review_log.dart';
import '../../domain/scheduling/fsrs_gateway.dart';
import 'mock_interview_state.dart';

/// Sequences the mock interview (H10).
///
/// It writes a [ReviewLog] with `source = mockInterview` and NOTHING else: no
/// stability, no dueAt, no state, no lapses. A mock draws cards far from their
/// due date, and rescheduling them would quietly undo the anticipation rule —
/// and would contaminate the only indicator that audits the app.
class MockInterviewViewModel {
  MockInterviewViewModel(
    this._mock,
    this._logs,
    this._cards,
    this._fsrs,
    this._clock,
  );

  final MockInterviewService _mock;
  final ReviewLogRepository _logs;
  final CardRepository _cards;
  final FsrsGateway _fsrs;
  final Clock _clock;

  final state =
      ValueNotifier<MockInterviewState>(const MockInterviewState.loading());

  List<Card> _questions = const [];
  final _answers = <Card, Rating>{};

  /// Mock answers that already existed when this run started — the baseline
  /// the new score is compared against.
  Map<Card, Rating> _previousAnswers = const {};

  int _position = 0;
  Timer? _timer;
  Duration? _remaining;

  /// Set when the clock runs out. The question on screen is never cut off:
  /// [answer] is what ends the mock, after the current one is finished.
  bool _timeExpired = false;

  DateTime? _shownAt;

  void load() {
    _previousAnswers = _pastMockAnswers();
    state.value = MockInterviewState.setup(
      availableCards: _cards.all.where((card) => card.isReleased).length,
    );
  }

  /// A mock of a fixed number of questions. The balanced draw is the service's.
  void startByCount(int questions) {
    _questions = _mock.draw(questions);
    _remaining = null;
    _start();
  }

  /// A mock that runs for a stretch of time. The draw is the whole released
  /// collection: how far it gets is up to the clock.
  void startByTime(Duration duration) {
    _questions = _mock.draw(_cards.all.where((card) => card.isReleased).length);
    _remaining = duration;
    _tick();
    _start();
  }

  void _start() {
    _answers.clear();
    _position = 0;
    _timeExpired = false;
    if (_questions.isEmpty) {
      state.value = const MockInterviewState.error(
        'Não há cartões liberados para sortear um simulado.',
      );
      return;
    }
    _showQuestion();
  }

  void reveal() {
    final card = _currentCard;
    if (card == null) return;
    state.value = MockInterviewState.showingAnswer(
      card: card,
      position: _position + 1,
      total: _remaining == null ? _questions.length : null,
      remaining: _remaining,
      lastQuestion: _timeExpired,
    );
  }

  /// Records the answer and moves on. The end of the time never interrupts the
  /// question in progress — it is checked here, once the current one is done.
  Future<void> answer(Rating rating) async {
    final card = _currentCard;
    if (card == null) return;

    final now = _clock.now();
    _answers[card] = rating;
    await _logs.append(
      ReviewLog(
        cardId: card.id,
        reviewedAt: now,
        rating: rating,
        elapsedDays: _elapsedDays(card, now),
        predictedRetention: _fsrs.retrievability(card.memory, now),
        stabilityBefore: card.stability,
        // TODO(pontos em aberto): the requirements do not say whether the time
        // spent on a mock question feeds the average of the dashboard. Left
        // out, so the mock cannot move an indicator of scheduled study.
        timeOnCard: null,
        source: ReviewSource.mockInterview,
      ),
    );

    _position++;
    if (_timeExpired || _position >= _questions.length) {
      _finish();
      return;
    }
    _showQuestion();
  }

  void finishEarly() => _finish();

  void _showQuestion() {
    _shownAt = _clock.now();
    state.value = MockInterviewState.showingQuestion(
      card: _questions[_position],
      position: _position + 1,
      total: _remaining == null ? _questions.length : null,
      remaining: _remaining,
    );
  }

  void _finish() {
    _timer?.cancel();
    _timer = null;
    state.value = MockInterviewState.finished(
      scores: _mock.score(_answers),
      previousScores: _mock.score(_previousAnswers),
    );
  }

  void _tick() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      final left = _remaining;
      if (left == null) return;
      if (left.inSeconds <= 0) {
        // The flag only marks the mock as ending; `answer` closes it.
        _timeExpired = true;
        _timer?.cancel();
        _timer = null;
        _refreshRemaining();
        return;
      }
      _remaining = left - const Duration(seconds: 1);
      _refreshRemaining();
    });
  }

  /// Repaints the countdown without changing which question is on screen.
  void _refreshRemaining() {
    final current = state.value;
    state.value = switch (current) {
      MockInterviewShowingQuestion(:final card, :final position, :final total) =>
        MockInterviewState.showingQuestion(
          card: card,
          position: position,
          total: total,
          remaining: _remaining,
        ),
      MockInterviewShowingAnswer(:final card, :final position, :final total) =>
        MockInterviewState.showingAnswer(
          card: card,
          position: position,
          total: total,
          remaining: _remaining,
          lastQuestion: _timeExpired,
        ),
      _ => current,
    };
  }

  Card? get _currentCard =>
      _position < _questions.length ? _questions[_position] : null;

  /// How long since this card was last seen, in decimal days — the datum the
  /// log carries, not a scheduling decision.
  double _elapsedDays(Card card, DateTime now) {
    final last = card.lastReviewedAt;
    if (last == null) return 0;
    return now.difference(last).inMinutes / 1440;
  }

  /// Every mock answer already on record, as the service's score input.
  Map<Card, Rating> _pastMockAnswers() {
    final answers = <Card, Rating>{};
    for (final log in _logs.all) {
      if (log.source != ReviewSource.mockInterview) continue;
      final card = _cards.byId(log.cardId);
      if (card != null) answers[card] = log.rating;
    }
    return answers;
  }

  /// How long the current question has been open, for the View.
  Duration timeOnCurrentCard() {
    final shown = _shownAt;
    return shown == null ? Duration.zero : _clock.now().difference(shown);
  }

  void dispose() {
    _timer?.cancel();
    state.dispose();
  }
}
