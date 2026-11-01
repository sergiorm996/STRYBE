/* STRYBE service worker
   - Página principal (index.html): primero la red (sin la caché HTTP de GitHub Pages), y si no hay
     conexión o tarda más de 3 s, la copia guardada. Así las versiones nuevas llegan al momento.
   - Resto de archivos propios: copia guardada al instante y se refresca en segundo plano.
   - Librerías del CDN (versión fijada, no cambian): caché primero.
   Sube CACHE (strybe-vN) y STRYBE_VERSION en index.html cada vez que cambies algo. */
const CACHE = 'strybe-v10';
const NAV_TIMEOUT_MS = 3000;

const LOCAL = [
  './', './index.html', './routines.json', './manifest.webmanifest',
  './icon.png', './icon.svg', './icon-192.png', './icon-512.png', './icon-maskable-512.png',
];
const CDN = [
  'https://unpkg.com/react@18.3.1/umd/react.production.min.js',
  'https://unpkg.com/react-dom@18.3.1/umd/react-dom.production.min.js',
  'https://unpkg.com/@babel/standalone@7.26.4/babel.min.js',
  'https://unpkg.com/@supabase/supabase-js@2.45.4/dist/umd/supabase.js',
];

self.addEventListener('install', e => {
  e.waitUntil((async () => {
    const c = await caches.open(CACHE);
    // cache: 'reload' → descarga fresca, ignorando la caché HTTP (max-age=600 de GitHub Pages).
    await c.addAll(LOCAL.map(u => new Request(u, { cache: 'reload' })));
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

// Navegación: red primero (revalidando), con la copia guardada como respaldo.
async function handleNavigate(event) {
  const network = fetch(event.request.url, { cache: 'no-cache', credentials: 'same-origin' }).then(res => {
    if (res.ok) put('./index.html', res.clone());
    return res;
  });
  event.waitUntil(network.catch(() => {}));
  const cached = await caches.match('./index.html');
  if (!cached) {
    return network.catch(() => new Response('Sin conexión', { status: 503, headers: { 'Content-Type': 'text/plain; charset=utf-8' } }));
  }
  const timeout = new Promise(resolve => setTimeout(() => resolve(null), NAV_TIMEOUT_MS));
  try {
    const res = await Promise.race([network, timeout]);
    return res && res.ok ? res : cached;
  } catch (e) {
    return cached; // sin conexión
  }
}

// Archivos propios: copia guardada al instante + revalidación en segundo plano.
async function handleLocal(event) {
  const cached = await caches.match(event.request, { ignoreSearch: true });
  const network = fetch(event.request, { cache: 'no-cache' }).then(res => {
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
  // Nube (Supabase) y peticiones marcadas "no-store": siempre directas a la red, nunca desde caché.
  if (url.hostname.endsWith('.supabase.co') || req.cache === 'no-store') return;
  if (req.mode === 'navigate') { e.respondWith(handleNavigate(e)); return; }
  if (url.origin === self.location.origin) { e.respondWith(handleLocal(e)); return; }
  e.respondWith(handleRemote(e));
});
