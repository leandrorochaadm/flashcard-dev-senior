import 'package:freezed_annotation/freezed_annotation.dart';

import 'enums.dart';

part 'study_session.freezed.dart';
part 'study_session.g.dart';

/// json_serializable has no built-in mapping for [Duration].
class DurationSecondsConverter implements JsonConverter<Duration, int> {
  const DurationSecondsConverter();

  @override
  Duration fromJson(int json) => Duration(seconds: json);

  @override
  int toJson(Duration object) => object.inSeconds;
}

/// How the study went in one 5-minute round.
@freezed
sealed class RoundScore with _$RoundScore {
  const RoundScore._();

  const factory RoundScore({
    required String subject,
    required int again,
    required int hard,
    required int good,
    required int easy,
  }) = _RoundScore;

  factory RoundScore.blank(String subject) =>
      RoundScore(subject: subject, again: 0, hard: 0, good: 0, easy: 0);

  factory RoundScore.fromJson(Map<String, Object?> json) =>
      _$RoundScoreFromJson(json);

  int get answered => again + hard + good + easy;

  /// "Errei" is the only miss; the other three all reached the answer.
  int get recalled => hard + good + easy;

  double? get accuracy => answered == 0 ? null : recalled / answered;

  RoundScore plus(Rating rating) => switch (rating) {
        Rating.again => copyWith(again: again + 1),
        Rating.hard => copyWith(hard: hard + 1),
        Rating.good => copyWith(good: good + 1),
        Rating.easy => copyWith(easy: easy + 1),
      };
}

/// A 25-minute block: 5 rounds of 5 minutes, one subject each.
///
/// Persisted on every answer and every round change so that closing the app
/// mid-round resumes on the same round with the same time left — the browser
/// gives no reliable "closing" event to hook onto.
@freezed
sealed class StudySession with _$StudySession {
  const StudySession._();

  const factory StudySession({
    required String id,
    required DateTime startedAt,
    required List<String> subjects,
    required int currentRound,
    @DurationSecondsConverter() required Duration remainingInRound,
    required List<RoundScore> scores,
    required bool finished,

    /// The current round was stopped by hand instead of running out of time.
    /// It survives a reload so that the resumed session still says "Round
    /// encerrado" — hence the schema bump to 2 and its migration.
    @Default(false) bool roundEndedEarly,
  }) = _StudySession;

  factory StudySession.fromJson(Map<String, Object?> json) =>
      _$StudySessionFromJson(json);

  String get currentSubject => subjects[currentRound];

  String? get nextSubject =>
      currentRound + 1 < subjects.length ? subjects[currentRound + 1] : null;

  RoundScore get currentScore => scores[currentRound];

  int get answered => scores.fold(0, (sum, score) => sum + score.answered);

  int get recalled => scores.fold(0, (sum, score) => sum + score.recalled);

  /// The four buttons summed across every round of the session.
  ///
  /// `RoundScore` has kept them apart since the first session was recorded and
  /// no screen ever showed them: the dashboard collapsed everything into
  /// [recalled], and "half the answers were 'Lembrei com esforço'" is a
  /// different reading from "8/12". Summing across rounds is the model's job,
  /// not the screen's.
  ///
  /// These are getters written in the body of the class, so they never pass
  /// through the generator: the persisted JSON does not change and
  /// `AppDatabase.schemaVersion` is not incremented.
  int get againTotal => scores.fold(0, (sum, score) => sum + score.again);

  int get hardTotal => scores.fold(0, (sum, score) => sum + score.hard);

  int get goodTotal => scores.fold(0, (sum, score) => sum + score.good);

  int get easyTotal => scores.fold(0, (sum, score) => sum + score.easy);
}
