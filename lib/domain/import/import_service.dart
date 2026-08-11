import 'package:collection/collection.dart';

import '../models/card.dart';
import '../models/enums.dart';
import '../policies/content_intake_policy.dart';
import '../ports.dart';
import 'import_preview.dart';

/// What confirming an import would do, card by card.
///
/// Computed before anything is written, because the preview has to show the
/// first review dates — that is how the spread of H5 is checked on the import
/// screen instead of weeks later.
final class ImportOutcome {
  const ImportOutcome({required this.created, required this.updated});

  final List<Card> created;
  final List<Card> updated;

  int get total => created.length + updated.length;
}

/// Turns a parsed preview into cards, recognizing what already exists.
///
/// Recognition is by the `id:` from the file and, when it is missing, by the
/// question text. Without the id, fixing a comma in the question makes the app
/// read it as a new card and lose the history — documented behavior, and the
/// reason the template ships with `id:` already filled in.
final class ImportService {
  const ImportService(this._collection, this._intake);

  final CollectionView _collection;
  final ContentIntakePolicy _intake;

  ImportOutcome resolve(ImportPreview preview, DateTime now) {
    final created = <Card>[];
    final updated = <Card>[];

    for (final parsed in preview.valid) {
      final existing = _match(parsed);
      if (existing == null) {
        created.add(_newCard(parsed, now, created.length, preview.valid.length));
      } else {
        // Updates the wording, keeps every bit of study history.
        updated.add(
          existing.copyWith(
            question: parsed.question,
            answer: parsed.answer,
            subject: parsed.subject,
            difficulty: parsed.difficulty,
          ),
        );
      }
    }
    return ImportOutcome(created: created, updated: updated);
  }

  Card? _match(ParsedCard parsed) {
    final id = parsed.id;
    if (id != null) {
      final byId = _collection.all.firstWhereOrNull((card) => card.id == id);
      if (byId != null) return byId;
    }
    return _collection.all
        .firstWhereOrNull((card) => card.question == parsed.question);
  }

  Card _newCard(ParsedCard parsed, DateTime now, int position, int batchSize) =>
      Card(
        id: parsed.id ?? _idFromQuestion(parsed.question, now),
        question: parsed.question,
        answer: parsed.answer,
        subject: parsed.subject,
        difficulty: parsed.difficulty,
        stability: 0,
        difficultyFsrs: 0,
        state: CardState.newCard,
        learningStep: 0,
        // The day the intake policy is expected to release it — the preview
        // shows these dates and they are not all identical, which is the
        // acceptance criterion of H5. Once released, the card is due at once.
        dueAt: _intake.projectedReleaseDate(position, batchSize, now),
        lapses: 0,
        reps: 0,
        lastReviewedAt: null,
        importedAt: now,
        // null = in the database but held back by the ContentIntakePolicy.
        introducedAt: null,
      );

  String _idFromQuestion(String question, DateTime now) =>
      'auto-${now.microsecondsSinceEpoch.toRadixString(36)}-'
      '${question.hashCode.toUnsigned(20).toRadixString(36)}';
}
