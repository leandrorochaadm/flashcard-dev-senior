import 'package:flutter/material.dart';

import '../../core/di/service_locator.dart';
import '../../core/router.dart';
import '../../domain/models/study_session.dart';
import '../../domain/policies/content_intake_policy.dart';
import '../shared/app_scaffold.dart';
import 'dashboard_state.dart';
import 'dashboard_viewmodel.dart';
import 'widgets/accuracy_vs_target_tile.dart';
import 'widgets/avg_time_tile.dart';
import 'widgets/calibration_chart.dart';
import 'widgets/deadline_banner.dart';
import 'widgets/firm_today_tile.dart';
import 'widgets/idle_time_panel.dart';
import 'widgets/load_forecast_chart.dart';
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

class _Ready extends StatelessWidget {
  const _Ready({required this.ready, required this.viewModel});

  final DashboardReady ready;
  final DashboardViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
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
        _BackupNotice(daysSinceBackup: ready.daysSinceBackup),
        if (ready.dayCleared)
          IdleTimePanel(
            onImportMore: () =>
                Navigator.of(context).pushNamed(AppRoutes.import),
            onMockInterview: () =>
                Navigator.of(context).pushNamed(AppRoutes.mockInterview),
            onWeakSubjects: () {
              // The map is already sorted worst-first by the domain.
              final weakest = ready.subjects.isEmpty
                  ? null
                  : ready.subjects.first.subject;
              if (weakest != null) {
                Navigator.of(context)
                    .pushNamed(AppRoutes.subject, arguments: weakest);
              }
            },
          ),
        // `IntrinsicHeight`, not `crossAxisAlignment: stretch`: inside a
        // `ListView` the row's height is unbounded, and stretching against
        // infinity aborts the build of everything below it.
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(child: FirmTodayTile(firmedToday: ready.firmedToday)),
              Expanded(
                child: AccuracyVsTargetTile(
                  accuracy: ready.accuracy,
                  target: ready.targetRetention,
                ),
              ),
            ],
          ),
        ),
        _LastSessionTile(session: ready.lastSession),
        SubjectMap(
          subjects: ready.subjects,
          onSubjectTap: (subject) => Navigator.of(context)
              .pushNamed(AppRoutes.subject, arguments: subject),
        ),
        CalibrationChart(
          series: ready.calibration,
          previousSeries: ready.previousCalibration,
          canRevert: ready.canRevertTuning,
          onRevert: viewModel.revertTuning,
          tuningMessage: ready.tuningMessage,
        ),
        LoadForecastChart(bars: ready.load),
        AvgTimeTile(stats: ready.timeOnCard),
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
