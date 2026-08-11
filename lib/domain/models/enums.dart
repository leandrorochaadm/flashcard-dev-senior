import 'package:json_annotation/json_annotation.dart';

/// The four answer buttons, in screen order.
///
/// Labels the user reads are pt-BR and fixed by the requirements:
/// Errei · Lembrei só uma parte · Lembrei com esforço · Sabia de cor.
enum Rating {
  @JsonValue('again')
  again,
  @JsonValue('hard')
  hard,
  @JsonValue('good')
  good,
  @JsonValue('easy')
  easy,
}

enum CardState {
  /// Imported and released, never answered.
  @JsonValue('new')
  newCard,
  @JsonValue('learning')
  learning,
  @JsonValue('review')
  review,
  @JsonValue('relearning')
  relearning;

  /// True while the card is inside the short cycle (15min → 1h → 4h → 1d).
  /// A brand new card has not graduated either, so it belongs here.
  bool get isLearning =>
      this == CardState.newCard ||
      this == CardState.learning ||
      this == CardState.relearning;
}

/// The label that came from the imported Markdown, not the FSRS 1..10 value.
/// The file spells them básico / intermediário / avançado.
enum Difficulty {
  @JsonValue('basico')
  basic,
  @JsonValue('intermediario')
  intermediate,
  @JsonValue('avancado')
  advanced,
}

/// A mock interview writes a [ReviewLog] and nothing else — it never touches
/// stability, dueAt, state or lapses. Calibration and the optimizer must
/// filter on [ReviewSource.session], otherwise the only indicator that audits
/// the app gets contaminated.
enum ReviewSource {
  @JsonValue('session')
  session,
  @JsonValue('mock_interview')
  mockInterview,
}
