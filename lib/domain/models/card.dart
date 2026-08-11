import 'dart:math' as math;

import 'package:freezed_annotation/freezed_annotation.dart';

import '../scheduling/memory_state.dart';
import 'enums.dart';
import 'schedule_window.dart';

part 'card.freezed.dart';
part 'card.g.dart';

/// A card is firm when the app calculates the memory would still hold a week
/// from now.
const firmStabilityDays = 7.0;

/// Four lapses in total mark a problem card.
const problemLapses = 4;

@freezed
sealed class Card with _$Card {
  const Card._();

  const factory Card({
    required String id, // comes from the `id:` line of the Markdown
    required String question,
    required String answer,
    required String subject, // subject → round name
    required Difficulty difficulty, // básico | intermediário | avançado
    // FSRS state
    required double stability, // days of memory — base of firm/ready
    required double difficultyFsrs, // 1..10, from FSRS (not the label above)
    required CardState state,
    required int learningStep, // 0..3 — position in the short cycle
    required DateTime? dueAt,
    required int lapses, // total "errei" — 4 marks a problem card
    required int reps,
    required DateTime? lastReviewedAt,
    // content intake (H16)
    required DateTime importedAt, // entered the collection
    required DateTime? introducedAt, // null = imported but NOT released yet
  }) = _Card;

  factory Card.fromJson(Map<String, Object?> json) => _$CardFromJson(json);

  /// Leandro would still remember it a week from now. Moves the counter every
  /// day — it is the sense of progress in real time.
  bool get isFirm => stability >= firmStabilityDays;

  /// Leandro would still remember it on the target date. Answers "am I ready
  /// for the interview?".
  ///
  /// The floor of one day matters: without the `max`, on the target date
  /// itself every card would turn "ready" — and the subject map exists
  /// precisely for that day.
  bool isReadyOn(DateTime now, DateTime targetDate) {
    final daysToTarget = dateOnly(targetDate).difference(dateOnly(now)).inDays;
    return stability >= math.max(1, daysToTarget);
  }

  bool get isProblem => lapses >= problemLapses;

  /// Imported but still held back by the ContentIntakePolicy.
  bool get isReleased => introducedAt != null;

  /// The interval that actually elapsed since the previous review, in decimal
  /// days — what `ReviewLog.elapsedDays` records and what the calibration
  /// recomputes retention from. Date arithmetic belongs here, not in a
  /// ViewModel.
  ///
  /// TODO(pontos em aberto): the requirements do not say what to record for a
  /// card answered for the first time; 0 is used until the client decides.
  double observedIntervalDays(DateTime now) {
    final last = lastReviewedAt;
    if (last == null) return 0;
    return now.difference(last).inMinutes / Duration.minutesPerDay;
  }

  bool isDueOn(DateTime now) => dueAt != null && !dueAt!.isAfter(now);

  MemoryState get memory => MemoryState(
        state: state,
        step: learningStep,
        stability: stability,
        difficulty: difficultyFsrs,
        dueAt: dueAt,
        lastReviewedAt: lastReviewedAt,
      );

  Card withMemory(MemoryState memory) => copyWith(
        state: memory.state,
        learningStep: memory.step,
        stability: memory.stability,
        difficultyFsrs: memory.difficulty,
        dueAt: memory.dueAt,
        lastReviewedAt: memory.lastReviewedAt,
      );
}
