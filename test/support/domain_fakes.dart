import 'package:flashcard_dev_senior/domain/models/card.dart';
import 'package:flashcard_dev_senior/domain/models/enums.dart';
import 'package:flashcard_dev_senior/domain/models/schedule_window.dart';
import 'package:flashcard_dev_senior/domain/ports.dart';

/// In-memory collection, so the domain can be tested without a database.
final class FakeCollection implements CollectionView {
  FakeCollection([List<Card> cards = const []]) : _cards = [...cards];

  final List<Card> _cards;

  @override
  List<Card> get all => List.unmodifiable(_cards);

  void save(Card card) {
    final at = _cards.indexWhere((existing) => existing.id == card.id);
    if (at == -1) {
      _cards.add(card);
    } else {
      _cards[at] = card;
    }
  }

  void addAll(Iterable<Card> cards) => _cards.addAll(cards);
}

final class FakeWindow implements ScheduleWindowView {
  FakeWindow(this.window);

  @override
  ScheduleWindow window;
}

final class FakeHistory implements StudyHistoryView {
  FakeHistory([Map<DateTime, int>? reviews]) : _reviews = {...?reviews};

  final Map<DateTime, int> _reviews;

  @override
  int reviewsOn(DateTime day) => _reviews[dateOnly(day)] ?? 0;

  void record(DateTime day, int count) =>
      _reviews[dateOnly(day)] = (_reviews[dateOnly(day)] ?? 0) + count;
}

/// A card as it lands right after import: not released, never answered.
Card newCard(
  String id, {
  String subject = 'Estado',
  required DateTime importedAt,
  DateTime? introducedAt,
  double stability = 0,
  CardState state = CardState.newCard,
  DateTime? dueAt,
  int lapses = 0,
}) =>
    Card(
      id: id,
      question: 'Pergunta $id',
      answer: 'Resposta $id',
      subject: subject,
      difficulty: Difficulty.intermediate,
      stability: stability,
      difficultyFsrs: stability > 0 ? 5 : 0,
      state: state,
      learningStep: 0,
      dueAt: dueAt,
      lapses: lapses,
      reps: 0,
      lastReviewedAt: null,
      importedAt: importedAt,
      introducedAt: introducedAt,
    );
