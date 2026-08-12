/// Display formatting shared by the screens. Formatting is a View concern, but
/// it is not a screen: nothing here imports Flutter, and above all nothing here
/// imports the router.
///
/// It used to live in `app_scaffold.dart`, and a widget that only needed to
/// print a date pulled in the scaffold, the scaffold pulled in `core/router.dart`
/// and the router pulled in every screen of the app — including the one that
/// reaches `dart:js_interop`, which does not exist on the Dart VM. A widget test
/// of the subject map then failed to compile for no reason of its own.
///
/// `app_scaffold.dart` re-exports this file, so every existing caller keeps
/// working unchanged.
library;

String formatDays(Duration duration) {
  final days = duration.inMinutes / 1440;
  if (days >= 1) return '${days.toStringAsFixed(1)} dia${days >= 2 ? 's' : ''}';
  final hours = duration.inMinutes / 60;
  if (hours >= 1) return '${hours.toStringAsFixed(0)} h';
  return '${duration.inMinutes} min';
}

/// A time on a card, or an em dash when there is nothing measured yet. Shared
/// by the average-time tile and the expanded subject map, so the two never
/// print the same duration differently.
String formatSeconds(Duration? duration) {
  if (duration == null) return '—';
  return '${(duration.inMilliseconds / 1000).toStringAsFixed(1)} s';
}

String formatDate(DateTime date) =>
    '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}';

String formatClock(Duration duration) {
  final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
  final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
  return '$minutes:$seconds';
}
