import 'package:freezed_annotation/freezed_annotation.dart';

import 'enums.dart';

part 'review_log.freezed.dart';
part 'review_log.g.dart';

/// json_serializable has no built-in mapping for [Duration].
class _MillisecondsConverter implements JsonConverter<Duration?, int?> {
  const _MillisecondsConverter();

  @override
  Duration? fromJson(int? json) =>
      json == null ? null : Duration(milliseconds: json);

  @override
  int? toJson(Duration? object) => object?.inMilliseconds;
}

/// Append-only. Base of the optimizer and of the calibration chart.
@freezed
sealed class ReviewLog with _$ReviewLog {
  const factory ReviewLog({
    required String cardId,
    required DateTime reviewedAt,
    required Rating rating,
    required double elapsedDays, // real interval since the previous review
    required double predictedRetention, // what the app predicted
    // Stability the card carried INTO this review. It is what allows the
    // calibration curve to be recomputed with older weights, which the undo
    // button of the self-tuning needs (decided 11/08/2026).
    required double stabilityBefore,
    @_MillisecondsConverter()
    required Duration? timeOnCard, // null when over 60s (dropped from average)
    required ReviewSource source,
  }) = _ReviewLog;

  factory ReviewLog.fromJson(Map<String, Object?> json) =>
      _$ReviewLogFromJson(json);
}
