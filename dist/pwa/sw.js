// ===============================================================
// CHRONOS IDE — SERVICE WORKER PWA OFFLINE (Zero-Dependencies)
// Caching Estratégico de Shell, Memoria Plana WASM (64 KB) y Canvas
// ===============================================================
const CACHE_NAME = 'phasor-pwa-v1.0.0';
const OFFLINE_URLS = [
  './',
  './index.html',
  './manifest.json',
  './sw.js'
];

// Instalación: Precacheo inmediato de la memoria y el runtime
self.addEventListener('install', function(event) {
  event.waitUntil(
    caches.open(CACHE_NAME).then(function(cache) {
      console.log('[Phasor PWA ServiceWorker] Precaching offline app shell & WASM linear memory');
      return cache.addAll(OFFLINE_URLS);
    }).then(function() {
      return self.skipWaiting();
    })
  );
});

// Activación: Reclamo inmediato de clientes y purga de versiones obsoletas
self.addEventListener('activate', function(event) {
  event.waitUntil(
    caches.keys().then(function(keys) {
      return Promise.all(
        keys.map(function(key) {
          if (key !== CACHE_NAME) {
            console.log('[Phasor PWA ServiceWorker] Purging old cache:', key);
            return caches.delete(key);
          }
        })
      );
    }).then(function() {
      return self.clients.claim();
    })
  );
});

// Fetch: Estrategia Cache-First con fallback a Red y Offline Shell
self.addEventListener('fetch', function(event) {
  if (event.request.method !== 'GET') return;
  event.respondWith(
    caches.match(event.request).then(function(cached) {
      if (cached) {
        return cached;
      }
      return fetch(event.request).then(function(response) {
        if (!response || response.status !== 200 || response.type !== 'basic') {
          return response;
        }
        var responseClone = response.clone();
        caches.open(CACHE_NAME).then(function(cache) {
          cache.put(event.request, responseClone);
        });
        return response;
      }).catch(function() {
        return caches.match('./index.html');
      });
    })
  );
});
