import 'package:flutter/material.dart' hide Card;
import 'package:flutter/material.dart' as material show Card;

import '../../core/di/service_locator.dart';
import '../../domain/models/card.dart';
import '../import/widgets/preview_list.dart' show difficultyLabel;
import '../shared/app_scaffold.dart';
import '../shared/card_markdown.dart';
import '../shared/delete_confirmation.dart';
import 'cards_state.dart';
import 'cards_viewmodel.dart';
import 'widgets/problem_card_banner.dart';

/// The whole collection (H7), filtered by subject, with problem cards marked.
class CardsView extends StatefulWidget {
  const CardsView({super.key});

  @override
  State<CardsView> createState() => _CardsViewState();
}

class _CardsViewState extends State<CardsView> {
  late final CardsViewModel _viewModel =
      CardsViewModel(getIt(), getIt(), getIt(), getIt(), getIt())..start();

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  Future<void> _deleteEverything(int total) async {
    final confirmed = await confirmDeletion(
      context,
      title: 'Apagar todos os cartões?',
      message: 'Isso apaga os $total cartões da coleção, de todos os assuntos.',
    );
    if (!confirmed) return;
    final erased = await _viewModel.deleteEverything();
    _report(erased);
  }

  Future<void> _deleteSubject(String subject, int total) async {
    final confirmed = await confirmDeletion(
      context,
      title: 'Apagar o assunto “$subject”?',
      message: 'Isso apaga os $total cartões de $subject.',
    );
    if (!confirmed) return;
    final erased = await _viewModel.deleteSubject(subject);
    _report(erased);
  }

  Future<void> _deleteCard(Card card) async {
    final confirmed = await confirmDeletion(
      context,
      title: 'Apagar este cartão?',
      message: card.question,
    );
    if (!confirmed) return;
    final erased = await _viewModel.deleteCard(card.id);
    _report(erased);
  }

  /// Releasing is not erasing, so this does not reuse `confirmDeletion`. The
  /// warning about the queue is literal and matters: with more released cards
  /// the moving ceiling shortens the interval of every card, not only of the
  /// ones released here.
  Future<void> _confirmRelease(int pending) async {
    final confirmed = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Liberar $pending cartão(ões) agora?'),
            content: const Text(
              'Todos entram na fila de revisão de hoje de uma vez. A fila do '
              'dia fica maior, e o intervalo entre revisões encurta.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Cancelar'),
              ),
              FilledButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('Liberar'),
              ),
            ],
          ),
        ) ??
        false;
    if (!confirmed) return;
    final released = await _viewModel.releaseAllPending();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$released cartão(ões) liberado(s).')),
    );
  }

  void _report(int erased) {
    if (!mounted || erased == 0) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$erased cartão(ões) apagado(s).')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Cartões',
      showNavigation: true,
      actions: [
        ValueListenableBuilder<CardsState>(
          valueListenable: _viewModel.state,
          builder: (context, state, _) => switch (state) {
            CardsReady(
              :final cards,
              :final selectedSubject,
              :final totalCount,
            )
                when totalCount > 0 =>
              _deleteMenu(
                shownCount: cards.length,
                totalCount: totalCount,
                selectedSubject: selectedSubject,
              ),
            _ => const SizedBox.shrink(),
          },
        ),
      ],
      child: ValueListenableBuilder<CardsState>(
        valueListenable: _viewModel.state,
        builder: (context, state, _) => switch (state) {
          CardsLoading() => const Center(child: CircularProgressIndicator()),
          CardsError(:final message) => Center(child: Text(message)),
          CardsReady(
            :final cards,
            :final subjects,
            :final countsBySubject,
            :final selectedSubject,
            :final problemCount,
            :final totalCount,
            :final pendingCount,
            :final targetDate,
            :final now,
          ) =>
            _ready(
              context,
              cards: cards,
              subjects: subjects,
              countsBySubject: countsBySubject,
              totalCount: totalCount,
              selectedSubject: selectedSubject,
              problemCount: problemCount,
              pendingCount: pendingCount,
              targetDate: targetDate,
              now: now,
            ),
        },
      ),
    );
  }

  Widget _ready(
    BuildContext context, {
    required List<Card> cards,
    required List<String> subjects,
    required Map<String, int> countsBySubject,
    required int totalCount,
    required String? selectedSubject,
    required int problemCount,
    required int pendingCount,
    required DateTime targetDate,
    required DateTime now,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (problemCount > 0) ProblemCardBanner(problemCount: problemCount),
        if (pendingCount > 0)
          material.Card(
            child: ListTile(
              leading: const Icon(Icons.lock_clock),
              title: Text('$pendingCount cartão(ões) ainda não liberado(s)'),
              subtitle: const Text(
                'Em toda a coleção, não só no assunto filtrado. Eles estão no '
                'app, mas fora da fila de revisão até a liberação diária '
                'alcançá-los.',
              ),
              trailing: FilledButton(
                onPressed: () => _confirmRelease(pendingCount),
                child: const Text('Liberar agora'),
              ),
            ),
          ),
        SizedBox(
          height: 40,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              _subjectChip(
                label: 'Todos',
                count: totalCount,
                subject: null,
                selected: selectedSubject,
              ),
              for (final subject in subjects)
                _subjectChip(
                  label: subject,
                  count: countsBySubject[subject] ?? 0,
                  subject: subject,
                  selected: selectedSubject,
                ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Expanded(
          child: cards.isEmpty
              ? const Center(child: Text('Nenhum cartão aqui ainda.'))
              : ListView.builder(
                  itemCount: cards.length,
                  itemBuilder: (context, index) => _CardTile(
                    card: cards[index],
                    now: now,
                    targetDate: targetDate,
                    onDelete: () => _deleteCard(cards[index]),
                  ),
                ),
        ),
      ],
    );
  }

  Widget _deleteMenu({
    required int shownCount,
    required int totalCount,
    required String? selectedSubject,
  }) {
    return PopupMenuButton<void>(
      icon: const Icon(Icons.delete_outline),
      tooltip: 'Apagar cartões',
      itemBuilder: (context) => [
        if (selectedSubject != null)
          PopupMenuItem<void>(
            onTap: () => _deleteSubject(selectedSubject, shownCount),
            child: Text('Apagar “$selectedSubject” ($shownCount)'),
          ),
        PopupMenuItem<void>(
          onTap: () => _deleteEverything(totalCount),
          child: Text('Apagar todos ($totalCount)'),
        ),
      ],
    );
  }

  Widget _subjectChip({
    required String label,
    required int count,
    required String? subject,
    required String? selected,
  }) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text('$label ($count)'),
        selected: selected == subject,
        onSelected: (_) => _viewModel.selectSubject(subject),
      ),
    );
  }
}

class _CardTile extends StatelessWidget {
  const _CardTile({
    required this.card,
    required this.now,
    required this.targetDate,
    required this.onDelete,
  });

  final Card card;
  final DateTime now;
  final DateTime targetDate;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final dueAt = card.dueAt;
    return material.Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ExpansionTile(
        title: Text(
          card.question,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Wrap(
          spacing: 8,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Text('${card.subject} · ${difficultyLabel(card.difficulty)}'),
            if (card.isProblem) const ProblemCardTag(),
            if (!card.isReleased) const Text('ainda não liberado'),
            if (card.isFirm) const Text('firme'),
            if (card.isReadyOn(now, targetDate)) const Text('pronto'),
            if (dueAt != null) Text('revisa em ${formatDate(dueAt)}'),
          ],
        ),
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        expandedCrossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (card.isProblem)
            const Padding(
              padding: EdgeInsets.only(bottom: 12),
              child: Text(
                'Este cartão já foi errado várias vezes. Reescreva-o como '
                'perguntas menores: uma ideia por cartão.',
              ),
            ),
          CardMarkdown(text: card.answer),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton.icon(
              onPressed: onDelete,
              icon: const Icon(Icons.delete_outline),
              label: const Text('Apagar cartão'),
            ),
          ),
        ],
      ),
    );
  }
}
