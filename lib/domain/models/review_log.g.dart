// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'review_log.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ReviewLog _$ReviewLogFromJson(Map<String, dynamic> json) => _ReviewLog(
  cardId: json['cardId'] as String,
  reviewedAt: DateTime.parse(json['reviewedAt'] as String),
  rating: $enumDecode(_$RatingEnumMap, json['rating']),
  elapsedDays: (json['elapsedDays'] as num).toDouble(),
  predictedRetention: (json['predictedRetention'] as num).toDouble(),
  stabilityBefore: (json['stabilityBefore'] as num).toDouble(),
  timeOnCard: const _MillisecondsConverter().fromJson(
    (json['timeOnCard'] as num?)?.toInt(),
  ),
  source: $enumDecode(_$ReviewSourceEnumMap, json['source']),
);

Map<String, dynamic> _$ReviewLogToJson(_ReviewLog instance) =>
    <String, dynamic>{
      'cardId': instance.cardId,
      'reviewedAt': instance.reviewedAt.toIso8601String(),
      'rating': _$RatingEnumMap[instance.rating]!,
      'elapsedDays': instance.elapsedDays,
      'predictedRetention': instance.predictedRetention,
      'stabilityBefore': instance.stabilityBefore,
      'timeOnCard': const _MillisecondsConverter().toJson(instance.timeOnCard),
      'source': _$ReviewSourceEnumMap[instance.source]!,
    };

const _$RatingEnumMap = {
  Rating.again: 'again',
  Rating.hard: 'hard',
  Rating.good: 'good',
  Rating.easy: 'easy',
};

const _$ReviewSourceEnumMap = {
  ReviewSource.session: 'session',
  ReviewSource.mockInterview: 'mock_interview',
};
