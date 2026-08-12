import 'package:collection/collection.dart';
import 'package:flutter/material.dart';

import '../../core/clock.dart';
import '../../core/di/service_locator.dart';
import '../../data/repositories/card_repository.dart';
import '../../data/repositories/review_log_repository.dart';
import '../../domain/mock_interview/mock_interview_service.dart';
import '../../domain/models/card.dart' as domain;
import '../../domain/models/enums.dart';
import '../../domain/stats/calibration.dart';
import '../../domain/stats/progress_stats.dart';
import '../shared/app_scaffold.dart';
import 'widgets/dashboard_metric_line.dart';

/// One subject, read only: how it stands and how it went over the days.
///
/// It deliberately starts nothing — no session, no list of cards to review.
/// Studying a single subject on demand would break the round structure the
/// session screen owns.
class SubjectDetailView extends StatefulWidget {
  const SubjectDetailView({required this.subject, super.key});

  final String subject;

  @override
  State<SubjectDetailView> createState() => _SubjectDetailViewState();
}

class _SubjectDetailViewState extends State<SubjectDetailView> {
  SubjectProgress? _progress;
  List<CalibrationPoint> _history = const [];
  List<MockInterviewScore> _mockScores = const [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() {
    final stats = getIt<ProgressStats>();
    final calibration = getIt<Calibration>();
    final mock = getIt<MockInterviewService>();
    final cards = getIt<CardRepository>();
    final logs = getIt<ReviewLogRepository>();
    final clock = getIt<Clock>();

    final subjectOf = {for (final card in cards.all) card.id: card.subject};
    bool belongs(String cardId) => subjectOf[cardId] == widget.subject;

    // TODO(pontos em aberto): a mock interview is not persisted as a session,
    // only as its review logs, so "o último simulado" cannot be isolated. What
    // is shown here is every mock answer recorded for this subject.
    final mockAnswers = <domain.Card, Rating>{};
    for (final log in logs.all) {
      if (log.source != ReviewSource.mockInterview) continue;
      final card = cards.byId(log.cardId);
      if (card == null || card.subject != widget.subject) continue;
      mockAnswers[card] = log.rating;
    }

    setState(() {
      // The same call the dashboard makes, logs included, so the two screens
      // never show different numbers for the same subject.
      _progress = stats
          .subjectMap(clock.now(), logs: logs.all)
          .firstWhereOrNull((entry) => entry.subject == widget.subject);
      _history = calibration.series(
        logs.all.where((log) => belongs(log.cardId)).toList(),
      );
      _mockScores = mock.score(mockAnswers);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final progress = _progress;

    return AppScaffold(
      title: widget.subject,
      child: ListView(
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: progress == null
                  ? const Text('Nenhum cartão liberado neste assunto ainda.')
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Como está o assunto',
                            style: theme.textTheme.titleMedium),
                        const SizedBox(height: 12),
                        DashboardMetricLine(
                          label: 'Cartões firmes',
                          value: '${progress.firm} de ${progress.total}',
                        ),
                        DashboardMetricLine(
                          label: 'Cartões travados',
                          value: '${progress.stuck}',
                        ),
                        DashboardMetricLine(
                          label: 'Prontos para a data-alvo',
                          value: '${progress.ready} de ${progress.total}',
                        ),
                        DashboardMetricLine(
                          label: 'Vencendo hoje',
                          value: '${progress.dueToday}',
                        ),
                        DashboardMetricLine(
                          label: 'Nunca respondidos',
                          value: '${progress.neverAnswered}',
                        ),
                        DashboardMetricLine(
                          label: 'Tempo médio',
                          value: formatSeconds(progress.averageTime),
                        ),
                        DashboardMetricLine(
                          label: 'Próximo vencimento',
                          value: progress.nextDueAt == null
                              ? 'tudo vencido'
                              : formatDate(progress.nextDueAt!),
                        ),
                      ],
                    ),
            ),
          ),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Acertos ao longo dos dias',
                      style: theme.textTheme.titleMedium),
                  const SizedBox(height: 12),
                  if (_history.isEmpty)
                    const Text('Ainda não há respostas neste assunto.')
                  else
                    for (final point in _history)
                      DashboardMetricLine(
                        label: formatDate(point.day),
                        value: '${(point.actual * 100).toStringAsFixed(0)}% '
                            'em ${point.reviews} respostas',
                      ),
                ],
              ),
            ),
          ),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('No simulado', style: theme.textTheme.titleMedium),
                  const SizedBox(height: 12),
                  if (_mockScores.isEmpty)
                    const Text('Este assunto ainda não caiu num simulado.')
                  else
                    for (final score in _mockScores)
                      DashboardMetricLine(
                        label: score.subject,
                        value: '${score.recalled} de ${score.asked} '
                            '(${(score.accuracy * 100).toStringAsFixed(0)}%)',
                      ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

