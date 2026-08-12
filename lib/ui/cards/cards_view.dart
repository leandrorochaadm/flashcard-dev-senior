import 'package:flutter/material.dart' hide Card;
import 'package:flutter/material.dart' as material show Card;

import '../../core/di/service_locator.dart';
import '../../domain/models/card.dart';
import '../import/widgets/preview_list.dart' show difficultyLabel;
import '../shared/app_scaffold.dart';
import '../shared/card_markdown.dart';
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
      CardsViewModel(getIt(), getIt(), getIt())..start();

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Cartões',
      showNavigation: true,
      child: ValueListenableBuilder<CardsState>(
        valueListenable: _viewModel.state,
        builder: (context, state, _) => switch (state) {
          CardsLoading() => const Center(child: CircularProgressIndicator()),
          CardsError(:final message) => Center(child: Text(message)),
          CardsReady(
            :final cards,
            :final subjects,
            :final selectedSubject,
            :final problemCount,
            :final targetDate,
            :final now,
          ) =>
            _ready(
              context,
              cards: cards,
              subjects: subjects,
              selectedSubject: selectedSubject,
              problemCount: problemCount,
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
    required String? selectedSubject,
    required int problemCount,
    required DateTime targetDate,
    required DateTime now,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (problemCount > 0) ProblemCardBanner(problemCount: problemCount),
        SizedBox(
          height: 40,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              _subjectChip(label: 'Todos', subject: null, selected: selectedSubject),
              for (final subject in subjects)
                _subjectChip(
                  label: subject,
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
                  ),
                ),
        ),
      ],
    );
  }

  Widget _subjectChip({
    required String label,
    required String? subject,
    required String? selected,
  }) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(label),
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
  });

  final Card card;
  final DateTime now;
  final DateTime targetDate;

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
        ],
      ),
    );
  }
}
