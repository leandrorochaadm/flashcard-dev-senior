// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'card.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Card {

 String get id; String get question; String get answer; String get subject; Difficulty get difficulty; double get stability; double get difficultyFsrs; CardState get state; int get learningStep; DateTime? get dueAt; int get lapses; int get reps; DateTime? get lastReviewedAt; DateTime get importedAt; DateTime? get introducedAt;
/// Create a copy of Card
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CardCopyWith<Card> get copyWith => _$CardCopyWithImpl<Card>(this as Card, _$identity);

  /// Serializes this Card to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Card&&(identical(other.id, id) || other.id == id)&&(identical(other.question, question) || other.question == question)&&(identical(other.answer, answer) || other.answer == answer)&&(identical(other.subject, subject) || other.subject == subject)&&(identical(other.difficulty, difficulty) || other.difficulty == difficulty)&&(identical(other.stability, stability) || other.stability == stability)&&(identical(other.difficultyFsrs, difficultyFsrs) || other.difficultyFsrs == difficultyFsrs)&&(identical(other.state, state) || other.state == state)&&(identical(other.learningStep, learningStep) || other.learningStep == learningStep)&&(identical(other.dueAt, dueAt) || other.dueAt == dueAt)&&(identical(other.lapses, lapses) || other.lapses == lapses)&&(identical(other.reps, reps) || other.reps == reps)&&(identical(other.lastReviewedAt, lastReviewedAt) || other.lastReviewedAt == lastReviewedAt)&&(identical(other.importedAt, importedAt) || other.importedAt == importedAt)&&(identical(other.introducedAt, introducedAt) || other.introducedAt == introducedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,question,answer,subject,difficulty,stability,difficultyFsrs,state,learningStep,dueAt,lapses,reps,lastReviewedAt,importedAt,introducedAt);

@override
String toString() {
  return 'Card(id: $id, question: $question, answer: $answer, subject: $subject, difficulty: $difficulty, stability: $stability, difficultyFsrs: $difficultyFsrs, state: $state, learningStep: $learningStep, dueAt: $dueAt, lapses: $lapses, reps: $reps, lastReviewedAt: $lastReviewedAt, importedAt: $importedAt, introducedAt: $introducedAt)';
}


}

/// @nodoc
abstract mixin class $CardCopyWith<$Res>  {
  factory $CardCopyWith(Card value, $Res Function(Card) _then) = _$CardCopyWithImpl;
@useResult
$Res call({
 String id, String question, String answer, String subject, Difficulty difficulty, double stability, double difficultyFsrs, CardState state, int learningStep, DateTime? dueAt, int lapses, int reps, DateTime? lastReviewedAt, DateTime importedAt, DateTime? introducedAt
});




}
/// @nodoc
class _$CardCopyWithImpl<$Res>
    implements $CardCopyWith<$Res> {
  _$CardCopyWithImpl(this._self, this._then);

  final Card _self;
  final $Res Function(Card) _then;

/// Create a copy of Card
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? question = null,Object? answer = null,Object? subject = null,Object? difficulty = null,Object? stability = null,Object? difficultyFsrs = null,Object? state = null,Object? learningStep = null,Object? dueAt = freezed,Object? lapses = null,Object? reps = null,Object? lastReviewedAt = freezed,Object? importedAt = null,Object? introducedAt = freezed,}) {
  return _then(Card(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,question: null == question ? _self.question : question // ignore: cast_nullable_to_non_nullable
as String,answer: null == answer ? _self.answer : answer // ignore: cast_nullable_to_non_nullable
as String,subject: null == subject ? _self.subject : subject // ignore: cast_nullable_to_non_nullable
as String,difficulty: null == difficulty ? _self.difficulty : difficulty // ignore: cast_nullable_to_non_nullable
as Difficulty,stability: null == stability ? _self.stability : stability // ignore: cast_nullable_to_non_nullable
as double,difficultyFsrs: null == difficultyFsrs ? _self.difficultyFsrs : difficultyFsrs // ignore: cast_nullable_to_non_nullable
as double,state: null == state ? _self.state : state // ignore: cast_nullable_to_non_nullable
as CardState,learningStep: null == learningStep ? _self.learningStep : learningStep // ignore: cast_nullable_to_non_nullable
as int,dueAt: freezed == dueAt ? _self.dueAt : dueAt // ignore: cast_nullable_to_non_nullable
as DateTime?,lapses: null == lapses ? _self.lapses : lapses // ignore: cast_nullable_to_non_nullable
as int,reps: null == reps ? _self.reps : reps // ignore: cast_nullable_to_non_nullable
as int,lastReviewedAt: freezed == lastReviewedAt ? _self.lastReviewedAt : lastReviewedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,importedAt: null == importedAt ? _self.importedAt : importedAt // ignore: cast_nullable_to_non_nullable
as DateTime,introducedAt: freezed == introducedAt ? _self.introducedAt : introducedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [Card].
extension CardPatterns on Card {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Card value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Card() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Card value)  $default,){
final _that = this;
switch (_that) {
case _Card():
return $default(_that);}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Card value)?  $default,){
final _that = this;
switch (_that) {
case _Card() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String question,  String answer,  String subject,  Difficulty difficulty,  double stability,  double difficultyFsrs,  CardState state,  int learningStep,  DateTime? dueAt,  int lapses,  int reps,  DateTime? lastReviewedAt,  DateTime importedAt,  DateTime? introducedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Card() when $default != null:
return $default(_that.id,_that.question,_that.answer,_that.subject,_that.difficulty,_that.stability,_that.difficultyFsrs,_that.state,_that.learningStep,_that.dueAt,_that.lapses,_that.reps,_that.lastReviewedAt,_that.importedAt,_that.introducedAt);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String question,  String answer,  String subject,  Difficulty difficulty,  double stability,  double difficultyFsrs,  CardState state,  int learningStep,  DateTime? dueAt,  int lapses,  int reps,  DateTime? lastReviewedAt,  DateTime importedAt,  DateTime? introducedAt)  $default,) {final _that = this;
switch (_that) {
case _Card():
return $default(_that.id,_that.question,_that.answer,_that.subject,_that.difficulty,_that.stability,_that.difficultyFsrs,_that.state,_that.learningStep,_that.dueAt,_that.lapses,_that.reps,_that.lastReviewedAt,_that.importedAt,_that.introducedAt);}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String question,  String answer,  String subject,  Difficulty difficulty,  double stability,  double difficultyFsrs,  CardState state,  int learningStep,  DateTime? dueAt,  int lapses,  int reps,  DateTime? lastReviewedAt,  DateTime importedAt,  DateTime? introducedAt)?  $default,) {final _that = this;
switch (_that) {
case _Card() when $default != null:
return $default(_that.id,_that.question,_that.answer,_that.subject,_that.difficulty,_that.stability,_that.difficultyFsrs,_that.state,_that.learningStep,_that.dueAt,_that.lapses,_that.reps,_that.lastReviewedAt,_that.importedAt,_that.introducedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Card extends Card {
  const _Card({required this.id, required this.question, required this.answer, required this.subject, required this.difficulty, required this.stability, required this.difficultyFsrs, required this.state, required this.learningStep, required this.dueAt, required this.lapses, required this.reps, required this.lastReviewedAt, required this.importedAt, required this.introducedAt}): super._();
  factory _Card.fromJson(Map<String, dynamic> json) => _$CardFromJson(json);

@override final  String id;
@override final  String question;
@override final  String answer;
@override final  String subject;
@override final  Difficulty difficulty;
@override final  double stability;
@override final  double difficultyFsrs;
@override final  CardState state;
@override final  int learningStep;
@override final  DateTime? dueAt;
@override final  int lapses;
@override final  int reps;
@override final  DateTime? lastReviewedAt;
@override final  DateTime importedAt;
@override final  DateTime? introducedAt;

/// Create a copy of Card
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CardCopyWith<_Card> get copyWith => __$CardCopyWithImpl<_Card>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CardToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Card&&(identical(other.id, id) || other.id == id)&&(identical(other.question, question) || other.question == question)&&(identical(other.answer, answer) || other.answer == answer)&&(identical(other.subject, subject) || other.subject == subject)&&(identical(other.difficulty, difficulty) || other.difficulty == difficulty)&&(identical(other.stability, stability) || other.stability == stability)&&(identical(other.difficultyFsrs, difficultyFsrs) || other.difficultyFsrs == difficultyFsrs)&&(identical(other.state, state) || other.state == state)&&(identical(other.learningStep, learningStep) || other.learningStep == learningStep)&&(identical(other.dueAt, dueAt) || other.dueAt == dueAt)&&(identical(other.lapses, lapses) || other.lapses == lapses)&&(identical(other.reps, reps) || other.reps == reps)&&(identical(other.lastReviewedAt, lastReviewedAt) || other.lastReviewedAt == lastReviewedAt)&&(identical(other.importedAt, importedAt) || other.importedAt == importedAt)&&(identical(other.introducedAt, introducedAt) || other.introducedAt == introducedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,question,answer,subject,difficulty,stability,difficultyFsrs,state,learningStep,dueAt,lapses,reps,lastReviewedAt,importedAt,introducedAt);

@override
String toString() {
  return 'Card(id: $id, question: $question, answer: $answer, subject: $subject, difficulty: $difficulty, stability: $stability, difficultyFsrs: $difficultyFsrs, state: $state, learningStep: $learningStep, dueAt: $dueAt, lapses: $lapses, reps: $reps, lastReviewedAt: $lastReviewedAt, importedAt: $importedAt, introducedAt: $introducedAt)';
}


}

/// @nodoc
abstract mixin class _$CardCopyWith<$Res> implements $CardCopyWith<$Res> {
  factory _$CardCopyWith(_Card value, $Res Function(_Card) _then) = __$CardCopyWithImpl;
@override @useResult
$Res call({
 String id, String question, String answer, String subject, Difficulty difficulty, double stability, double difficultyFsrs, CardState state, int learningStep, DateTime? dueAt, int lapses, int reps, DateTime? lastReviewedAt, DateTime importedAt, DateTime? introducedAt
});




}
/// @nodoc
class __$CardCopyWithImpl<$Res>
    implements _$CardCopyWith<$Res> {
  __$CardCopyWithImpl(this._self, this._then);

  final _Card _self;
  final $Res Function(_Card) _then;

/// Create a copy of Card
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? question = null,Object? answer = null,Object? subject = null,Object? difficulty = null,Object? stability = null,Object? difficultyFsrs = null,Object? state = null,Object? learningStep = null,Object? dueAt = freezed,Object? lapses = null,Object? reps = null,Object? lastReviewedAt = freezed,Object? importedAt = null,Object? introducedAt = freezed,}) {
  return _then(_Card(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,question: null == question ? _self.question : question // ignore: cast_nullable_to_non_nullable
as String,answer: null == answer ? _self.answer : answer // ignore: cast_nullable_to_non_nullable
as String,subject: null == subject ? _self.subject : subject // ignore: cast_nullable_to_non_nullable
as String,difficulty: null == difficulty ? _self.difficulty : difficulty // ignore: cast_nullable_to_non_nullable
as Difficulty,stability: null == stability ? _self.stability : stability // ignore: cast_nullable_to_non_nullable
as double,difficultyFsrs: null == difficultyFsrs ? _self.difficultyFsrs : difficultyFsrs // ignore: cast_nullable_to_non_nullable
as double,state: null == state ? _self.state : state // ignore: cast_nullable_to_non_nullable
as CardState,learningStep: null == learningStep ? _self.learningStep : learningStep // ignore: cast_nullable_to_non_nullable
as int,dueAt: freezed == dueAt ? _self.dueAt : dueAt // ignore: cast_nullable_to_non_nullable
as DateTime?,lapses: null == lapses ? _self.lapses : lapses // ignore: cast_nullable_to_non_nullable
as int,reps: null == reps ? _self.reps : reps // ignore: cast_nullable_to_non_nullable
as int,lastReviewedAt: freezed == lastReviewedAt ? _self.lastReviewedAt : lastReviewedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,importedAt: null == importedAt ? _self.importedAt : importedAt // ignore: cast_nullable_to_non_nullable
as DateTime,introducedAt: freezed == introducedAt ? _self.introducedAt : introducedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on
