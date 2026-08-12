import 'package:flashcard_dev_senior/domain/models/card.dart';
import 'package:flashcard_dev_senior/domain/models/enums.dart';
import 'package:flashcard_dev_senior/domain/models/review_log.dart';
import 'package:flashcard_dev_senior/domain/models/schedule_window.dart';
import 'package:flashcard_dev_senior/domain/policies/due_cards_policy.dart';
import 'package:flashcard_dev_senior/domain/stats/progress_stats.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/domain_fakes.dart';

/// The collection funnel and the study streak: where every number the
/// dashboard shows comes from. No `WidgetTester` anywhere.
void main() {
  final importedAt = DateTime(2026, 8, 11);
  final now = DateTime(2026, 8, 20, 9);
  final window = ScheduleWindow.forFirstOpening(importedAt);

  ProgressStats statsOf(FakeCollection collection, {FakeWindow? on}) =>
      ProgressStats(
        collection,
        on ?? FakeWindow(window),
        DueCardsPolicy(collection),
      );

  Card released(
    String id, {
    String subject = 'Estado',
    double stability = 0,
    CardState state = CardState.newCard,
    DateTime? dueAt,
    int lapses = 0,
    int reps = 0,
  }) =>
      newCard(
        id,
        subject: subject,
        importedAt: importedAt,
        introducedAt: importedAt,
        stability: stability,
        state: state,
        dueAt: dueAt,
        lapses: lapses,
      ).copyWith(reps: reps);

  ReviewLog answer(
    String cardId,
    DateTime at, {
    ReviewSource source = ReviewSource.session,
  }) =>
      ReviewLog(
        cardId: cardId,
        reviewedAt: at,
        rating: Rating.good,
        elapsedDays: 1,
        predictedRetention: 0.9,
        stabilityBefore: 3,
        timeOnCard: null,
        source: source,
      );

  group('the collection funnel', () {
    test('held counts only cards with a null introducedAt', () {
      final collection = FakeCollection([
        newCard('held', importedAt: importedAt),
        released('out'),
      ]);

      final overview = statsOf(collection).overview(now);

      expect(overview.total, 2);
      expect(overview.held, 1, reason: 'importing is not releasing');
      expect(overview.released, 1);
    });

    test('released totals exclude held cards', () {
      final collection = FakeCollection([
        newCard('held', importedAt: importedAt, stability: 9, lapses: 4),
        released('out', stability: 9, lapses: 4),
      ]);

      final overview = statsOf(collection).overview(now);

      expect(overview.firm, 1, reason: 'the held card is firm but invisible');
      expect(overview.stuck, 1);
      expect(overview.neverAnswered, 1);
    });

    test('never answered counts released cards with no reps', () {
      final collection = FakeCollection([
        released('fresh'),
        released('seen', reps: 3, state: CardState.review),
      ]);

      expect(statsOf(collection).overview(now).neverAnswered, 1);
    });

    test('a card in the short cycle is not counted as review', () {
      final collection = FakeCollection([
        released('fresh'),
        released('learning', state: CardState.learning, reps: 1),
        released('relearning', state: CardState.relearning, reps: 5),
        released('graduated', state: CardState.review, reps: 4),
      ]);

      final overview = statsOf(collection).overview(now);

      expect(
        overview.inShortCycle,
        2,
        reason: 'the never-answered card has not entered the cycle yet',
      );
      expect(overview.inReview, 1);
    });

    test('ready uses the target date, not a fixed number of days', () {
      final collection = FakeCollection([released('a', stability: 5)]);
      final movable = FakeWindow(window);
      final stats = statsOf(collection, on: movable);

      expect(
        stats.overview(now).ready,
        0,
        reason: 'twenty days out, five days of memory is not enough',
      );

      movable.window = window.withTarget(now.add(const Duration(days: 3)));

      expect(stats.overview(now).ready, 1);
    });

    test('due today counts overdue and same-day cards once', () {
      final collection = FakeCollection([
        released('overdue', dueAt: now.subtract(const Duration(hours: 2))),
        released('later-today', dueAt: now.add(const Duration(hours: 5))),
        released('tomorrow', dueAt: now.add(const Duration(days: 1))),
        released('undated'),
      ]);

      final overview = statsOf(collection).overview(now);

      expect(overview.dueToday, 2);
      expect(overview.subjectsDueToday, 1);
    });

    test('subjects due today counts one line per subject with a queue', () {
      final collection = FakeCollection([
        released('a', dueAt: now.subtract(const Duration(hours: 1))),
        released('b', subject: 'Widgets', dueAt: now),
        released('c', subject: 'Testes', dueAt: now.add(const Duration(days: 2))),
      ]);

      expect(statsOf(collection).overview(now).subjectsDueToday, 2);
    });

    test('ratios are zero on an empty collection', () {
      final overview = statsOf(FakeCollection()).overview(now);

      expect(overview.firmRatio, 0);
      expect(overview.readyRatio, 0);
      expect(overview.total, 0);
    });

    test('stuck counts the same cards problemCards lists', () {
      final collection = FakeCollection([
        newCard('held', importedAt: importedAt, lapses: 4),
        released('bad', lapses: 4),
        released('ok'),
      ]);
      final stats = statsOf(collection);

      expect(stats.overview(now).stuck, stats.problemCards().length);
      expect(stats.problemCards().map((card) => card.id), ['bad']);
    });

    test('the load average is zero on an empty forecast', () {
      expect(statsOf(FakeCollection()).averageLoad([]), 0);
    });

    test('the load average divides the forecast by its own length', () {
      final collection = FakeCollection([
        released('a', dueAt: now.subtract(const Duration(hours: 1))),
        released('b', dueAt: now.add(const Duration(days: 1))),
        released('c', dueAt: now.add(const Duration(days: 1))),
      ]);
      final stats = statsOf(collection);

      expect(stats.averageLoad(stats.loadForecast(now)), 3 / 7);
    });
  });

  group('the study streak', () {
    final collection = FakeCollection([released('a')]);

    test('the streak counts consecutive days ending today', () {
      final streak = statsOf(collection).streak(now, [
        answer('a', now.subtract(const Duration(days: 2))),
        answer('a', now.subtract(const Duration(days: 1))),
        answer('a', now),
      ]);

      expect(streak.current, 3);
      expect(streak.studiedToday, isTrue);
      expect(streak.answeredToday, 1);
    });

    test('a streak that ended the day before yesterday reads as zero', () {
      final streak = statsOf(collection).streak(now, [
        answer('a', now.subtract(const Duration(days: 3))),
        answer('a', now.subtract(const Duration(days: 2))),
      ]);

      expect(streak.current, 0, reason: 'the streak is already broken');
      expect(streak.longest, 2);
      expect(streak.studiedToday, isFalse);
    });

    test('studying yesterday but not yet today keeps the streak alive', () {
      final streak = statsOf(collection).streak(now, [
        answer('a', now.subtract(const Duration(days: 1))),
      ]);

      expect(streak.current, 1, reason: 'the day is not over yet');
      expect(streak.answeredToday, 0);
    });

    test('mock interview answers do not feed the streak', () {
      final streak = statsOf(collection).streak(now, [
        answer('a', now, source: ReviewSource.mockInterview),
        answer('a', now.subtract(const Duration(days: 1)),
            source: ReviewSource.mockInterview),
      ]);

      expect(streak.current, 0);
      expect(streak.answeredToday, 0);
      expect(streak.daysStudiedLastSeven, 0);
    });

    test('the longest streak survives a gap', () {
      final streak = statsOf(collection).streak(now, [
        for (var day = 10; day >= 7; day--)
          answer('a', now.subtract(Duration(days: day))),
        answer('a', now),
      ]);

      expect(streak.current, 1);
      expect(streak.longest, 4);
    });

    test('days studied in the last seven ignores older days', () {
      final streak = statsOf(collection).streak(now, [
        answer('a', now.subtract(const Duration(days: 8))),
        answer('a', now.subtract(const Duration(days: 7))),
        answer('a', now.subtract(const Duration(days: 6))),
        answer('a', now),
      ]);

      expect(
        streak.daysStudiedLastSeven,
        2,
        reason: 'the window is closed on both ends: today and six days back',
      );
    });

    test('several answers on the same day count as one day', () {
      final streak = statsOf(collection).streak(now, [
        answer('a', now.subtract(const Duration(hours: 3))),
        answer('a', now.subtract(const Duration(hours: 2))),
        answer('a', now),
      ]);

      expect(streak.current, 1);
      expect(streak.answeredToday, 3);
    });

    test('no logs at all is a streak of zero, never a crash', () {
      final streak = statsOf(collection).streak(now, []);

      expect(streak.current, 0);
      expect(streak.longest, 0);
      expect(streak.daysStudiedLastSeven, 0);
      expect(streak.studiedToday, isFalse);
    });
  });
}
