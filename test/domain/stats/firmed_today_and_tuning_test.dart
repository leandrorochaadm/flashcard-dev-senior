import 'package:flashcard_dev_senior/domain/import/import_preview.dart';
import 'package:flashcard_dev_senior/domain/mock_interview/mock_interview_service.dart';
import 'package:flashcard_dev_senior/domain/models/card.dart';
import 'package:flashcard_dev_senior/domain/models/enums.dart';
import 'package:flashcard_dev_senior/domain/models/review_log.dart';
import 'package:flashcard_dev_senior/domain/models/schedule_window.dart';
import 'package:flashcard_dev_senior/domain/policies/due_cards_policy.dart';
import 'package:flashcard_dev_senior/domain/scheduling/fsrs_adapter.dart';
import 'package:flashcard_dev_senior/domain/scheduling/optimizer/fsrs_optimizer.dart';
import 'package:flashcard_dev_senior/domain/stats/progress_stats.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/domain_fakes.dart';

void main() {
  final importedAt = DateTime(2026, 8, 11);
  final today = DateTime(2026, 8, 20, 18);
  final window = ScheduleWindow.forFirstOpening(importedAt);

  ReviewLog crossing(
    String cardId,
    DateTime at, {
    required double stabilityBefore,
    Rating rating = Rating.good,
    ReviewSource source = ReviewSource.session,
  }) =>
      ReviewLog(
        cardId: cardId,
        reviewedAt: at,
        rating: rating,
        elapsedDays: 2,
        predictedRetention: 0.9,
        stabilityBefore: stabilityBefore,
        timeOnCard: null,
        source: source,
      );

  ProgressStats statsOf(FakeCollection collection) =>
      ProgressStats(collection, FakeWindow(window), DueCardsPolicy(collection));

  group('cards that firmed today', () {
    Card firmCard(String id, {required DateTime lastReviewedAt}) =>
        newCard(id, importedAt: importedAt, introducedAt: importedAt, stability: 9)
            .copyWith(lastReviewedAt: lastReviewedAt);

    test('a card that crossed into firm today counts', () {
      final collection = FakeCollection([firmCard('a', lastReviewedAt: today)]);

      final firmed = statsOf(collection).firmedToday(
        today,
        [crossing('a', today, stabilityBefore: 4)],
      );

      expect(firmed, 1);
    });

    test('a card that was already firm before today does not count again', () {
      final collection = FakeCollection([firmCard('a', lastReviewedAt: today)]);

      final firmed = statsOf(collection).firmedToday(today, [
        crossing('a', today.subtract(const Duration(days: 3)),
            stabilityBefore: 4),
        crossing('a', today, stabilityBefore: 8),
      ]);

      expect(firmed, 0, reason: 'it crossed three days ago, not today');
    });

    test('a firm card not reviewed today does not count', () {
      final collection = FakeCollection([
        firmCard('a', lastReviewedAt: today.subtract(const Duration(days: 2))),
      ]);

      expect(statsOf(collection).firmedToday(today, []), 0);
    });

    test('a card that is not firm yet never counts', () {
      final collection = FakeCollection([
        newCard('a',
                importedAt: importedAt,
                introducedAt: importedAt,
                stability: 3)
            .copyWith(lastReviewedAt: today),
      ]);

      expect(
        statsOf(collection).firmedToday(today, [
          crossing('a', today, stabilityBefore: 1),
        ]),
        0,
      );
    });

    test('a mock interview never moves the counter', () {
      final collection = FakeCollection([firmCard('a', lastReviewedAt: today)]);

      final firmed = statsOf(collection).firmedToday(today, [
        crossing('a', today.subtract(const Duration(days: 4)),
            stabilityBefore: 2, source: ReviewSource.mockInterview),
        crossing('a', today, stabilityBefore: 4),
      ]);

      expect(firmed, 1);
    });

    test('a card held back by the intake policy is invisible to the counter',
        () {
      final collection = FakeCollection([
        newCard('a', importedAt: importedAt, stability: 9)
            .copyWith(lastReviewedAt: today),
      ]);

      expect(
        statsOf(collection).firmedToday(today, [
          crossing('a', today, stabilityBefore: 4),
        ]),
        0,
      );
    });
  });

  test('problem cards are listed for the banner', () {
    final collection = FakeCollection([
      newCard('ok', importedAt: importedAt, introducedAt: importedAt),
      newCard('bad',
          importedAt: importedAt, introducedAt: importedAt, lapses: 4),
    ]);

    expect(
      statsOf(collection).problemCards().map((card) => card.id),
      ['bad'],
    );
  });

  test('no times recorded at all leaves the average empty, not zero', () {
    final collection = FakeCollection([
      newCard('a', importedAt: importedAt, introducedAt: importedAt),
    ]);

    final times = statsOf(collection).timeOnCard([]);

    expect(times.overall, isNull);
    expect(times.bySubject, isEmpty);
  });

  test('a subject with no released cards produces no line on the map', () {
    final collection = FakeCollection([
      newCard('held', importedAt: importedAt),
    ]);

    expect(statsOf(collection).subjectMap(today), isEmpty);
  });

  group('the optimizer', () {
    // Reviews that systematically beat the prediction: the fit has room to
    // improve, which is what "the app re-tunes itself" means.
    List<ReviewLog> biasedSample() => [
          for (var i = 0; i < 500; i++)
            crossing('c$i', today.add(Duration(minutes: i)),
                stabilityBefore: 5,
                rating: i % 20 == 0 ? Rating.again : Rating.good),
        ];

    test('it improves the log-loss and keeps the weights inside the bounds',
        () async {
      final gateway = FsrsAdapter();
      final optimizer = FsrsOptimizer(gateway, epochs: 2);

      final result = await optimizer.optimize(biasedSample());

      expect(result, isA<TuningApplied>());
      final applied = result as TuningApplied;
      expect(applied.lossAfter, lessThan(applied.lossBefore));
      expect(gateway.parametersAreInRange(applied.parameters), isTrue);
      expect(applied.parameters.length, gateway.parameters.length);
    });

    test('mock-interview reviews never enter the training set', () async {
      final optimizer = FsrsOptimizer(FsrsAdapter(), epochs: 1);

      final result = await optimizer.optimize([
        for (var i = 0; i < 500; i++)
          crossing('c$i', today,
              stabilityBefore: 5, source: ReviewSource.mockInterview),
      ]);

      expect(result, isA<TuningSkipped>());
      expect((result as TuningSkipped).reason, contains('amostra'));
    });

    test('reviews with no stability yet are dropped from the sample', () async {
      final optimizer = FsrsOptimizer(FsrsAdapter(), epochs: 1);

      final result = await optimizer.optimize([
        for (var i = 0; i < 500; i++)
          crossing('c$i', today, stabilityBefore: 0),
      ]);

      expect(result, isA<TuningSkipped>());
    });
  });

  test('an empty preview knows it is empty', () {
    const empty = ImportPreview(valid: [], invalid: []);
    const withIssues = ImportPreview(
      valid: [],
      invalid: [
        InvalidBlock(blockIndex: 0, rawText: '', issues: [ImportIssue.missingSubject]),
      ],
    );

    expect(empty.isEmpty, isTrue);
    expect(withIssues.isEmpty, isFalse);
  });

  test('a mock over a collection with nothing released draws nothing', () {
    final collection = FakeCollection([newCard('held', importedAt: importedAt)]);

    expect(MockInterviewService(collection).draw(10), isEmpty);
  });
}
