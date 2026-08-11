import 'dart:math' as math;

import 'package:collection/collection.dart';

import '../models/card.dart';
import '../models/enums.dart';
import '../ports.dart';

/// The score of one mock interview, per subject.
final class MockInterviewScore {
  const MockInterviewScore({required this.subject, required this.asked, required this.recalled});

  final String subject;
  final int asked;
  final int recalled;

  double get accuracy => asked == 0 ? 0 : recalled / asked;
}

/// Draws questions from every subject, imitating a real interview.
///
/// It writes a `ReviewLog` with `source = mockInterview` and NOTHING else: it
/// never touches stability, dueAt, state or lapses. The reason is in the
/// requirements — a mock draws cards far from their due date, and rescheduling
/// them would quietly undo the anticipation rule.
final class MockInterviewService {
  MockInterviewService(this._collection, {math.Random? random})
      : _random = random ?? math.Random();

  final CollectionView _collection;
  final math.Random _random;

  /// A balanced draw of [size] questions, so no subject dominates.
  ///
  /// A subject with too few cards gives its unused quota back to the others.
  List<Card> draw(int size) {
    final bySubject = <String, List<Card>>{};
    for (final card in _collection.all.where((card) => card.isReleased)) {
      bySubject.putIfAbsent(card.subject, () => []).add(card);
    }
    if (bySubject.isEmpty) return const [];

    final pools = {
      for (final entry in bySubject.entries) entry.key: (entry.value..shuffle(_random)),
    };
    final picked = <Card>[];
    final subjects = pools.keys.toList()..sort();

    // Round-robin: every pass takes one card from each subject that still has
    // one, which balances the draw and redistributes the leftover quota.
    var exhausted = false;
    while (picked.length < size && !exhausted) {
      exhausted = true;
      for (final subject in subjects) {
        if (picked.length >= size) break;
        final pool = pools[subject]!;
        final next = pool.firstWhereOrNull((card) => !picked.contains(card));
        if (next == null) continue;
        picked.add(next);
        exhausted = false;
      }
    }
    return picked;
  }

  /// Score of a finished mock, per subject. Separate from the subject map on
  /// purpose: a green map with a bad mock is the most useful signal the app
  /// gives — memorized cards, subject not connected under pressure.
  List<MockInterviewScore> score(Map<Card, Rating> answers) {
    final asked = <String, int>{};
    final recalled = <String, int>{};
    for (final entry in answers.entries) {
      final subject = entry.key.subject;
      asked[subject] = (asked[subject] ?? 0) + 1;
      if (entry.value != Rating.again) {
        recalled[subject] = (recalled[subject] ?? 0) + 1;
      }
    }
    final subjects = asked.keys.toList()..sort();
    return [
      for (final subject in subjects)
        MockInterviewScore(
          subject: subject,
          asked: asked[subject]!,
          recalled: recalled[subject] ?? 0,
        ),
    ];
  }
}
