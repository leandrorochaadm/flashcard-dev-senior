import 'package:flashcard_dev_senior/domain/models/enums.dart';
import 'package:flashcard_dev_senior/domain/models/study_session.dart';
import 'package:flashcard_dev_senior/domain/policies/session_policy.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const subjects = ['Estado', 'Widgets', 'Testes', 'Async', 'Plataforma'];
  const policy = SessionPolicy();
  final startedAt = DateTime(2026, 8, 11, 9);

  group('round score', () {
    test('a blank round has nothing answered and no accuracy yet', () {
      final score = RoundScore.blank('Estado');

      expect(score.answered, 0);
      expect(score.recalled, 0);
      expect(score.accuracy, isNull);
    });

    test('"errei" is the only miss; the other three reached the answer', () {
      var score = RoundScore.blank('Estado');
      for (final rating in Rating.values) {
        score = score.plus(rating);
      }

      expect(score.answered, 4);
      expect(score.recalled, 3);
      expect(score.accuracy, 0.75);
      expect(score.again, 1);
      expect(score.hard, 1);
      expect(score.good, 1);
      expect(score.easy, 1);
    });
  });

  group('study session', () {
    test('it knows the current and the next subject', () {
      final session = policy.start('s1', startedAt, subjects);

      expect(session.currentSubject, 'Estado');
      expect(session.nextSubject, 'Widgets');
      expect(session.currentScore.subject, 'Estado');
    });

    test('the last round has no next subject', () {
      var session = policy.start('s1', startedAt, subjects);
      for (var i = 0; i < 4; i++) {
        session = policy.advanceRound(session);
      }

      expect(session.currentSubject, 'Plataforma');
      expect(session.nextSubject, isNull);
    });

    test('answers land on the round being played', () {
      var session = policy.start('s1', startedAt, subjects);
      session = policy.registerAnswer(session, Rating.good);
      session = policy.registerAnswer(session, Rating.again);
      session = policy.advanceRound(session);
      session = policy.registerAnswer(session, Rating.easy);

      expect(session.scores[0].answered, 2);
      expect(session.scores[0].recalled, 1);
      expect(session.scores[1].answered, 1);
      expect(session.answered, 3);
      expect(session.recalled, 2);
    });

    test('a session survives a round trip through JSON, time left included',
        () {
      var session = policy.start('s1', startedAt, subjects);
      session = policy.tick(session, const Duration(minutes: 3));
      session = policy.registerAnswer(session, Rating.hard);

      final back = StudySession.fromJson(session.toJson());

      expect(back.remainingInRound, const Duration(minutes: 2));
      expect(back.currentRound, 0);
      expect(back.scores.first.hard, 1);
      expect(back.startedAt, startedAt);
      expect(back.finished, isFalse);
    });

    test('ticking past zero never goes negative', () {
      var session = policy.start('s1', startedAt, subjects);
      session = policy.tick(session, const Duration(minutes: 12));

      expect(session.remainingInRound, Duration.zero);
    });
  });
}
