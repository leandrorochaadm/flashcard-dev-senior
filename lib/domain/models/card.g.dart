// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'card.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Card _$CardFromJson(Map<String, dynamic> json) => _Card(
  id: json['id'] as String,
  question: json['question'] as String,
  answer: json['answer'] as String,
  subject: json['subject'] as String,
  difficulty: $enumDecode(_$DifficultyEnumMap, json['difficulty']),
  stability: (json['stability'] as num).toDouble(),
  difficultyFsrs: (json['difficultyFsrs'] as num).toDouble(),
  state: $enumDecode(_$CardStateEnumMap, json['state']),
  learningStep: (json['learningStep'] as num).toInt(),
  dueAt: json['dueAt'] == null ? null : DateTime.parse(json['dueAt'] as String),
  lapses: (json['lapses'] as num).toInt(),
  reps: (json['reps'] as num).toInt(),
  lastReviewedAt: json['lastReviewedAt'] == null
      ? null
      : DateTime.parse(json['lastReviewedAt'] as String),
  importedAt: DateTime.parse(json['importedAt'] as String),
  introducedAt: json['introducedAt'] == null
      ? null
      : DateTime.parse(json['introducedAt'] as String),
);

Map<String, dynamic> _$CardToJson(_Card instance) => <String, dynamic>{
  'id': instance.id,
  'question': instance.question,
  'answer': instance.answer,
  'subject': instance.subject,
  'difficulty': _$DifficultyEnumMap[instance.difficulty]!,
  'stability': instance.stability,
  'difficultyFsrs': instance.difficultyFsrs,
  'state': _$CardStateEnumMap[instance.state]!,
  'learningStep': instance.learningStep,
  'dueAt': instance.dueAt?.toIso8601String(),
  'lapses': instance.lapses,
  'reps': instance.reps,
  'lastReviewedAt': instance.lastReviewedAt?.toIso8601String(),
  'importedAt': instance.importedAt.toIso8601String(),
  'introducedAt': instance.introducedAt?.toIso8601String(),
};

const _$DifficultyEnumMap = {
  Difficulty.basic: 'basico',
  Difficulty.intermediate: 'intermediario',
  Difficulty.advanced: 'avancado',
};

const _$CardStateEnumMap = {
  CardState.newCard: 'new',
  CardState.learning: 'learning',
  CardState.review: 'review',
  CardState.relearning: 'relearning',
};
