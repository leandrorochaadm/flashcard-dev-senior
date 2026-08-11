import 'package:flutter/material.dart';

import '../../core/clock.dart';
import '../../core/di/service_locator.dart';
import '../../data/database/web_database_factory.dart';
import '../../data/repositories/card_repository.dart';
import '../../data/repositories/review_log_repository.dart';
import '../../domain/models/card.dart' as domain;
import '../../domain/models/enums.dart';
import '../../domain/models/review_log.dart';
import '../../domain/policies/due_cards_policy.dart';
import '../../domain/ports.dart';
import '../../domain/scheduling/card_scheduler.dart';
import '../../domain/scheduling/fsrs_gateway.dart';
import '../../domain/scheduling/moving_ceiling.dart';
import '../../domain/stats/progress_stats.dart';
import '../shared/app_scaffold.dart';

/// Time travel — a development tool, on the hidden route `/debug`.
///
/// It always points the whole object graph at `flashcards_debug`, never at the
/// real database: a tool that fakes 30 days of study must not be able to
/// corrupt the history the app exists to protect. No production code knows it
/// is here, and nothing in the navigation links to it.
class TimeTravelView extends StatefulWidget {
  const TimeTravelView({super.key});

  @override
  State<TimeTravelView> createState() => _TimeTravelViewState();
}

class _TimeTravelViewState extends State<TimeTravelView> {
  FakeClock? _clock;
  bool _busy = false;
  String? _message;

  Future<void> _enterDebugMode() async {
    setState(() => _busy = true);
    // The clock starts on the real "now" so day 1 of the debug database lines
    // up with the day the tool was opened.
    final clock = FakeClock(const SystemClock().now());
    await resetLocator(
      factory: webDatabaseFactory,
      databaseName: debugDatabaseName,
      clock: clock,
    );
    if (!mounted) return;
    setState(() {
      _clock = clock;
      _busy = false;
      _message = 'Banco de testes aberto. Nada aqui toca o banco real.';
    });
  }

  Future<void> _leaveDebugMode() async {
    setState(() => _busy = true);
    await resetLocator(factory: webDatabaseFactory);
    if (!mounted) return;
    setState(() {
      _clock = null;
      _busy = false;
      _message = 'De volta ao banco real.';
    });
  }

  Future<void> _advance(Duration by) async {
    _clock?.advance(by);
    setState(() => _message = null);
  }

  /// Answers everything that is due with one button, so a whole day can be
  /// simulated in a click. It goes through [CardScheduler], exactly like the
  /// session screen — a shortcut around it would test nothing.
  Future<void> _answerAll(Rating rating) async {
    final clock = _clock;
    if (clock == null) return;
    setState(() => _busy = true);

    final scheduler = getIt<CardScheduler>();
    final cards = getIt<CardRepository>();
    final logs = getIt<ReviewLogRepository>();
    final fsrs = getIt<FsrsGateway>();
    final due = getIt<DueCardsPolicy>().dueNow(clock.now());

    for (final card in due) {
      final now = clock.now();
      await logs.append(
        ReviewLog(
          cardId: card.id,
          reviewedAt: now,
          rating: rating,
          elapsedDays: _elapsedDays(card, now),
          predictedRetention: fsrs.retrievability(card.memory, now),
          stabilityBefore: card.stability,
          timeOnCard: const Duration(seconds: 5),
          source: ReviewSource.session,
        ),
      );
      await cards.save(scheduler.apply(card, rating, now));
    }

    if (!mounted) return;
    setState(() {
      _busy = false;
      _message = '${due.length} cartões respondidos.';
    });
  }

  static double _elapsedDays(domain.Card card, DateTime now) {
    final last = card.lastReviewedAt;
    if (last == null) return 0;
    return now.difference(last).inMinutes / 1440;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final clock = _clock;

    return AppScaffold(
      title: 'Viagem no tempo',
      child: ListView(
        children: [
          Card(
            color: theme.colorScheme.errorContainer,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Ferramenta de desenvolvimento',
                    style: theme.textTheme.titleMedium,
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Tudo aqui acontece no banco "flashcards_debug". O banco '
                    'real não é aberto nem lido.',
                  ),
                  const SizedBox(height: 12),
                  if (clock == null)
                    FilledButton(
                      onPressed: _busy ? null : _enterDebugMode,
                      child: const Text('Abrir o banco de testes'),
                    )
                  else
                    OutlinedButton(
                      onPressed: _busy ? null : _leaveDebugMode,
                      child: const Text('Voltar ao banco real'),
                    ),
                ],
              ),
            ),
          ),
          if (_message != null)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text(_message!, style: theme.textTheme.bodySmall),
            ),
          if (_busy) const LinearProgressIndicator(),
          if (clock != null) ...[
            _Readout(clock: clock),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    OutlinedButton(
                      onPressed: _busy
                          ? null
                          : () => _advance(const Duration(days: 1)),
                      child: const Text('+1 dia'),
                    ),
                    OutlinedButton(
                      onPressed: _busy
                          ? null
                          : () => _advance(const Duration(days: 7)),
                      child: const Text('+7 dias'),
                    ),
                    OutlinedButton(
                      onPressed: _busy ? null : _enterDebugMode,
                      child: const Text('Reiniciar'),
                    ),
                    FilledButton(
                      onPressed: _busy ? null : () => _answerAll(Rating.easy),
                      child: const Text('Responder tudo: sabia de cor'),
                    ),
                    FilledButton.tonal(
                      onPressed: _busy ? null : () => _answerAll(Rating.again),
                      child: const Text('Responder tudo: errei'),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Everything the tool has to show comes from the domain, read fresh on every
/// rebuild — the clock moved, so the numbers moved with it.
class _Readout extends StatelessWidget {
  const _Readout({required this.clock});

  final FakeClock clock;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final now = clock.now();
    final window = getIt<ScheduleWindowView>().window;
    final ceiling = getIt<MovingCeiling>().forDate(now);
    final forecast = getIt<ProgressStats>().loadForecast(now);
    final released =
        getIt<CardRepository>().all.where((card) => card.isReleased).length;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Estado simulado', style: theme.textTheme.titleMedium),
            const SizedBox(height: 12),
            _Line('Data simulada', formatDate(now)),
            _Line('Dia de uso', '${window.dayOfUse(now)}'),
            _Line('Faltam para a data-alvo',
                '${window.daysRemainingFrom(now)} dias'),
            _Line('Teto de hoje', formatDays(ceiling)),
            _Line('Cartões liberados', '$released'),
            const Divider(height: 24),
            Text('Carga prevista', style: theme.textTheme.labelLarge),
            const SizedBox(height: 8),
            for (final bar in forecast)
              _Line(formatDate(bar.day), '${bar.cards} cartões'),
          ],
        ),
      ),
    );
  }
}

class _Line extends StatelessWidget {
  const _Line(this.label, this.value);

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Expanded(child: Text(label)),
          Text(value, style: Theme.of(context).textTheme.titleSmall),
        ],
      ),
    );
  }
}
