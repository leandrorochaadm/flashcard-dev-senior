import 'package:flashcard_dev_senior/domain/models/card.dart';
import 'package:flashcard_dev_senior/domain/models/schedule_window.dart';
import 'package:flashcard_dev_senior/domain/policies/content_intake_policy.dart';
import 'package:flashcard_dev_senior/domain/policies/due_cards_policy.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/domain_fakes.dart';

void main() {
  final firstOpening = DateTime(2026, 8, 11, 8);
  final window = ScheduleWindow.forFirstOpening(firstOpening);

  ({ContentIntakePolicy policy, FakeCollection collection, FakeHistory history})
      build({int pending = 100, List<Card> released = const []}) {
    final collection = FakeCollection([
      for (var i = 0; i < pending; i++)
        newCard('p$i', importedAt: firstOpening),
      ...released,
    ]);
    final history = FakeHistory();
    return (
      policy: ContentIntakePolicy(
        FakeWindow(window),
        collection,
        history,
        DueCardsPolicy(collection),
      ),
      collection: collection,
      history: history,
    );
  }

  test('the initial load releases about 20 cards a day for five days', () {
    final built = build();
    for (var day = 1; day <= 5; day++) {
      final now = firstOpening.add(Duration(days: day - 1));
      final release = built.policy.releaseToday(now);

      expect(release.quota, 20, reason: 'day $day of the initial load');
      expect(release.reason, IntakeReason.initialLoad);
      for (final card in release.cards) {
        built.collection.save(card.copyWith(introducedAt: now));
      }
    }
    expect(built.collection.all.where((card) => card.isReleased).length, 100);
  });

  // The rule that disappears in a refactor: if "studied little" applied here,
  // the last cards would enter too late to firm up before the deadline.
  test('"studied little" does NOT reduce the batch during the initial load', () {
    final built = build();
    // No review recorded on any day: the worst possible study history.
    for (var day = 1; day <= 5; day++) {
      final now = firstOpening.add(Duration(days: day - 1));
      final release = built.policy.releaseToday(now);

      expect(release.quota, 20);
      expect(release.reason, IntakeReason.initialLoad);
      expect(release.shouldWarn, isFalse);
      for (final card in release.cards) {
        built.collection.save(card.copyWith(introducedAt: now));
      }
    }
    expect(built.collection.all.where((card) => card.isReleased).length, 100);
  });

  test('outside the initial load, no study at all releases nothing and warns',
      () {
    final built = build();
    final day10 = firstOpening.add(const Duration(days: 9));

    final release = built.policy.releaseToday(day10);

    expect(release.quota, 0);
    expect(release.shouldWarn, isTrue);
  });

  test('the forecast holding the intake back is never silent', () {
    // A pile-up: everything already scheduled for tomorrow.
    final tomorrow = firstOpening.add(const Duration(days: 10));
    final collection = FakeCollection([
      for (var i = 0; i < 200; i++)
        newCard('r$i',
            importedAt: firstOpening,
            introducedAt: firstOpening,
            dueAt: tomorrow),
      for (var i = 0; i < 10; i++) newCard('p$i', importedAt: firstOpening),
    ]);
    final policy = ContentIntakePolicy(
      FakeWindow(window),
      collection,
      FakeHistory(),
      DueCardsPolicy(collection),
    );

    final release = policy.releaseToday(firstOpening.add(const Duration(days: 9)));

    expect(release.reason, IntakeReason.heldByForecast);
    expect(release.cards, isEmpty);
    expect(release.shouldWarn, isTrue);
  });

  group('the 80% signal', () {
    test('warns with the current percentage but never blocks', () {
      final built = build(
        pending: 0,
        released: [
          for (var i = 0; i < 6; i++)
            newCard('firm$i',
                importedAt: firstOpening,
                introducedAt: firstOpening,
                stability: 10),
          for (var i = 0; i < 4; i++)
            newCard('soft$i',
                importedAt: firstOpening,
                introducedAt: firstOpening,
                stability: 2),
        ],
      );

      expect(built.policy.firmRatio(), closeTo(0.60, 0.001));
      expect(built.policy.shouldWarnBeforeImport(), isTrue);
    });

    test('does not warn at 80% or above', () {
      final built = build(
        pending: 0,
        released: [
          for (var i = 0; i < 8; i++)
            newCard('firm$i',
                importedAt: firstOpening,
                introducedAt: firstOpening,
                stability: 10),
          for (var i = 0; i < 2; i++)
            newCard('soft$i',
                importedAt: firstOpening,
                introducedAt: firstOpening,
                stability: 2),
        ],
      );

      expect(built.policy.shouldWarnBeforeImport(), isFalse);
    });
  });

  // Decision of 12/08/2026: the ramp became optional. The import screen offers
  // the release as a switch, the collection screen as a button, and both land
  // here — the only class allowed to write `introducedAt`.
  group('releasing outside the daily ramp', () {
    test('pendingCount counts what is held back, not the whole collection', () {
      final built = build(
        pending: 3,
        released: [
          for (var i = 0; i < 2; i++)
            newCard('r$i',
                importedAt: firstOpening, introducedAt: firstOpening),
        ],
      );

      expect(built.policy.pendingCount, 3);
      expect(built.collection.all, hasLength(5));
    });

    test('releasedNow stamps introducedAt and dueAt with the same instant', () {
      final built = build(pending: 1);

      final released =
          built.policy.releasedNow(built.collection.all.single, firstOpening);

      expect(released.introducedAt, firstOpening);
      expect(released.isReleased, isTrue);
      expect(released.dueAt, firstOpening,
          reason: 'a released card is due at once');
    });

    test('releasedNow leaves an already released card exactly as it was', () {
      // Re-stamping would rewrite the day the card entered the study and pull
      // a real schedule back to now.
      final dueAt = firstOpening.add(const Duration(days: 6));
      final studied = newCard(
        'r0',
        importedAt: firstOpening,
        introducedAt: firstOpening,
        dueAt: dueAt,
        stability: 9,
      );
      final built = build(pending: 0, released: [studied]);

      final released = built.policy
          .releasedNow(studied, firstOpening.add(const Duration(days: 3)));

      expect(released.introducedAt, firstOpening);
      expect(released.dueAt, dueAt);
    });

    test('releaseAllPending reaches every held-back card and nothing else', () {
      final alreadyOut = newCard(
        'r0',
        importedAt: firstOpening,
        introducedAt: firstOpening,
        dueAt: firstOpening.add(const Duration(days: 6)),
      );
      final built = build(pending: 3, released: [alreadyOut]);
      final now = firstOpening.add(const Duration(days: 2));

      final released = built.policy.releaseAllPending(now);

      expect(released.map((card) => card.id), ['p0', 'p1', 'p2']);
      expect(released.every((card) => card.introducedAt == now), isTrue);
      expect(released.every((card) => card.dueAt == now), isTrue);
    });

    test('releaseAllPending on a collection with nothing pending releases '
        'nothing', () {
      final built = build(
        pending: 0,
        released: [
          newCard('r0', importedAt: firstOpening, introducedAt: firstOpening),
        ],
      );

      expect(built.policy.releaseAllPending(firstOpening), isEmpty);
      expect(built.policy.pendingCount, 0);
    });
  });

  group('releasing once a day', () {
    test('the batch goes out once a day, however many times it is asked for',
        () {
      final built = build();

      final first = built.policy.releaseToday(firstOpening);
      expect(first.cards, hasLength(20));

      // Same day, asked again: the ramp would collapse if this freed 16 more.
      final second = built.policy.releaseToday(
        firstOpening.add(const Duration(hours: 3)),
        lastReleasedOn: firstOpening,
      );

      expect(second.cards, isEmpty);
      expect(second.reason, IntakeReason.alreadyReleasedToday);
      expect(second.shouldWarn, isFalse,
          reason: 'normal operation, not a batch held back');
    });

    test('an empty collection does not settle the day, a held batch does', () {
      // A fresh install answers `nothingPending`. Treating that as the day's
      // decision would hold everything imported minutes later until tomorrow.
      final empty = build(pending: 0).policy.releaseToday(firstOpening);
      expect(empty.reason, IntakeReason.nothingPending);
      expect(empty.decidesTheDay, isFalse);

      final released = build().policy.releaseToday(firstOpening);
      expect(released.decidesTheDay, isTrue);
    });

    test('the policy stamps introducedAt, so no caller has to', () {
      final release = build().policy.releaseToday(firstOpening);

      expect(release.cards.every((card) => card.introducedAt == firstOpening),
          isTrue);
      expect(release.cards.every((card) => card.isReleased), isTrue);
    });

    test('a mass release does not make the day batch go out twice', () {
      // The release outside the ramp writes no journal entry, so nothing stops
      // `releaseToday` from being called on the same day — what stops it is
      // there being nothing left pending.
      final built = build(pending: 10);
      for (final card in built.policy.releaseAllPending(firstOpening)) {
        built.collection.save(card);
      }

      final release = built.policy.releaseToday(firstOpening);

      expect(release.cards, isEmpty);
      expect(release.reason, IntakeReason.nothingPending);
    });

    test('a new day releases the next batch', () {
      final built = build();
      final dayTwo = firstOpening.add(const Duration(days: 1));

      // The first day's batch has to be persisted, or day two sees all 100
      // still pending and hands out the same cards again.
      for (final card in built.policy.releaseToday(firstOpening).cards) {
        built.collection.save(card);
      }
      final next =
          built.policy.releaseToday(dayTwo, lastReleasedOn: firstOpening);

      expect(next.cards, hasLength(20));
      expect(next.reason, IntakeReason.initialLoad);
      expect(next.cards.map((card) => card.id), isNot(contains('p0')));
    });
  });
}
