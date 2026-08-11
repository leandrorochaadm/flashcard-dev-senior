import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Copies the template to the clipboard (H15), so it can be pasted into an AI
/// chat without editing anything.
class CopyTemplateButton extends StatelessWidget {
  const CopyTemplateButton({required this.template, super.key});

  final String template;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: () async {
        await Clipboard.setData(ClipboardData(text: template));
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Template copiado. Cole no chat da IA.'),
          ),
        );
      },
      icon: const Icon(Icons.copy_all_outlined),
      label: const Text('Copiar template'),
    );
  }
}
