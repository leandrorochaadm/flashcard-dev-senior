import 'package:flutter/material.dart';

import '../../core/di/service_locator.dart';
import '../../core/router.dart';
import '../../domain/models/study_session.dart';
import '../../domain/policies/due_cards_policy.dart';
import '../../domain/policies/session_policy.dart';
import '../shared/app_scaffold.dart';
import 'session_state.dart';
import 'session_viewmodel.dart';
import 'widgets/card_face.dart';
import 'widgets/confirm_stopping.dart';
import 'widgets/rating_buttons.dart';
import 'widgets/round_break_screen.dart';
import 'widgets/round_timer.dart';

/// The study screen. It is one of the two places allowed to resolve `get_it`:
/// the ViewModel receives everything through its constructor.
class SessionView extends StatefulWidget {
  const SessionView({super.key});

  @override
  State<SessionView> createState() => _SessionViewState();
}

class _SessionViewState extends State<SessionView> {
  late final SessionViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = SessionViewModel(
      getIt(),
      getIt(),
      getIt(),
      getIt(),
      getIt(),
      getIt(),
      getIt(),
      getIt(),
      getIt(),
      getIt(),
    );
    _viewModel.init();
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  /// Ending the session drops the rounds that were still to come, so it asks
  /// first — like ending a single round does. No pause to manage here: at the
  /// turn of the round there is no clock running.
  Future<void> _confirmEndSession(BuildContext context) async {
    final confirmed = await confirmStopping(
      context,
      title: 'Encerrar a sessão?',
      message: 'Os rounds que faltam não serão estudados agora. O placar do '
          'que você já respondeu continua valendo.',
      confirmLabel: 'Encerrar a sessão',
      keepLabel: 'Continuar a sessão',
    );
    if (confirmed) await _viewModel.endSession();
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Estudar',
      showNavigation: true,
      child: ValueListenableBuilder<SessionState>(
        valueListenable: _viewModel.state,
        builder: (context, state, _) => switch (state) {
          SessionLoading() => const Center(child: CircularProgressIndicator()),
          SessionChooseSubjects(:final availableSubjects) => _SubjectPicker(
              subjects: availableSubjects,
              onStart: _viewModel.start,
            ),
          SessionShowingQuestion(
            :final card,
            :final roundIndex,
            :final roundCount,
            :final remaining
          ) =>
            _StudyBody(
              viewModel: _viewModel,
              roundIndex: roundIndex,
              roundCount: roundCount,
              remaining: remaining,
              face: CardFace(card: card, revealed: false),
              footer: SizedBox(
                height: 68,
                width: double.infinity,
                child: FilledButton(
                  onPressed: _viewModel.reveal,
                  style: FilledButton.styleFrom(
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                    ),
                  ),
                  child: const Text('Mostrar resposta'),
                ),
              ),
            ),
          SessionShowingAnswer(
            :final card,
            :final previews,
            :final roundIndex,
            :final roundCount,
            :final remaining
          ) =>
            _StudyBody(
              viewModel: _viewModel,
              roundIndex: roundIndex,
              roundCount: roundCount,
              remaining: remaining,
              face: CardFace(card: card, revealed: true),
              footer: RatingButtons(
                previews: previews,
                onRated: _viewModel.answer,
              ),
            ),
          SessionRoundBreak(
            :final finished,
            :final next,
            :final remainingDueCards,
            :final endedEarly
          ) =>
            RoundBreakScreen(
              finished: finished,
              next: next,
              remainingDueCards: remainingDueCards,
              endedEarly: endedEarly,
              onContinue: _viewModel.nextRound,
              onExtend: _viewModel.extendRound,
              onEndSession: () => _confirmEndSession(context),
            ),
          SessionScoreboard(:final session) => _Scoreboard(session: session),
          SessionDayCleared() => const _DayClearedScreen(),
          SessionError(:final message) => Center(child: Text(message)),
        },
      ),
    );
  }
}

/// Question or answer, always under the round clock.
class _StudyBody extends StatelessWidget {
  const _StudyBody({
    required this.viewModel,
    required this.roundIndex,
    required this.roundCount,
    required this.remaining,
    required this.face,
    required this.footer,
  });

  final SessionViewModel viewModel;
  final int roundIndex;
  final int roundCount;
  final int remaining;
  final Widget face;
  final Widget footer;

  /// The stop button sits next to the pause button on a 390-point phone, and
  /// there is no way back into the round it ends — so it asks first. The
  /// dialog lives here, in the View: the ViewModel never sees a
  /// `BuildContext`.
  ///
  /// Reading the question is not studying, so the round pauses while the
  /// dialog is up. Otherwise the seconds spent deciding would land in the
  /// card's `timeOnCard`, and a round could reach zero on its own with the
  /// dialog still on screen — the answer would then relabel a round that had
  /// already ended by itself.
  Future<void> _confirmEndRound(BuildContext context) async {
    final wasPaused = viewModel.paused.value;
    if (!wasPaused) viewModel.togglePause();
    final confirmed = await confirmStopping(
      context,
      title: 'Encerrar o round?',
      message: 'O tempo que resta é descartado. As respostas que você já deu '
          'continuam valendo.',
      confirmLabel: 'Encerrar',
      keepLabel: 'Continuar estudando',
    );
    if (confirmed) {
      await viewModel.endRound();
    } else if (!wasPaused) {
      viewModel.togglePause();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ValueListenableBuilder<Duration>(
          valueListenable: viewModel.roundRemaining,
          builder: (context, roundLeft, _) =>
              ValueListenableBuilder<bool>(
            valueListenable: viewModel.paused,
            builder: (context, paused, _) => ValueListenableBuilder<bool>(
              valueListenable: viewModel.stopwatchVisible,
              builder: (context, stopwatchVisible, _) =>
                  ValueListenableBuilder<Duration>(
                valueListenable: viewModel.elapsedOnCard,
                builder: (context, elapsed, _) => RoundTimer(
                  roundRemaining: roundLeft,
                  roundIndex: roundIndex,
                  roundCount: roundCount,
                  remaining: remaining,
                  paused: paused,
                  stopwatchVisible: stopwatchVisible,
                  elapsedOnCard: elapsed,
                  onTogglePause: viewModel.togglePause,
                  onToggleStopwatch: viewModel.toggleStopwatch,
                  onEndRound: () => _confirmEndRound(context),
                ),
              ),
            ),
          ),
        ),
        const Divider(height: 1),
        Expanded(child: Center(child: face)),
        const SizedBox(height: 12),
        footer,
      ],
    );
  }
}

class _SubjectPicker extends StatefulWidget {
  const _SubjectPicker({required this.subjects, required this.onStart});

  final List<SubjectQueue> subjects;
  final ValueChanged<List<String>> onStart;

  @override
  State<_SubjectPicker> createState() => _SubjectPickerState();
}

class _SubjectPickerState extends State<_SubjectPicker> {
  final _selected = <String>[];

  // The picker is a View, so it may resolve `get_it` — the ViewModel may not.
  final _policy = getIt<SessionPolicy>();

  @override
  Widget build(BuildContext context) {
    if (widget.subjects.isEmpty) {
      return const Center(
        child: Text('Nenhum assunto com cartão para estudar hoje.'),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Escolha os assuntos — cada um é um round de 5 minutos.',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 12),
        Expanded(
          child: ListView(
            children: [
              for (final queue in widget.subjects)
                CheckboxListTile(
                  title: Text(queue.subject),
                  subtitle: Text(
                    '${queue.cards} '
                    '${queue.cards == 1 ? 'cartão' : 'cartões'} para hoje',
                  ),
                  value: _selected.contains(queue.subject),
                  onChanged: (checked) => setState(() {
                    if (checked ?? false) {
                      _selected.add(queue.subject);
                    } else {
                      _selected.remove(queue.subject);
                    }
                  }),
                ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Center(
          child: FilledButton(
            onPressed: _policy.canStart(_selected)
                ? () => widget.onStart(List.of(_selected))
                : null,
            child: Text(
              _policy.canStart(_selected)
                  ? 'Começar · ${_selected.length} '
                        '${_selected.length == 1 ? 'assunto' : 'assuntos'} · '
                        '${_policy.durationFor(_selected).inMinutes} min'
                  : 'Começar',
            ),
          ),
        ),
      ],
    );
  }
}

class _Scoreboard extends StatelessWidget {
  const _Scoreboard({required this.session});

  final StudySession session;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Sessão concluída', style: theme.textTheme.headlineSmall),
        const SizedBox(height: 4),
        Text(
          '${session.recalled} de ${session.answered} lembrados',
          style: theme.textTheme.titleMedium,
        ),
        const SizedBox(height: 16),
        Expanded(
          child: ListView(
            children: [
              for (final score in session.scores)
                ListTile(
                  title: Text(score.subject),
                  subtitle: Text(
                    'Errei ${score.again} · Só uma parte ${score.hard} · '
                    'Com esforço ${score.good} · De cor ${score.easy}',
                  ),
                  trailing: Text('${score.recalled}/${score.answered}'),
                ),
            ],
          ),
        ),
        Center(
          child: FilledButton(
            onPressed: () =>
                Navigator.of(context).pushNamed(AppRoutes.dashboard),
            child: const Text('Ver o painel'),
          ),
        ),
      ],
    );
  }
}

/// H12: nothing due and nothing to anticipate. Three ways out instead of an
/// empty screen.
class _DayClearedScreen extends StatelessWidget {
  const _DayClearedScreen();

  @override
  Widget build(BuildContext context) {
    void go(String route) => Navigator.of(context).pushNamed(route);

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Nada vencido por hoje.',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 24),
          FilledButton(
            onPressed: () => go(AppRoutes.import),
            child: const Text('Importar conteúdo novo'),
          ),
          const SizedBox(height: 8),
          OutlinedButton(
            onPressed: () => go(AppRoutes.mockInterview),
            child: const Text('Fazer um simulado'),
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: () => go(AppRoutes.dashboard),
            child: const Text('Ver assuntos fracos'),
          ),
        ],
      ),
    );
  }
}
