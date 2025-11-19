// public/service-worker.js
const CACHE = 'kbj-soapi-v2';
const ASSETS = [
  '/',
  '/index.html',
  '/styles.css',
  '/main.js',
  '/db.js',
  '/manifest.json'
];

self.addEventListener('install', (e) => {
  e.waitUntil(caches.open(CACHE).then(c => c.addAll(ASSETS)));
  self.skipWaiting();
});

self.addEventListener('activate', (e) => {
  e.waitUntil(
    caches.keys().then(keys =>
      Promise.all(keys.map(k => (k !== CACHE ? caches.delete(k) : null)))
    )
  );
  self.clients.claim();
});

self.addEventListener('fetch', (e) => {
  const req = e.request;

  if (req.mode === 'navigate') {
    e.respondWith(
      (async () => {
        const cache = await caches.open(CACHE);
        const cached = await cache.match('/index.html'); // fallback utama
        try {
          const resp = await fetch(req);
          return resp;
        } catch {
          return cached;
        }
      })()
    );
    return;
  }

  if (req.method === 'GET') {
    e.respondWith(
      caches.match(req).then(cached => {
        if (cached) return cached;
        return fetch(req).catch(() => cached);
      })
    );
  }
});
