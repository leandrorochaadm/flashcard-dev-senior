import 'package:freezed_annotation/freezed_annotation.dart';

part 'result.freezed.dart';

/// Outcome of an operation that can fail in a way the screen has to show.
///
/// Kept as a union instead of exceptions so the ViewModel can translate it
/// into a screen state without a try/catch at every call site.
@freezed
sealed class Result<T> with _$Result<T> {
  const factory Result.success(T value) = Success<T>;
  const factory Result.failure(String message) = Failure<T>;
}
