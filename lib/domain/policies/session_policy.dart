import '../models/enums.dart';
import '../models/study_session.dart';

/// A 25-minute session: 5 rounds of 5 minutes, one subject each.
///
/// The 1-second `Timer` is ViewModel infrastructure, but the durations, the
/// number of rounds and "pausing freezes everything" are requirement 8.
final class SessionPolicy {
  const SessionPolicy();

  static const roundDuration = Duration(minutes: 5);
  static const roundsPerSession = 5;

  Duration get sessionDuration => roundDuration * roundsPerSession;

  StudySession start(String id, DateTime now, List<String> subjects) =>
      StudySession(
        id: id,
        startedAt: now,
        subjects: subjects,
        currentRound: 0,
        remainingInRound: roundDuration,
        scores: [for (final subject in subjects) RoundScore.blank(subject)],
        finished: false,
      );

  bool isRoundOver(StudySession session) =>
      session.remainingInRound <= Duration.zero;

  bool isLastRound(StudySession session) =>
      session.currentRound >= session.subjects.length - 1;

  /// One tick of the round clock. Pausing simply stops calling this: the
  /// remaining time is state, not a wall-clock difference, so the pause
  /// freezes the card timer, the round and the session alike.
  StudySession tick(StudySession session, Duration by) {
    final left = session.remainingInRound - by;
    return session.copyWith(
      remainingInRound: left.isNegative ? Duration.zero : left,
    );
  }

  StudySession registerAnswer(StudySession session, Rating rating) =>
      session.copyWith(
        scores: [
          for (var i = 0; i < session.scores.length; i++)
            if (i == session.currentRound)
              session.scores[i].plus(rating)
            else
              session.scores[i],
        ],
      );

  /// Moves to the next round, or finishes the session on the last one.
  StudySession advanceRound(StudySession session) {
    if (isLastRound(session)) return session.copyWith(finished: true);
    return session.copyWith(
      currentRound: session.currentRound + 1,
      remainingInRound: roundDuration,
    );
  }

  /// "Estender o round": keeps the subject and gives another full round.
  StudySession extendRound(StudySession session) =>
      session.copyWith(remainingInRound: roundDuration);
}
