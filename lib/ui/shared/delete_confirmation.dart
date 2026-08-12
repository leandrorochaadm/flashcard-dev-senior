import 'package:flutter/material.dart';

/// Confirmation before an erasure. Deleting takes the review history along and
/// there is no undo, so the dialog spells out what disappears and how many.
Future<bool> confirmDeletion(
  BuildContext context, {
  required String title,
  required String message,
}) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(title),
      content: Text(
        '$message\n\nO histórico de estudo desses cartões também é apagado. '
        'Não dá para desfazer — só restaurando um backup.',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(true),
          child: const Text('Apagar'),
        ),
      ],
    ),
  );
  return confirmed ?? false;
}
