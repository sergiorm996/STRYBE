/* STRYBE service worker
   - Archivos propios: se sirven al instante desde caché y se actualizan en segundo plano
     (la versión nueva aparece la siguiente vez que abras la app).
   - Librerías del CDN (versión fijada, no cambian): caché primero.
   Sube CACHE (strybe-vN) cuando cambies este archivo o la lista de librerías. */
const CACHE = 'strybe-v3';

const LOCAL = [
  './', './index.html', './manifest.webmanifest',
  './icon.png', './icon.svg', './icon-192.png', './icon-512.png', './icon-maskable-512.png',
];
const CDN = [
  'https://unpkg.com/react@18.3.1/umd/react.production.min.js',
  'https://unpkg.com/react-dom@18.3.1/umd/react-dom.production.min.js',
  'https://unpkg.com/@babel/standalone@7.26.4/babel.min.js',
];

self.addEventListener('install', e => {
  e.waitUntil((async () => {
    const c = await caches.open(CACHE);
    await c.addAll(LOCAL);
    // El CDN es "mejor esfuerzo": si falla, se cacheará cuando la página lo pida.
    await Promise.all(CDN.map(u =>
      fetch(u, { mode: 'cors' }).then(r => r.ok && c.put(u, r)).catch(() => {})
    ));
    await self.skipWaiting();
  })());
});

self.addEventListener('activate', e => {
  e.waitUntil((async () => {
    const keys = await caches.keys();
    await Promise.all(keys.filter(k => k !== CACHE).map(k => caches.delete(k)));
    await self.clients.claim();
  })());
});

const cacheable = res => res && (res.ok || res.type === 'opaque');

async function put(req, res) {
  try { const c = await caches.open(CACHE); await c.put(req, res); } catch (e) {}
}

// Navegación: responde con el index.html cacheado y lo refresca en segundo plano.
async function handleNavigate(event) {
  const cached = await caches.match('./index.html');
  const network = fetch(event.request).then(res => {
    if (res.ok) put('./index.html', res.clone());
    return res;
  });
  if (cached) {
    event.waitUntil(network.catch(() => {}));
    return cached;
  }
  return network.catch(() => new Response('Sin conexión', { status: 503, headers: { 'Content-Type': 'text/plain; charset=utf-8' } }));
}

// Archivos propios: stale-while-revalidate.
async function handleLocal(event) {
  const cached = await caches.match(event.request, { ignoreSearch: true });
  const network = fetch(event.request).then(res => {
    if (res.ok) put(event.request, res.clone());
    return res;
  });
  if (cached) {
    event.waitUntil(network.catch(() => {}));
    return cached;
  }
  return network;
}

// Terceros (CDN, Google Fonts): caché primero.
async function handleRemote(event) {
  const cached = await caches.match(event.request);
  if (cached) return cached;
  const res = await fetch(event.request);
  if (cacheable(res)) put(event.request, res.clone());
  return res;
}

self.addEventListener('fetch', e => {
  const req = e.request;
  if (req.method !== 'GET') return;
  const url = new URL(req.url);
  if (!url.protocol.startsWith('http')) return;
  if (req.mode === 'navigate') { e.respondWith(handleNavigate(e)); return; }
  if (url.origin === self.location.origin) { e.respondWith(handleLocal(e)); return; }
  e.respondWith(handleRemote(e));
});
