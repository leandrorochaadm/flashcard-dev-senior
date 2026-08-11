import 'dart:async';
import 'dart:js_interop';

import 'package:web/web.dart' as web;

/// Opens the browser's file dialog and reads the chosen file as text.
///
/// Chrome is the only target platform, so there is no plugin here: a hidden
/// `<input type="file">` plus a `FileReader` is all the requirement needs, and
/// it keeps the app free of native code (which Flutter Web could not load).
///
/// Returns `null` when the dialog is dismissed or the file cannot be read.
Future<String?> pickTextFile({String accept = '.md,.txt,text/plain'}) {
  final completer = Completer<String?>();
  final input = web.document.createElement('input') as web.HTMLInputElement
    ..type = 'file'
    ..accept = accept;

  input.onchange = ((web.Event _) {
    final files = input.files;
    final file = (files == null || files.length == 0) ? null : files.item(0);
    if (file == null) {
      if (!completer.isCompleted) completer.complete(null);
      return;
    }
    final reader = web.FileReader();
    reader.onload = ((web.Event _) {
      final result = reader.result;
      if (!completer.isCompleted) {
        completer.complete(result.isA<JSString>() ? (result! as JSString).toDart : null);
      }
    }).toJS;
    reader.onerror = ((web.Event _) {
      if (!completer.isCompleted) completer.complete(null);
    }).toJS;
    reader.readAsText(file);
  }).toJS;

  input.click();
  return completer.future;
}
