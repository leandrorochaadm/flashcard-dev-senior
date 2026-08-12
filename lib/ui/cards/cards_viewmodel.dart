import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../core/clock.dart';
import '../../data/repositories/card_repository.dart';
import '../../data/repositories/settings_repository.dart';
import '../../domain/cards/card_deletion_service.dart';
import '../../domain/models/card.dart';
import '../../domain/policies/card_listing_policy.dart';
import '../../domain/policies/content_intake_policy.dart';
import 'cards_state.dart';

/// The collection window (H7): every card, narrowed by subject, with the
/// problem cards marked.
///
/// "Problem card" is [Card.isProblem] — the ViewModel never spells out the
/// number of lapses, otherwise the screen would become a second authority on
/// what a problem card is.
class CardsViewModel {
  CardsViewModel(
    this._cards,
    this._settings,
    this._clock,
    this._deletion,
    this._intake,
  );

  final CardRepository _cards;
  final SettingsRepository _settings;
  final Clock _clock;
  final CardDeletionService _deletion;
  final ContentIntakePolicy _intake;

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

  /// The three erasures the screen offers. Which cards each one reaches is a
  /// [CardDeletionSelection] decision, not the screen's: the ViewModel only
  /// says what the user asked for and repaints.
  Future<int> deleteCard(String id) =>
      _delete(CardDeletionSelection.single(_cards.all, id));

  Future<int> deleteSubject(String subject) =>
      _delete(CardDeletionSelection.subject(_cards.all, subject));

  Future<int> deleteEverything() =>
      _delete(CardDeletionSelection.everything(_cards.all));

  /// Releases every held-back card at once (decision of 12/08/2026). Which
  /// cards that reaches and what "released" means are the policy's call; this
  /// method only saves what came back and repaints.
  Future<int> releaseAllPending() async {
    try {
      final released = _intake.releaseAllPending(_clock.now());
      if (released.isEmpty) return 0;
      await _cards.saveAll(released);
      // Explicit, even with `_cards.changes` listening: the stream may emit
      // later, and the banner has to go away on the same frame as the tap.
      _publish();
      return released.length;
    } on Object catch (error) {
      state.value = CardsState.error('Não foi possível liberar: $error');
      return 0;
    }
  }

  Future<int> _delete(CardDeletionSelection selection) async {
    try {
      final erased = await _deletion.delete(selection);
      // The subject may have just ceased to exist; falling back to "all"
      // avoids a filter chip selected on nothing.
      if (_selectedSubject != null &&
          !_cards.subjects.contains(_selectedSubject)) {
        _selectedSubject = null;
      }
      _publish();
      return erased;
    } on Object catch (error) {
      state.value = CardsState.error('Não foi possível apagar: $error');
      return 0;
    }
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
        countsBySubject: CardListingPolicy.countBySubject(all),
        selectedSubject: selected,
        problemCount: all.where((card) => card.isProblem).length,
        totalCount: all.length,
        pendingCount: _intake.pendingCount,
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
