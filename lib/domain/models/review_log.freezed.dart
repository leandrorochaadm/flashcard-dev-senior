// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'review_log.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ReviewLog {

 String get cardId; DateTime get reviewedAt; Rating get rating; double get elapsedDays; double get predictedRetention; double get stabilityBefore;@_MillisecondsConverter() Duration? get timeOnCard; ReviewSource get source;
/// Create a copy of ReviewLog
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ReviewLogCopyWith<ReviewLog> get copyWith => _$ReviewLogCopyWithImpl<ReviewLog>(this as ReviewLog, _$identity);

  /// Serializes this ReviewLog to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ReviewLog&&(identical(other.cardId, cardId) || other.cardId == cardId)&&(identical(other.reviewedAt, reviewedAt) || other.reviewedAt == reviewedAt)&&(identical(other.rating, rating) || other.rating == rating)&&(identical(other.elapsedDays, elapsedDays) || other.elapsedDays == elapsedDays)&&(identical(other.predictedRetention, predictedRetention) || other.predictedRetention == predictedRetention)&&(identical(other.stabilityBefore, stabilityBefore) || other.stabilityBefore == stabilityBefore)&&(identical(other.timeOnCard, timeOnCard) || other.timeOnCard == timeOnCard)&&(identical(other.source, source) || other.source == source));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,cardId,reviewedAt,rating,elapsedDays,predictedRetention,stabilityBefore,timeOnCard,source);

@override
String toString() {
  return 'ReviewLog(cardId: $cardId, reviewedAt: $reviewedAt, rating: $rating, elapsedDays: $elapsedDays, predictedRetention: $predictedRetention, stabilityBefore: $stabilityBefore, timeOnCard: $timeOnCard, source: $source)';
}


}

/// @nodoc
abstract mixin class $ReviewLogCopyWith<$Res>  {
  factory $ReviewLogCopyWith(ReviewLog value, $Res Function(ReviewLog) _then) = _$ReviewLogCopyWithImpl;
@useResult
$Res call({
 String cardId, DateTime reviewedAt, Rating rating, double elapsedDays, double predictedRetention, double stabilityBefore,@_MillisecondsConverter() Duration? timeOnCard, ReviewSource source
});




}
/// @nodoc
class _$ReviewLogCopyWithImpl<$Res>
    implements $ReviewLogCopyWith<$Res> {
  _$ReviewLogCopyWithImpl(this._self, this._then);

  final ReviewLog _self;
  final $Res Function(ReviewLog) _then;

/// Create a copy of ReviewLog
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? cardId = null,Object? reviewedAt = null,Object? rating = null,Object? elapsedDays = null,Object? predictedRetention = null,Object? stabilityBefore = null,Object? timeOnCard = freezed,Object? source = null,}) {
  return _then(ReviewLog(
cardId: null == cardId ? _self.cardId : cardId // ignore: cast_nullable_to_non_nullable
as String,reviewedAt: null == reviewedAt ? _self.reviewedAt : reviewedAt // ignore: cast_nullable_to_non_nullable
as DateTime,rating: null == rating ? _self.rating : rating // ignore: cast_nullable_to_non_nullable
as Rating,elapsedDays: null == elapsedDays ? _self.elapsedDays : elapsedDays // ignore: cast_nullable_to_non_nullable
as double,predictedRetention: null == predictedRetention ? _self.predictedRetention : predictedRetention // ignore: cast_nullable_to_non_nullable
as double,stabilityBefore: null == stabilityBefore ? _self.stabilityBefore : stabilityBefore // ignore: cast_nullable_to_non_nullable
as double,timeOnCard: freezed == timeOnCard ? _self.timeOnCard : timeOnCard // ignore: cast_nullable_to_non_nullable
as Duration?,source: null == source ? _self.source : source // ignore: cast_nullable_to_non_nullable
as ReviewSource,
  ));
}

}


/// Adds pattern-matching-related methods to [ReviewLog].
extension ReviewLogPatterns on ReviewLog {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ReviewLog value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ReviewLog() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ReviewLog value)  $default,){
final _that = this;
switch (_that) {
case _ReviewLog():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ReviewLog value)?  $default,){
final _that = this;
switch (_that) {
case _ReviewLog() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String cardId,  DateTime reviewedAt,  Rating rating,  double elapsedDays,  double predictedRetention,  double stabilityBefore, @_MillisecondsConverter()  Duration? timeOnCard,  ReviewSource source)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ReviewLog() when $default != null:
return $default(_that.cardId,_that.reviewedAt,_that.rating,_that.elapsedDays,_that.predictedRetention,_that.stabilityBefore,_that.timeOnCard,_that.source);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String cardId,  DateTime reviewedAt,  Rating rating,  double elapsedDays,  double predictedRetention,  double stabilityBefore, @_MillisecondsConverter()  Duration? timeOnCard,  ReviewSource source)  $default,) {final _that = this;
switch (_that) {
case _ReviewLog():
return $default(_that.cardId,_that.reviewedAt,_that.rating,_that.elapsedDays,_that.predictedRetention,_that.stabilityBefore,_that.timeOnCard,_that.source);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String cardId,  DateTime reviewedAt,  Rating rating,  double elapsedDays,  double predictedRetention,  double stabilityBefore, @_MillisecondsConverter()  Duration? timeOnCard,  ReviewSource source)?  $default,) {final _that = this;
switch (_that) {
case _ReviewLog() when $default != null:
return $default(_that.cardId,_that.reviewedAt,_that.rating,_that.elapsedDays,_that.predictedRetention,_that.stabilityBefore,_that.timeOnCard,_that.source);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ReviewLog implements ReviewLog {
  const _ReviewLog({required this.cardId, required this.reviewedAt, required this.rating, required this.elapsedDays, required this.predictedRetention, required this.stabilityBefore, @_MillisecondsConverter() required this.timeOnCard, required this.source});
  factory _ReviewLog.fromJson(Map<String, dynamic> json) => _$ReviewLogFromJson(json);

@override final  String cardId;
@override final  DateTime reviewedAt;
@override final  Rating rating;
@override final  double elapsedDays;
@override final  double predictedRetention;
@override final  double stabilityBefore;
@override@_MillisecondsConverter() final  Duration? timeOnCard;
@override final  ReviewSource source;

/// Create a copy of ReviewLog
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ReviewLogCopyWith<_ReviewLog> get copyWith => __$ReviewLogCopyWithImpl<_ReviewLog>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ReviewLogToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ReviewLog&&(identical(other.cardId, cardId) || other.cardId == cardId)&&(identical(other.reviewedAt, reviewedAt) || other.reviewedAt == reviewedAt)&&(identical(other.rating, rating) || other.rating == rating)&&(identical(other.elapsedDays, elapsedDays) || other.elapsedDays == elapsedDays)&&(identical(other.predictedRetention, predictedRetention) || other.predictedRetention == predictedRetention)&&(identical(other.stabilityBefore, stabilityBefore) || other.stabilityBefore == stabilityBefore)&&(identical(other.timeOnCard, timeOnCard) || other.timeOnCard == timeOnCard)&&(identical(other.source, source) || other.source == source));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,cardId,reviewedAt,rating,elapsedDays,predictedRetention,stabilityBefore,timeOnCard,source);

@override
String toString() {
  return 'ReviewLog(cardId: $cardId, reviewedAt: $reviewedAt, rating: $rating, elapsedDays: $elapsedDays, predictedRetention: $predictedRetention, stabilityBefore: $stabilityBefore, timeOnCard: $timeOnCard, source: $source)';
}


}

/// @nodoc
abstract mixin class _$ReviewLogCopyWith<$Res> implements $ReviewLogCopyWith<$Res> {
  factory _$ReviewLogCopyWith(_ReviewLog value, $Res Function(_ReviewLog) _then) = __$ReviewLogCopyWithImpl;
@override @useResult
$Res call({
 String cardId, DateTime reviewedAt, Rating rating, double elapsedDays, double predictedRetention, double stabilityBefore,@_MillisecondsConverter() Duration? timeOnCard, ReviewSource source
});




}
/// @nodoc
class __$ReviewLogCopyWithImpl<$Res>
    implements _$ReviewLogCopyWith<$Res> {
  __$ReviewLogCopyWithImpl(this._self, this._then);

  final _ReviewLog _self;
  final $Res Function(_ReviewLog) _then;

/// Create a copy of ReviewLog
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? cardId = null,Object? reviewedAt = null,Object? rating = null,Object? elapsedDays = null,Object? predictedRetention = null,Object? stabilityBefore = null,Object? timeOnCard = freezed,Object? source = null,}) {
  return _then(_ReviewLog(
cardId: null == cardId ? _self.cardId : cardId // ignore: cast_nullable_to_non_nullable
as String,reviewedAt: null == reviewedAt ? _self.reviewedAt : reviewedAt // ignore: cast_nullable_to_non_nullable
as DateTime,rating: null == rating ? _self.rating : rating // ignore: cast_nullable_to_non_nullable
as Rating,elapsedDays: null == elapsedDays ? _self.elapsedDays : elapsedDays // ignore: cast_nullable_to_non_nullable
as double,predictedRetention: null == predictedRetention ? _self.predictedRetention : predictedRetention // ignore: cast_nullable_to_non_nullable
as double,stabilityBefore: null == stabilityBefore ? _self.stabilityBefore : stabilityBefore // ignore: cast_nullable_to_non_nullable
as double,timeOnCard: freezed == timeOnCard ? _self.timeOnCard : timeOnCard // ignore: cast_nullable_to_non_nullable
as Duration?,source: null == source ? _self.source : source // ignore: cast_nullable_to_non_nullable
as ReviewSource,
  ));
}


}

// dart format on
