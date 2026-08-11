import 'package:flutter/material.dart';

import '../../core/di/service_locator.dart';
import '../import/widgets/text_file_picker.dart';
import '../shared/app_scaffold.dart';
import 'backup_state.dart';
import 'backup_viewmodel.dart';
import 'browser_download.dart';

/// Backup window (H14): download the whole database as a file and restore it.
class BackupView extends StatefulWidget {
  const BackupView({super.key});

  @override
  State<BackupView> createState() => _BackupViewState();
}

class _BackupViewState extends State<BackupView> {
  late final BackupViewModel _viewModel =
      BackupViewModel(getIt(), getIt(), getIt(), getIt(), getIt());

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  Future<void> _export() async {
    final file = await _viewModel.export();
    if (file == null) return;
    downloadTextFile(fileName: file.fileName, contents: file.contents);
  }

  Future<void> _restore() async {
    final contents = await pickTextFile(accept: '.json,application/json');
    if (contents == null || !mounted) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Restaurar cópia de segurança'),
        content: const Text(
          'Isso apaga tudo o que está no app agora e coloca no lugar o que '
          'está no arquivo: cartões, histórico de respostas e configurações. '
          'Não dá para desfazer.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Restaurar mesmo assim'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    await _viewModel.restore(contents);
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Cópia de segurança',
      child: ValueListenableBuilder<BackupState>(
        valueListenable: _viewModel.state,
        builder: (context, state, _) => switch (state) {
          BackupWorking() => const Center(child: CircularProgressIndicator()),
          BackupReady(
            :final lastBackupAt,
            :final daysSinceLastBackup,
            :final cardCount,
            :final reviewCount,
          ) =>
            _ready(
              context,
              lastBackupAt: lastBackupAt,
              daysSinceLastBackup: daysSinceLastBackup,
              cardCount: cardCount,
              reviewCount: reviewCount,
            ),
          BackupExported(:final fileName) => _message(
              context,
              icon: Icons.download_done,
              text: 'Cópia gerada: $fileName\n'
                  'Guarde o arquivo fora do navegador.',
            ),
          BackupRestored() => _message(
              context,
              icon: Icons.check_circle_outline,
              text: 'Cópia restaurada. Tudo voltou como estava no arquivo.',
            ),
          BackupError(:final message) =>
            _message(context, icon: Icons.error_outline, text: message),
        },
      ),
    );
  }

  Widget _ready(
    BuildContext context, {
    required DateTime? lastBackupAt,
    required int? daysSinceLastBackup,
    required int cardCount,
    required int reviewCount,
  }) {
    final text = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          switch (daysSinceLastBackup) {
            null => 'Você ainda não fez nenhuma cópia de segurança.',
            0 => 'Última cópia: hoje.',
            1 => 'Última cópia: ontem.',
            final days => 'Última cópia: há $days dias '
                '(${formatDate(lastBackupAt!)}).',
          },
          style: text.titleMedium,
        ),
        const SizedBox(height: 8),
        Text(
          'O navegador pode apagar os dados do app sem avisar. A cópia é a '
          'única forma de não perder $cardCount cartão(ões) e $reviewCount '
          'resposta(s) de histórico.',
          style: text.bodyMedium,
        ),
        const SizedBox(height: 24),
        FilledButton.icon(
          onPressed: _export,
          icon: const Icon(Icons.download),
          label: const Text('Baixar cópia de segurança'),
        ),
        const SizedBox(height: 12),
        OutlinedButton.icon(
          onPressed: _restore,
          icon: const Icon(Icons.upload_file),
          label: const Text('Restaurar de um arquivo'),
        ),
      ],
    );
  }

  Widget _message(
    BuildContext context, {
    required IconData icon,
    required String text,
  }) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 48),
          const SizedBox(height: 12),
          Text(text, textAlign: TextAlign.center),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: _viewModel.refresh,
            child: const Text('Voltar'),
          ),
        ],
      ),
    );
  }
}
