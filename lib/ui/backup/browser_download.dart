import 'dart:js_interop';

import 'package:web/web.dart' as web;

/// Hands a text file to the browser's download flow.
///
/// There is no `dart:io` on Flutter Web, so the file is a Blob behind an
/// object URL clicked through a detached anchor. This is the last step of the
/// export and it belongs to the View, never to the ViewModel.
void downloadTextFile({required String fileName, required String contents}) {
  final blob = web.Blob(
    <JSAny>[contents.toJS].toJS,
    web.BlobPropertyBag(type: 'application/json'),
  );
  final url = web.URL.createObjectURL(blob);
  final anchor = web.document.createElement('a') as web.HTMLAnchorElement
    ..href = url
    ..download = fileName;
  anchor.click();
  web.URL.revokeObjectURL(url);
}
