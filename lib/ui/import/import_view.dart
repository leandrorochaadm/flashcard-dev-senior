import 'package:flutter/material.dart';

import '../../core/di/service_locator.dart';
import '../../domain/import/import_preview.dart';
import '../../domain/import/import_service.dart';
import '../shared/app_scaffold.dart';
import '../shared/delete_confirmation.dart';
import 'import_state.dart';
import 'import_viewmodel.dart';
import 'widgets/copy_template_button.dart';
import 'widgets/intake_warning.dart';
import 'widgets/preview_list.dart';
import 'widgets/text_file_picker.dart';

/// Import window (H3, H15, H16): paste the Markdown or send a file, check the
/// preview — including the first review dates — and confirm.
class ImportView extends StatefulWidget {
  const ImportView({super.key});

  @override
  State<ImportView> createState() => _ImportViewState();
}

class _ImportViewState extends State<ImportView> {
  // The View is one of the two places allowed to resolve get_it.
  late final ImportViewModel _viewModel = ImportViewModel(
    getIt(),
    getIt(),
    getIt(),
    getIt(),
    getIt(),
    getIt(),
  );
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    _viewModel.dispose();
    super.dispose();
  }

  Future<void> _pickFiles() async {
    final contents = await pickTextFiles();
    if (contents.isEmpty || !mounted) return;
    // Each file becomes its own block group; the parser already splits cards
    // on a `---` line, so joining files that way merges every file's cards
    // into a single preview without touching the domain parser.
    final merged = contents.join('\n\n---\n\n');
    _controller.text = merged;
    _viewModel.parse(merged);
  }

  void _backToEditing() {
    _viewModel.reset();
  }

  /// An import that only adds goes straight through; one that erases asks
  /// first, with the count on screen.
  Future<void> _confirmImport(ImportOutcome outcome) async {
    if (outcome.removed.isNotEmpty) {
      final confirmed = await confirmDeletion(
        context,
        title: 'Apagar ${outcome.removed.length} cartão(ões)?',
        message: 'Eles estão na coleção e não aparecem no texto importado.',
      );
      if (!confirmed) return;
    }
    await _viewModel.confirm();
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Importar cartões',
      showNavigation: true,
      child: ValueListenableBuilder<ImportState>(
        valueListenable: _viewModel.state,
        builder: (context, state, _) => switch (state) {
          ImportIdle() => _editor(context),
          ImportImporting() => const Center(child: CircularProgressIndicator()),
          ImportPreviewing(
            :final preview,
            :final outcome,
            :final firmRatio,
            :final warnBelowThreshold,
          ) =>
            _preview(
              context,
              preview: preview,
              outcome: outcome,
              firmRatio: firmRatio,
              warnBelowThreshold: warnBelowThreshold,
            ),
          ImportDone(
            :final created,
            :final updated,
            :final removed,
            :final released,
          ) =>
            _done(
              context,
              created: created,
              updated: updated,
              removed: removed,
              released: released,
            ),
          ImportError(:final message) => _error(context, message),
        },
      ),
    );
  }

  Widget _editor(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            CopyTemplateButton(template: _viewModel.template),
            OutlinedButton.icon(
              onPressed: _pickFiles,
              icon: const Icon(Icons.upload_file),
              label: const Text('Enviar arquivo(s)'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Expanded(
          child: TextField(
            controller: _controller,
            maxLines: null,
            expands: true,
            textAlignVertical: TextAlignVertical.top,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              alignLabelWithHint: true,
              labelText: 'Cole aqui o Markdown dos cartões',
            ),
          ),
        ),
        const SizedBox(height: 12),
        // The most used decision first, the destructive one last.
        _releaseNowSwitch(),
        _mirrorSwitch(),
        FilledButton(
          onPressed: () => _viewModel.parse(_controller.text),
          child: const Text('Conferir antes de importar'),
        ),
      ],
    );
  }

  Widget _releaseNowSwitch() {
    return ValueListenableBuilder<bool>(
      valueListenable: _viewModel.releaseNow,
      builder: (context, enabled, _) => SwitchListTile(
        contentPadding: EdgeInsets.zero,
        value: enabled,
        onChanged: (value) => _viewModel.setReleaseNow(enabled: value),
        title: const Text('Liberar para estudo agora'),
        subtitle: const Text(
          'Os cartões novos entram na fila de revisão de hoje. Desligado, eles '
          'são liberados aos poucos, cerca de 20 por dia.',
        ),
      ),
    );
  }

  Widget _mirrorSwitch() {
    return ValueListenableBuilder<bool>(
      valueListenable: _viewModel.mirror,
      builder: (context, enabled, _) => SwitchListTile(
        contentPadding: EdgeInsets.zero,
        value: enabled,
        onChanged: (value) => _viewModel.setMirror(enabled: value),
        title: const Text('O arquivo é a coleção inteira'),
        subtitle: const Text(
          'Apaga os cartões que não estiverem no texto, com o histórico deles. '
          'A prévia lista quais antes de confirmar.',
        ),
      ),
    );
  }

  Widget _preview(
    BuildContext context, {
    required ImportPreview preview,
    required ImportOutcome outcome,
    required double firmRatio,
    required bool warnBelowThreshold,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(child: PreviewList(preview: preview, outcome: outcome)),
        const SizedBox(height: 12),
        if (warnBelowThreshold)
          IntakeWarning(
            firmRatio: firmRatio,
            onImportAnyway: () => _confirmImport(outcome),
            onCancel: _backToEditing,
          )
        else
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: _backToEditing,
                child: const Text('Voltar'),
              ),
              const SizedBox(width: 8),
              FilledButton(
                onPressed: () => _confirmImport(outcome),
                child: Text(
                  outcome.removed.isEmpty
                      ? 'Importar'
                      : 'Importar e apagar ${outcome.removed.length}',
                ),
              ),
            ],
          ),
      ],
    );
  }

  Widget _done(
    BuildContext context, {
    required int created,
    required int updated,
    required int removed,
    required bool released,
  }) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.check_circle_outline, size: 48),
          const SizedBox(height: 12),
          Text(
            '$created cartão(ões) novo(s) e $updated atualizado(s).'
            '${removed == 0 ? '' : ' $removed apagado(s).'}',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          // Reads the state, not the switch: the notifier can change after the
          // import, and this screen reports what actually happened.
          Text(
            released
                ? 'Os $created cartão(ões) novo(s) já estão na fila de revisão '
                    'de hoje.'
                : 'Os cartões entram na coleção agora e são liberados aos '
                    'poucos, todo dia, para a fila de revisão não estourar.',
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: () {
              _controller.clear();
              _viewModel.reset();
            },
            child: const Text('Importar mais'),
          ),
        ],
      ),
    );
  }

  Widget _error(BuildContext context, String message) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.error_outline,
            size: 48,
            color: Theme.of(context).colorScheme.error,
          ),
          const SizedBox(height: 12),
          Text(message, textAlign: TextAlign.center),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: _viewModel.reset,
            child: const Text('Voltar'),
          ),
        ],
      ),
    );
  }
}
