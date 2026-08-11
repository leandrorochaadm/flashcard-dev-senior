import '../../domain/models/enums.dart';
import '../../domain/models/review_log.dart';
import '../../domain/models/schedule_window.dart';
import '../../domain/ports.dart';
import '../database/app_database.dart';

/// Append-only history. Base of the calibration chart and of the optimizer.
final class ReviewLogRepository implements StudyHistoryView {
  ReviewLogRepository(this._db);

  final AppDatabase _db;
  final _logs = <ReviewLog>[];

  List<ReviewLog> get all => List.unmodifiable(_logs);

  /// Only scheduled study. A mock interview must never contaminate the one
  /// indicator that audits the app.
  List<ReviewLog> get sessionOnly =>
      _logs.where((log) => log.source == ReviewSource.session).toList();

  Future<void> load() async {
    _logs
      ..clear()
      ..addAll([for (final json in await _db.allReviews()) ReviewLog.fromJson(json)]);
  }

  Future<void> append(ReviewLog log) async {
    _logs.add(log);
    await _db.appendReview(log.toJson());
  }

  @override
  int reviewsOn(DateTime day) {
    final target = dateOnly(day);
    return _logs
        .where((log) => log.source == ReviewSource.session)
        .where((log) => dateOnly(log.reviewedAt) == target)
        .length;
  }

  int get count => _logs.length;
}
