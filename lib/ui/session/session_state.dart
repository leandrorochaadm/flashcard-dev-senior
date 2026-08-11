import 'package:freezed_annotation/freezed_annotation.dart';

import '../../domain/models/card.dart';
import '../../domain/models/enums.dart';
import '../../domain/models/study_session.dart';

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
  /// first.
  const factory SessionState.chooseSubjects(List<String> availableSubjects) =
      SessionChooseSubjects;

  /// Question only. The answer is not in the widget tree yet — it is built
  /// when the state changes, never hidden behind an `Opacity`.
  const factory SessionState.showingQuestion(
    Card card,
    int roundIndex,
    String subject,
  ) = SessionShowingQuestion;

  /// Answer revealed, with the interval each button would schedule.
  const factory SessionState.showingAnswer(
    Card card,
    Map<Rating, Duration> previews,
    int roundIndex,
    String subject,
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
