import '../models/enums.dart';

/// One card the parser managed to read, before it becomes a [Card].
///
/// Plain data: the View only paints it. Deciding whether it is new or an
/// update of an existing card belongs to the import use case, not to the
/// widget.
final class ParsedCard {
  const ParsedCard({
    required this.id,
    required this.question,
    required this.answer,
    required this.subject,
    required this.difficulty,
    required this.blockIndex,
  });

  /// The `id:` line, or null when the file omitted it — then the card is
  /// matched by the question text.
  final String? id;
  final String question;
  final String answer;
  final String subject;
  final Difficulty difficulty;

  /// Position of the block in the pasted text, so the preview can point at it.
  final int blockIndex;
}

/// Why a block could not be read. The preview marks it and the other blocks
/// still get imported — that is the whole promise of the `---` format.
enum ImportIssue {
  missingSubject,
  unknownDifficulty,
  missingQuestion,
  missingAnswer,

  /// A ```dart block that does not parse in any shape. Syntax only: a snippet
  /// with a misspelled method name is not caught, and cannot be — see
  /// [DartCodeFormatter]. Marked instead of imported so the card is fixed at
  /// the door, not read wrong for the next 30 days.
  unparsableDartCode,
}

final class InvalidBlock {
  const InvalidBlock({
    required this.blockIndex,
    required this.rawText,
    required this.issues,
  });

  final int blockIndex;
  final String rawText;
  final List<ImportIssue> issues;
}

/// Pure data handed to the import screen: what was understood and what was not.
final class ImportPreview {
  const ImportPreview({required this.valid, required this.invalid});

  final List<ParsedCard> valid;
  final List<InvalidBlock> invalid;

  bool get isEmpty => valid.isEmpty && invalid.isEmpty;
}
