import 'package:flashcard_dev_senior/domain/models/enums.dart';
import 'package:flashcard_dev_senior/domain/policies/session_policy.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const policy = SessionPolicy();

  group('ending a round before the time runs out', () {
    test('the round is over right away', () {
      final session = policy.start('s1', DateTime(2026, 8, 12), ['Dart']);
      final ended = policy.endRound(policy.tick(session, const Duration(minutes: 1)));

      expect(ended.remainingInRound, Duration.zero);
      expect(policy.isRoundOver(ended), isTrue);
    });

    test('what was answered still counts', () {
      var session = policy.start('s1', DateTime(2026, 8, 12), ['Dart']);
      session = policy.registerAnswer(session, Rating.good);
      session = policy.registerAnswer(session, Rating.again);

      final ended = policy.endRound(session);

      expect(ended.answered, 2);
      expect(ended.recalled, 1);
      expect(ended.scores.first.good, 1);
      expect(ended.scores.first.again, 1);
    });
    test('the session remembers it, so a reload still knows', () {
      final session = policy.start('s1', DateTime(2026, 8, 12), ['Dart', 'Web']);

      expect(policy.endRound(session).roundEndedEarly, isTrue);
      // The mark belongs to the round, not to the session: the next round and
      // the extension both start clean.
      expect(
        policy.advanceRound(policy.endRound(session)).roundEndedEarly,
        isFalse,
      );
      expect(
        policy.extendRound(policy.endRound(session)).roundEndedEarly,
        isFalse,
      );
    });

    test('a round that runs out of time is not marked', () {
      final session = policy.start('s1', DateTime(2026, 8, 12), ['Dart']);
      final drained = policy.tick(session, const Duration(minutes: 5));

      expect(policy.isRoundOver(drained), isTrue);
      expect(drained.roundEndedEarly, isFalse);
    });
  });

  group('ending the session', () {
    test('it closes with the score it has', () {
      var session = policy.start('s1', DateTime(2026, 8, 12), ['Dart', 'Web']);
      session = policy.registerAnswer(session, Rating.easy);

      final ended = policy.endSession(session);

      expect(ended.finished, isTrue);
      expect(ended.remainingInRound, Duration.zero);
      expect(ended.answered, 1);
      expect(ended.recalled, 1);
      // The rounds that were given up on keep their blank score.
      expect(ended.scores.last.answered, 0);
    });

    test('ending the session on the last round is the same ending', () {
      var session = policy.start('s1', DateTime(2026, 8, 12), ['Dart']);
      session = policy.endSession(session);

      expect(policy.isLastRound(session), isTrue);
      expect(session.finished, isTrue);
    });
  });
}
