import 'package:flutter/material.dart';

import '../../core/di/service_locator.dart';
import '../../core/router.dart';
import '../../domain/models/study_session.dart';
import '../../domain/policies/content_intake_policy.dart';
import '../../domain/policies/next_action_policy.dart';
import '../shared/app_scaffold.dart';
import 'dashboard_state.dart';
import 'dashboard_viewmodel.dart';
import 'widgets/accuracy_vs_target_tile.dart';
import 'widgets/avg_time_tile.dart';
import 'widgets/calibration_chart.dart';
import 'widgets/collection_funnel_tile.dart';
import 'widgets/deadline_banner.dart';
import 'widgets/due_today_tile.dart';
import 'widgets/firm_today_tile.dart';
import 'widgets/idle_time_panel.dart';
import 'widgets/load_forecast_chart.dart';
import 'widgets/next_action_card.dart';
import 'widgets/streak_tile.dart';
import 'widgets/stuck_cards_panel.dart';
import 'widgets/subject_map.dart';

/// The dashboard (H6, H12, H13). The View is the place allowed to resolve
/// `get_it`; the ViewModel receives everything through its constructor.
class DashboardView extends StatefulWidget {
  const DashboardView({super.key});

  @override
  State<DashboardView> createState() => _DashboardViewState();
}

class _DashboardViewState extends State<DashboardView> {
  late final DashboardViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    // The list is positional: `NextActionPolicy` and `CardRepository` are the
    // last two parameters of the constructor, in this order, and these two
    // `getIt()` calls are the last two here for the same reason.
    _viewModel = DashboardViewModel(
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
      getIt(),
      getIt(),
      getIt(),
    );
    _load();
  }

  Future<void> _load() async {
    await _viewModel.load();
    // Self-tuning only runs outside a session: it trains in slices on the main
    // thread, because Flutter Web has no isolate.
    await _viewModel.runTuningIfDue();
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Painel',
      showNavigation: true,
      actions: [
        IconButton(
          onPressed: () => Navigator.of(context).pushNamed(AppRoutes.backup),
          icon: const Icon(Icons.save_alt),
          tooltip: 'Cópia de segurança',
        ),
        IconButton(
          onPressed: () => Navigator.of(context).pushNamed(AppRoutes.about),
          icon: const Icon(Icons.info_outline),
          tooltip: 'Sobre',
        ),
      ],
      child: ValueListenableBuilder<DashboardState>(
        valueListenable: _viewModel.state,
        builder: (context, state, _) => switch (state) {
          DashboardLoading() =>
            const Center(child: CircularProgressIndicator()),
          DashboardError(:final message) => Center(child: Text(message)),
          final DashboardReady ready => _Ready(ready: ready, viewModel: _viewModel),
        },
      ),
    );
  }
}

/// Stateful because the scroll targets need `GlobalKey`s and the tiles opened
/// from the outside need controllers.
class _Ready extends StatefulWidget {
  const _Ready({required this.ready, required this.viewModel});

  final DashboardReady ready;
  final DashboardViewModel viewModel;

  @override
  State<_Ready> createState() => _ReadyState();
}

class _ReadyState extends State<_Ready> {
  final _mapKey = GlobalKey();
  final _stuckKey = GlobalKey();
  final _stuckController = ExpansibleController();

  /// `ExpansibleController` has no `dispose`; the map grows at most with the
  /// number of subjects and goes away with the `State`.
  final _subjectControllers = <String, ExpansibleController>{};

  ExpansibleController _controllerFor(String subject) =>
      _subjectControllers.putIfAbsent(subject, ExpansibleController.new);

  /// Who decides which subject is the weak one is the domain
  /// (`ProgressStats.weakestSubject`); here it is only opened and scrolled to.
  void _revealWeakestSubject() {
    final weakest = widget.ready.weakestSubject;
    if (weakest == null) return; // the button would already be disabled
    _controllerFor(weakest.subject).expand();
    _scrollTo(_mapKey);
  }

  /// `expand()` before `ensureVisible`: the tile has to be open in the frame
  /// the scrolling happens in, or the target changes height mid-animation.
  void _scrollTo(GlobalKey key) {
    // With the `Column` below every child exists, so the context is always
    // available; the guard is defensive, not an expected path.
    final target = key.currentContext;
    assert(target != null, 'alvo de rolagem não construído');
    if (target == null) return;
    Scrollable.ensureVisible(
      target,
      duration: const Duration(milliseconds: 300),
      alignment: 0.1,
    );
  }

  @override
  Widget build(BuildContext context) {
    final ready = widget.ready;
    final viewModel = widget.viewModel;
    final kind = ready.nextAction.kind;

    // `SingleChildScrollView` + `Column`, not `ListView`: the list only builds
    // what is near the viewport, so the `GlobalKey` of a block below the fold —
    // exactly the case of the map and of the stuck cards — would have a null
    // context and the button would swallow the tap in silence again. With ~13
    // fixed children and no long repeated list, lazy building does not pay for
    // itself here.
    return SingleChildScrollView(
      child: Column(
        children: [
          // Not painted on `answerDeadline`: the banner right below owns that
          // question and carries the calendar, and a card whose only action is
          // to scroll 80 points down informs nothing.
          if (kind != NextActionKind.answerDeadline)
            NextActionCard(
              action: ready.nextAction,
              onStudy: () => Navigator.of(context).pushNamed(AppRoutes.session),
              onBackup: () => Navigator.of(context).pushNamed(AppRoutes.backup),
              onImport: () => Navigator.of(context).pushNamed(AppRoutes.import),
              onMockInterview: () =>
                  Navigator.of(context).pushNamed(AppRoutes.mockInterview),
              onShowStuck: () {
                _stuckController.expand();
                _scrollTo(_stuckKey);
              },
            ),
          DeadlineBanner(
            targetDate: ready.targetDate,
            daysToTarget: ready.daysToTarget,
            ceilingToday: ready.ceilingToday,
            deadlineReached: ready.deadlineReached,
            ceilingFor: viewModel.ceilingForCandidateTarget,
            onPickTarget: viewModel.setTargetDate,
            onKeep: viewModel.keepDeadline,
          ),
          _IntakeNotice(intake: ready.intake),
          // Hidden when the card above just gave the same advice with the same
          // button — which is the first opening of the app, every time.
          if (kind != NextActionKind.backup)
            _BackupNotice(daysSinceBackup: ready.daysSinceBackup),
          if (ready.dayCleared)
            IdleTimePanel(
              onImportMore: () =>
                  Navigator.of(context).pushNamed(AppRoutes.import),
              onMockInterview: () =>
                  Navigator.of(context).pushNamed(AppRoutes.mockInterview),
              // With no released subject there is no map to open; the button is
              // born disabled instead of swallowing the tap.
              onWeakSubjects:
                  ready.weakestSubject == null ? null : _revealWeakestSubject,
            ),
          _MetricStrip(ready: ready),
          _LastSessionTile(session: ready.lastSession),
          SubjectMap(
            key: _mapKey,
            subjects: ready.subjects,
            controllerOf: _controllerFor,
            onSubjectTap: (subject) => Navigator.of(context)
                .pushNamed(AppRoutes.subject, arguments: subject),
          ),
          // The funnel and the stuck cards are lookups, not daily readings, so
          // they come after the map and are born collapsed.
          CollectionFunnelTile(overview: ready.overview),
          StuckCardsPanel(
            key: _stuckKey,
            cards: ready.stuckCards,
            controller: _stuckController,
            onOpenCards: () => Navigator.of(context).pushNamed(AppRoutes.cards),
          ),
          LoadForecastChart(points: ready.load, average: ready.loadAverage),
          // The calibration chart audits the app; it is not what answers "how
          // am I doing today", so it sits below the load.
          CalibrationChart(
            series: ready.calibration,
            previousSeries: ready.previousCalibration,
            canRevert: ready.canRevertTuning,
            onRevert: viewModel.revertTuning,
            tuningMessage: ready.tuningMessage,
          ),
          AvgTimeTile(stats: ready.timeOnCard),
        ],
      ),
    );
  }
}

/// The four compact tiles, two by two. It replaces the single row of two full
/// tiles and is what keeps the dashboard from growing taller by gaining two
/// indicators.
class _MetricStrip extends StatelessWidget {
  const _MetricStrip({required this.ready});

  final DashboardReady ready;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // `IntrinsicHeight`, not `crossAxisAlignment: stretch`: inside a child
        // of unbounded height, stretching against infinity aborts the build of
        // everything below it.
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: FirmTodayTile(
                  firmedToday: ready.firmedToday,
                  series: ready.firmedSeries,
                  average: ready.firmedAverage,
                ),
              ),
              Expanded(
                child: AccuracyVsTargetTile(
                  accuracy: ready.accuracy,
                  target: ready.targetRetention,
                ),
              ),
            ],
          ),
        ),
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(child: StreakTile(streak: ready.streak)),
              Expanded(
                child: DueTodayTile(
                  cards: ready.overview.dueToday,
                  subjects: ready.overview.subjectsDueToday,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// The requirement is explicit: a collection that stops growing without a word
/// is worse than a smaller batch. [IntakeRelease.shouldWarn] decides.
class _IntakeNotice extends StatelessWidget {
  const _IntakeNotice({required this.intake});

  final IntakeRelease intake;

  @override
  Widget build(BuildContext context) {
    if (!intake.shouldWarn) return const SizedBox.shrink();
    final text = switch (intake.reason) {
      IntakeReason.heldByForecast =>
        'Hoje não entraram cartões novos: os próximos dias já estão cheios.',
      IntakeReason.reducedByLowStudy =>
        'Hoje entraram menos cartões novos, porque você estudou pouco nos '
            'últimos dias.',
      _ => '',
    };
    return Card(
      color: Theme.of(context).colorScheme.tertiaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Text(text),
      ),
    );
  }
}

/// Backup is the only real protection against the browser evicting IndexedDB.
class _BackupNotice extends StatelessWidget {
  const _BackupNotice({required this.daysSinceBackup});

  final int? daysSinceBackup;

  @override
  Widget build(BuildContext context) {
    final days = daysSinceBackup;
    final label = days == null
        ? 'Você ainda não fez nenhuma cópia de segurança.'
        : days == 0
            ? 'Cópia de segurança feita hoje.'
            : 'Última cópia de segurança há $days '
                '${days == 1 ? 'dia' : 'dias'}.';
    return Card(
      child: ListTile(
        leading: const Icon(Icons.save_alt),
        title: Text(label),
        trailing: TextButton(
          onPressed: () => Navigator.of(context).pushNamed(AppRoutes.backup),
          child: const Text('Fazer cópia'),
        ),
      ),
    );
  }
}

class _LastSessionTile extends StatelessWidget {
  const _LastSessionTile({required this.session});

  final StudySession? session;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final last = session;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Última sessão', style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),
            if (last == null)
              const Text('Você ainda não estudou nenhuma sessão.')
            else ...[
              Text(
                '${formatDate(last.startedAt)} · ${last.answered} respostas · '
                '${last.recalled} lembradas',
                style: theme.textTheme.bodyMedium,
              ),
              if (last.answered > 0) ...[
                const SizedBox(height: 12),
                _RatingBar(session: last),
              ],
              const SizedBox(height: 8),
              for (final score in last.scores)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: Row(
                    children: [
                      Expanded(child: Text(score.subject)),
                      Text('${score.recalled}/${score.answered}'),
                    ],
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }
}

/// How the four buttons were pressed across the whole session.
///
/// The four totals were already recorded in every `RoundScore` and had never
/// appeared on any screen. The labels are fixed by the requirements and are
/// read by the user, so they are pt-BR, word for word.
class _RatingBar extends StatelessWidget {
  const _RatingBar({required this.session});

  final StudySession session;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final segments = <(String, int, Color)>[
      ('Errei', session.againTotal, colors.error),
      ('Lembrei só uma parte', session.hardTotal, colors.tertiary),
      ('Lembrei com esforço', session.goodTotal, colors.primary),
      ('Sabia de cor', session.easyTotal, colors.secondary),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: SizedBox(
            height: 10,
            child: Row(
              children: [
                // `flex` only accepts a positive integer, so a button nobody
                // pressed does not enter the row — the legend still shows it.
                for (final (_, total, color) in segments)
                  if (total > 0)
                    Expanded(
                      flex: total,
                      child: ColoredBox(
                        color: color,
                        child: const SizedBox.expand(),
                      ),
                    ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          [for (final (label, total, _) in segments) '$label $total'].join(' · '),
          style: theme.textTheme.bodySmall,
        ),
      ],
    );
  }
}
