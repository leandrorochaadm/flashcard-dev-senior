// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'dashboard_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$DashboardState {





@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DashboardState);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'DashboardState()';
}


}

/// @nodoc
class $DashboardStateCopyWith<$Res>  {
$DashboardStateCopyWith(DashboardState _, $Res Function(DashboardState) __);
}


/// Adds pattern-matching-related methods to [DashboardState].
extension DashboardStatePatterns on DashboardState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( DashboardLoading value)?  loading,TResult Function( DashboardReady value)?  ready,TResult Function( DashboardError value)?  error,required TResult orElse(),}){
final _that = this;
switch (_that) {
case DashboardLoading() when loading != null:
return loading(_that);case DashboardReady() when ready != null:
return ready(_that);case DashboardError() when error != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( DashboardLoading value)  loading,required TResult Function( DashboardReady value)  ready,required TResult Function( DashboardError value)  error,}){
final _that = this;
switch (_that) {
case DashboardLoading():
return loading(_that);case DashboardReady():
return ready(_that);case DashboardError():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( DashboardLoading value)?  loading,TResult? Function( DashboardReady value)?  ready,TResult? Function( DashboardError value)?  error,}){
final _that = this;
switch (_that) {
case DashboardLoading() when loading != null:
return loading(_that);case DashboardReady() when ready != null:
return ready(_that);case DashboardError() when error != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function()?  loading,TResult Function( int firmedToday,  double? accuracy,  double targetRetention,  List<SubjectProgress> subjects,  StudySession? lastSession,  List<CalibrationPoint> calibration,  List<CalibrationPoint>? previousCalibration,  List<LoadBar> load,  TimeOnCardStats timeOnCard,  Duration ceilingToday,  int daysToTarget,  DateTime targetDate,  int? daysSinceBackup,  bool dayCleared,  bool deadlineReached,  IntakeRelease intake,  bool canRevertTuning,  String? tuningMessage)?  ready,TResult Function( String message)?  error,required TResult orElse(),}) {final _that = this;
switch (_that) {
case DashboardLoading() when loading != null:
return loading();case DashboardReady() when ready != null:
return ready(_that.firmedToday,_that.accuracy,_that.targetRetention,_that.subjects,_that.lastSession,_that.calibration,_that.previousCalibration,_that.load,_that.timeOnCard,_that.ceilingToday,_that.daysToTarget,_that.targetDate,_that.daysSinceBackup,_that.dayCleared,_that.deadlineReached,_that.intake,_that.canRevertTuning,_that.tuningMessage);case DashboardError() when error != null:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function()  loading,required TResult Function( int firmedToday,  double? accuracy,  double targetRetention,  List<SubjectProgress> subjects,  StudySession? lastSession,  List<CalibrationPoint> calibration,  List<CalibrationPoint>? previousCalibration,  List<LoadBar> load,  TimeOnCardStats timeOnCard,  Duration ceilingToday,  int daysToTarget,  DateTime targetDate,  int? daysSinceBackup,  bool dayCleared,  bool deadlineReached,  IntakeRelease intake,  bool canRevertTuning,  String? tuningMessage)  ready,required TResult Function( String message)  error,}) {final _that = this;
switch (_that) {
case DashboardLoading():
return loading();case DashboardReady():
return ready(_that.firmedToday,_that.accuracy,_that.targetRetention,_that.subjects,_that.lastSession,_that.calibration,_that.previousCalibration,_that.load,_that.timeOnCard,_that.ceilingToday,_that.daysToTarget,_that.targetDate,_that.daysSinceBackup,_that.dayCleared,_that.deadlineReached,_that.intake,_that.canRevertTuning,_that.tuningMessage);case DashboardError():
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function()?  loading,TResult? Function( int firmedToday,  double? accuracy,  double targetRetention,  List<SubjectProgress> subjects,  StudySession? lastSession,  List<CalibrationPoint> calibration,  List<CalibrationPoint>? previousCalibration,  List<LoadBar> load,  TimeOnCardStats timeOnCard,  Duration ceilingToday,  int daysToTarget,  DateTime targetDate,  int? daysSinceBackup,  bool dayCleared,  bool deadlineReached,  IntakeRelease intake,  bool canRevertTuning,  String? tuningMessage)?  ready,TResult? Function( String message)?  error,}) {final _that = this;
switch (_that) {
case DashboardLoading() when loading != null:
return loading();case DashboardReady() when ready != null:
return ready(_that.firmedToday,_that.accuracy,_that.targetRetention,_that.subjects,_that.lastSession,_that.calibration,_that.previousCalibration,_that.load,_that.timeOnCard,_that.ceilingToday,_that.daysToTarget,_that.targetDate,_that.daysSinceBackup,_that.dayCleared,_that.deadlineReached,_that.intake,_that.canRevertTuning,_that.tuningMessage);case DashboardError() when error != null:
return error(_that.message);case _:
  return null;

}
}

}

/// @nodoc


class DashboardLoading implements DashboardState {
  const DashboardLoading();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DashboardLoading);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'DashboardState.loading()';
}


}




/// @nodoc


class DashboardReady implements DashboardState {
  const DashboardReady({required this.firmedToday, required this.accuracy, required this.targetRetention, required  List<SubjectProgress> subjects, required this.lastSession, required  List<CalibrationPoint> calibration, required  List<CalibrationPoint>? previousCalibration, required  List<LoadBar> load, required this.timeOnCard, required this.ceilingToday, required this.daysToTarget, required this.targetDate, required this.daysSinceBackup, required this.dayCleared, required this.deadlineReached, required this.intake, required this.canRevertTuning, required this.tuningMessage}): _subjects = subjects,_calibration = calibration,_previousCalibration = previousCalibration,_load = load;
  

/// Cards that crossed into "firm" today.
 final  int firmedToday;
/// Real recall rate of scheduled study; `null` while nothing was reviewed.
 final  double? accuracy;
/// The 0.90 the algorithm aims at — shown next to [accuracy].
 final  double targetRetention;
/// The subject map, worst first.
 final  List<SubjectProgress> _subjects;
/// The subject map, worst first.
 List<SubjectProgress> get subjects {
  if (_subjects is EqualUnmodifiableListView) return _subjects;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_subjects);
}

/// Scoreboard of the last study session; `null` on a fresh install.
 final  StudySession? lastSession;
/// Predicted against real, day by day.
 final  List<CalibrationPoint> _calibration;
/// Predicted against real, day by day.
 List<CalibrationPoint> get calibration {
  if (_calibration is EqualUnmodifiableListView) return _calibration;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_calibration);
}

/// The same days recomputed with the weights in force before the last
/// tuning. `null` when there has never been one.
 final  List<CalibrationPoint>? _previousCalibration;
/// The same days recomputed with the weights in force before the last
/// tuning. `null` when there has never been one.
 List<CalibrationPoint>? get previousCalibration {
  final value = _previousCalibration;
  if (value == null) return null;
  if (_previousCalibration is EqualUnmodifiableListView) return _previousCalibration;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}

/// One bar per day of the next seven.
 final  List<LoadBar> _load;
/// One bar per day of the next seven.
 List<LoadBar> get load {
  if (_load is EqualUnmodifiableListView) return _load;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_load);
}

 final  TimeOnCardStats timeOnCard;
/// Longest interval the schedule may hand out today.
 final  Duration ceilingToday;
 final  int daysToTarget;
 final  DateTime targetDate;
/// Days since the last export; `null` when no backup was ever taken.
 final  int? daysSinceBackup;
/// Nothing due and nothing to anticipate (H12).
 final  bool dayCleared;
/// The target date arrived and the question of H13 is still unanswered.
 final  bool deadlineReached;
/// Today's release, carrying the reason it was the size it was — the app
/// never holds cards back silently.
 final  IntakeRelease intake;
/// Hidden when there is nothing to go back to.
 final  bool canRevertTuning;
/// Outcome of the last self-tuning attempt, already in words.
 final  String? tuningMessage;

/// Create a copy of DashboardState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DashboardReadyCopyWith<DashboardReady> get copyWith => _$DashboardReadyCopyWithImpl<DashboardReady>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DashboardReady&&(identical(other.firmedToday, firmedToday) || other.firmedToday == firmedToday)&&(identical(other.accuracy, accuracy) || other.accuracy == accuracy)&&(identical(other.targetRetention, targetRetention) || other.targetRetention == targetRetention)&&const DeepCollectionEquality().equals(other._subjects, _subjects)&&(identical(other.lastSession, lastSession) || other.lastSession == lastSession)&&const DeepCollectionEquality().equals(other._calibration, _calibration)&&const DeepCollectionEquality().equals(other._previousCalibration, _previousCalibration)&&const DeepCollectionEquality().equals(other._load, _load)&&(identical(other.timeOnCard, timeOnCard) || other.timeOnCard == timeOnCard)&&(identical(other.ceilingToday, ceilingToday) || other.ceilingToday == ceilingToday)&&(identical(other.daysToTarget, daysToTarget) || other.daysToTarget == daysToTarget)&&(identical(other.targetDate, targetDate) || other.targetDate == targetDate)&&(identical(other.daysSinceBackup, daysSinceBackup) || other.daysSinceBackup == daysSinceBackup)&&(identical(other.dayCleared, dayCleared) || other.dayCleared == dayCleared)&&(identical(other.deadlineReached, deadlineReached) || other.deadlineReached == deadlineReached)&&(identical(other.intake, intake) || other.intake == intake)&&(identical(other.canRevertTuning, canRevertTuning) || other.canRevertTuning == canRevertTuning)&&(identical(other.tuningMessage, tuningMessage) || other.tuningMessage == tuningMessage));
}


@override
int get hashCode => Object.hash(runtimeType,firmedToday,accuracy,targetRetention,const DeepCollectionEquality().hash(_subjects),lastSession,const DeepCollectionEquality().hash(_calibration),const DeepCollectionEquality().hash(_previousCalibration),const DeepCollectionEquality().hash(_load),timeOnCard,ceilingToday,daysToTarget,targetDate,daysSinceBackup,dayCleared,deadlineReached,intake,canRevertTuning,tuningMessage);

@override
String toString() {
  return 'DashboardState.ready(firmedToday: $firmedToday, accuracy: $accuracy, targetRetention: $targetRetention, subjects: $subjects, lastSession: $lastSession, calibration: $calibration, previousCalibration: $previousCalibration, load: $load, timeOnCard: $timeOnCard, ceilingToday: $ceilingToday, daysToTarget: $daysToTarget, targetDate: $targetDate, daysSinceBackup: $daysSinceBackup, dayCleared: $dayCleared, deadlineReached: $deadlineReached, intake: $intake, canRevertTuning: $canRevertTuning, tuningMessage: $tuningMessage)';
}


}

/// @nodoc
abstract mixin class $DashboardReadyCopyWith<$Res> implements $DashboardStateCopyWith<$Res> {
  factory $DashboardReadyCopyWith(DashboardReady value, $Res Function(DashboardReady) _then) = _$DashboardReadyCopyWithImpl;
@useResult
$Res call({
 int firmedToday, double? accuracy, double targetRetention, List<SubjectProgress> subjects, StudySession? lastSession, List<CalibrationPoint> calibration, List<CalibrationPoint>? previousCalibration, List<LoadBar> load, TimeOnCardStats timeOnCard, Duration ceilingToday, int daysToTarget, DateTime targetDate, int? daysSinceBackup, bool dayCleared, bool deadlineReached, IntakeRelease intake, bool canRevertTuning, String? tuningMessage
});


$StudySessionCopyWith<$Res>? get lastSession;

}
/// @nodoc
class _$DashboardReadyCopyWithImpl<$Res>
    implements $DashboardReadyCopyWith<$Res> {
  _$DashboardReadyCopyWithImpl(this._self, this._then);

  final DashboardReady _self;
  final $Res Function(DashboardReady) _then;

/// Create a copy of DashboardState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? firmedToday = null,Object? accuracy = freezed,Object? targetRetention = null,Object? subjects = null,Object? lastSession = freezed,Object? calibration = null,Object? previousCalibration = freezed,Object? load = null,Object? timeOnCard = null,Object? ceilingToday = null,Object? daysToTarget = null,Object? targetDate = null,Object? daysSinceBackup = freezed,Object? dayCleared = null,Object? deadlineReached = null,Object? intake = null,Object? canRevertTuning = null,Object? tuningMessage = freezed,}) {
  return _then(DashboardReady(
firmedToday: null == firmedToday ? _self.firmedToday : firmedToday // ignore: cast_nullable_to_non_nullable
as int,accuracy: freezed == accuracy ? _self.accuracy : accuracy // ignore: cast_nullable_to_non_nullable
as double?,targetRetention: null == targetRetention ? _self.targetRetention : targetRetention // ignore: cast_nullable_to_non_nullable
as double,subjects: null == subjects ? _self._subjects : subjects // ignore: cast_nullable_to_non_nullable
as List<SubjectProgress>,lastSession: freezed == lastSession ? _self.lastSession : lastSession // ignore: cast_nullable_to_non_nullable
as StudySession?,calibration: null == calibration ? _self._calibration : calibration // ignore: cast_nullable_to_non_nullable
as List<CalibrationPoint>,previousCalibration: freezed == previousCalibration ? _self._previousCalibration : previousCalibration // ignore: cast_nullable_to_non_nullable
as List<CalibrationPoint>?,load: null == load ? _self._load : load // ignore: cast_nullable_to_non_nullable
as List<LoadBar>,timeOnCard: null == timeOnCard ? _self.timeOnCard : timeOnCard // ignore: cast_nullable_to_non_nullable
as TimeOnCardStats,ceilingToday: null == ceilingToday ? _self.ceilingToday : ceilingToday // ignore: cast_nullable_to_non_nullable
as Duration,daysToTarget: null == daysToTarget ? _self.daysToTarget : daysToTarget // ignore: cast_nullable_to_non_nullable
as int,targetDate: null == targetDate ? _self.targetDate : targetDate // ignore: cast_nullable_to_non_nullable
as DateTime,daysSinceBackup: freezed == daysSinceBackup ? _self.daysSinceBackup : daysSinceBackup // ignore: cast_nullable_to_non_nullable
as int?,dayCleared: null == dayCleared ? _self.dayCleared : dayCleared // ignore: cast_nullable_to_non_nullable
as bool,deadlineReached: null == deadlineReached ? _self.deadlineReached : deadlineReached // ignore: cast_nullable_to_non_nullable
as bool,intake: null == intake ? _self.intake : intake // ignore: cast_nullable_to_non_nullable
as IntakeRelease,canRevertTuning: null == canRevertTuning ? _self.canRevertTuning : canRevertTuning // ignore: cast_nullable_to_non_nullable
as bool,tuningMessage: freezed == tuningMessage ? _self.tuningMessage : tuningMessage // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

/// Create a copy of DashboardState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$StudySessionCopyWith<$Res>? get lastSession {
    if (_self.lastSession == null) {
    return null;
  }

  return $StudySessionCopyWith<$Res>(_self.lastSession!, (value) {
    return _then(_self.copyWith(lastSession: value));
  });
}
}

/// @nodoc


class DashboardError implements DashboardState {
  const DashboardError(this.message);
  

 final  String message;

/// Create a copy of DashboardState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DashboardErrorCopyWith<DashboardError> get copyWith => _$DashboardErrorCopyWithImpl<DashboardError>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DashboardError&&(identical(other.message, message) || other.message == message));
}


@override
int get hashCode => Object.hash(runtimeType,message);

@override
String toString() {
  return 'DashboardState.error(message: $message)';
}


}

/// @nodoc
abstract mixin class $DashboardErrorCopyWith<$Res> implements $DashboardStateCopyWith<$Res> {
  factory $DashboardErrorCopyWith(DashboardError value, $Res Function(DashboardError) _then) = _$DashboardErrorCopyWithImpl;
@useResult
$Res call({
 String message
});




}
/// @nodoc
class _$DashboardErrorCopyWithImpl<$Res>
    implements $DashboardErrorCopyWith<$Res> {
  _$DashboardErrorCopyWithImpl(this._self, this._then);

  final DashboardError _self;
  final $Res Function(DashboardError) _then;

/// Create a copy of DashboardState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? message = null,}) {
  return _then(DashboardError(
null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
