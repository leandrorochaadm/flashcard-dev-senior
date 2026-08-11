'use strict';

// Offline support for the PWA.
//
// WHY THIS FILE EXISTS
//
// Flutter used to ship a caching service worker. As of 3.44 the generated
// `flutter_service_worker.js` unregisters itself on activate and caches
// nothing — the bundle even labels it "deprecated and will be removed in a
// future Flutter release". So `tool/build_web.sh` passes `--pwa-strategy=none`
// to stop Flutter registering anything, and `index.html` registers this file
// instead.
//
// Offline is a product requirement, not a nicety: the whole point is studying
// on a commute. The study data already survives offline in IndexedDB — what
// was missing was the app shell that reads it.
//
// CACHE NAME CARRIES THE BUILD
//
// `tool/build_web.sh` replaces the placeholder below with the build number the
// pre-push hook bumps. A new build therefore opens a new cache and drops the
// old one wholesale, which avoids the classic half-updated bundle: a new
// main.dart.js paired with a stale asset manifest.
const BUILD_ID = '{{BUILD_ID}}';
const CACHE = `flashcards-${BUILD_ID}`;

// Enough to boot the app with no network on a cold start. Everything else —
// canvaskit, fonts, the asset manifest — is cached as it is first requested,
// because those filenames come from the build and listing them here by hand
// would rot silently.
const SHELL = [
  './',
  'index.html',
  'flutter_bootstrap.js',
  'main.dart.js',
  'flutter.js',
  'manifest.json',
  'favicon.png',
];

self.addEventListener('install', (event) => {
  event.waitUntil(
    (async () => {
      const cache = await caches.open(CACHE);
      // `reload` bypasses the HTTP cache: installing from a stale entry would
      // bake yesterday's bundle into a cache named after today's build.
      await Promise.all(
        SHELL.map((url) =>
          cache
            .add(new Request(url, { cache: 'reload' }))
            .catch(() => {
              // A missing shell file must not abort the install — the app still
              // works online, and the runtime cache picks it up later.
            })
        )
      );
      // No waiting room: an installed PWA is suspended rather than closed, so a
      // worker parked in `waiting` could sit there for days.
      await self.skipWaiting();
    })()
  );
});

self.addEventListener('activate', (event) => {
  event.waitUntil(
    (async () => {
      const names = await caches.keys();
      await Promise.all(
        names
          .filter((name) => name.startsWith('flashcards-') && name !== CACHE)
          .map((name) => caches.delete(name))
      );
      await self.clients.claim();

      // Tell the open pages that the new bundle is in place. Only now is a
      // reload safe: reloading earlier would pair a fresh index.html with the
      // previous build's main.dart.js, still being served from the old cache.
      const clients = await self.clients.matchAll({ type: 'window' });
      for (const client of clients) {
        client.postMessage({ type: 'activated', build: BUILD_ID });
      }
    })()
  );
});

self.addEventListener('fetch', (event) => {
  const request = event.request;

  // Never touch anything but same-origin reads. A POST or a cross-origin call
  // has no business in this cache.
  if (request.method !== 'GET') return;
  const url = new URL(request.url);
  if (url.origin !== self.location.origin) return;

  // version.json is how index.html notices a new build. Serving it from cache
  // would make the app permanently believe it is up to date.
  if (url.pathname.endsWith('version.json')) {
    event.respondWith(fetch(request).catch(() => caches.match(request)));
    return;
  }

  // A navigation is answered from the network when there is one, so a reload
  // always lands on the newest shell, and from the cached shell when there is
  // not — this is the offline entry point.
  if (request.mode === 'navigate') {
    event.respondWith(
      (async () => {
        try {
          return await fetch(request);
        } catch (_) {
          const cache = await caches.open(CACHE);
          return (
            (await cache.match('index.html')) ||
            (await cache.match('./')) ||
            Response.error()
          );
        }
      })()
    );
    return;
  }

  // Everything else: serve from cache, refresh in the background. Fast on a
  // train, and never stale for long — and when the refresh does bring a new
  // build, version.json polling in index.html is what triggers the reload.
  event.respondWith(
    (async () => {
      const cache = await caches.open(CACHE);
      const cached = await cache.match(request);

      const network = fetch(request)
        .then((response) => {
          if (response && response.ok) cache.put(request, response.clone());
          return response;
        })
        .catch(() => null);

      if (cached) return cached;

      const fresh = await network;
      return fresh || Response.error();
    })()
  );
});
