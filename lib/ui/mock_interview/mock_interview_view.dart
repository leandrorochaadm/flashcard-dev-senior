import 'package:collection/collection.dart';
import 'package:flutter/material.dart';

import '../../core/di/service_locator.dart';
import '../../domain/mock_interview/mock_interview_service.dart';
import '../../domain/models/enums.dart';
import '../shared/app_scaffold.dart';
import '../shared/rich_text_body.dart';
import 'mock_interview_state.dart';
import 'mock_interview_viewmodel.dart';

/// The mock interview (H10): questions from every subject, drawn as an
/// interviewer would, with no effect on the schedule.
class MockInterviewView extends StatefulWidget {
  const MockInterviewView({super.key});

  @override
  State<MockInterviewView> createState() => _MockInterviewViewState();
}

class _MockInterviewViewState extends State<MockInterviewView> {
  late final MockInterviewViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = MockInterviewViewModel(
      getIt(),
      getIt(),
      getIt(),
      getIt(),
      getIt(),
    );
    _viewModel.load();
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Simulado',
      child: ValueListenableBuilder<MockInterviewState>(
        valueListenable: _viewModel.state,
        builder: (context, state, _) => switch (state) {
          MockInterviewLoading() =>
            const Center(child: CircularProgressIndicator()),
          MockInterviewError(:final message) => Center(child: Text(message)),
          final MockInterviewSetup setup =>
            _Setup(setup: setup, viewModel: _viewModel),
          final MockInterviewShowingQuestion question => _Question(
              question: question,
              onReveal: _viewModel.reveal,
              onGiveUp: _viewModel.finishEarly,
            ),
          final MockInterviewShowingAnswer answer =>
            _Answer(answer: answer, onAnswer: _viewModel.answer),
          final MockInterviewFinished finished => _Finished(finished: finished),
        },
      ),
    );
  }
}

class _Setup extends StatelessWidget {
  const _Setup({required this.setup, required this.viewModel});

  final MockInterviewSetup setup;
  final MockInterviewViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListView(
      children: [
        Text('Tamanho do simulado', style: theme.textTheme.titleMedium),
        const SizedBox(height: 4),
        Text(
          '${setup.availableCards} cartões liberados. As perguntas são '
          'sorteadas de todos os assuntos.',
          style: theme.textTheme.bodySmall,
        ),
        const SizedBox(height: 16),
        Text('Por número de perguntas', style: theme.textTheme.labelLarge),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: [
            for (final size in const [10, 20, 30])
              OutlinedButton(
                onPressed: setup.availableCards == 0
                    ? null
                    : () => viewModel.startByCount(size),
                child: Text('$size perguntas'),
              ),
          ],
        ),
        const SizedBox(height: 24),
        Text('Por tempo', style: theme.textTheme.labelLarge),
        const SizedBox(height: 4),
        Text(
          'O fim do tempo não corta a pergunta que estiver aberta.',
          style: theme.textTheme.bodySmall,
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: [
            for (final minutes in const [10, 20, 30])
              OutlinedButton(
                onPressed: setup.availableCards == 0
                    ? null
                    : () => viewModel.startByTime(Duration(minutes: minutes)),
                child: Text('$minutes minutos'),
              ),
          ],
        ),
      ],
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.position, required this.total, required this.remaining});

  final int position;
  final int? total;
  final Duration? remaining;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final left = remaining;
    return Row(
      children: [
        Text(
          total == null ? 'Pergunta $position' : 'Pergunta $position de $total',
          style: theme.textTheme.labelLarge,
        ),
        const Spacer(),
        if (left != null)
          Text(formatClock(left), style: theme.textTheme.labelLarge),
      ],
    );
  }
}

class _Question extends StatelessWidget {
  const _Question({
    required this.question,
    required this.onReveal,
    required this.onGiveUp,
  });

  final MockInterviewShowingQuestion question;
  final VoidCallback onReveal;
  final VoidCallback onGiveUp;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _Header(
          position: question.position,
          total: question.total,
          remaining: question.remaining,
        ),
        const SizedBox(height: 16),
        Expanded(
          child: SingleChildScrollView(
            child: RichTextBody(text: question.card.question),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: FilledButton(
                onPressed: onReveal,
                child: const Text('Ver resposta'),
              ),
            ),
            const SizedBox(width: 8),
            TextButton(onPressed: onGiveUp, child: const Text('Encerrar')),
          ],
        ),
      ],
    );
  }
}

class _Answer extends StatelessWidget {
  const _Answer({required this.answer, required this.onAnswer});

  final MockInterviewShowingAnswer answer;
  final Future<void> Function(Rating) onAnswer;

  /// Fixed by the requirements, in the client's own words.
  static const _labels = {
    Rating.again: 'Errei',
    Rating.hard: 'Lembrei só uma parte',
    Rating.good: 'Lembrei com esforço',
    Rating.easy: 'Sabia de cor',
  };

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _Header(
          position: answer.position,
          total: answer.total,
          remaining: answer.remaining,
        ),
        if (answer.lastQuestion)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              'O tempo acabou — esta é a última pergunta.',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
        const SizedBox(height: 16),
        Expanded(
          child: SingleChildScrollView(
            child: RichTextBody(text: answer.card.answer),
          ),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final rating in Rating.values)
              FilledButton.tonal(
                onPressed: () => onAnswer(rating),
                child: Text(_labels[rating]!),
              ),
          ],
        ),
      ],
    );
  }
}

class _Finished extends StatelessWidget {
  const _Finished({required this.finished});

  final MockInterviewFinished finished;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListView(
      children: [
        Text('Placar do simulado', style: theme.textTheme.titleMedium),
        const SizedBox(height: 4),
        Text(
          'O simulado não mexe no agendamento: nenhum cartão mudou de data.',
          style: theme.textTheme.bodySmall,
        ),
        const SizedBox(height: 16),
        if (finished.scores.isEmpty)
          const Text('Nenhuma pergunta foi respondida.')
        else
          for (final score in finished.scores)
            _ScoreRow(
              score: score,
              previous: finished.previousScores
                  .firstWhereOrNull((old) => old.subject == score.subject),
            ),
      ],
    );
  }
}

class _ScoreRow extends StatelessWidget {
  const _ScoreRow({required this.score, required this.previous});

  final MockInterviewScore score;
  final MockInterviewScore? previous;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final old = previous;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: Text(score.subject)),
              Text('${score.recalled}/${score.asked}',
                  style: theme.textTheme.titleSmall),
            ],
          ),
          const SizedBox(height: 4),
          LinearProgressIndicator(value: score.accuracy),
          const SizedBox(height: 4),
          Text(
            old == null
                ? 'Primeiro simulado deste assunto.'
                : 'Antes: ${(old.accuracy * 100).toStringAsFixed(0)}% · '
                    'agora: ${(score.accuracy * 100).toStringAsFixed(0)}%',
            style: theme.textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}
