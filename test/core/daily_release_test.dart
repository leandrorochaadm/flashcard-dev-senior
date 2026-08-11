import 'package:flashcard_dev_senior/core/clock.dart';
import 'package:flashcard_dev_senior/core/daily_release.dart';
import 'package:flashcard_dev_senior/domain/models/card.dart';
import 'package:flashcard_dev_senior/domain/models/schedule_window.dart';
import 'package:flashcard_dev_senior/domain/policies/content_intake_policy.dart';
import 'package:flashcard_dev_senior/domain/policies/due_cards_policy.dart';
import 'package:flashcard_dev_senior/domain/ports.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/domain_fakes.dart';

/// Writes straight into the in-memory collection the policy reads from.
final class FakeCardWriter implements CardWriter {
  FakeCardWriter(this._collection);

  final FakeCollection _collection;

  @override
  Future<void> saveAll(Iterable<Card> cards) async {
    for (final card in cards) {
      _collection.save(card);
    }
  }
}

final class FakeReleaseJournal implements ReleaseJournal {
  @override
  DateTime? lastReleaseAt;

  @override
  IntakeReason? lastReleaseReason;

  @override
  int? lastReleaseQuota;

  @override
  Future<void> markReleased(
    DateTime now,
    IntakeReason reason,
    int quota,
  ) async {
    lastReleaseAt = now;
    lastReleaseReason = reason;
    lastReleaseQuota = quota;
  }
}

void main() {
  final firstOpening = DateTime(2026, 8, 11, 8);

  ({
    DailyRelease release,
    FakeCollection collection,
    DueCardsPolicy duePolicy,
    FakeHistory history,
    FakeReleaseJournal journal,
    FakeClock clock,
  }) build({DateTime? now, int pending = 100}) {
    final at = now ?? firstOpening;
    // `dueAt` is not optional here: `newCard` defaults it to null and
    // `Card.isDueOn` is `dueAt != null && !dueAt.isAfter(now)`. Without it the
    // cards would come out released and still invisible, and the assertions
    // below would be measuring the fixture instead of the behaviour.
    final collection = FakeCollection([
      for (var i = 0; i < pending; i++)
        newCard('p$i', importedAt: firstOpening, dueAt: firstOpening),
    ]);
    final history = FakeHistory();
    final duePolicy = DueCardsPolicy(collection);
    final journal = FakeReleaseJournal();
    final clock = FakeClock(at);
    return (
      release: DailyRelease(
        ContentIntakePolicy(
          FakeWindow(ScheduleWindow.forFirstOpening(firstOpening)),
          collection,
          history,
          duePolicy,
        ),
        FakeCardWriter(collection),
        journal,
        clock,
      ),
      collection: collection,
      duePolicy: duePolicy,
      history: history,
      journal: journal,
      clock: clock,
    );
  }

  // The bug this file exists for: importing and going straight to the study
  // tab found nothing, because only the dashboard ever released a batch.
  test('cards imported today become studiable without opening the dashboard',
      () async {
    final built = build();
    final now = built.clock.now();

    expect(built.duePolicy.isDayCleared(now), isTrue, reason: 'before release');

    await built.release.run();

    expect(built.duePolicy.isDayCleared(now), isFalse);
    expect(built.duePolicy.studiableSubjects(now), isNotEmpty);
    expect(built.duePolicy.dueNow(now), hasLength(20));
  });

  test('a second run on the same day releases nothing more', () async {
    final built = build();

    await built.release.run();
    await built.release.run();

    expect(built.collection.all.where((card) => card.isReleased), hasLength(20));
  });

  test('the journal records the day, so a new instance holds the batch', () async {
    final first = build();
    await first.release.run();

    expect(first.journal.lastReleaseAt, first.clock.now());
    expect(first.journal.lastReleaseReason, IntakeReason.initialLoad);
    expect(first.journal.lastReleaseQuota, 20);
  });

  // The regression the fourth review of the plan caught: `run()` used to
  // overwrite the day's outcome with `alreadyReleasedToday`, so the dashboard
  // showed the warning once and never again.
  group('a reduced batch keeps explaining itself all day', () {
    // Day 10 is outside the five-day initial load, where the precedence rule
    // would ignore "studied little". With no study recorded, the steady quota
    // lands below the baseline and the batch is reduced.
    final dayTen = firstOpening.add(const Duration(days: 9));

    ({DailyRelease release, FakeReleaseJournal journal, FakeClock clock})
        reduced() {
      final built = build(now: dayTen);
      // Something released and already answered, so the forecast has nothing
      // piling up ahead and the hold does not take precedence.
      built.collection.save(
        newCard(
          'seen',
          importedAt: firstOpening,
          introducedAt: firstOpening,
          dueAt: dayTen.add(const Duration(days: 40)),
          stability: 12,
        ),
      );
      return (
        release: built.release,
        journal: built.journal,
        clock: built.clock,
      );
    }

    test('across repeated dashboard openings', () async {
      final built = reduced();

      final first = await built.release.run();
      expect(first.reason, IntakeReason.reducedByLowStudy);
      expect(first.shouldWarn, isTrue);

      final second = await built.release.run();

      expect(second.reason, IntakeReason.reducedByLowStudy,
          reason: 'the dashboard reopened; the reason must not be lost');
    });

    test('and across a reload, which the service worker performs on its own',
        () async {
      final built = reduced();
      await built.release.run();

      // A brand-new instance over the same journal, which is what a page
      // reload produces: the object graph is rebuilt, the settings are not.
      final afterReload = DailyRelease(
        ContentIntakePolicy(
          FakeWindow(ScheduleWindow.forFirstOpening(firstOpening)),
          FakeCollection(),
          FakeHistory(),
          DueCardsPolicy(FakeCollection()),
        ),
        FakeCardWriter(FakeCollection()),
        built.journal,
        built.clock,
      )..restoreFromSettings(built.clock.now());

      expect((await afterReload.run()).reason, IntakeReason.reducedByLowStudy);
    });
  });
}
