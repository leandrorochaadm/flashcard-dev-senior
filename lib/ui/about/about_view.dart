import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/app_version.dart';
import '../shared/app_scaffold.dart';

/// Which build is running: version, build number and the commit it came from.
///
/// It exists so that a bug report can name the exact bundle — the app is a PWA
/// and the browser may keep an older service-worker cache around.
class AboutView extends StatelessWidget {
  const AboutView({super.key});

  @override
  Widget build(BuildContext context) {
    final rows = <(String, String)>[
      ('Versão', AppVersion.name),
      ('Build', AppVersion.build),
      ('Commit', AppVersion.commitOrUnknown),
    ];

    return AppScaffold(
      title: 'Sobre',
      child: ListView(
        children: [
          Text(
            'Flashcards',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 4),
          Text(
            'Cartões de estudo com repetição espaçada para a entrevista de '
            'Flutter sênior. Funciona sem internet, e tudo fica guardado neste '
            'aparelho.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 24),
          Card(
            child: Column(
              children: [
                for (final (label, value) in rows)
                  ListTile(
                    dense: true,
                    title: Text(label),
                    trailing: SelectableText(
                      value,
                      style: const TextStyle(fontFamily: 'monospace'),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Align(
            alignment: Alignment.centerLeft,
            child: OutlinedButton.icon(
              onPressed: () async {
                await Clipboard.setData(
                  ClipboardData(
                    text: 'Flashcards ${AppVersion.full} '
                        '(commit ${AppVersion.commitOrUnknown})',
                  ),
                );
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Dados da versão copiados.')),
                  );
                }
              },
              icon: const Icon(Icons.copy),
              label: const Text('Copiar dados da versão'),
            ),
          ),
        ],
      ),
    );
  }
}
