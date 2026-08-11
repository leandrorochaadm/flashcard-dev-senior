import '../domain/models/schedule_window.dart';
import '../domain/policies/content_intake_policy.dart';
import '../domain/ports.dart';
import 'clock.dart';

/// Releases the day's batch, wherever the user enters the app.
///
/// Runs at startup and on every resume, not on a screen: importing and going
/// straight to the study tab has to work, and it did not while
/// `ContentIntakePolicy` was reachable only through the dashboard's
/// `initState` — every study query filters on `isReleased`, so the app served
/// nothing at all.
///
/// No business rule here. The policy decides the batch, stamps the cards and
/// refuses a second batch on the same day; this class only saves what came
/// back and records the day.
final class DailyRelease {
  DailyRelease(this._intake, this._cards, this._journal, this._clock);

  final ContentIntakePolicy _intake;
  final CardWriter _cards;
  final ReleaseJournal _journal;
  final Clock _clock;

  /// What came out today, kept so the dashboard can explain a held or reduced
  /// batch. Asking the policy again after the batch has gone out answers
  /// `alreadyReleasedToday`, and the real reason would be lost.
  ///
  /// Paired with the day it refers to: the app is a PWA that stays open across
  /// midnight, so a result with no date would go stale and the dashboard would
  /// keep explaining yesterday's batch.
  IntakeRelease? _today;
  DateTime? _todayFor;

  IntakeRelease? today(DateTime now) =>
      _todayFor != null && dateOnly(_todayFor!) == dateOnly(now) ? _today : null;

  Future<IntakeRelease> run() async {
    final now = _clock.now();

    // Already answered for today: do not ask the policy again, and above all
    // do not overwrite what it answered the first time. `releaseToday` would
    // reply `alreadyReleasedToday`, erasing the real reason of the day — the
    // one the dashboard has to show, because the app never shrinks the intake
    // in silence.
    final known = today(now);
    if (known != null) return known;

    final release = _intake.releaseToday(
      now,
      lastReleasedOn: _journal.lastReleaseAt,
    );
    // Which outcomes settle the day is the policy's call, not this class's:
    // `IntakeRelease.decidesTheDay` carries it, and getting it wrong means the
    // user studies the wrong cards.
    //
    // Nothing is remembered for an outcome that does not settle the day. A
    // fresh install answers `nothingPending`, and caching that would lock the
    // day in memory: importing five minutes later would release nothing until
    // tomorrow, which is the bug this class exists to fix with the sign
    // flipped. The journal below is skipped for the same reason.
    if (!release.decidesTheDay) return release;

    _today = release;
    _todayFor = now;

    if (release.cards.isNotEmpty) await _cards.saveAll(release.cards);
    await _journal.markReleased(now, release.reason, release.quota);
    return release;
  }

  /// Rebuilds the day's outcome from what was persisted, for the case where
  /// this instance is new but the batch already went out — a reload, which the
  /// service worker now performs on its own when a new build activates.
  ///
  /// No cards in it: they are already in the database, and nothing reads
  /// `cards` after the save. Reason and quota are what the notice needs.
  void restoreFromSettings(DateTime now) {
    final last = _journal.lastReleaseAt;
    if (last == null || dateOnly(last) != dateOnly(now)) return;
    _today = IntakeRelease(
      cards: const [],
      quota: _journal.lastReleaseQuota ?? 0,
      reason: _journal.lastReleaseReason ?? IntakeReason.steady,
    );
    _todayFor = last;
  }
}
