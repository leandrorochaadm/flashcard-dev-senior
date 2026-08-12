import 'dart:math' as math;

import 'package:flashcard_dev_senior/domain/mock_interview/mock_interview_service.dart';
import 'package:flashcard_dev_senior/domain/models/enums.dart';
import 'package:flashcard_dev_senior/domain/models/review_log.dart';
import 'package:flashcard_dev_senior/domain/models/schedule_window.dart';
import 'package:flashcard_dev_senior/domain/policies/due_cards_policy.dart';
import 'package:flashcard_dev_senior/domain/scheduling/fsrs_gateway.dart';
import 'package:flashcard_dev_senior/domain/scheduling/memory_state.dart';
import 'package:flashcard_dev_senior/domain/scheduling/optimizer/fsrs_optimizer.dart';
import 'package:flashcard_dev_senior/domain/stats/calibration.dart';
import 'package:flashcard_dev_senior/domain/stats/progress_stats.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/domain_fakes.dart';

const subjects = ['Estado', 'Widgets', 'Testes', 'Async', 'Plataforma'];

ReviewLog log(
  String cardId,
  DateTime at, {
  Rating rating = Rating.good,
  double predicted = 0.9,
  double stabilityBefore = 4,
  ReviewSource source = ReviewSource.session,
  Duration? timeOnCard,
}) =>
    ReviewLog(
      cardId: cardId,
      reviewedAt: at,
      rating: rating,
      elapsedDays: 2,
      predictedRetention: predicted,
      stabilityBefore: stabilityBefore,
      timeOnCard: timeOnCard,
      source: source,
    );

void main() {
  final importedAt = DateTime(2026, 8, 11);
  final window = ScheduleWindow.forFirstOpening(importedAt);

  group('mock interview', () {
    FakeCollection collectionOf({int perSubject = 20}) => FakeCollection([
          for (final subject in subjects)
            for (var i = 0; i < perSubject; i++)
              newCard('$subject-$i',
                  subject: subject,
                  importedAt: importedAt,
                  introducedAt: importedAt,
                  dueAt: importedAt.add(const Duration(days: 5))),
        ]);

    test('a 20-question mock is balanced across the subjects', () {
      final service = MockInterviewService(collectionOf(), random: math.Random(1));

      final drawn = service.draw(20);

      expect(drawn.length, 20);
      final perSubject = <String, int>{};
      for (final card in drawn) {
        perSubject[card.subject] = (perSubject[card.subject] ?? 0) + 1;
      }
      expect(perSubject.length, subjects.length);
      expect(perSubject.values.toSet(), {4});
    });

    test('a subject short of cards gives its quota back to the others', () {
      final collection = collectionOf(perSubject: 20);
      final thin = FakeCollection([
        ...collection.all.where((card) => card.subject != 'Async'),
        newCard('Async-0',
            subject: 'Async', importedAt: importedAt, introducedAt: importedAt),
      ]);
      final service = MockInterviewService(thin, random: math.Random(1));

      final drawn = service.draw(20);

      expect(drawn.length, 20);
      expect(drawn.where((card) => card.subject == 'Async').length, 1);
    });

    // Requirement 10: the mock draws cards far from their due date, so
    // rescheduling them would quietly undo the anticipation rule.
    test('the mock reschedules nothing: every dueAt is identical afterwards',
        () {
      final collection = collectionOf();
      final before = {for (final card in collection.all) card.id: card.dueAt};
      final service = MockInterviewService(collection, random: math.Random(3));

      final drawn = service.draw(20);
      final scores = service.score({for (final card in drawn) card: Rating.again});

      expect(scores, isNotEmpty);
      for (final card in collection.all) {
        expect(card.dueAt, before[card.id]);
        expect(card.lapses, 0);
        expect(card.stability, 0);
      }
    });

    test('the score is per subject and separate from the subject map', () {
      final collection = collectionOf();
      final service = MockInterviewService(collection, random: math.Random(5));
      final drawn = service.draw(10);

      final scores = service.score({
        for (var i = 0; i < drawn.length; i++)
          drawn[i]: i.isEven ? Rating.good : Rating.again,
      });

      expect(scores.map((score) => score.subject).toSet().length,
          greaterThan(1));
      expect(scores.fold(0, (sum, score) => sum + score.asked), 10);
    });

    test('a mock over an empty collection draws nothing instead of throwing',
        () {
      expect(MockInterviewService(FakeCollection()).draw(20), isEmpty);
    });
  });

  group('calibration', () {
    const calibration = Calibration();

    // Risk 4: the only indicator that audits the app cannot be contaminated.
    test('mock-interview reviews stay out of the curve', () {
      final day = DateTime(2026, 8, 20, 10);
      final logs = [
        log('a', day, rating: Rating.good, predicted: 0.9),
        log('b', day, rating: Rating.again, source: ReviewSource.mockInterview),
        log('c', day, rating: Rating.again, source: ReviewSource.mockInterview),
      ];

      final series = calibration.series(logs);

      expect(series.single.reviews, 1);
      expect(series.single.actual, 1.0);
      expect(calibration.accuracy(logs), 1.0);
    });

    test('the curve compares what was predicted with what happened, per day',
        () {
      final day = DateTime(2026, 8, 20, 10);
      final logs = [
        for (var i = 0; i < 10; i++)
          log('c$i', day.add(Duration(minutes: i)),
              rating: i < 8 ? Rating.good : Rating.again, predicted: 0.9),
      ];

      final point = calibration.series(logs).single;

      expect(point.predicted, closeTo(0.9, 0.0001));
      expect(point.actual, closeTo(0.8, 0.0001));
      expect(point.gap, lessThan(0));
    });

    test('the curve can be recomputed with older weights', () {
      final day = DateTime(2026, 8, 20, 10);
      // Not elapsed == stability: at that point every decay answers 0.9 by
      // definition, and the two curves would coincide by accident.
      final logs = [log('a', day, stabilityBefore: 8)];
      final flat = List<double>.filled(21, 0.5);

      final recomputed = calibration.seriesWithParameters(logs, flat);

      expect(recomputed.single.predicted,
          isNot(closeTo(logs.single.predictedRetention, 0.0001)));
    });
  });

  group('progress stats', () {
    test('the subject map counts ready cards and sorts worst first', () {
      final now = DateTime(2026, 8, 20);
      final collection = FakeCollection([
        for (var i = 0; i < 10; i++)
          newCard('estado$i',
              subject: 'Estado',
              importedAt: importedAt,
              introducedAt: importedAt,
              stability: 30),
        for (var i = 0; i < 10; i++)
          newCard('async$i',
              subject: 'Async',
              importedAt: importedAt,
              introducedAt: importedAt,
              stability: 1),
      ]);
      final stats = ProgressStats(
        collection,
        FakeWindow(window),
        DueCardsPolicy(collection),
      );

      final map = stats.subjectMap(now);

      expect(map.first.subject, 'Async');
      expect(map.first.ready, 0);
      expect(map.last.subject, 'Estado');
      expect(map.last.ready, 10);
    });

    test('the forecast returns one bar per day for the next seven days', () {
      final now = DateTime(2026, 8, 20, 9);
      final collection = FakeCollection([
        for (var i = 0; i < 5; i++)
          newCard('c$i',
              importedAt: importedAt,
              introducedAt: importedAt,
              dueAt: now.add(const Duration(days: 2))),
      ]);
      final stats = ProgressStats(
        collection,
        FakeWindow(window),
        DueCardsPolicy(collection),
      );

      final bars = stats.loadForecast(now);

      expect(bars.length, 7);
      expect(bars[2].cards, 5);
      expect(bars[0].cards, 0);
    });

    test('time over the ceiling never entered the average, the review did', () {
      final now = DateTime(2026, 8, 20, 9);
      final collection = FakeCollection([
        newCard('a',
            subject: 'Estado',
            importedAt: importedAt,
            introducedAt: importedAt),
      ]);
      final stats = ProgressStats(
        collection,
        FakeWindow(window),
        DueCardsPolicy(collection),
      );

      final logs = [
        log('a', now, timeOnCard: const Duration(seconds: 20)),
        log('a', now, timeOnCard: const Duration(seconds: 40)),
        log('a', now), // dropped by TimeOnCardPolicy.ceiling
      ];

      final times = stats.timeOnCard(logs);

      expect(times.overall, const Duration(seconds: 30));
      expect(times.bySubject['Estado'], const Duration(seconds: 30));
    });
  });

  group('self-tuning', () {
    test('the first tuning needs 400 reviews AND 7 days, not just the volume',
        () {
      final optimizer = FsrsOptimizer(_StubGateway());

      expect(
        optimizer.shouldTune(
          totalReviews: 450,
          daysOfUse: 6,
          reviewsSinceLastTuning: 450,
          hasTunedBefore: false,
        ),
        isFalse,
        reason: 'on day 6 almost every review is still a short-cycle rung',
      );
      expect(
        optimizer.shouldTune(
          totalReviews: 450,
          daysOfUse: 7,
          reviewsSinceLastTuning: 450,
          hasTunedBefore: false,
        ),
        isTrue,
      );
    });

    test('after the first one, it re-tunes every 200 new reviews', () {
      final optimizer = FsrsOptimizer(_StubGateway());

      expect(
        optimizer.shouldTune(
          totalReviews: 900,
          daysOfUse: 20,
          reviewsSinceLastTuning: 199,
          hasTunedBefore: true,
        ),
        isFalse,
      );
      expect(
        optimizer.shouldTune(
          totalReviews: 900,
          daysOfUse: 20,
          reviewsSinceLastTuning: 200,
          hasTunedBefore: true,
        ),
        isTrue,
      );
    });

    test('a sample too small keeps the current weights, in silence', () async {
      final result = await FsrsOptimizer(_StubGateway()).optimize([]);

      expect(result, isA<TuningSkipped>());
    });
  });
}

/// Enough of the gateway for the trigger rules; the fit itself goes through
/// the calibration formula, which is tested above.
final class _StubGateway implements FsrsGateway {
  @override
  List<double> get parameters => List<double>.filled(21, 0.5);

  @override
  bool parametersAreInRange(List<double> candidate) => true;

  @override
  MemoryState review(MemoryState state, Rating rating, DateTime now) =>
      throw UnimplementedError();

  @override
  double retrievability(MemoryState state, DateTime now) =>
      throw UnimplementedError();

  @override
  FsrsGateway withParameters(List<double> parameters) => this;

  @override
  void useParameters(List<double> parameters) {}
}
