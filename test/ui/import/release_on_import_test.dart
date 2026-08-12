import 'package:flashcard_dev_senior/core/clock.dart';
import 'package:flashcard_dev_senior/data/database/sembast_adapter.dart';
import 'package:flashcard_dev_senior/data/repositories/card_repository.dart';
import 'package:flashcard_dev_senior/data/repositories/review_log_repository.dart';
import 'package:flashcard_dev_senior/data/repositories/settings_repository.dart';
import 'package:flashcard_dev_senior/domain/cards/card_deletion_service.dart';
import 'package:flashcard_dev_senior/domain/import/import_service.dart';
import 'package:flashcard_dev_senior/domain/import/markdown_parser.dart';
import 'package:flashcard_dev_senior/domain/policies/content_intake_policy.dart';
import 'package:flashcard_dev_senior/domain/policies/due_cards_policy.dart';
import 'package:flashcard_dev_senior/ui/import/import_state.dart';
import 'package:flashcard_dev_senior/ui/import/import_viewmodel.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sembast/sembast_memory.dart';

import '../../support/domain_fakes.dart';

/// The import screen can release what it imports (decision of 12/08/2026), and
/// this is the one place in the flow where the screen could lie about what
/// confirming will do: the preview shows first review dates, and the switch
/// changes them.
///
/// ViewModel built by hand, no `WidgetTester` — only the View reaches
/// `dart:js_interop`, so this runs on the plain Dart VM.
const _source = '''
---
id: est-001
assunto: Estado
dificuldade: intermediário

**Pergunta**
Qual a diferença entre setState e um notifier?

**Resposta**
setState reconstrói o widget inteiro.
---
id: est-002
assunto: Estado
dificuldade: intermediário

**Pergunta**
O que o ValueNotifier notifica?

**Resposta**
Ele avisa os ouvintes quando o valor muda.
''';

void main() {
  final now = DateTime(2026, 8, 11, 9);

  Future<
      ({
        ImportViewModel viewModel,
        CardRepository cards,
        ContentIntakePolicy intake,
      })> build(String database) async {
    final db = await SembastAdapter.open(newDatabaseFactoryMemory(), database);
    final cards = CardRepository(db);
    final logs = ReviewLogRepository(db);
    final settings = SettingsRepository(db);
    await settings.load(now);

    final intake = ContentIntakePolicy(
      settings,
      cards,
      FakeHistory(),
      DueCardsPolicy(cards),
    );
    return (
      viewModel: ImportViewModel(
        // No formatter: the answer comes back byte for byte.
        const MarkdownParser(),
        ImportService(cards, intake),
        intake,
        cards,
        FakeClock(now),
        CardDeletionService(cards, logs),
      ),
      cards: cards,
      intake: intake,
    );
  }

  test('the preview carries the intention, and the cards are still held back',
      () async {
    final built = await build('flashcards_release_on_import_preview_test');

    built.viewModel.parse(_source);

    final state = built.viewModel.state.value as ImportPreviewing;
    expect(state.outcome.releasedOnImport, isTrue, reason: 'on by default');
    expect(
      state.outcome.created.every((card) => card.introducedAt == null),
      isTrue,
      reason: 'nothing is stamped until the import is confirmed',
    );

    built.viewModel.dispose();
  });

  test('turning the switch off recomputes the preview on screen', () async {
    final built = await build('flashcards_release_on_import_toggle_test');
    built.viewModel.parse(_source);

    built.viewModel.setReleaseNow(enabled: false);

    final state = built.viewModel.state.value as ImportPreviewing;
    expect(
      state.outcome.releasedOnImport,
      isFalse,
      reason: 'a stale intention on screen is a screen that lies',
    );

    built.viewModel.dispose();
  });

  test('confirming with the switch on releases the new cards at once',
      () async {
    final built = await build('flashcards_release_on_import_confirm_test');
    built.viewModel.parse(_source);

    await built.viewModel.confirm();

    final saved = built.cards.all;
    expect(saved, hasLength(2));
    expect(saved.every((card) => card.introducedAt == now), isTrue);
    expect(saved.every((card) => card.dueAt == now), isTrue);
    expect(
      saved.map((card) => card.introducedAt).toSet(),
      hasLength(1),
      reason: 'one clock reading for the whole batch',
    );
    final state = built.viewModel.state.value as ImportDone;
    expect(state.created, 2);
    expect(state.released, isTrue);

    built.viewModel.dispose();
  });

  test('confirming with the switch off leaves them to the daily ramp',
      () async {
    final built = await build('flashcards_release_on_import_ramp_test');
    built.viewModel.setReleaseNow(enabled: false);
    built.viewModel.parse(_source);

    await built.viewModel.confirm();

    final saved = built.cards.all.toList()
      ..sort((a, b) => a.id.compareTo(b.id));
    expect(saved.every((card) => card.introducedAt == null), isTrue);
    for (var i = 0; i < saved.length; i++) {
      expect(saved[i].dueAt, built.intake.projectedReleaseDate(i, 2, now));
    }
    expect((built.viewModel.state.value as ImportDone).released, isFalse);

    built.viewModel.dispose();
  });
}
