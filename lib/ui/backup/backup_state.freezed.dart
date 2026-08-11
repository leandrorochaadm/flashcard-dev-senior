// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'backup_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$BackupState {





@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is BackupState);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'BackupState()';
}


}

/// @nodoc
class $BackupStateCopyWith<$Res>  {
$BackupStateCopyWith(BackupState _, $Res Function(BackupState) __);
}


/// Adds pattern-matching-related methods to [BackupState].
extension BackupStatePatterns on BackupState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( BackupReady value)?  ready,TResult Function( BackupWorking value)?  working,TResult Function( BackupExported value)?  exported,TResult Function( BackupRestored value)?  restored,TResult Function( BackupError value)?  error,required TResult orElse(),}){
final _that = this;
switch (_that) {
case BackupReady() when ready != null:
return ready(_that);case BackupWorking() when working != null:
return working(_that);case BackupExported() when exported != null:
return exported(_that);case BackupRestored() when restored != null:
return restored(_that);case BackupError() when error != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( BackupReady value)  ready,required TResult Function( BackupWorking value)  working,required TResult Function( BackupExported value)  exported,required TResult Function( BackupRestored value)  restored,required TResult Function( BackupError value)  error,}){
final _that = this;
switch (_that) {
case BackupReady():
return ready(_that);case BackupWorking():
return working(_that);case BackupExported():
return exported(_that);case BackupRestored():
return restored(_that);case BackupError():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( BackupReady value)?  ready,TResult? Function( BackupWorking value)?  working,TResult? Function( BackupExported value)?  exported,TResult? Function( BackupRestored value)?  restored,TResult? Function( BackupError value)?  error,}){
final _that = this;
switch (_that) {
case BackupReady() when ready != null:
return ready(_that);case BackupWorking() when working != null:
return working(_that);case BackupExported() when exported != null:
return exported(_that);case BackupRestored() when restored != null:
return restored(_that);case BackupError() when error != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function( DateTime? lastBackupAt,  int? daysSinceLastBackup,  int cardCount,  int reviewCount)?  ready,TResult Function()?  working,TResult Function( String fileName)?  exported,TResult Function()?  restored,TResult Function( String message)?  error,required TResult orElse(),}) {final _that = this;
switch (_that) {
case BackupReady() when ready != null:
return ready(_that.lastBackupAt,_that.daysSinceLastBackup,_that.cardCount,_that.reviewCount);case BackupWorking() when working != null:
return working();case BackupExported() when exported != null:
return exported(_that.fileName);case BackupRestored() when restored != null:
return restored();case BackupError() when error != null:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function( DateTime? lastBackupAt,  int? daysSinceLastBackup,  int cardCount,  int reviewCount)  ready,required TResult Function()  working,required TResult Function( String fileName)  exported,required TResult Function()  restored,required TResult Function( String message)  error,}) {final _that = this;
switch (_that) {
case BackupReady():
return ready(_that.lastBackupAt,_that.daysSinceLastBackup,_that.cardCount,_that.reviewCount);case BackupWorking():
return working();case BackupExported():
return exported(_that.fileName);case BackupRestored():
return restored();case BackupError():
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function( DateTime? lastBackupAt,  int? daysSinceLastBackup,  int cardCount,  int reviewCount)?  ready,TResult? Function()?  working,TResult? Function( String fileName)?  exported,TResult? Function()?  restored,TResult? Function( String message)?  error,}) {final _that = this;
switch (_that) {
case BackupReady() when ready != null:
return ready(_that.lastBackupAt,_that.daysSinceLastBackup,_that.cardCount,_that.reviewCount);case BackupWorking() when working != null:
return working();case BackupExported() when exported != null:
return exported(_that.fileName);case BackupRestored() when restored != null:
return restored();case BackupError() when error != null:
return error(_that.message);case _:
  return null;

}
}

}

/// @nodoc


class BackupReady implements BackupState {
  const BackupReady({required this.lastBackupAt, required this.daysSinceLastBackup, required this.cardCount, required this.reviewCount});
  

 final  DateTime? lastBackupAt;
 final  int? daysSinceLastBackup;
 final  int cardCount;
 final  int reviewCount;

/// Create a copy of BackupState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$BackupReadyCopyWith<BackupReady> get copyWith => _$BackupReadyCopyWithImpl<BackupReady>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is BackupReady&&(identical(other.lastBackupAt, lastBackupAt) || other.lastBackupAt == lastBackupAt)&&(identical(other.daysSinceLastBackup, daysSinceLastBackup) || other.daysSinceLastBackup == daysSinceLastBackup)&&(identical(other.cardCount, cardCount) || other.cardCount == cardCount)&&(identical(other.reviewCount, reviewCount) || other.reviewCount == reviewCount));
}


@override
int get hashCode => Object.hash(runtimeType,lastBackupAt,daysSinceLastBackup,cardCount,reviewCount);

@override
String toString() {
  return 'BackupState.ready(lastBackupAt: $lastBackupAt, daysSinceLastBackup: $daysSinceLastBackup, cardCount: $cardCount, reviewCount: $reviewCount)';
}


}

/// @nodoc
abstract mixin class $BackupReadyCopyWith<$Res> implements $BackupStateCopyWith<$Res> {
  factory $BackupReadyCopyWith(BackupReady value, $Res Function(BackupReady) _then) = _$BackupReadyCopyWithImpl;
@useResult
$Res call({
 DateTime? lastBackupAt, int? daysSinceLastBackup, int cardCount, int reviewCount
});




}
/// @nodoc
class _$BackupReadyCopyWithImpl<$Res>
    implements $BackupReadyCopyWith<$Res> {
  _$BackupReadyCopyWithImpl(this._self, this._then);

  final BackupReady _self;
  final $Res Function(BackupReady) _then;

/// Create a copy of BackupState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? lastBackupAt = freezed,Object? daysSinceLastBackup = freezed,Object? cardCount = null,Object? reviewCount = null,}) {
  return _then(BackupReady(
lastBackupAt: freezed == lastBackupAt ? _self.lastBackupAt : lastBackupAt // ignore: cast_nullable_to_non_nullable
as DateTime?,daysSinceLastBackup: freezed == daysSinceLastBackup ? _self.daysSinceLastBackup : daysSinceLastBackup // ignore: cast_nullable_to_non_nullable
as int?,cardCount: null == cardCount ? _self.cardCount : cardCount // ignore: cast_nullable_to_non_nullable
as int,reviewCount: null == reviewCount ? _self.reviewCount : reviewCount // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

/// @nodoc


class BackupWorking implements BackupState {
  const BackupWorking();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is BackupWorking);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'BackupState.working()';
}


}




/// @nodoc


class BackupExported implements BackupState {
  const BackupExported(this.fileName);
  

 final  String fileName;

/// Create a copy of BackupState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$BackupExportedCopyWith<BackupExported> get copyWith => _$BackupExportedCopyWithImpl<BackupExported>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is BackupExported&&(identical(other.fileName, fileName) || other.fileName == fileName));
}


@override
int get hashCode => Object.hash(runtimeType,fileName);

@override
String toString() {
  return 'BackupState.exported(fileName: $fileName)';
}


}

/// @nodoc
abstract mixin class $BackupExportedCopyWith<$Res> implements $BackupStateCopyWith<$Res> {
  factory $BackupExportedCopyWith(BackupExported value, $Res Function(BackupExported) _then) = _$BackupExportedCopyWithImpl;
@useResult
$Res call({
 String fileName
});




}
/// @nodoc
class _$BackupExportedCopyWithImpl<$Res>
    implements $BackupExportedCopyWith<$Res> {
  _$BackupExportedCopyWithImpl(this._self, this._then);

  final BackupExported _self;
  final $Res Function(BackupExported) _then;

/// Create a copy of BackupState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? fileName = null,}) {
  return _then(BackupExported(
null == fileName ? _self.fileName : fileName // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc


class BackupRestored implements BackupState {
  const BackupRestored();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is BackupRestored);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'BackupState.restored()';
}


}




/// @nodoc


class BackupError implements BackupState {
  const BackupError(this.message);
  

 final  String message;

/// Create a copy of BackupState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$BackupErrorCopyWith<BackupError> get copyWith => _$BackupErrorCopyWithImpl<BackupError>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is BackupError&&(identical(other.message, message) || other.message == message));
}


@override
int get hashCode => Object.hash(runtimeType,message);

@override
String toString() {
  return 'BackupState.error(message: $message)';
}


}

/// @nodoc
abstract mixin class $BackupErrorCopyWith<$Res> implements $BackupStateCopyWith<$Res> {
  factory $BackupErrorCopyWith(BackupError value, $Res Function(BackupError) _then) = _$BackupErrorCopyWithImpl;
@useResult
$Res call({
 String message
});




}
/// @nodoc
class _$BackupErrorCopyWithImpl<$Res>
    implements $BackupErrorCopyWith<$Res> {
  _$BackupErrorCopyWithImpl(this._self, this._then);

  final BackupError _self;
  final $Res Function(BackupError) _then;

/// Create a copy of BackupState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? message = null,}) {
  return _then(BackupError(
null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
