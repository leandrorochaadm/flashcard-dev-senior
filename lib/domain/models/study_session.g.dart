// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'study_session.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_RoundScore _$RoundScoreFromJson(Map<String, dynamic> json) => _RoundScore(
  subject: json['subject'] as String,
  again: (json['again'] as num).toInt(),
  hard: (json['hard'] as num).toInt(),
  good: (json['good'] as num).toInt(),
  easy: (json['easy'] as num).toInt(),
);

Map<String, dynamic> _$RoundScoreToJson(_RoundScore instance) =>
    <String, dynamic>{
      'subject': instance.subject,
      'again': instance.again,
      'hard': instance.hard,
      'good': instance.good,
      'easy': instance.easy,
    };

_StudySession _$StudySessionFromJson(Map<String, dynamic> json) =>
    _StudySession(
      id: json['id'] as String,
      startedAt: DateTime.parse(json['startedAt'] as String),
      subjects: (json['subjects'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      currentRound: (json['currentRound'] as num).toInt(),
      remainingInRound: const DurationSecondsConverter().fromJson(
        (json['remainingInRound'] as num).toInt(),
      ),
      scores: (json['scores'] as List<dynamic>)
          .map((e) => RoundScore.fromJson(e as Map<String, dynamic>))
          .toList(),
      finished: json['finished'] as bool,
      roundEndedEarly: json['roundEndedEarly'] as bool? ?? false,
    );

Map<String, dynamic> _$StudySessionToJson(_StudySession instance) =>
    <String, dynamic>{
      'id': instance.id,
      'startedAt': instance.startedAt.toIso8601String(),
      'subjects': instance.subjects,
      'currentRound': instance.currentRound,
      'remainingInRound': const DurationSecondsConverter().toJson(
        instance.remainingInRound,
      ),
      'scores': instance.scores.map((e) => e.toJson()).toList(),
      'finished': instance.finished,
      'roundEndedEarly': instance.roundEndedEarly,
    };
