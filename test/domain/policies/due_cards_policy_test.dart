import 'package:flashcard_dev_senior/domain/models/schedule_window.dart';
import 'package:flashcard_dev_senior/domain/policies/due_cards_policy.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/domain_fakes.dart';

void main() {
  final importedAt = DateTime(2026, 8, 11);
  final now = DateTime(2026, 8, 20, 14);

  DueCardsPolicy policyWith(FakeCollection collection) =>
      DueCardsPolicy(collection);

  test('only released cards are ever studiable', () {
    final collection = FakeCollection([
      newCard('held', importedAt: importedAt, dueAt: now),
      newCard('free',
          importedAt: importedAt, introducedAt: importedAt, dueAt: now),
    ]);

    expect(
      policyWith(collection).dueNow(now).map((card) => card.id),
      ['free'],
    );
  });

  test('due cards come oldest first', () {
    final collection = FakeCollection([
      newCard('late',
          importedAt: importedAt,
          introducedAt: importedAt,
          dueAt: now.subtract(const Duration(hours: 1))),
      newCard('later',
          importedAt: importedAt,
          introducedAt: importedAt,
          dueAt: now.subtract(const Duration(days: 2))),
    ]);

    expect(
      policyWith(collection).dueNow(now).map((card) => card.id),
      ['later', 'late'],
    );
  });

  // Anticipation may only reach what would fall due later today; never
  // tomorrow's, which would undo the ceiling in practice.
  test('anticipation reaches today only, never tomorrow', () {
    final collection = FakeCollection([
      newCard('todayLater',
          importedAt: importedAt,
          introducedAt: importedAt,
          dueAt: now.add(const Duration(hours: 4))),
      newCard('tomorrow',
          importedAt: importedAt,
          introducedAt: importedAt,
          dueAt: now.add(const Duration(days: 1))),
    ]);

    expect(
      policyWith(collection).anticipateToday(now).map((card) => card.id),
      ['todayLater'],
    );
  });

  test('nothing due in the subject falls back to what falls due today', () {
    final collection = FakeCollection([
      newCard('other',
          subject: 'Async',
          importedAt: importedAt,
          introducedAt: importedAt,
          dueAt: now),
      newCard('laterToday',
          subject: 'Estado',
          importedAt: importedAt,
          introducedAt: importedAt,
          dueAt: now.add(const Duration(hours: 2))),
    ]);

    final next = policyWith(collection).nextDueCard(now, 'Estado');

    expect(next!.id, 'laterToday');
  });

  test('a subject with nothing at all answers null instead of throwing', () {
    final collection = FakeCollection([
      newCard('other',
          subject: 'Async',
          importedAt: importedAt,
          introducedAt: importedAt,
          dueAt: now),
    ]);

    expect(policyWith(collection).nextDueCard(now, 'Estado'), isNull);
  });

  test('cards already seen in the round are skipped', () {
    final collection = FakeCollection([
      newCard('first',
          importedAt: importedAt, introducedAt: importedAt, dueAt: now),
      newCard('second',
          importedAt: importedAt,
          introducedAt: importedAt,
          dueAt: now.add(const Duration(minutes: 1))),
    ]);

    final next =
        policyWith(collection).nextDueCard(now, 'Estado', skip: {'first'});

    expect(next!.id, 'second');
  });

  test('the day is cleared when nothing is due and nothing can be anticipated',
      () {
    final collection = FakeCollection([
      newCard('tomorrow',
          importedAt: importedAt,
          introducedAt: importedAt,
          dueAt: now.add(const Duration(days: 1))),
    ]);

    expect(policyWith(collection).isDayCleared(now), isTrue);
  });

  test('overdue cards count as work for today in the forecast', () {
    final collection = FakeCollection([
      newCard('overdue',
          importedAt: importedAt,
          introducedAt: importedAt,
          dueAt: now.subtract(const Duration(days: 3))),
      newCard('inThreeDays',
          importedAt: importedAt,
          introducedAt: importedAt,
          dueAt: now.add(const Duration(days: 3))),
      newCard('faraway',
          importedAt: importedAt,
          introducedAt: importedAt,
          dueAt: now.add(const Duration(days: 30))),
      newCard('never', importedAt: importedAt, introducedAt: importedAt),
    ]);

    final forecast = policyWith(collection).forecast(now);

    expect(forecast.length, 7);
    expect(forecast[dateOnly(now)], 1);
    expect(forecast[dateOnly(now.add(const Duration(days: 3)))], 1);
    expect(forecast.values.fold(0, (sum, value) => sum + value), 2);
  });

  test('the schedule window knows when the deadline has arrived', () {
    final window = ScheduleWindow.forFirstOpening(DateTime(2026, 8, 11));

    expect(window.isPastDeadline(DateTime(2026, 9, 8)), isFalse);
    expect(window.isPastDeadline(DateTime(2026, 9, 9, 7)), isTrue);
    expect(window.isPastDeadline(DateTime(2026, 9, 20)), isTrue);
  });


  // A subject whose cards are all still held, or all scheduled for a later
  // day, must not reach the picker: choosing it would open a round that ends
  // before the first question appears.
  test('the picker only offers subjects that can serve a card today', () {
    final collection = FakeCollection([
      newCard('mvvm-held',
          subject: 'MVVM', importedAt: importedAt, dueAt: now),
      newCard('vn-tomorrow',
          subject: 'ValueNotifier',
          importedAt: importedAt,
          introducedAt: importedAt,
          dueAt: now.add(const Duration(days: 1))),
      newCard('estado-due',
          subject: 'Estado',
          importedAt: importedAt,
          introducedAt: importedAt,
          dueAt: now),
    ]);

    expect(
      policyWith(collection).studiableSubjects(now).map((q) => q.subject),
      ['Estado'],
    );
  });

  test('subjects come with the size of their queue, biggest first', () {
    final collection = FakeCollection([
      newCard('a',
          subject: 'Estado',
          importedAt: importedAt,
          introducedAt: importedAt,
          dueAt: now),
      newCard('b',
          subject: 'Estado',
          importedAt: importedAt,
          introducedAt: importedAt,
          // Later today: anticipation reaches it, so it counts.
          dueAt: now.add(const Duration(hours: 2))),
      newCard('c',
          subject: 'MVVM',
          importedAt: importedAt,
          introducedAt: importedAt,
          dueAt: now),
    ]);

    final queues = policyWith(collection).studiableSubjects(now);

    expect(queues.map((q) => q.subject), ['Estado', 'MVVM']);
    expect(queues.map((q) => q.cards), [2, 1]);
  });

  test('the round counter drops the cards already answered', () {
    final collection = FakeCollection([
      newCard('a',
          subject: 'Estado',
          importedAt: importedAt,
          introducedAt: importedAt,
          dueAt: now),
      newCard('b',
          subject: 'Estado',
          importedAt: importedAt,
          introducedAt: importedAt,
          dueAt: now),
    ]);
    final policy = policyWith(collection);

    expect(policy.studiableCount(now, 'Estado'), 2);
    expect(policy.studiableCount(now, 'Estado', skip: {'a'}), 1);
  });
}
