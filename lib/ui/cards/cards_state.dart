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
  /// [totalCount] is the whole collection too — what "apagar todos" reaches,
  /// which is not the length of [cards] while a subject filter is on.
  /// [countsBySubject] is how many cards each filter chip selects.
  /// [pendingCount] is how many cards of the whole collection are not released
  /// yet — what "liberar todos agora" reaches, not what the subject filter
  /// narrowed the screen down to.
  const factory CardsState.ready({
    required List<Card> cards,
    required List<String> subjects,
    required Map<String, int> countsBySubject,
    required String? selectedSubject,
    required int problemCount,
    required int totalCount,
    required int pendingCount,
    required DateTime targetDate,
    required DateTime now,
  }) = CardsReady;

  const factory CardsState.error(String message) = CardsError;
}
