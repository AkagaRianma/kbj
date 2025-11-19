const DB_NAME = 'kbj_soapi_offline';
const DB_VERSION = 1;

function openDb() {
  return new Promise((resolve, reject) => {
    const req = indexedDB.open(DB_NAME, DB_VERSION);
    req.onupgradeneeded = (e) => {
      const db = e.target.result;
      if (!db.objectStoreNames.contains('cache_kunjungan')) {
        db.createObjectStore('cache_kunjungan', { keyPath: 'id_kunjungan' });
      }
      if (!db.objectStoreNames.contains('cache_soapi')) {
        db.createObjectStore('cache_soapi', { keyPath: 'id_soapi' });
      }
      if (!db.objectStoreNames.contains('pending_ops')) {
        db.createObjectStore('pending_ops', { keyPath: 'id' });
      }
    };
    req.onsuccess = (e) => resolve(e.target.result);
    req.onerror = (e) => reject(e.target.error);
  });
}

async function put(store, item) {
  const db = await openDb();
  return new Promise((resolve, reject) => {
    const tx = db.transaction(store, 'readwrite');
    tx.objectStore(store).put(item);
    tx.oncomplete = () => resolve();
    tx.onerror = (e) => reject(e.target.error);
  });
}

async function bulkPut(store, items) {
  const db = await openDb();
  return new Promise((resolve, reject) => {
    const tx = db.transaction(store, 'readwrite');
    const os = tx.objectStore(store);
    items.forEach(it => os.put(it));
    tx.oncomplete = () => resolve();
    tx.onerror = (e) => reject(e.target.error);
  });
}

async function deactiveSoapi(id_kunjungan, waktu_dokumen) {
  const db = await openDb();
  const tx = db.transaction('cache_soapi', 'readwrite');
  const store = tx.objectStore('cache_soapi');

  for (const cursorReq = store.openCursor(); ; ) {
    const cursor = await new Promise((resolve, reject) => {
      cursorReq.onsuccess = e => resolve(e.target.result);
      cursorReq.onerror = e => reject(e.target.error);
    });

    if (!cursor) break;

    const row = cursor.value;
    const cond1 = row.id_kunjungan == id_kunjungan;
    const cond2 = row.waktu_dokumen == waktu_dokumen;

    if (cond1 && cond2) {
      row.aktif = false;

      await new Promise((resolve, reject) => {
        const req = cursor.update(row);
        req.onsuccess = () => resolve();
        req.onerror = e => reject(e.target.error);
      });
    }

    cursor.continue();
  }

  await new Promise((resolve, reject) => {
    tx.oncomplete = () => resolve();
    tx.onerror = e => reject(e.target.error);
  });
}

async function getAll(store) {
  const db = await openDb();
  return new Promise((resolve, reject) => {
    const tx = db.transaction(store, 'readonly');
    const req = tx.objectStore(store).getAll();
    req.onsuccess = () => resolve(req.result || []);
    req.onerror = (e) => reject(e.target.error);
  });
}

async function del(store, key) {
  const db = await openDb();
  return new Promise((resolve, reject) => {
    const tx = db.transaction(store, 'readwrite');
    tx.objectStore(store).delete(key);
    tx.oncomplete = () => resolve();
    tx.onerror = (e) => reject(e.target.error);
  });
}

async function delAll(store) {
  const db = await openDb();
  return new Promise((resolve, reject) => {
    const tx = db.transaction(store, 'readwrite');
    tx.objectStore(store).clear();
    tx.oncomplete = () => resolve();
    tx.onerror = (e) => reject(e.target.error);
  });
}

export const cache = {
  putKunjungan: (arr) => bulkPut('cache_kunjungan', arr),
  getKunjunganAll: () => getAll('cache_kunjungan'),

  putSoapi: (arr) => bulkPut('cache_soapi', arr),
  addSoapi: async (item) => {
    await del('cache_soapi', item.id_soapi);
    return put('cache_soapi', item);
  },
  delSoapi: async (id_soapi) => {
    await del('cache_soapi', id_soapi);
  },
  getSoapiAll: () => getAll('cache_soapi'),
  deactiveOldSoapi: async (id_kunjungan, waktu_dokumen) => deactiveSoapi(id_kunjungan, waktu_dokumen),
  trashAll: async() => {
    await delAll('cache_kunjungan');
    await delAll('cache_soapi');
    await delAll('pending_ops');
  },
};

export const pending = {
  add: async (op) => {
    const id = Date.now() + '-' + Math.random().toString(16).slice(2);
    await put('pending_ops', { id, status: 'queued', created_at: Date.now(), ...op });
    return id;
  },
  all: () => getAll('pending_ops'),
  done: (id) => del('pending_ops', id)
};

