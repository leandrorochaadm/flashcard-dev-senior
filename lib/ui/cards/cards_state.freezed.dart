// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'cards_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$CardsState {





@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CardsState);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'CardsState()';
}


}

/// @nodoc
class $CardsStateCopyWith<$Res>  {
$CardsStateCopyWith(CardsState _, $Res Function(CardsState) __);
}


/// Adds pattern-matching-related methods to [CardsState].
extension CardsStatePatterns on CardsState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( CardsLoading value)?  loading,TResult Function( CardsReady value)?  ready,TResult Function( CardsError value)?  error,required TResult orElse(),}){
final _that = this;
switch (_that) {
case CardsLoading() when loading != null:
return loading(_that);case CardsReady() when ready != null:
return ready(_that);case CardsError() when error != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( CardsLoading value)  loading,required TResult Function( CardsReady value)  ready,required TResult Function( CardsError value)  error,}){
final _that = this;
switch (_that) {
case CardsLoading():
return loading(_that);case CardsReady():
return ready(_that);case CardsError():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( CardsLoading value)?  loading,TResult? Function( CardsReady value)?  ready,TResult? Function( CardsError value)?  error,}){
final _that = this;
switch (_that) {
case CardsLoading() when loading != null:
return loading(_that);case CardsReady() when ready != null:
return ready(_that);case CardsError() when error != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function()?  loading,TResult Function( List<Card> cards,  List<String> subjects,  String? selectedSubject,  int problemCount,  DateTime targetDate,  DateTime now)?  ready,TResult Function( String message)?  error,required TResult orElse(),}) {final _that = this;
switch (_that) {
case CardsLoading() when loading != null:
return loading();case CardsReady() when ready != null:
return ready(_that.cards,_that.subjects,_that.selectedSubject,_that.problemCount,_that.targetDate,_that.now);case CardsError() when error != null:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function()  loading,required TResult Function( List<Card> cards,  List<String> subjects,  String? selectedSubject,  int problemCount,  DateTime targetDate,  DateTime now)  ready,required TResult Function( String message)  error,}) {final _that = this;
switch (_that) {
case CardsLoading():
return loading();case CardsReady():
return ready(_that.cards,_that.subjects,_that.selectedSubject,_that.problemCount,_that.targetDate,_that.now);case CardsError():
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function()?  loading,TResult? Function( List<Card> cards,  List<String> subjects,  String? selectedSubject,  int problemCount,  DateTime targetDate,  DateTime now)?  ready,TResult? Function( String message)?  error,}) {final _that = this;
switch (_that) {
case CardsLoading() when loading != null:
return loading();case CardsReady() when ready != null:
return ready(_that.cards,_that.subjects,_that.selectedSubject,_that.problemCount,_that.targetDate,_that.now);case CardsError() when error != null:
return error(_that.message);case _:
  return null;

}
}

}

/// @nodoc


class CardsLoading implements CardsState {
  const CardsLoading();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CardsLoading);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'CardsState.loading()';
}


}




/// @nodoc


class CardsReady implements CardsState {
  const CardsReady({required  List<Card> cards, required  List<String> subjects, required this.selectedSubject, required this.problemCount, required this.targetDate, required this.now}): _cards = cards,_subjects = subjects;
  

 final  List<Card> _cards;
 List<Card> get cards {
  if (_cards is EqualUnmodifiableListView) return _cards;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_cards);
}

 final  List<String> _subjects;
 List<String> get subjects {
  if (_subjects is EqualUnmodifiableListView) return _subjects;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_subjects);
}

 final  String? selectedSubject;
 final  int problemCount;
 final  DateTime targetDate;
 final  DateTime now;

/// Create a copy of CardsState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CardsReadyCopyWith<CardsReady> get copyWith => _$CardsReadyCopyWithImpl<CardsReady>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CardsReady&&const DeepCollectionEquality().equals(other._cards, _cards)&&const DeepCollectionEquality().equals(other._subjects, _subjects)&&(identical(other.selectedSubject, selectedSubject) || other.selectedSubject == selectedSubject)&&(identical(other.problemCount, problemCount) || other.problemCount == problemCount)&&(identical(other.targetDate, targetDate) || other.targetDate == targetDate)&&(identical(other.now, now) || other.now == now));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_cards),const DeepCollectionEquality().hash(_subjects),selectedSubject,problemCount,targetDate,now);

@override
String toString() {
  return 'CardsState.ready(cards: $cards, subjects: $subjects, selectedSubject: $selectedSubject, problemCount: $problemCount, targetDate: $targetDate, now: $now)';
}


}

/// @nodoc
abstract mixin class $CardsReadyCopyWith<$Res> implements $CardsStateCopyWith<$Res> {
  factory $CardsReadyCopyWith(CardsReady value, $Res Function(CardsReady) _then) = _$CardsReadyCopyWithImpl;
@useResult
$Res call({
 List<Card> cards, List<String> subjects, String? selectedSubject, int problemCount, DateTime targetDate, DateTime now
});




}
/// @nodoc
class _$CardsReadyCopyWithImpl<$Res>
    implements $CardsReadyCopyWith<$Res> {
  _$CardsReadyCopyWithImpl(this._self, this._then);

  final CardsReady _self;
  final $Res Function(CardsReady) _then;

/// Create a copy of CardsState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? cards = null,Object? subjects = null,Object? selectedSubject = freezed,Object? problemCount = null,Object? targetDate = null,Object? now = null,}) {
  return _then(CardsReady(
cards: null == cards ? _self._cards : cards // ignore: cast_nullable_to_non_nullable
as List<Card>,subjects: null == subjects ? _self._subjects : subjects // ignore: cast_nullable_to_non_nullable
as List<String>,selectedSubject: freezed == selectedSubject ? _self.selectedSubject : selectedSubject // ignore: cast_nullable_to_non_nullable
as String?,problemCount: null == problemCount ? _self.problemCount : problemCount // ignore: cast_nullable_to_non_nullable
as int,targetDate: null == targetDate ? _self.targetDate : targetDate // ignore: cast_nullable_to_non_nullable
as DateTime,now: null == now ? _self.now : now // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

/// @nodoc


class CardsError implements CardsState {
  const CardsError(this.message);
  

 final  String message;

/// Create a copy of CardsState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CardsErrorCopyWith<CardsError> get copyWith => _$CardsErrorCopyWithImpl<CardsError>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CardsError&&(identical(other.message, message) || other.message == message));
}


@override
int get hashCode => Object.hash(runtimeType,message);

@override
String toString() {
  return 'CardsState.error(message: $message)';
}


}

/// @nodoc
abstract mixin class $CardsErrorCopyWith<$Res> implements $CardsStateCopyWith<$Res> {
  factory $CardsErrorCopyWith(CardsError value, $Res Function(CardsError) _then) = _$CardsErrorCopyWithImpl;
@useResult
$Res call({
 String message
});




}
/// @nodoc
class _$CardsErrorCopyWithImpl<$Res>
    implements $CardsErrorCopyWith<$Res> {
  _$CardsErrorCopyWithImpl(this._self, this._then);

  final CardsError _self;
  final $Res Function(CardsError) _then;

/// Create a copy of CardsState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? message = null,}) {
  return _then(CardsError(
null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
