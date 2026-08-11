import '../models/enums.dart';

/// The half of a card the algorithm is allowed to see.
///
/// Question, answer, subject and import history have nothing to do with
/// scheduling. Handing the whole [Card] to the adapter would give it access to
/// fields it must not use — which is how business rules migrate to the wrong
/// place without anyone noticing.
///
/// Deliberately a plain immutable class, not freezed: it is never serialized
/// on its own (it travels inside `Card.toJson()`) and it has to compile before
/// the generator runs.
final class MemoryState {
  const MemoryState({
    required this.state,
    required this.step,
    required this.stability,
    required this.difficulty,
    required this.dueAt,
    required this.lastReviewedAt,
  });

  /// A card that has never been answered.
  const MemoryState.fresh()
      : state = CardState.newCard,
        step = 0,
        stability = 0,
        difficulty = 0,
        dueAt = null,
        lastReviewedAt = null;

  final CardState state;

  /// Position in the short cycle, 0..3.
  final int step;

  /// Days the memory lasts. Base of "firme" and "pronto".
  final double stability;

  /// The FSRS 1..10 value — not the básico/intermediário/avançado label.
  final double difficulty;

  final DateTime? dueAt;
  final DateTime? lastReviewedAt;

  MemoryState copyWith({DateTime? dueAt, CardState? state, int? step}) =>
      MemoryState(
        state: state ?? this.state,
        step: step ?? this.step,
        stability: stability,
        difficulty: difficulty,
        dueAt: dueAt ?? this.dueAt,
        lastReviewedAt: lastReviewedAt,
      );

  @override
  String toString() => 'MemoryState(${state.name}, step: $step, '
      'stability: ${stability.toStringAsFixed(2)}, due: $dueAt)';
}
