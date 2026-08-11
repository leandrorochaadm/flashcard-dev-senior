import 'package:collection/collection.dart';

import '../../domain/models/study_session.dart';
import '../database/app_database.dart';

/// Keeps the running session so that closing the app mid-round resumes on the
/// same round with the same time left. It is written on every answer and every
/// round change: the browser gives no reliable "closing" event.
final class SessionRepository {
  SessionRepository(this._db);

  final AppDatabase _db;

  Future<StudySession?> unfinished() async {
    final sessions = [
      for (final json in await _db.allSessions()) StudySession.fromJson(json),
    ]..sort((a, b) => b.startedAt.compareTo(a.startedAt));
    return sessions.firstWhereOrNull((session) => !session.finished);
  }

  Future<List<StudySession>> all() async => [
        for (final json in await _db.allSessions()) StudySession.fromJson(json),
      ]..sort((a, b) => b.startedAt.compareTo(a.startedAt));

  Future<void> save(StudySession session) =>
      _db.saveSession(session.id, session.toJson());

  Future<void> delete(String id) => _db.deleteSession(id);
}
