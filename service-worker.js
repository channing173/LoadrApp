const urlsToCache = [
  './index.html',
  './manifest.json',
  './version.json',
  './peter.jpeg'
];

// Helper to get active cache name (fallback to v0.72, must match version.json)
function currentCacheName() {
  return self.CACHE_NAME || 'weight-converter-v0.72';
}

// Install service worker — read version.json to choose cache name
self.addEventListener('install', event => {
  self.skipWaiting();
  event.waitUntil(
    fetch('./version.json', { cache: 'no-store' })
      .then(r => r.json())
      .then(obj => {
        const ver = obj && obj.version ? obj.version : '0.3';
        const CACHE_NAME = `weight-converter-v${ver}`;
        self.CACHE_NAME = CACHE_NAME;
        return caches.open(CACHE_NAME).then(cache => cache.addAll(urlsToCache));
      })
      .catch(() => {
        // fallback to v0.72 (must match version.json)
        const CACHE_NAME = 'weight-converter-v0.72';
        self.CACHE_NAME = CACHE_NAME;
        return caches.open(CACHE_NAME).then(cache => cache.addAll(urlsToCache));
      })
  );
});

// Fetch from cache — use the currently set cache name
self.addEventListener('fetch', event => {
  event.respondWith(
    fetch(event.request)
      .then(fetchResponse => {
        return caches.open(currentCacheName()).then(cache => {
          try { cache.put(event.request, fetchResponse.clone()); } catch (e) { /* ignore */ }
          return fetchResponse;
        });
      })
      .catch(() => caches.match(event.request))
  );
});

// Update service worker: remove old caches that don't match current cache
self.addEventListener('activate', event => {
  event.waitUntil(
    (async () => {
      await clients.claim();
      const cacheNames = await caches.keys();
      const keep = currentCacheName();
      await Promise.all(
        cacheNames.map(name => {
          if (name !== keep) return caches.delete(name);
          return Promise.resolve();
        })
      );
    })()
  );
});
