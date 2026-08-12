import 'package:flashcard_dev_senior/domain/models/card.dart';
import 'package:flashcard_dev_senior/domain/models/enums.dart';
import 'package:flashcard_dev_senior/domain/models/review_log.dart';
import 'package:flashcard_dev_senior/domain/models/schedule_window.dart';
import 'package:flashcard_dev_senior/domain/policies/due_cards_policy.dart';
import 'package:flashcard_dev_senior/domain/stats/collection_overview.dart';
import 'package:flashcard_dev_senior/domain/stats/progress_stats.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/domain_fakes.dart';

/// The crossing into "firm", rebuilt from the history.
///
/// The day a card firmed cannot be read from the card for past days — the card
/// only carries `lastReviewedAt`. These tests pin the two places where the
/// rebuilt traversal deliberately disagrees with the counter that shipped
/// before it.
void main() {
  final importedAt = DateTime(2026, 8, 11);
  final today = DateTime(2026, 8, 20, 18);
  final window = ScheduleWindow.forFirstOpening(importedAt);

  DateTime daysAgo(int days) => today.subtract(Duration(days: days));

  ReviewLog review(
    String cardId,
    DateTime at, {
    required double stabilityBefore,
    ReviewSource source = ReviewSource.session,
  }) =>
      ReviewLog(
        cardId: cardId,
        reviewedAt: at,
        rating: Rating.good,
        elapsedDays: 1,
        predictedRetention: 0.9,
        stabilityBefore: stabilityBefore,
        timeOnCard: null,
        source: source,
      );

  Card card(String id, {required double stability}) => newCard(
        id,
        importedAt: importedAt,
        introducedAt: importedAt,
        stability: stability,
      );

  ProgressStats statsOf(List<Card> cards) {
    final collection = FakeCollection(cards);
    return ProgressStats(
      collection,
      FakeWindow(window),
      DueCardsPolicy(collection),
    );
  }

  int cardsOn(List<FirmedDay> series, DateTime day) =>
      series.singleWhere((point) => point.day == dateOnly(day)).cards;

  test('a card crossing into firm is counted on the day of the crossing review',
      () {
    final summary = statsOf([card('a', stability: 9)]).firmedSummary(
      today,
      [review('a', today, stabilityBefore: 4)],
    );

    expect(summary.today, 1);
    expect(summary.series.last.day, dateOnly(today));
    expect(summary.series.last.cards, 1);
  });

  test('a card that needed four reviews to firm counts on the day of the fourth',
      () {
    // The ramp 0 → 1.5 → 3.2 → 5.8 → firm. The previous counter kept the
    // *first* log below the firm threshold and demanded that day be today, so
    // this card — the ordinary one, since the short cycle serves 15 min → 1 h →
    // 4 h → 1 d before any long interval — was never counted at all.
    final summary = statsOf([card('a', stability: 8.5)]).firmedSummary(today, [
      review('a', daysAgo(3), stabilityBefore: 0),
      review('a', daysAgo(2), stabilityBefore: 1.5),
      review('a', daysAgo(1), stabilityBefore: 3.2),
      review('a', today, stabilityBefore: 5.8),
    ]);

    expect(summary.today, 1);
    expect(cardsOn(summary.series, daysAgo(3)), 0);
  });

  test('a card firmed on day 14 and reviewed on day 18 stays on day 14', () {
    final summary = statsOf([card('a', stability: 12)]).firmedSummary(today, [
      review('a', daysAgo(6), stabilityBefore: 4),
      review('a', daysAgo(2), stabilityBefore: 9),
    ]);

    expect(cardsOn(summary.series, daysAgo(6)), 1);
    expect(cardsOn(summary.series, daysAgo(2)), 0);
    expect(summary.today, 0);
  });

  test('the last review of a still-firm card counts as the crossing', () {
    final summary = statsOf([card('a', stability: 9)]).firmedSummary(
      today,
      [review('a', daysAgo(1), stabilityBefore: 6.9)],
    );

    expect(cardsOn(summary.series, daysAgo(1)), 1);
  });

  test('a card that never reached firm is never counted', () {
    final summary = statsOf([card('a', stability: 3)]).firmedSummary(today, [
      review('a', daysAgo(1), stabilityBefore: 1),
      review('a', today, stabilityBefore: 2),
    ]);

    expect(summary.today, 0);
    expect(summary.series.every((point) => point.cards == 0), isTrue);
  });

  test('a card rescued after a lapse counts again on the day of the rescue', () {
    // Firmed well outside the window, slipped, and was rescued today. Keeping
    // the *first* crossing would put it out of the seven-day series and today's
    // number would read 0 for a session spent rescuing stuck cards.
    final summary = statsOf([card('a', stability: 9)]).firmedSummary(today, [
      review('a', daysAgo(15), stabilityBefore: 1),
      review('a', daysAgo(14), stabilityBefore: 8),
      review('a', daysAgo(5), stabilityBefore: 2),
      review('a', today, stabilityBefore: 3),
    ]);

    expect(summary.today, 1);
    expect(cardsOn(summary.series, today), 1);
  });

  test('the same card never adds two points to one day', () {
    final summary = statsOf([card('a', stability: 9)]).firmedSummary(today, [
      review('a', DateTime(2026, 8, 20, 8), stabilityBefore: 4),
      review('a', DateTime(2026, 8, 20, 9), stabilityBefore: 8),
      review('a', DateTime(2026, 8, 20, 10), stabilityBefore: 2),
      review('a', DateTime(2026, 8, 20, 11), stabilityBefore: 3),
    ]);

    expect(summary.today, 1);
    expect(cardsOn(summary.series, today), 1);
  });

  test('a card that crossed and lapsed on the same day counts in the series',
      () {
    // Crossed in the morning, missed in the afternoon and fell back under the
    // ceiling. The series records the progress; today's number does not.
    final summary = statsOf([card('a', stability: 2)]).firmedSummary(today, [
      review('a', DateTime(2026, 8, 20, 9), stabilityBefore: 4),
      review('a', DateTime(2026, 8, 20, 15), stabilityBefore: 8),
    ]);

    expect(cardsOn(summary.series, today), 1);
    expect(summary.today, 0, reason: 'the card is no longer firm');
  });

  test('firmedToday ignores a crossing whose card is no longer firm', () {
    final stats = statsOf([card('a', stability: 2)]);

    expect(
      stats.firmedToday(today, [
        review('a', DateTime(2026, 8, 20, 9), stabilityBefore: 4),
        review('a', DateTime(2026, 8, 20, 15), stabilityBefore: 8),
      ]),
      0,
    );
  });

  test('firmedToday matches the last series point when nothing lapsed', () {
    final stats = statsOf([card('a', stability: 9), card('b', stability: 11)]);
    final logs = [
      review('a', today, stabilityBefore: 4),
      review('b', today, stabilityBefore: 5),
    ];

    final summary = stats.firmedSummary(today, logs);

    expect(summary.today, 2);
    expect(summary.series.last.cards, summary.today);
  });

  test('firmedToday delegates to firmedSummary without a second traversal', () {
    final stats = statsOf([card('a', stability: 9)]);
    final logs = [review('a', today, stabilityBefore: 4)];

    expect(stats.firmedToday(today, logs), stats.firmedSummary(today, logs).today);
  });

  test('mock interview logs never firm a card', () {
    final summary = statsOf([card('a', stability: 9)]).firmedSummary(today, [
      review('a', today, stabilityBefore: 4, source: ReviewSource.mockInterview),
    ]);

    expect(summary.today, 0);
    expect(summary.series.every((point) => point.cards == 0), isTrue);
  });

  test('a held-back card never enters the series', () {
    final collection = FakeCollection([
      newCard('held', importedAt: importedAt, stability: 9),
    ]);
    final stats = ProgressStats(
      collection,
      FakeWindow(window),
      DueCardsPolicy(collection),
    );

    final summary = stats.firmedSummary(today, [
      review('held', daysAgo(1), stabilityBefore: 4),
      review('held', today, stabilityBefore: 8),
    ]);

    expect(summary.series.every((point) => point.cards == 0), isTrue);
  });

  test('the series always ends on today and has one point per day', () {
    final summary = statsOf([card('a', stability: 9)]).firmedSummary(today, []);

    expect(summary.series.length, 7);
    expect(summary.series.last.day, dateOnly(today));
    expect(summary.series.first.day, dateOnly(daysAgo(6)));
  });

  test('the daily average is zero on an empty series', () {
    final stats = statsOf([card('a', stability: 9)]);

    expect(stats.firmedSummary(today, [], days: 0).dailyAverage, 0);
    expect(stats.firmedSummary(today, []).dailyAverage, 0);
  });

  test('the daily average divides the crossings by the length of the series',
      () {
    final summary = statsOf([
      card('a', stability: 9),
      card('b', stability: 9),
    ]).firmedSummary(today, [
      review('a', today, stabilityBefore: 4),
      review('b', daysAgo(2), stabilityBefore: 4),
      review('b', daysAgo(1), stabilityBefore: 8),
    ]);

    expect(summary.dailyAverage, 2 / 7);
  });
}
