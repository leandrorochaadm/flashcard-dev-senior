import 'dart:math' as math;

// The one and only file allowed to import the package. The prefix is
// mandatory: it exports Card, ReviewLog, Rating and State, all homonyms of
// ours.
import 'package:fsrs/fsrs.dart' as fsrs;

import '../models/enums.dart';
import 'fsrs_gateway.dart';
import 'memory_state.dart';

/// The four steps of the short cycle: 15 min → 1 h → 4 h → 1 day.
const learningSteps = <Duration>[
  Duration(minutes: 15),
  Duration(hours: 1),
  Duration(hours: 4),
  Duration(days: 1),
];

/// Target retention: Leandro should recall about 9 out of every 10 cards.
const desiredRetention = 0.90;

/// Translates between [MemoryState] and `fsrs.Card`.
///
/// Three package traps are confined here:
/// 1. `reviewCard` throws unless `reviewDateTime` is UTC — the Clock hands out
///    local time, so `toUtc()` on the way in and `toLocal()` on the way out.
/// 2. `getCardRetrievability` uses `.inDays`, which truncates: during the
///    whole short cycle it would answer a constant 1.0 and the calibration
///    would be a meaningless straight line. Recomputed here on decimal days.
/// 3. `fsrs.Card`'s constructor defaults `due` to `DateTime.now()` and fills
///    `step` on its own — both are always passed explicitly.
final class FsrsAdapter implements FsrsGateway {
  FsrsAdapter([List<double>? parameters])
      : parameters = List.unmodifiable(parameters ?? fsrs.defaultParameters),
        _scheduler = fsrs.Scheduler(
          parameters: parameters ?? fsrs.defaultParameters,
          desiredRetention: desiredRetention,
          learningSteps: learningSteps,
          // The requirements say a card just missed goes through the four
          // steps again ("errar em qualquer degrau volta o cartão para o
          // primeiro"), so relearning repeats the same ladder.
          relearningSteps: learningSteps,
          // Off on purpose: it is an int in days and cannot express a decimal
          // ceiling. The moving ceiling runs at step 5 of our pipeline.
          maximumInterval: 36500,
          // Off on purpose: the package fuzzes before the ceiling, which would
          // punch through it. Fuzzing is step 3 of our pipeline.
          enableFuzzing: false,
        );

  final fsrs.Scheduler _scheduler;

  @override
  final List<double> parameters;

  /// The package does not use `cardId` in any calculation, so a constant is
  /// enough — our ids are strings like `est-001`.
  static const _unusedCardId = 0;

  @override
  MemoryState review(MemoryState state, Rating rating, DateTime now) {
    final reviewedAt = now.toUtc();
    final result = _scheduler.reviewCard(
      _toFsrs(state, reviewedAt),
      _toFsrsRating(rating),
      reviewDateTime: reviewedAt,
    );
    final card = result.card;
    return MemoryState(
      state: _fromFsrsState(card.state),
      step: card.step ?? 0,
      stability: card.stability ?? 0,
      difficulty: card.difficulty ?? 0,
      dueAt: card.due.toLocal(),
      lastReviewedAt: card.lastReview?.toLocal() ?? now,
    );
  }

  @override
  double retrievability(MemoryState state, DateTime now) {
    final lastReview = state.lastReviewedAt;
    // The package answers 0 for a never-answered card; that would enter the
    // calibration as a huge prediction error on every card's first review.
    if (lastReview == null || state.stability <= 0) return 1;

    final decay = -parameters[20];
    final factor = math.pow(0.9, 1 / decay) - 1;
    final elapsedDays =
        math.max(0, now.difference(lastReview).inMinutes) / 1440.0;
    return math
        .pow(1 + factor * elapsedDays / state.stability, decay)
        .toDouble()
        .clamp(0.0, 1.0);
  }

  @override
  bool parametersAreInRange(List<double> candidate) {
    if (candidate.length != fsrs.lowerBoundsParameters.length) return false;
    for (var i = 0; i < candidate.length; i++) {
      final value = candidate[i];
      if (value.isNaN || value.isInfinite) return false;
      if (value < fsrs.lowerBoundsParameters[i]) return false;
      if (value > fsrs.upperBoundsParameters[i]) return false;
    }
    return true;
  }

  @override
  FsrsGateway withParameters(List<double> parameters) =>
      FsrsAdapter(parameters);

  fsrs.Card _toFsrs(MemoryState state, DateTime nowUtc) => fsrs.Card(
        cardId: _unusedCardId,
        state: _toFsrsState(state.state),
        // Always explicit: the position in the short cycle is our decision,
        // not a default filled in by the package.
        step: state.state.isLearning ? state.step : null,
        stability: state.stability > 0 ? state.stability : null,
        difficulty: state.difficulty > 0 ? state.difficulty : null,
        // Always explicit: the default is `DateTime.now()`, which would punch
        // a silent hole in the injected Clock.
        due: state.dueAt?.toUtc() ?? nowUtc,
        lastReview: state.lastReviewedAt?.toUtc(),
      );

  /// `fsrs.State` has no "new": a brand new card enters as learning, step 0.
  fsrs.State _toFsrsState(CardState state) => switch (state) {
        CardState.newCard || CardState.learning => fsrs.State.learning,
        CardState.review => fsrs.State.review,
        CardState.relearning => fsrs.State.relearning,
      };

  CardState _fromFsrsState(fsrs.State state) => switch (state) {
        fsrs.State.learning => CardState.learning,
        fsrs.State.review => CardState.review,
        fsrs.State.relearning => CardState.relearning,
      };

  fsrs.Rating _toFsrsRating(Rating rating) => switch (rating) {
        Rating.again => fsrs.Rating.again,
        Rating.hard => fsrs.Rating.hard,
        Rating.good => fsrs.Rating.good,
        Rating.easy => fsrs.Rating.easy,
      };
}
