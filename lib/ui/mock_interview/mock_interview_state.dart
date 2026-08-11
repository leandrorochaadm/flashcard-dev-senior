import 'package:freezed_annotation/freezed_annotation.dart';

import '../../domain/mock_interview/mock_interview_service.dart';
import '../../domain/models/card.dart';

part 'mock_interview_state.freezed.dart';

/// Screen state of the mock interview (H10).
///
/// A union: "answer revealed" and "the mock is over" are mutually exclusive,
/// and the timed run needs the remaining time to travel with the question, not
/// beside it.
@freezed
sealed class MockInterviewState with _$MockInterviewState {
  const factory MockInterviewState.loading() = MockInterviewLoading;

  /// Picking the size: by number of questions or by time.
  const factory MockInterviewState.setup({
    required int availableCards,
  }) = MockInterviewSetup;

  const factory MockInterviewState.showingQuestion({
    required Card card,
    required int position,

    /// `null` on a timed mock: the number of questions is not known upfront.
    required int? total,

    /// `null` on a mock sized by number of questions.
    required Duration? remaining,
  }) = MockInterviewShowingQuestion;

  const factory MockInterviewState.showingAnswer({
    required Card card,
    required int position,
    required int? total,
    required Duration? remaining,

    /// The clock ran out while this question was open — it will be the last.
    required bool lastQuestion,
  }) = MockInterviewShowingAnswer;

  /// Score per subject, next to every mock answered before this one.
  const factory MockInterviewState.finished({
    required List<MockInterviewScore> scores,
    required List<MockInterviewScore> previousScores,
  }) = MockInterviewFinished;

  const factory MockInterviewState.error(String message) = MockInterviewError;
}
