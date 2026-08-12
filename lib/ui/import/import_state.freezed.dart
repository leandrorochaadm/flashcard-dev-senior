// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'import_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$ImportState {





@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ImportState);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'ImportState()';
}


}

/// @nodoc
class $ImportStateCopyWith<$Res>  {
$ImportStateCopyWith(ImportState _, $Res Function(ImportState) __);
}


/// Adds pattern-matching-related methods to [ImportState].
extension ImportStatePatterns on ImportState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( ImportIdle value)?  idle,TResult Function( ImportPreviewing value)?  previewing,TResult Function( ImportImporting value)?  importing,TResult Function( ImportDone value)?  done,TResult Function( ImportError value)?  error,required TResult orElse(),}){
final _that = this;
switch (_that) {
case ImportIdle() when idle != null:
return idle(_that);case ImportPreviewing() when previewing != null:
return previewing(_that);case ImportImporting() when importing != null:
return importing(_that);case ImportDone() when done != null:
return done(_that);case ImportError() when error != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( ImportIdle value)  idle,required TResult Function( ImportPreviewing value)  previewing,required TResult Function( ImportImporting value)  importing,required TResult Function( ImportDone value)  done,required TResult Function( ImportError value)  error,}){
final _that = this;
switch (_that) {
case ImportIdle():
return idle(_that);case ImportPreviewing():
return previewing(_that);case ImportImporting():
return importing(_that);case ImportDone():
return done(_that);case ImportError():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( ImportIdle value)?  idle,TResult? Function( ImportPreviewing value)?  previewing,TResult? Function( ImportImporting value)?  importing,TResult? Function( ImportDone value)?  done,TResult? Function( ImportError value)?  error,}){
final _that = this;
switch (_that) {
case ImportIdle() when idle != null:
return idle(_that);case ImportPreviewing() when previewing != null:
return previewing(_that);case ImportImporting() when importing != null:
return importing(_that);case ImportDone() when done != null:
return done(_that);case ImportError() when error != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function()?  idle,TResult Function( ImportPreview preview,  ImportOutcome outcome,  double firmRatio,  bool warnBelowThreshold)?  previewing,TResult Function()?  importing,TResult Function( int created,  int updated,  int removed,  bool released)?  done,TResult Function( String message)?  error,required TResult orElse(),}) {final _that = this;
switch (_that) {
case ImportIdle() when idle != null:
return idle();case ImportPreviewing() when previewing != null:
return previewing(_that.preview,_that.outcome,_that.firmRatio,_that.warnBelowThreshold);case ImportImporting() when importing != null:
return importing();case ImportDone() when done != null:
return done(_that.created,_that.updated,_that.removed,_that.released);case ImportError() when error != null:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function()  idle,required TResult Function( ImportPreview preview,  ImportOutcome outcome,  double firmRatio,  bool warnBelowThreshold)  previewing,required TResult Function()  importing,required TResult Function( int created,  int updated,  int removed,  bool released)  done,required TResult Function( String message)  error,}) {final _that = this;
switch (_that) {
case ImportIdle():
return idle();case ImportPreviewing():
return previewing(_that.preview,_that.outcome,_that.firmRatio,_that.warnBelowThreshold);case ImportImporting():
return importing();case ImportDone():
return done(_that.created,_that.updated,_that.removed,_that.released);case ImportError():
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function()?  idle,TResult? Function( ImportPreview preview,  ImportOutcome outcome,  double firmRatio,  bool warnBelowThreshold)?  previewing,TResult? Function()?  importing,TResult? Function( int created,  int updated,  int removed,  bool released)?  done,TResult? Function( String message)?  error,}) {final _that = this;
switch (_that) {
case ImportIdle() when idle != null:
return idle();case ImportPreviewing() when previewing != null:
return previewing(_that.preview,_that.outcome,_that.firmRatio,_that.warnBelowThreshold);case ImportImporting() when importing != null:
return importing();case ImportDone() when done != null:
return done(_that.created,_that.updated,_that.removed,_that.released);case ImportError() when error != null:
return error(_that.message);case _:
  return null;

}
}

}

/// @nodoc


class ImportIdle implements ImportState {
  const ImportIdle();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ImportIdle);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'ImportState.idle()';
}


}




/// @nodoc


class ImportPreviewing implements ImportState {
  const ImportPreviewing({required this.preview, required this.outcome, required this.firmRatio, required this.warnBelowThreshold});
  

 final  ImportPreview preview;
 final  ImportOutcome outcome;
 final  double firmRatio;
 final  bool warnBelowThreshold;

/// Create a copy of ImportState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ImportPreviewingCopyWith<ImportPreviewing> get copyWith => _$ImportPreviewingCopyWithImpl<ImportPreviewing>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ImportPreviewing&&(identical(other.preview, preview) || other.preview == preview)&&(identical(other.outcome, outcome) || other.outcome == outcome)&&(identical(other.firmRatio, firmRatio) || other.firmRatio == firmRatio)&&(identical(other.warnBelowThreshold, warnBelowThreshold) || other.warnBelowThreshold == warnBelowThreshold));
}


@override
int get hashCode => Object.hash(runtimeType,preview,outcome,firmRatio,warnBelowThreshold);

@override
String toString() {
  return 'ImportState.previewing(preview: $preview, outcome: $outcome, firmRatio: $firmRatio, warnBelowThreshold: $warnBelowThreshold)';
}


}

/// @nodoc
abstract mixin class $ImportPreviewingCopyWith<$Res> implements $ImportStateCopyWith<$Res> {
  factory $ImportPreviewingCopyWith(ImportPreviewing value, $Res Function(ImportPreviewing) _then) = _$ImportPreviewingCopyWithImpl;
@useResult
$Res call({
 ImportPreview preview, ImportOutcome outcome, double firmRatio, bool warnBelowThreshold
});




}
/// @nodoc
class _$ImportPreviewingCopyWithImpl<$Res>
    implements $ImportPreviewingCopyWith<$Res> {
  _$ImportPreviewingCopyWithImpl(this._self, this._then);

  final ImportPreviewing _self;
  final $Res Function(ImportPreviewing) _then;

/// Create a copy of ImportState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? preview = null,Object? outcome = null,Object? firmRatio = null,Object? warnBelowThreshold = null,}) {
  return _then(ImportPreviewing(
preview: null == preview ? _self.preview : preview // ignore: cast_nullable_to_non_nullable
as ImportPreview,outcome: null == outcome ? _self.outcome : outcome // ignore: cast_nullable_to_non_nullable
as ImportOutcome,firmRatio: null == firmRatio ? _self.firmRatio : firmRatio // ignore: cast_nullable_to_non_nullable
as double,warnBelowThreshold: null == warnBelowThreshold ? _self.warnBelowThreshold : warnBelowThreshold // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

/// @nodoc


class ImportImporting implements ImportState {
  const ImportImporting();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ImportImporting);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'ImportState.importing()';
}


}




/// @nodoc


class ImportDone implements ImportState {
  const ImportDone({required this.created, required this.updated, this.removed = 0, this.released = false});
  

 final  int created;
 final  int updated;
@JsonKey() final  int removed;
@JsonKey() final  bool released;

/// Create a copy of ImportState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ImportDoneCopyWith<ImportDone> get copyWith => _$ImportDoneCopyWithImpl<ImportDone>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ImportDone&&(identical(other.created, created) || other.created == created)&&(identical(other.updated, updated) || other.updated == updated)&&(identical(other.removed, removed) || other.removed == removed)&&(identical(other.released, released) || other.released == released));
}


@override
int get hashCode => Object.hash(runtimeType,created,updated,removed,released);

@override
String toString() {
  return 'ImportState.done(created: $created, updated: $updated, removed: $removed, released: $released)';
}


}

/// @nodoc
abstract mixin class $ImportDoneCopyWith<$Res> implements $ImportStateCopyWith<$Res> {
  factory $ImportDoneCopyWith(ImportDone value, $Res Function(ImportDone) _then) = _$ImportDoneCopyWithImpl;
@useResult
$Res call({
 int created, int updated, int removed, bool released
});




}
/// @nodoc
class _$ImportDoneCopyWithImpl<$Res>
    implements $ImportDoneCopyWith<$Res> {
  _$ImportDoneCopyWithImpl(this._self, this._then);

  final ImportDone _self;
  final $Res Function(ImportDone) _then;

/// Create a copy of ImportState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? created = null,Object? updated = null,Object? removed = null,Object? released = null,}) {
  return _then(ImportDone(
created: null == created ? _self.created : created // ignore: cast_nullable_to_non_nullable
as int,updated: null == updated ? _self.updated : updated // ignore: cast_nullable_to_non_nullable
as int,removed: null == removed ? _self.removed : removed // ignore: cast_nullable_to_non_nullable
as int,released: null == released ? _self.released : released // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

/// @nodoc


class ImportError implements ImportState {
  const ImportError(this.message);
  

 final  String message;

/// Create a copy of ImportState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ImportErrorCopyWith<ImportError> get copyWith => _$ImportErrorCopyWithImpl<ImportError>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ImportError&&(identical(other.message, message) || other.message == message));
}


@override
int get hashCode => Object.hash(runtimeType,message);

@override
String toString() {
  return 'ImportState.error(message: $message)';
}


}

/// @nodoc
abstract mixin class $ImportErrorCopyWith<$Res> implements $ImportStateCopyWith<$Res> {
  factory $ImportErrorCopyWith(ImportError value, $Res Function(ImportError) _then) = _$ImportErrorCopyWithImpl;
@useResult
$Res call({
 String message
});




}
/// @nodoc
class _$ImportErrorCopyWithImpl<$Res>
    implements $ImportErrorCopyWith<$Res> {
  _$ImportErrorCopyWithImpl(this._self, this._then);

  final ImportError _self;
  final $Res Function(ImportError) _then;

/// Create a copy of ImportState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? message = null,}) {
  return _then(ImportError(
null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
