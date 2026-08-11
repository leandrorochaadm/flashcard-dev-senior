import 'package:freezed_annotation/freezed_annotation.dart';

import '../../domain/models/card.dart';
import '../../domain/models/enums.dart';
import '../../domain/models/study_session.dart';
import '../../domain/policies/due_cards_policy.dart';

part 'session_state.freezed.dart';

/// What the study screen is showing right now.
///
/// A union, never a pile of booleans: "the answer is revealed" and "the round
/// is over" are mutually exclusive, and a union makes the illegal combinations
/// unrepresentable.
@freezed
sealed class SessionState with _$SessionState {
  const factory SessionState.loading() = SessionLoading;

  /// No session running: the five subjects of the next 25 minutes are picked
  /// first. Only subjects that have something to serve today are offered —
  /// the domain decides which, in `DueCardsPolicy.studiableSubjects`.
  const factory SessionState.chooseSubjects(
    List<SubjectQueue> availableSubjects,
  ) = SessionChooseSubjects;

  /// Question only. The answer is not in the widget tree yet — it is built
  /// when the state changes, never hidden behind an `Opacity`.
  ///
  /// [remaining] counts this card too: it is "how many are left", the way a
  /// reviewer's counter reads.
  const factory SessionState.showingQuestion(
    Card card,
    int roundIndex,
    String subject,
    int remaining,
  ) = SessionShowingQuestion;

  /// Answer revealed, with the interval each button would schedule.
  const factory SessionState.showingAnswer(
    Card card,
    Map<Rating, Duration> previews,
    int roundIndex,
    String subject,
    int remaining,
  ) = SessionShowingAnswer;

  /// Silent turn of the round: which subject ended, which one starts, and how
  /// much is still due in the one that ended.
  const factory SessionState.roundBreak(
    String finished,
    String? next,
    int remainingDueCards,
  ) = SessionRoundBreak;

  const factory SessionState.scoreboard(StudySession session) =
      SessionScoreboard;

  /// Nothing due and nothing to anticipate (H12).
  const factory SessionState.dayCleared() = SessionDayCleared;

  const factory SessionState.error(String message) = SessionError;
}
