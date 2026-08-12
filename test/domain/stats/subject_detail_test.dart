import 'package:flashcard_dev_senior/domain/models/card.dart';
import 'package:flashcard_dev_senior/domain/models/enums.dart';
import 'package:flashcard_dev_senior/domain/models/review_log.dart';
import 'package:flashcard_dev_senior/domain/models/schedule_window.dart';
import 'package:flashcard_dev_senior/domain/policies/due_cards_policy.dart';
import 'package:flashcard_dev_senior/domain/stats/progress_stats.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/domain_fakes.dart';

/// The detail the subject map now shows inline, and who decides which subject
/// is the weak one.
void main() {
  final importedAt = DateTime(2026, 8, 11);
  final now = DateTime(2026, 8, 20, 9);
  final window = ScheduleWindow.forFirstOpening(importedAt);

  ProgressStats statsOf(FakeCollection collection) => ProgressStats(
        collection,
        FakeWindow(window),
        DueCardsPolicy(collection),
      );

  Card released(
    String id, {
    String subject = 'Estado',
    double stability = 0,
    DateTime? dueAt,
    int reps = 0,
  }) =>
      newCard(
        id,
        subject: subject,
        importedAt: importedAt,
        introducedAt: importedAt,
        stability: stability,
        dueAt: dueAt,
      ).copyWith(reps: reps);

  ReviewLog timed(String cardId, Duration? time) => ReviewLog(
        cardId: cardId,
        reviewedAt: now,
        rating: Rating.good,
        elapsedDays: 1,
        predictedRetention: 0.9,
        stabilityBefore: 3,
        timeOnCard: time,
        source: ReviewSource.session,
      );

  SubjectProgress lineOf(List<SubjectProgress> map, String subject) =>
      map.singleWhere((entry) => entry.subject == subject);

  group('the subject map', () {
    test('dueToday per subject matches DueCardsPolicy.studiableCount', () {
      final collection = FakeCollection([
        released('a', dueAt: now.subtract(const Duration(hours: 1))),
        released('b', dueAt: now.add(const Duration(hours: 3))),
        released('c', dueAt: now.add(const Duration(days: 2))),
        released('d', subject: 'Widgets', dueAt: now),
      ]);
      final stats = statsOf(collection);
      final policy = DueCardsPolicy(collection);

      final map = stats.subjectMap(now);

      expect(lineOf(map, 'Estado').dueToday, policy.studiableCount(now, 'Estado'));
      expect(lineOf(map, 'Estado').dueToday, 2);
      expect(lineOf(map, 'Widgets').dueToday, 1);
    });

    test('nextDueAt is null when every card of the subject is overdue', () {
      final collection = FakeCollection([
        released('a', dueAt: now.subtract(const Duration(days: 1))),
        released('b', dueAt: now.subtract(const Duration(hours: 2))),
      ]);

      expect(lineOf(statsOf(collection).subjectMap(now), 'Estado').nextDueAt,
          isNull);
    });

    test('nextDueAt picks the earliest strictly future dueAt', () {
      final soon = now.add(const Duration(days: 1));
      final collection = FakeCollection([
        released('overdue', dueAt: now.subtract(const Duration(days: 3))),
        released('later', dueAt: now.add(const Duration(days: 4))),
        released('soon', dueAt: soon),
        released('undated'),
      ]);

      expect(
        lineOf(statsOf(collection).subjectMap(now), 'Estado').nextDueAt,
        soon,
      );
    });

    test('averageTime is null for a subject with no timed answers', () {
      final collection = FakeCollection([
        released('a'),
        released('b', subject: 'Widgets'),
      ]);

      // A time over the ceiling was already dropped to null when the log was
      // written, so it never reaches the average.
      final map = statsOf(collection).subjectMap(
        now,
        logs: [timed('a', const Duration(seconds: 40)), timed('b', null)],
      );

      expect(lineOf(map, 'Estado').averageTime, const Duration(seconds: 40));
      expect(lineOf(map, 'Widgets').averageTime, isNull);
    });

    test('neverAnswered counts the released cards with no reps', () {
      final collection = FakeCollection([
        released('a'),
        released('b', reps: 2),
      ]);

      expect(lineOf(statsOf(collection).subjectMap(now), 'Estado').neverAnswered,
          1);
    });

    test('subjectMap keeps the worst-first order', () {
      final collection = FakeCollection([
        released('strong', subject: 'Widgets', stability: 40),
        released('weak'),
      ]);

      final map = statsOf(collection).subjectMap(now);

      expect(map.map((entry) => entry.subject), ['Estado', 'Widgets']);
    });

    test('subjectMap without logs still returns every subject', () {
      final collection = FakeCollection([
        released('a'),
        released('b', subject: 'Widgets'),
      ]);

      final map = statsOf(collection).subjectMap(now);

      expect(map.length, 2);
      expect(map.every((entry) => entry.averageTime == null), isTrue);
    });
  });

  group('the weakest subject', () {
    test('weakestSubject picks the lowest ready ratio', () {
      final collection = FakeCollection([
        released('strong', subject: 'Widgets', stability: 40),
        released('weak'),
      ]);
      final stats = statsOf(collection);

      final weakest = stats.weakestSubject(stats.subjectMap(now));

      expect(weakest?.subject, 'Estado');
    });

    test('weakestSubject does not depend on the order of the list it receives',
        () {
      final collection = FakeCollection([
        released('strong', subject: 'Widgets', stability: 40),
        released('weak'),
      ]);
      final stats = statsOf(collection);
      final reversed = stats.subjectMap(now).reversed.toList();

      expect(stats.weakestSubject(reversed)?.subject, 'Estado');
    });

    test('weakestSubject is null on an empty map', () {
      expect(statsOf(FakeCollection()).weakestSubject(const []), isNull);
    });
  });
}
