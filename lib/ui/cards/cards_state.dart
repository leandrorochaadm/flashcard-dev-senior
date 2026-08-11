import 'package:freezed_annotation/freezed_annotation.dart';

import '../../domain/models/card.dart';

part 'cards_state.freezed.dart';

/// Screen state of the collection window (H7).
@freezed
sealed class CardsState with _$CardsState {
  const factory CardsState.loading() = CardsLoading;

  /// [cards] is what the screen paints, already narrowed by [selectedSubject]
  /// (`null` = every subject). [problemCount] counts the problem cards in the
  /// whole collection, so the banner does not disappear when a filter is on.
  const factory CardsState.ready({
    required List<Card> cards,
    required List<String> subjects,
    required String? selectedSubject,
    required int problemCount,
    required DateTime targetDate,
    required DateTime now,
  }) = CardsReady;

  const factory CardsState.error(String message) = CardsError;
}
