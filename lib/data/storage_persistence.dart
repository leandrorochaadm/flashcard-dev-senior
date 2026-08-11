import 'dart:js_interop';

import 'package:web/web.dart' as web;

/// Asks the browser to mark the storage as persistent.
///
/// No guarantee, but it sharply reduces the chance of IndexedDB being evicted
/// under disk pressure — risk 2, whose only real protection is the manual
/// backup of H14. It is a browser API, not a database one, so it stays outside
/// the sembast adapter.
Future<bool> requestPersistentStorage() async {
  try {
    final storage = web.window.navigator.storage;
    return (await storage.persist().toDart).toDart;
  } catch (_) {
    // Browsers without the API simply do not support the request.
    return false;
  }
}
