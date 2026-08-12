// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'study_session.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$RoundScore {

 String get subject; int get again; int get hard; int get good; int get easy;
/// Create a copy of RoundScore
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RoundScoreCopyWith<RoundScore> get copyWith => _$RoundScoreCopyWithImpl<RoundScore>(this as RoundScore, _$identity);

  /// Serializes this RoundScore to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RoundScore&&(identical(other.subject, subject) || other.subject == subject)&&(identical(other.again, again) || other.again == again)&&(identical(other.hard, hard) || other.hard == hard)&&(identical(other.good, good) || other.good == good)&&(identical(other.easy, easy) || other.easy == easy));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,subject,again,hard,good,easy);

@override
String toString() {
  return 'RoundScore(subject: $subject, again: $again, hard: $hard, good: $good, easy: $easy)';
}


}

/// @nodoc
abstract mixin class $RoundScoreCopyWith<$Res>  {
  factory $RoundScoreCopyWith(RoundScore value, $Res Function(RoundScore) _then) = _$RoundScoreCopyWithImpl;
@useResult
$Res call({
 String subject, int again, int hard, int good, int easy
});




}
/// @nodoc
class _$RoundScoreCopyWithImpl<$Res>
    implements $RoundScoreCopyWith<$Res> {
  _$RoundScoreCopyWithImpl(this._self, this._then);

  final RoundScore _self;
  final $Res Function(RoundScore) _then;

/// Create a copy of RoundScore
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? subject = null,Object? again = null,Object? hard = null,Object? good = null,Object? easy = null,}) {
  return _then(RoundScore(
subject: null == subject ? _self.subject : subject // ignore: cast_nullable_to_non_nullable
as String,again: null == again ? _self.again : again // ignore: cast_nullable_to_non_nullable
as int,hard: null == hard ? _self.hard : hard // ignore: cast_nullable_to_non_nullable
as int,good: null == good ? _self.good : good // ignore: cast_nullable_to_non_nullable
as int,easy: null == easy ? _self.easy : easy // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [RoundScore].
extension RoundScorePatterns on RoundScore {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _RoundScore value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _RoundScore() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _RoundScore value)  $default,){
final _that = this;
switch (_that) {
case _RoundScore():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _RoundScore value)?  $default,){
final _that = this;
switch (_that) {
case _RoundScore() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String subject,  int again,  int hard,  int good,  int easy)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _RoundScore() when $default != null:
return $default(_that.subject,_that.again,_that.hard,_that.good,_that.easy);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String subject,  int again,  int hard,  int good,  int easy)  $default,) {final _that = this;
switch (_that) {
case _RoundScore():
return $default(_that.subject,_that.again,_that.hard,_that.good,_that.easy);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String subject,  int again,  int hard,  int good,  int easy)?  $default,) {final _that = this;
switch (_that) {
case _RoundScore() when $default != null:
return $default(_that.subject,_that.again,_that.hard,_that.good,_that.easy);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _RoundScore extends RoundScore {
  const _RoundScore({required this.subject, required this.again, required this.hard, required this.good, required this.easy}): super._();
  factory _RoundScore.fromJson(Map<String, dynamic> json) => _$RoundScoreFromJson(json);

@override final  String subject;
@override final  int again;
@override final  int hard;
@override final  int good;
@override final  int easy;

/// Create a copy of RoundScore
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RoundScoreCopyWith<_RoundScore> get copyWith => __$RoundScoreCopyWithImpl<_RoundScore>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$RoundScoreToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _RoundScore&&(identical(other.subject, subject) || other.subject == subject)&&(identical(other.again, again) || other.again == again)&&(identical(other.hard, hard) || other.hard == hard)&&(identical(other.good, good) || other.good == good)&&(identical(other.easy, easy) || other.easy == easy));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,subject,again,hard,good,easy);

@override
String toString() {
  return 'RoundScore(subject: $subject, again: $again, hard: $hard, good: $good, easy: $easy)';
}


}

/// @nodoc
abstract mixin class _$RoundScoreCopyWith<$Res> implements $RoundScoreCopyWith<$Res> {
  factory _$RoundScoreCopyWith(_RoundScore value, $Res Function(_RoundScore) _then) = __$RoundScoreCopyWithImpl;
@override @useResult
$Res call({
 String subject, int again, int hard, int good, int easy
});




}
/// @nodoc
class __$RoundScoreCopyWithImpl<$Res>
    implements _$RoundScoreCopyWith<$Res> {
  __$RoundScoreCopyWithImpl(this._self, this._then);

  final _RoundScore _self;
  final $Res Function(_RoundScore) _then;

/// Create a copy of RoundScore
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? subject = null,Object? again = null,Object? hard = null,Object? good = null,Object? easy = null,}) {
  return _then(_RoundScore(
subject: null == subject ? _self.subject : subject // ignore: cast_nullable_to_non_nullable
as String,again: null == again ? _self.again : again // ignore: cast_nullable_to_non_nullable
as int,hard: null == hard ? _self.hard : hard // ignore: cast_nullable_to_non_nullable
as int,good: null == good ? _self.good : good // ignore: cast_nullable_to_non_nullable
as int,easy: null == easy ? _self.easy : easy // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}


/// @nodoc
mixin _$StudySession {

 String get id; DateTime get startedAt; List<String> get subjects; int get currentRound;@DurationSecondsConverter() Duration get remainingInRound; List<RoundScore> get scores; bool get finished;/// The current round was stopped by hand instead of running out of time.
/// It survives a reload so that the resumed session still says "Round
/// encerrado" — hence the schema bump to 2 and its migration.
 bool get roundEndedEarly;
/// Create a copy of StudySession
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$StudySessionCopyWith<StudySession> get copyWith => _$StudySessionCopyWithImpl<StudySession>(this as StudySession, _$identity);

  /// Serializes this StudySession to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is StudySession&&(identical(other.id, id) || other.id == id)&&(identical(other.startedAt, startedAt) || other.startedAt == startedAt)&&const DeepCollectionEquality().equals(other.subjects, subjects)&&(identical(other.currentRound, currentRound) || other.currentRound == currentRound)&&(identical(other.remainingInRound, remainingInRound) || other.remainingInRound == remainingInRound)&&const DeepCollectionEquality().equals(other.scores, scores)&&(identical(other.finished, finished) || other.finished == finished)&&(identical(other.roundEndedEarly, roundEndedEarly) || other.roundEndedEarly == roundEndedEarly));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,startedAt,const DeepCollectionEquality().hash(subjects),currentRound,remainingInRound,const DeepCollectionEquality().hash(scores),finished,roundEndedEarly);

@override
String toString() {
  return 'StudySession(id: $id, startedAt: $startedAt, subjects: $subjects, currentRound: $currentRound, remainingInRound: $remainingInRound, scores: $scores, finished: $finished, roundEndedEarly: $roundEndedEarly)';
}


}

/// @nodoc
abstract mixin class $StudySessionCopyWith<$Res>  {
  factory $StudySessionCopyWith(StudySession value, $Res Function(StudySession) _then) = _$StudySessionCopyWithImpl;
@useResult
$Res call({
 String id, DateTime startedAt, List<String> subjects, int currentRound,@DurationSecondsConverter() Duration remainingInRound, List<RoundScore> scores, bool finished, bool roundEndedEarly
});




}
/// @nodoc
class _$StudySessionCopyWithImpl<$Res>
    implements $StudySessionCopyWith<$Res> {
  _$StudySessionCopyWithImpl(this._self, this._then);

  final StudySession _self;
  final $Res Function(StudySession) _then;

/// Create a copy of StudySession
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? startedAt = null,Object? subjects = null,Object? currentRound = null,Object? remainingInRound = null,Object? scores = null,Object? finished = null,Object? roundEndedEarly = null,}) {
  return _then(StudySession(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,startedAt: null == startedAt ? _self.startedAt : startedAt // ignore: cast_nullable_to_non_nullable
as DateTime,subjects: null == subjects ? _self.subjects : subjects // ignore: cast_nullable_to_non_nullable
as List<String>,currentRound: null == currentRound ? _self.currentRound : currentRound // ignore: cast_nullable_to_non_nullable
as int,remainingInRound: null == remainingInRound ? _self.remainingInRound : remainingInRound // ignore: cast_nullable_to_non_nullable
as Duration,scores: null == scores ? _self.scores : scores // ignore: cast_nullable_to_non_nullable
as List<RoundScore>,finished: null == finished ? _self.finished : finished // ignore: cast_nullable_to_non_nullable
as bool,roundEndedEarly: null == roundEndedEarly ? _self.roundEndedEarly : roundEndedEarly // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [StudySession].
extension StudySessionPatterns on StudySession {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _StudySession value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _StudySession() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _StudySession value)  $default,){
final _that = this;
switch (_that) {
case _StudySession():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _StudySession value)?  $default,){
final _that = this;
switch (_that) {
case _StudySession() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  DateTime startedAt,  List<String> subjects,  int currentRound, @DurationSecondsConverter()  Duration remainingInRound,  List<RoundScore> scores,  bool finished,  bool roundEndedEarly)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _StudySession() when $default != null:
return $default(_that.id,_that.startedAt,_that.subjects,_that.currentRound,_that.remainingInRound,_that.scores,_that.finished,_that.roundEndedEarly);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  DateTime startedAt,  List<String> subjects,  int currentRound, @DurationSecondsConverter()  Duration remainingInRound,  List<RoundScore> scores,  bool finished,  bool roundEndedEarly)  $default,) {final _that = this;
switch (_that) {
case _StudySession():
return $default(_that.id,_that.startedAt,_that.subjects,_that.currentRound,_that.remainingInRound,_that.scores,_that.finished,_that.roundEndedEarly);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  DateTime startedAt,  List<String> subjects,  int currentRound, @DurationSecondsConverter()  Duration remainingInRound,  List<RoundScore> scores,  bool finished,  bool roundEndedEarly)?  $default,) {final _that = this;
switch (_that) {
case _StudySession() when $default != null:
return $default(_that.id,_that.startedAt,_that.subjects,_that.currentRound,_that.remainingInRound,_that.scores,_that.finished,_that.roundEndedEarly);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _StudySession extends StudySession {
  const _StudySession({required this.id, required this.startedAt, required  List<String> subjects, required this.currentRound, @DurationSecondsConverter() required this.remainingInRound, required  List<RoundScore> scores, required this.finished, this.roundEndedEarly = false}): _subjects = subjects,_scores = scores,super._();
  factory _StudySession.fromJson(Map<String, dynamic> json) => _$StudySessionFromJson(json);

@override final  String id;
@override final  DateTime startedAt;
 final  List<String> _subjects;
@override List<String> get subjects {
  if (_subjects is EqualUnmodifiableListView) return _subjects;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_subjects);
}

@override final  int currentRound;
@override@DurationSecondsConverter() final  Duration remainingInRound;
 final  List<RoundScore> _scores;
@override List<RoundScore> get scores {
  if (_scores is EqualUnmodifiableListView) return _scores;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_scores);
}

@override final  bool finished;
/// The current round was stopped by hand instead of running out of time.
/// It survives a reload so that the resumed session still says "Round
/// encerrado" — hence the schema bump to 2 and its migration.
@override@JsonKey() final  bool roundEndedEarly;

/// Create a copy of StudySession
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$StudySessionCopyWith<_StudySession> get copyWith => __$StudySessionCopyWithImpl<_StudySession>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$StudySessionToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _StudySession&&(identical(other.id, id) || other.id == id)&&(identical(other.startedAt, startedAt) || other.startedAt == startedAt)&&const DeepCollectionEquality().equals(other._subjects, _subjects)&&(identical(other.currentRound, currentRound) || other.currentRound == currentRound)&&(identical(other.remainingInRound, remainingInRound) || other.remainingInRound == remainingInRound)&&const DeepCollectionEquality().equals(other._scores, _scores)&&(identical(other.finished, finished) || other.finished == finished)&&(identical(other.roundEndedEarly, roundEndedEarly) || other.roundEndedEarly == roundEndedEarly));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,startedAt,const DeepCollectionEquality().hash(_subjects),currentRound,remainingInRound,const DeepCollectionEquality().hash(_scores),finished,roundEndedEarly);

@override
String toString() {
  return 'StudySession(id: $id, startedAt: $startedAt, subjects: $subjects, currentRound: $currentRound, remainingInRound: $remainingInRound, scores: $scores, finished: $finished, roundEndedEarly: $roundEndedEarly)';
}


}

/// @nodoc
abstract mixin class _$StudySessionCopyWith<$Res> implements $StudySessionCopyWith<$Res> {
  factory _$StudySessionCopyWith(_StudySession value, $Res Function(_StudySession) _then) = __$StudySessionCopyWithImpl;
@override @useResult
$Res call({
 String id, DateTime startedAt, List<String> subjects, int currentRound,@DurationSecondsConverter() Duration remainingInRound, List<RoundScore> scores, bool finished, bool roundEndedEarly
});




}
/// @nodoc
class __$StudySessionCopyWithImpl<$Res>
    implements _$StudySessionCopyWith<$Res> {
  __$StudySessionCopyWithImpl(this._self, this._then);

  final _StudySession _self;
  final $Res Function(_StudySession) _then;

/// Create a copy of StudySession
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? startedAt = null,Object? subjects = null,Object? currentRound = null,Object? remainingInRound = null,Object? scores = null,Object? finished = null,Object? roundEndedEarly = null,}) {
  return _then(_StudySession(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,startedAt: null == startedAt ? _self.startedAt : startedAt // ignore: cast_nullable_to_non_nullable
as DateTime,subjects: null == subjects ? _self._subjects : subjects // ignore: cast_nullable_to_non_nullable
as List<String>,currentRound: null == currentRound ? _self.currentRound : currentRound // ignore: cast_nullable_to_non_nullable
as int,remainingInRound: null == remainingInRound ? _self.remainingInRound : remainingInRound // ignore: cast_nullable_to_non_nullable
as Duration,scores: null == scores ? _self._scores : scores // ignore: cast_nullable_to_non_nullable
as List<RoundScore>,finished: null == finished ? _self.finished : finished // ignore: cast_nullable_to_non_nullable
as bool,roundEndedEarly: null == roundEndedEarly ? _self.roundEndedEarly : roundEndedEarly // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
