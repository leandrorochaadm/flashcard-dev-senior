import 'package:flutter/material.dart';

/// Asks before something that cannot be undone from the screen it leaves.
///
/// Both stop buttons of the study screen — the round and the session — sit one
/// tap away from a phone-sized layout and have no way back, so both go through
/// here. Dismissing the dialog counts as keeping things as they are.
Future<bool> confirmStopping(
  BuildContext context, {
  required String title,
  required String message,
  required String confirmLabel,
  required String keepLabel,
}) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(title),
      content: Text(message),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(keepLabel),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(true),
          child: Text(confirmLabel),
        ),
      ],
    ),
  );
  return confirmed ?? false;
}
