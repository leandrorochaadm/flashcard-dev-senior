import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../core/clock.dart';
import '../../data/repositories/card_repository.dart';
import '../../data/repositories/settings_repository.dart';
import '../../domain/models/card.dart';
import '../../domain/policies/card_listing_policy.dart';
import 'cards_state.dart';

/// The collection window (H7): every card, narrowed by subject, with the
/// problem cards marked.
///
/// "Problem card" is [Card.isProblem] — the ViewModel never spells out the
/// number of lapses, otherwise the screen would become a second authority on
/// what a problem card is.
class CardsViewModel {
  CardsViewModel(this._cards, this._settings, this._clock);

  final CardRepository _cards;
  final SettingsRepository _settings;
  final Clock _clock;

  final state = ValueNotifier<CardsState>(const CardsState.loading());

  StreamSubscription<List<Card>>? _subscription;
  String? _selectedSubject;

  void start() {
    _subscription = _cards.changes.listen((_) => _publish());
    _publish();
  }

  /// `null` = every subject. Narrowing a list for display is not scheduling.
  void selectSubject(String? subject) {
    _selectedSubject = subject;
    _publish();
  }

  void _publish() {
    try {
      final all = _cards.all;
      final selected = _selectedSubject;
      final narrowed = selected == null
          ? all
          : all.where((card) => card.subject == selected).toList();
      final shown = CardListingPolicy.sortForCollection(narrowed);

      state.value = CardsState.ready(
        cards: shown,
        subjects: _cards.subjects,
        selectedSubject: selected,
        problemCount: all.where((card) => card.isProblem).length,
        targetDate: _settings.window.targetDate,
        now: _clock.now(),
      );
    } on Object catch (error) {
      state.value = CardsState.error('Não foi possível ler a coleção: $error');
    }
  }

  void dispose() {
    unawaited(_subscription?.cancel());
    state.dispose();
  }
}
