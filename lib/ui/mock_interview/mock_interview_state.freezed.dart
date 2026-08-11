// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'mock_interview_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$MockInterviewState {





@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MockInterviewState);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'MockInterviewState()';
}


}

/// @nodoc
class $MockInterviewStateCopyWith<$Res>  {
$MockInterviewStateCopyWith(MockInterviewState _, $Res Function(MockInterviewState) __);
}


/// Adds pattern-matching-related methods to [MockInterviewState].
extension MockInterviewStatePatterns on MockInterviewState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( MockInterviewLoading value)?  loading,TResult Function( MockInterviewSetup value)?  setup,TResult Function( MockInterviewShowingQuestion value)?  showingQuestion,TResult Function( MockInterviewShowingAnswer value)?  showingAnswer,TResult Function( MockInterviewFinished value)?  finished,TResult Function( MockInterviewError value)?  error,required TResult orElse(),}){
final _that = this;
switch (_that) {
case MockInterviewLoading() when loading != null:
return loading(_that);case MockInterviewSetup() when setup != null:
return setup(_that);case MockInterviewShowingQuestion() when showingQuestion != null:
return showingQuestion(_that);case MockInterviewShowingAnswer() when showingAnswer != null:
return showingAnswer(_that);case MockInterviewFinished() when finished != null:
return finished(_that);case MockInterviewError() when error != null:
return error(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( MockInterviewLoading value)  loading,required TResult Function( MockInterviewSetup value)  setup,required TResult Function( MockInterviewShowingQuestion value)  showingQuestion,required TResult Function( MockInterviewShowingAnswer value)  showingAnswer,required TResult Function( MockInterviewFinished value)  finished,required TResult Function( MockInterviewError value)  error,}){
final _that = this;
switch (_that) {
case MockInterviewLoading():
return loading(_that);case MockInterviewSetup():
return setup(_that);case MockInterviewShowingQuestion():
return showingQuestion(_that);case MockInterviewShowingAnswer():
return showingAnswer(_that);case MockInterviewFinished():
return finished(_that);case MockInterviewError():
return error(_that);}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( MockInterviewLoading value)?  loading,TResult? Function( MockInterviewSetup value)?  setup,TResult? Function( MockInterviewShowingQuestion value)?  showingQuestion,TResult? Function( MockInterviewShowingAnswer value)?  showingAnswer,TResult? Function( MockInterviewFinished value)?  finished,TResult? Function( MockInterviewError value)?  error,}){
final _that = this;
switch (_that) {
case MockInterviewLoading() when loading != null:
return loading(_that);case MockInterviewSetup() when setup != null:
return setup(_that);case MockInterviewShowingQuestion() when showingQuestion != null:
return showingQuestion(_that);case MockInterviewShowingAnswer() when showingAnswer != null:
return showingAnswer(_that);case MockInterviewFinished() when finished != null:
return finished(_that);case MockInterviewError() when error != null:
return error(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function()?  loading,TResult Function( int availableCards)?  setup,TResult Function( Card card,  int position,  int? total,  Duration? remaining)?  showingQuestion,TResult Function( Card card,  int position,  int? total,  Duration? remaining,  bool lastQuestion)?  showingAnswer,TResult Function( List<MockInterviewScore> scores,  List<MockInterviewScore> previousScores)?  finished,TResult Function( String message)?  error,required TResult orElse(),}) {final _that = this;
switch (_that) {
case MockInterviewLoading() when loading != null:
return loading();case MockInterviewSetup() when setup != null:
return setup(_that.availableCards);case MockInterviewShowingQuestion() when showingQuestion != null:
return showingQuestion(_that.card,_that.position,_that.total,_that.remaining);case MockInterviewShowingAnswer() when showingAnswer != null:
return showingAnswer(_that.card,_that.position,_that.total,_that.remaining,_that.lastQuestion);case MockInterviewFinished() when finished != null:
return finished(_that.scores,_that.previousScores);case MockInterviewError() when error != null:
return error(_that.message);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function()  loading,required TResult Function( int availableCards)  setup,required TResult Function( Card card,  int position,  int? total,  Duration? remaining)  showingQuestion,required TResult Function( Card card,  int position,  int? total,  Duration? remaining,  bool lastQuestion)  showingAnswer,required TResult Function( List<MockInterviewScore> scores,  List<MockInterviewScore> previousScores)  finished,required TResult Function( String message)  error,}) {final _that = this;
switch (_that) {
case MockInterviewLoading():
return loading();case MockInterviewSetup():
return setup(_that.availableCards);case MockInterviewShowingQuestion():
return showingQuestion(_that.card,_that.position,_that.total,_that.remaining);case MockInterviewShowingAnswer():
return showingAnswer(_that.card,_that.position,_that.total,_that.remaining,_that.lastQuestion);case MockInterviewFinished():
return finished(_that.scores,_that.previousScores);case MockInterviewError():
return error(_that.message);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function()?  loading,TResult? Function( int availableCards)?  setup,TResult? Function( Card card,  int position,  int? total,  Duration? remaining)?  showingQuestion,TResult? Function( Card card,  int position,  int? total,  Duration? remaining,  bool lastQuestion)?  showingAnswer,TResult? Function( List<MockInterviewScore> scores,  List<MockInterviewScore> previousScores)?  finished,TResult? Function( String message)?  error,}) {final _that = this;
switch (_that) {
case MockInterviewLoading() when loading != null:
return loading();case MockInterviewSetup() when setup != null:
return setup(_that.availableCards);case MockInterviewShowingQuestion() when showingQuestion != null:
return showingQuestion(_that.card,_that.position,_that.total,_that.remaining);case MockInterviewShowingAnswer() when showingAnswer != null:
return showingAnswer(_that.card,_that.position,_that.total,_that.remaining,_that.lastQuestion);case MockInterviewFinished() when finished != null:
return finished(_that.scores,_that.previousScores);case MockInterviewError() when error != null:
return error(_that.message);case _:
  return null;

}
}

}

/// @nodoc


class MockInterviewLoading implements MockInterviewState {
  const MockInterviewLoading();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MockInterviewLoading);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'MockInterviewState.loading()';
}


}




/// @nodoc


class MockInterviewSetup implements MockInterviewState {
  const MockInterviewSetup({required this.availableCards});
  

 final  int availableCards;

/// Create a copy of MockInterviewState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MockInterviewSetupCopyWith<MockInterviewSetup> get copyWith => _$MockInterviewSetupCopyWithImpl<MockInterviewSetup>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MockInterviewSetup&&(identical(other.availableCards, availableCards) || other.availableCards == availableCards));
}


@override
int get hashCode => Object.hash(runtimeType,availableCards);

@override
String toString() {
  return 'MockInterviewState.setup(availableCards: $availableCards)';
}


}

/// @nodoc
abstract mixin class $MockInterviewSetupCopyWith<$Res> implements $MockInterviewStateCopyWith<$Res> {
  factory $MockInterviewSetupCopyWith(MockInterviewSetup value, $Res Function(MockInterviewSetup) _then) = _$MockInterviewSetupCopyWithImpl;
@useResult
$Res call({
 int availableCards
});




}
/// @nodoc
class _$MockInterviewSetupCopyWithImpl<$Res>
    implements $MockInterviewSetupCopyWith<$Res> {
  _$MockInterviewSetupCopyWithImpl(this._self, this._then);

  final MockInterviewSetup _self;
  final $Res Function(MockInterviewSetup) _then;

/// Create a copy of MockInterviewState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? availableCards = null,}) {
  return _then(MockInterviewSetup(
availableCards: null == availableCards ? _self.availableCards : availableCards // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

/// @nodoc


class MockInterviewShowingQuestion implements MockInterviewState {
  const MockInterviewShowingQuestion({required this.card, required this.position, required this.total, required this.remaining});
  

 final  Card card;
 final  int position;
/// `null` on a timed mock: the number of questions is not known upfront.
 final  int? total;
/// `null` on a mock sized by number of questions.
 final  Duration? remaining;

/// Create a copy of MockInterviewState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MockInterviewShowingQuestionCopyWith<MockInterviewShowingQuestion> get copyWith => _$MockInterviewShowingQuestionCopyWithImpl<MockInterviewShowingQuestion>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MockInterviewShowingQuestion&&(identical(other.card, card) || other.card == card)&&(identical(other.position, position) || other.position == position)&&(identical(other.total, total) || other.total == total)&&(identical(other.remaining, remaining) || other.remaining == remaining));
}


@override
int get hashCode => Object.hash(runtimeType,card,position,total,remaining);

@override
String toString() {
  return 'MockInterviewState.showingQuestion(card: $card, position: $position, total: $total, remaining: $remaining)';
}


}

/// @nodoc
abstract mixin class $MockInterviewShowingQuestionCopyWith<$Res> implements $MockInterviewStateCopyWith<$Res> {
  factory $MockInterviewShowingQuestionCopyWith(MockInterviewShowingQuestion value, $Res Function(MockInterviewShowingQuestion) _then) = _$MockInterviewShowingQuestionCopyWithImpl;
@useResult
$Res call({
 Card card, int position, int? total, Duration? remaining
});


$CardCopyWith<$Res> get card;

}
/// @nodoc
class _$MockInterviewShowingQuestionCopyWithImpl<$Res>
    implements $MockInterviewShowingQuestionCopyWith<$Res> {
  _$MockInterviewShowingQuestionCopyWithImpl(this._self, this._then);

  final MockInterviewShowingQuestion _self;
  final $Res Function(MockInterviewShowingQuestion) _then;

/// Create a copy of MockInterviewState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? card = null,Object? position = null,Object? total = freezed,Object? remaining = freezed,}) {
  return _then(MockInterviewShowingQuestion(
card: null == card ? _self.card : card // ignore: cast_nullable_to_non_nullable
as Card,position: null == position ? _self.position : position // ignore: cast_nullable_to_non_nullable
as int,total: freezed == total ? _self.total : total // ignore: cast_nullable_to_non_nullable
as int?,remaining: freezed == remaining ? _self.remaining : remaining // ignore: cast_nullable_to_non_nullable
as Duration?,
  ));
}

/// Create a copy of MockInterviewState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CardCopyWith<$Res> get card {
  
  return $CardCopyWith<$Res>(_self.card, (value) {
    return _then(_self.copyWith(card: value));
  });
}
}

/// @nodoc


class MockInterviewShowingAnswer implements MockInterviewState {
  const MockInterviewShowingAnswer({required this.card, required this.position, required this.total, required this.remaining, required this.lastQuestion});
  

 final  Card card;
 final  int position;
 final  int? total;
 final  Duration? remaining;
/// The clock ran out while this question was open — it will be the last.
 final  bool lastQuestion;

/// Create a copy of MockInterviewState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MockInterviewShowingAnswerCopyWith<MockInterviewShowingAnswer> get copyWith => _$MockInterviewShowingAnswerCopyWithImpl<MockInterviewShowingAnswer>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MockInterviewShowingAnswer&&(identical(other.card, card) || other.card == card)&&(identical(other.position, position) || other.position == position)&&(identical(other.total, total) || other.total == total)&&(identical(other.remaining, remaining) || other.remaining == remaining)&&(identical(other.lastQuestion, lastQuestion) || other.lastQuestion == lastQuestion));
}


@override
int get hashCode => Object.hash(runtimeType,card,position,total,remaining,lastQuestion);

@override
String toString() {
  return 'MockInterviewState.showingAnswer(card: $card, position: $position, total: $total, remaining: $remaining, lastQuestion: $lastQuestion)';
}


}

/// @nodoc
abstract mixin class $MockInterviewShowingAnswerCopyWith<$Res> implements $MockInterviewStateCopyWith<$Res> {
  factory $MockInterviewShowingAnswerCopyWith(MockInterviewShowingAnswer value, $Res Function(MockInterviewShowingAnswer) _then) = _$MockInterviewShowingAnswerCopyWithImpl;
@useResult
$Res call({
 Card card, int position, int? total, Duration? remaining, bool lastQuestion
});


$CardCopyWith<$Res> get card;

}
/// @nodoc
class _$MockInterviewShowingAnswerCopyWithImpl<$Res>
    implements $MockInterviewShowingAnswerCopyWith<$Res> {
  _$MockInterviewShowingAnswerCopyWithImpl(this._self, this._then);

  final MockInterviewShowingAnswer _self;
  final $Res Function(MockInterviewShowingAnswer) _then;

/// Create a copy of MockInterviewState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? card = null,Object? position = null,Object? total = freezed,Object? remaining = freezed,Object? lastQuestion = null,}) {
  return _then(MockInterviewShowingAnswer(
card: null == card ? _self.card : card // ignore: cast_nullable_to_non_nullable
as Card,position: null == position ? _self.position : position // ignore: cast_nullable_to_non_nullable
as int,total: freezed == total ? _self.total : total // ignore: cast_nullable_to_non_nullable
as int?,remaining: freezed == remaining ? _self.remaining : remaining // ignore: cast_nullable_to_non_nullable
as Duration?,lastQuestion: null == lastQuestion ? _self.lastQuestion : lastQuestion // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

/// Create a copy of MockInterviewState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CardCopyWith<$Res> get card {
  
  return $CardCopyWith<$Res>(_self.card, (value) {
    return _then(_self.copyWith(card: value));
  });
}
}

/// @nodoc


class MockInterviewFinished implements MockInterviewState {
  const MockInterviewFinished({required  List<MockInterviewScore> scores, required  List<MockInterviewScore> previousScores}): _scores = scores,_previousScores = previousScores;
  

 final  List<MockInterviewScore> _scores;
 List<MockInterviewScore> get scores {
  if (_scores is EqualUnmodifiableListView) return _scores;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_scores);
}

 final  List<MockInterviewScore> _previousScores;
 List<MockInterviewScore> get previousScores {
  if (_previousScores is EqualUnmodifiableListView) return _previousScores;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_previousScores);
}


/// Create a copy of MockInterviewState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MockInterviewFinishedCopyWith<MockInterviewFinished> get copyWith => _$MockInterviewFinishedCopyWithImpl<MockInterviewFinished>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MockInterviewFinished&&const DeepCollectionEquality().equals(other._scores, _scores)&&const DeepCollectionEquality().equals(other._previousScores, _previousScores));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_scores),const DeepCollectionEquality().hash(_previousScores));

@override
String toString() {
  return 'MockInterviewState.finished(scores: $scores, previousScores: $previousScores)';
}


}

/// @nodoc
abstract mixin class $MockInterviewFinishedCopyWith<$Res> implements $MockInterviewStateCopyWith<$Res> {
  factory $MockInterviewFinishedCopyWith(MockInterviewFinished value, $Res Function(MockInterviewFinished) _then) = _$MockInterviewFinishedCopyWithImpl;
@useResult
$Res call({
 List<MockInterviewScore> scores, List<MockInterviewScore> previousScores
});




}
/// @nodoc
class _$MockInterviewFinishedCopyWithImpl<$Res>
    implements $MockInterviewFinishedCopyWith<$Res> {
  _$MockInterviewFinishedCopyWithImpl(this._self, this._then);

  final MockInterviewFinished _self;
  final $Res Function(MockInterviewFinished) _then;

/// Create a copy of MockInterviewState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? scores = null,Object? previousScores = null,}) {
  return _then(MockInterviewFinished(
scores: null == scores ? _self._scores : scores // ignore: cast_nullable_to_non_nullable
as List<MockInterviewScore>,previousScores: null == previousScores ? _self._previousScores : previousScores // ignore: cast_nullable_to_non_nullable
as List<MockInterviewScore>,
  ));
}


}

/// @nodoc


class MockInterviewError implements MockInterviewState {
  const MockInterviewError(this.message);
  

 final  String message;

/// Create a copy of MockInterviewState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MockInterviewErrorCopyWith<MockInterviewError> get copyWith => _$MockInterviewErrorCopyWithImpl<MockInterviewError>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MockInterviewError&&(identical(other.message, message) || other.message == message));
}


@override
int get hashCode => Object.hash(runtimeType,message);

@override
String toString() {
  return 'MockInterviewState.error(message: $message)';
}


}

/// @nodoc
abstract mixin class $MockInterviewErrorCopyWith<$Res> implements $MockInterviewStateCopyWith<$Res> {
  factory $MockInterviewErrorCopyWith(MockInterviewError value, $Res Function(MockInterviewError) _then) = _$MockInterviewErrorCopyWithImpl;
@useResult
$Res call({
 String message
});




}
/// @nodoc
class _$MockInterviewErrorCopyWithImpl<$Res>
    implements $MockInterviewErrorCopyWith<$Res> {
  _$MockInterviewErrorCopyWithImpl(this._self, this._then);

  final MockInterviewError _self;
  final $Res Function(MockInterviewError) _then;

/// Create a copy of MockInterviewState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? message = null,}) {
  return _then(MockInterviewError(
null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
