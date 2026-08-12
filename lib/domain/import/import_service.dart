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
  const ImportOutcome({
    required this.created,
    required this.updated,
    this.removed = const [],
    this.mirrorHeldBack = false,
    this.releasedOnImport = false,
  });

  final List<Card> created;
  final List<Card> updated;

  /// Only filled when the import runs as a mirror: the cards already in the
  /// collection that the file no longer mentions. They are listed in the
  /// preview before anything is written, because erasing them takes their
  /// review history along.
  final List<Card> removed;

  /// True when the mirror was asked for and refused: the text has blocks the
  /// parser could not read, and a card whose block has a typo is
  /// indistinguishable from a card the file dropped on purpose. Removing under
  /// that doubt erases study history over a missing `assunto:` line, so the
  /// mirror stands down and the screen asks for the blocks to be fixed first.
  final bool mirrorHeldBack;

  /// Whether confirming this import releases the new cards at once, instead of
  /// letting them enter the ~20-a-day ramp (decision of 12/08/2026).
  ///
  /// An intention, not a stamp: the cards in [created] are still held back. The
  /// stamping happens once, when the import is confirmed, so the day the card
  /// enters the study is the day it was saved — a preview left open across
  /// midnight would otherwise record yesterday.
  final bool releasedOnImport;

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

  /// With [mirror] on, the file becomes the whole truth about the collection:
  /// whatever it does not mention lands in [ImportOutcome.removed]. Off — the
  /// default — an import only adds and updates, which is what H3 describes.
  ///
  /// A text with unreadable blocks holds the mirror back entirely — see
  /// [ImportOutcome.mirrorHeldBack]. Adding and updating still happen.
  ///
  /// [releaseNow] only travels: it comes out in
  /// [ImportOutcome.releasedOnImport] and is stamped by whoever confirms the
  /// import. The cards created here are held back either way, and the cards in
  /// `updated` are never reached by it — they already exist and may carry
  /// history, so a held-back one stays held back until the daily ramp or the
  /// collection screen releases it.
  ImportOutcome resolve(
    ImportPreview preview,
    DateTime now, {
    bool mirror = false,
    bool releaseNow = false,
  }) {
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
    final kept = {for (final card in updated) card.id};
    final heldBack = mirror && preview.invalid.isNotEmpty;
    return ImportOutcome(
      created: created,
      updated: updated,
      removed: mirror && !heldBack
          ? [
              for (final card in _collection.all)
                if (!kept.contains(card.id)) card,
            ]
          : const [],
      mirrorHeldBack: heldBack,
      releasedOnImport: releaseNow,
    );
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
