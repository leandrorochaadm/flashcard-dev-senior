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

/// Same as [pickTextFile], but lets the user select several `.md` files at
/// once and reads every one of them.
///
/// Returns an empty list when the dialog is dismissed. A file that fails to
/// read is skipped rather than failing the whole batch — one bad file should
/// not block importing the rest.
Future<List<String>> pickTextFiles({String accept = '.md,.txt,text/plain'}) {
  final completer = Completer<List<String>>();
  final input = web.document.createElement('input') as web.HTMLInputElement
    ..type = 'file'
    ..accept = accept
    ..multiple = true;

  input.onchange = ((web.Event _) {
    final files = input.files;
    if (files == null || files.length == 0) {
      if (!completer.isCompleted) completer.complete(const []);
      return;
    }

    final contents = List<String?>.filled(files.length, null);
    var remaining = files.length;

    void checkDone() {
      remaining--;
      if (remaining == 0 && !completer.isCompleted) {
        completer.complete([for (final c in contents) ?c]);
      }
    }

    for (var i = 0; i < files.length; i++) {
      final file = files.item(i);
      if (file == null) {
        checkDone();
        continue;
      }
      final reader = web.FileReader();
      final index = i;
      reader.onload = ((web.Event _) {
        final result = reader.result;
        contents[index] = result.isA<JSString>() ? (result! as JSString).toDart : null;
        checkDone();
      }).toJS;
      reader.onerror = ((web.Event _) => checkDone()).toJS;
      reader.readAsText(file);
    }
  }).toJS;

  input.click();
  return completer.future;
}
