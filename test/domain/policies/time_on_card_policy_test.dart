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

    test('a session is one five-minute round per chosen subject', () {
      final session = policy.start('s1', now, subjects);

      expect(session.subjects.length, subjects.length);
      expect(session.remainingInRound, SessionPolicy.roundDuration);
      expect(policy.sessionDuration(session), const Duration(minutes: 25));
    });

    test('the session shrinks and grows with the number of subjects', () {
      final short = policy.start('s2', now, const ['Estado']);
      final long = policy.start('s3', now, const [
        'Estado',
        'Widgets',
        'Testes',
        'Async',
        'Plataforma',
        'Build',
        'Deploy',
      ]);

      expect(short.scores, hasLength(1));
      expect(policy.sessionDuration(short), const Duration(minutes: 5));
      expect(policy.isLastRound(short), isTrue);
      expect(policy.advanceRound(short).finished, isTrue);

      expect(long.scores, hasLength(7));
      expect(policy.sessionDuration(long), const Duration(minutes: 35));
      expect(policy.isLastRound(long), isFalse);
    });

    test('the only floor on the chosen subjects is one', () {
      expect(policy.canStart(const []), isFalse);
      expect(policy.canStart(const ['Estado']), isTrue);
      expect(policy.canStart(subjects), isTrue);
      expect(policy.canStart([...subjects, 'Build', 'Deploy']), isTrue);
    });

    test('the picker can show the length before the session exists', () {
      expect(policy.durationFor(const []), Duration.zero);
      expect(policy.durationFor(const ['Estado']), const Duration(minutes: 5));
      expect(policy.durationFor(subjects), const Duration(minutes: 25));
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
