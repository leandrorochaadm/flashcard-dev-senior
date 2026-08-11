import 'package:flashcard_dev_senior/domain/policies/session_policy.dart';
import 'package:flashcard_dev_senior/domain/policies/time_on_card_policy.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('time on card', () {
    // Built at runtime, not as a const: this is how get_it registers it.
    // ignore: prefer_const_constructors
    final policy = TimeOnCardPolicy();

    test('time under the ceiling is recorded', () {
      expect(
        policy.timeToRecord(const Duration(seconds: 42)),
        const Duration(seconds: 42),
      );
    });

    // The review still counts; only the time is dropped from the average.
    test('a card left five minutes on screen drops out of the average', () {
      expect(policy.timeToRecord(const Duration(minutes: 5)), isNull);
      expect(policy.isOverCeiling(const Duration(minutes: 5)), isTrue);
    });

    test('exactly 60 seconds is still recorded', () {
      expect(
        policy.timeToRecord(const Duration(seconds: 60)),
        const Duration(seconds: 60),
      );
    });
  });

  group('session', () {
    // ignore: prefer_const_constructors
    final policy = SessionPolicy();
    final now = DateTime(2026, 8, 11, 9);
    const subjects = ['Estado', 'Widgets', 'Testes', 'Async', 'Plataforma'];

    test('a session is five rounds of five minutes', () {
      final session = policy.start('s1', now, subjects);

      expect(session.subjects.length, SessionPolicy.roundsPerSession);
      expect(session.remainingInRound, SessionPolicy.roundDuration);
      expect(policy.sessionDuration, const Duration(minutes: 25));
    });

    test('pausing simply stops ticking, so nothing drifts with the wall clock',
        () {
      var session = policy.start('s1', now, subjects);
      session = policy.tick(session, const Duration(seconds: 30));
      final paused = session.remainingInRound;

      expect(paused, const Duration(minutes: 4, seconds: 30));
      expect(session.remainingInRound, paused);
    });

    test('the round ends and the next one starts with a full five minutes', () {
      var session = policy.start('s1', now, subjects);
      session = policy.tick(session, const Duration(minutes: 6));

      expect(policy.isRoundOver(session), isTrue);
      expect(session.remainingInRound, Duration.zero);

      session = policy.advanceRound(session);
      expect(session.currentRound, 1);
      expect(session.currentSubject, 'Widgets');
      expect(session.remainingInRound, SessionPolicy.roundDuration);
    });

    test('extending the round keeps the subject', () {
      var session = policy.start('s1', now, subjects);
      session = policy.tick(session, const Duration(minutes: 5));
      session = policy.extendRound(session);

      expect(session.currentRound, 0);
      expect(session.remainingInRound, SessionPolicy.roundDuration);
    });

    test('the fifth round finishes the session', () {
      var session = policy.start('s1', now, subjects);
      for (var i = 0; i < 4; i++) {
        session = policy.advanceRound(session);
      }
      expect(policy.isLastRound(session), isTrue);

      session = policy.advanceRound(session);
      expect(session.finished, isTrue);
    });
  });
}
