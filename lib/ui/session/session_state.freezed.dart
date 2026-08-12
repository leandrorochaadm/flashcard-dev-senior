// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'session_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$SessionState {





@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SessionState);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'SessionState()';
}


}

/// @nodoc
class $SessionStateCopyWith<$Res>  {
$SessionStateCopyWith(SessionState _, $Res Function(SessionState) __);
}


/// Adds pattern-matching-related methods to [SessionState].
extension SessionStatePatterns on SessionState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( SessionLoading value)?  loading,TResult Function( SessionChooseSubjects value)?  chooseSubjects,TResult Function( SessionShowingQuestion value)?  showingQuestion,TResult Function( SessionShowingAnswer value)?  showingAnswer,TResult Function( SessionRoundBreak value)?  roundBreak,TResult Function( SessionScoreboard value)?  scoreboard,TResult Function( SessionDayCleared value)?  dayCleared,TResult Function( SessionError value)?  error,required TResult orElse(),}){
final _that = this;
switch (_that) {
case SessionLoading() when loading != null:
return loading(_that);case SessionChooseSubjects() when chooseSubjects != null:
return chooseSubjects(_that);case SessionShowingQuestion() when showingQuestion != null:
return showingQuestion(_that);case SessionShowingAnswer() when showingAnswer != null:
return showingAnswer(_that);case SessionRoundBreak() when roundBreak != null:
return roundBreak(_that);case SessionScoreboard() when scoreboard != null:
return scoreboard(_that);case SessionDayCleared() when dayCleared != null:
return dayCleared(_that);case SessionError() when error != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( SessionLoading value)  loading,required TResult Function( SessionChooseSubjects value)  chooseSubjects,required TResult Function( SessionShowingQuestion value)  showingQuestion,required TResult Function( SessionShowingAnswer value)  showingAnswer,required TResult Function( SessionRoundBreak value)  roundBreak,required TResult Function( SessionScoreboard value)  scoreboard,required TResult Function( SessionDayCleared value)  dayCleared,required TResult Function( SessionError value)  error,}){
final _that = this;
switch (_that) {
case SessionLoading():
return loading(_that);case SessionChooseSubjects():
return chooseSubjects(_that);case SessionShowingQuestion():
return showingQuestion(_that);case SessionShowingAnswer():
return showingAnswer(_that);case SessionRoundBreak():
return roundBreak(_that);case SessionScoreboard():
return scoreboard(_that);case SessionDayCleared():
return dayCleared(_that);case SessionError():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( SessionLoading value)?  loading,TResult? Function( SessionChooseSubjects value)?  chooseSubjects,TResult? Function( SessionShowingQuestion value)?  showingQuestion,TResult? Function( SessionShowingAnswer value)?  showingAnswer,TResult? Function( SessionRoundBreak value)?  roundBreak,TResult? Function( SessionScoreboard value)?  scoreboard,TResult? Function( SessionDayCleared value)?  dayCleared,TResult? Function( SessionError value)?  error,}){
final _that = this;
switch (_that) {
case SessionLoading() when loading != null:
return loading(_that);case SessionChooseSubjects() when chooseSubjects != null:
return chooseSubjects(_that);case SessionShowingQuestion() when showingQuestion != null:
return showingQuestion(_that);case SessionShowingAnswer() when showingAnswer != null:
return showingAnswer(_that);case SessionRoundBreak() when roundBreak != null:
return roundBreak(_that);case SessionScoreboard() when scoreboard != null:
return scoreboard(_that);case SessionDayCleared() when dayCleared != null:
return dayCleared(_that);case SessionError() when error != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function()?  loading,TResult Function( List<SubjectQueue> availableSubjects)?  chooseSubjects,TResult Function( Card card,  int roundIndex,  int roundCount,  String subject,  int remaining)?  showingQuestion,TResult Function( Card card,  Map<Rating, Duration> previews,  int roundIndex,  int roundCount,  String subject,  int remaining)?  showingAnswer,TResult Function( String finished,  String? next,  int remainingDueCards,  bool endedEarly)?  roundBreak,TResult Function( StudySession session)?  scoreboard,TResult Function()?  dayCleared,TResult Function( String message)?  error,required TResult orElse(),}) {final _that = this;
switch (_that) {
case SessionLoading() when loading != null:
return loading();case SessionChooseSubjects() when chooseSubjects != null:
return chooseSubjects(_that.availableSubjects);case SessionShowingQuestion() when showingQuestion != null:
return showingQuestion(_that.card,_that.roundIndex,_that.roundCount,_that.subject,_that.remaining);case SessionShowingAnswer() when showingAnswer != null:
return showingAnswer(_that.card,_that.previews,_that.roundIndex,_that.roundCount,_that.subject,_that.remaining);case SessionRoundBreak() when roundBreak != null:
return roundBreak(_that.finished,_that.next,_that.remainingDueCards,_that.endedEarly);case SessionScoreboard() when scoreboard != null:
return scoreboard(_that.session);case SessionDayCleared() when dayCleared != null:
return dayCleared();case SessionError() when error != null:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function()  loading,required TResult Function( List<SubjectQueue> availableSubjects)  chooseSubjects,required TResult Function( Card card,  int roundIndex,  int roundCount,  String subject,  int remaining)  showingQuestion,required TResult Function( Card card,  Map<Rating, Duration> previews,  int roundIndex,  int roundCount,  String subject,  int remaining)  showingAnswer,required TResult Function( String finished,  String? next,  int remainingDueCards,  bool endedEarly)  roundBreak,required TResult Function( StudySession session)  scoreboard,required TResult Function()  dayCleared,required TResult Function( String message)  error,}) {final _that = this;
switch (_that) {
case SessionLoading():
return loading();case SessionChooseSubjects():
return chooseSubjects(_that.availableSubjects);case SessionShowingQuestion():
return showingQuestion(_that.card,_that.roundIndex,_that.roundCount,_that.subject,_that.remaining);case SessionShowingAnswer():
return showingAnswer(_that.card,_that.previews,_that.roundIndex,_that.roundCount,_that.subject,_that.remaining);case SessionRoundBreak():
return roundBreak(_that.finished,_that.next,_that.remainingDueCards,_that.endedEarly);case SessionScoreboard():
return scoreboard(_that.session);case SessionDayCleared():
return dayCleared();case SessionError():
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function()?  loading,TResult? Function( List<SubjectQueue> availableSubjects)?  chooseSubjects,TResult? Function( Card card,  int roundIndex,  int roundCount,  String subject,  int remaining)?  showingQuestion,TResult? Function( Card card,  Map<Rating, Duration> previews,  int roundIndex,  int roundCount,  String subject,  int remaining)?  showingAnswer,TResult? Function( String finished,  String? next,  int remainingDueCards,  bool endedEarly)?  roundBreak,TResult? Function( StudySession session)?  scoreboard,TResult? Function()?  dayCleared,TResult? Function( String message)?  error,}) {final _that = this;
switch (_that) {
case SessionLoading() when loading != null:
return loading();case SessionChooseSubjects() when chooseSubjects != null:
return chooseSubjects(_that.availableSubjects);case SessionShowingQuestion() when showingQuestion != null:
return showingQuestion(_that.card,_that.roundIndex,_that.roundCount,_that.subject,_that.remaining);case SessionShowingAnswer() when showingAnswer != null:
return showingAnswer(_that.card,_that.previews,_that.roundIndex,_that.roundCount,_that.subject,_that.remaining);case SessionRoundBreak() when roundBreak != null:
return roundBreak(_that.finished,_that.next,_that.remainingDueCards,_that.endedEarly);case SessionScoreboard() when scoreboard != null:
return scoreboard(_that.session);case SessionDayCleared() when dayCleared != null:
return dayCleared();case SessionError() when error != null:
return error(_that.message);case _:
  return null;

}
}

}

/// @nodoc


class SessionLoading implements SessionState {
  const SessionLoading();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SessionLoading);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'SessionState.loading()';
}


}




/// @nodoc


class SessionChooseSubjects implements SessionState {
  const SessionChooseSubjects( List<SubjectQueue> availableSubjects): _availableSubjects = availableSubjects;
  

 final  List<SubjectQueue> _availableSubjects;
 List<SubjectQueue> get availableSubjects {
  if (_availableSubjects is EqualUnmodifiableListView) return _availableSubjects;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_availableSubjects);
}


/// Create a copy of SessionState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SessionChooseSubjectsCopyWith<SessionChooseSubjects> get copyWith => _$SessionChooseSubjectsCopyWithImpl<SessionChooseSubjects>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SessionChooseSubjects&&const DeepCollectionEquality().equals(other._availableSubjects, _availableSubjects));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_availableSubjects));

@override
String toString() {
  return 'SessionState.chooseSubjects(availableSubjects: $availableSubjects)';
}


}

/// @nodoc
abstract mixin class $SessionChooseSubjectsCopyWith<$Res> implements $SessionStateCopyWith<$Res> {
  factory $SessionChooseSubjectsCopyWith(SessionChooseSubjects value, $Res Function(SessionChooseSubjects) _then) = _$SessionChooseSubjectsCopyWithImpl;
@useResult
$Res call({
 List<SubjectQueue> availableSubjects
});




}
/// @nodoc
class _$SessionChooseSubjectsCopyWithImpl<$Res>
    implements $SessionChooseSubjectsCopyWith<$Res> {
  _$SessionChooseSubjectsCopyWithImpl(this._self, this._then);

  final SessionChooseSubjects _self;
  final $Res Function(SessionChooseSubjects) _then;

/// Create a copy of SessionState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? availableSubjects = null,}) {
  return _then(SessionChooseSubjects(
null == availableSubjects ? _self._availableSubjects : availableSubjects // ignore: cast_nullable_to_non_nullable
as List<SubjectQueue>,
  ));
}


}

/// @nodoc


class SessionShowingQuestion implements SessionState {
  const SessionShowingQuestion(this.card, this.roundIndex, this.roundCount, this.subject, this.remaining);
  

 final  Card card;
 final  int roundIndex;
 final  int roundCount;
 final  String subject;
 final  int remaining;

/// Create a copy of SessionState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SessionShowingQuestionCopyWith<SessionShowingQuestion> get copyWith => _$SessionShowingQuestionCopyWithImpl<SessionShowingQuestion>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SessionShowingQuestion&&(identical(other.card, card) || other.card == card)&&(identical(other.roundIndex, roundIndex) || other.roundIndex == roundIndex)&&(identical(other.roundCount, roundCount) || other.roundCount == roundCount)&&(identical(other.subject, subject) || other.subject == subject)&&(identical(other.remaining, remaining) || other.remaining == remaining));
}


@override
int get hashCode => Object.hash(runtimeType,card,roundIndex,roundCount,subject,remaining);

@override
String toString() {
  return 'SessionState.showingQuestion(card: $card, roundIndex: $roundIndex, roundCount: $roundCount, subject: $subject, remaining: $remaining)';
}


}

/// @nodoc
abstract mixin class $SessionShowingQuestionCopyWith<$Res> implements $SessionStateCopyWith<$Res> {
  factory $SessionShowingQuestionCopyWith(SessionShowingQuestion value, $Res Function(SessionShowingQuestion) _then) = _$SessionShowingQuestionCopyWithImpl;
@useResult
$Res call({
 Card card, int roundIndex, int roundCount, String subject, int remaining
});


$CardCopyWith<$Res> get card;

}
/// @nodoc
class _$SessionShowingQuestionCopyWithImpl<$Res>
    implements $SessionShowingQuestionCopyWith<$Res> {
  _$SessionShowingQuestionCopyWithImpl(this._self, this._then);

  final SessionShowingQuestion _self;
  final $Res Function(SessionShowingQuestion) _then;

/// Create a copy of SessionState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? card = null,Object? roundIndex = null,Object? roundCount = null,Object? subject = null,Object? remaining = null,}) {
  return _then(SessionShowingQuestion(
null == card ? _self.card : card // ignore: cast_nullable_to_non_nullable
as Card,null == roundIndex ? _self.roundIndex : roundIndex // ignore: cast_nullable_to_non_nullable
as int,null == roundCount ? _self.roundCount : roundCount // ignore: cast_nullable_to_non_nullable
as int,null == subject ? _self.subject : subject // ignore: cast_nullable_to_non_nullable
as String,null == remaining ? _self.remaining : remaining // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

/// Create a copy of SessionState
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


class SessionShowingAnswer implements SessionState {
  const SessionShowingAnswer(this.card,  Map<Rating, Duration> previews, this.roundIndex, this.roundCount, this.subject, this.remaining): _previews = previews;
  

 final  Card card;
 final  Map<Rating, Duration> _previews;
 Map<Rating, Duration> get previews {
  if (_previews is EqualUnmodifiableMapView) return _previews;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_previews);
}

 final  int roundIndex;
 final  int roundCount;
 final  String subject;
 final  int remaining;

/// Create a copy of SessionState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SessionShowingAnswerCopyWith<SessionShowingAnswer> get copyWith => _$SessionShowingAnswerCopyWithImpl<SessionShowingAnswer>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SessionShowingAnswer&&(identical(other.card, card) || other.card == card)&&const DeepCollectionEquality().equals(other._previews, _previews)&&(identical(other.roundIndex, roundIndex) || other.roundIndex == roundIndex)&&(identical(other.roundCount, roundCount) || other.roundCount == roundCount)&&(identical(other.subject, subject) || other.subject == subject)&&(identical(other.remaining, remaining) || other.remaining == remaining));
}


@override
int get hashCode => Object.hash(runtimeType,card,const DeepCollectionEquality().hash(_previews),roundIndex,roundCount,subject,remaining);

@override
String toString() {
  return 'SessionState.showingAnswer(card: $card, previews: $previews, roundIndex: $roundIndex, roundCount: $roundCount, subject: $subject, remaining: $remaining)';
}


}

/// @nodoc
abstract mixin class $SessionShowingAnswerCopyWith<$Res> implements $SessionStateCopyWith<$Res> {
  factory $SessionShowingAnswerCopyWith(SessionShowingAnswer value, $Res Function(SessionShowingAnswer) _then) = _$SessionShowingAnswerCopyWithImpl;
@useResult
$Res call({
 Card card, Map<Rating, Duration> previews, int roundIndex, int roundCount, String subject, int remaining
});


$CardCopyWith<$Res> get card;

}
/// @nodoc
class _$SessionShowingAnswerCopyWithImpl<$Res>
    implements $SessionShowingAnswerCopyWith<$Res> {
  _$SessionShowingAnswerCopyWithImpl(this._self, this._then);

  final SessionShowingAnswer _self;
  final $Res Function(SessionShowingAnswer) _then;

/// Create a copy of SessionState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? card = null,Object? previews = null,Object? roundIndex = null,Object? roundCount = null,Object? subject = null,Object? remaining = null,}) {
  return _then(SessionShowingAnswer(
null == card ? _self.card : card // ignore: cast_nullable_to_non_nullable
as Card,null == previews ? _self._previews : previews // ignore: cast_nullable_to_non_nullable
as Map<Rating, Duration>,null == roundIndex ? _self.roundIndex : roundIndex // ignore: cast_nullable_to_non_nullable
as int,null == roundCount ? _self.roundCount : roundCount // ignore: cast_nullable_to_non_nullable
as int,null == subject ? _self.subject : subject // ignore: cast_nullable_to_non_nullable
as String,null == remaining ? _self.remaining : remaining // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

/// Create a copy of SessionState
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


class SessionRoundBreak implements SessionState {
  const SessionRoundBreak(this.finished, this.next, this.remainingDueCards, {this.endedEarly = false});
  

 final  String finished;
 final  String? next;
 final  int remainingDueCards;
@JsonKey() final  bool endedEarly;

/// Create a copy of SessionState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SessionRoundBreakCopyWith<SessionRoundBreak> get copyWith => _$SessionRoundBreakCopyWithImpl<SessionRoundBreak>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SessionRoundBreak&&(identical(other.finished, finished) || other.finished == finished)&&(identical(other.next, next) || other.next == next)&&(identical(other.remainingDueCards, remainingDueCards) || other.remainingDueCards == remainingDueCards)&&(identical(other.endedEarly, endedEarly) || other.endedEarly == endedEarly));
}


@override
int get hashCode => Object.hash(runtimeType,finished,next,remainingDueCards,endedEarly);

@override
String toString() {
  return 'SessionState.roundBreak(finished: $finished, next: $next, remainingDueCards: $remainingDueCards, endedEarly: $endedEarly)';
}


}

/// @nodoc
abstract mixin class $SessionRoundBreakCopyWith<$Res> implements $SessionStateCopyWith<$Res> {
  factory $SessionRoundBreakCopyWith(SessionRoundBreak value, $Res Function(SessionRoundBreak) _then) = _$SessionRoundBreakCopyWithImpl;
@useResult
$Res call({
 String finished, String? next, int remainingDueCards, bool endedEarly
});




}
/// @nodoc
class _$SessionRoundBreakCopyWithImpl<$Res>
    implements $SessionRoundBreakCopyWith<$Res> {
  _$SessionRoundBreakCopyWithImpl(this._self, this._then);

  final SessionRoundBreak _self;
  final $Res Function(SessionRoundBreak) _then;

/// Create a copy of SessionState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? finished = null,Object? next = freezed,Object? remainingDueCards = null,Object? endedEarly = null,}) {
  return _then(SessionRoundBreak(
null == finished ? _self.finished : finished // ignore: cast_nullable_to_non_nullable
as String,freezed == next ? _self.next : next // ignore: cast_nullable_to_non_nullable
as String?,null == remainingDueCards ? _self.remainingDueCards : remainingDueCards // ignore: cast_nullable_to_non_nullable
as int,endedEarly: null == endedEarly ? _self.endedEarly : endedEarly // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

/// @nodoc


class SessionScoreboard implements SessionState {
  const SessionScoreboard(this.session);
  

 final  StudySession session;

/// Create a copy of SessionState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SessionScoreboardCopyWith<SessionScoreboard> get copyWith => _$SessionScoreboardCopyWithImpl<SessionScoreboard>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SessionScoreboard&&(identical(other.session, session) || other.session == session));
}


@override
int get hashCode => Object.hash(runtimeType,session);

@override
String toString() {
  return 'SessionState.scoreboard(session: $session)';
}


}

/// @nodoc
abstract mixin class $SessionScoreboardCopyWith<$Res> implements $SessionStateCopyWith<$Res> {
  factory $SessionScoreboardCopyWith(SessionScoreboard value, $Res Function(SessionScoreboard) _then) = _$SessionScoreboardCopyWithImpl;
@useResult
$Res call({
 StudySession session
});


$StudySessionCopyWith<$Res> get session;

}
/// @nodoc
class _$SessionScoreboardCopyWithImpl<$Res>
    implements $SessionScoreboardCopyWith<$Res> {
  _$SessionScoreboardCopyWithImpl(this._self, this._then);

  final SessionScoreboard _self;
  final $Res Function(SessionScoreboard) _then;

/// Create a copy of SessionState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? session = null,}) {
  return _then(SessionScoreboard(
null == session ? _self.session : session // ignore: cast_nullable_to_non_nullable
as StudySession,
  ));
}

/// Create a copy of SessionState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$StudySessionCopyWith<$Res> get session {
  
  return $StudySessionCopyWith<$Res>(_self.session, (value) {
    return _then(_self.copyWith(session: value));
  });
}
}

/// @nodoc


class SessionDayCleared implements SessionState {
  const SessionDayCleared();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SessionDayCleared);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'SessionState.dayCleared()';
}


}




/// @nodoc


class SessionError implements SessionState {
  const SessionError(this.message);
  

 final  String message;

/// Create a copy of SessionState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SessionErrorCopyWith<SessionError> get copyWith => _$SessionErrorCopyWithImpl<SessionError>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SessionError&&(identical(other.message, message) || other.message == message));
}


@override
int get hashCode => Object.hash(runtimeType,message);

@override
String toString() {
  return 'SessionState.error(message: $message)';
}


}

/// @nodoc
abstract mixin class $SessionErrorCopyWith<$Res> implements $SessionStateCopyWith<$Res> {
  factory $SessionErrorCopyWith(SessionError value, $Res Function(SessionError) _then) = _$SessionErrorCopyWithImpl;
@useResult
$Res call({
 String message
});




}
/// @nodoc
class _$SessionErrorCopyWithImpl<$Res>
    implements $SessionErrorCopyWith<$Res> {
  _$SessionErrorCopyWithImpl(this._self, this._then);

  final SessionError _self;
  final $Res Function(SessionError) _then;

/// Create a copy of SessionState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? message = null,}) {
  return _then(SessionError(
null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
