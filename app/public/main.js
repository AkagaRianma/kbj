import { cache, pending } from './db.js';

let socket = null;
let isConnected = false;

const statusEl = document.getElementById('status');
const cardsEl = document.getElementById('cards');
const soapiListEl = document.getElementById('soapiList');

const modalEl = document.getElementById('soapiModal');
const bsModal = new bootstrap.Modal(modalEl);
const form = document.getElementById('soapiForm');
const fIdKunj = document.getElementById('form_id_kunjungan');
const fS = document.getElementById('form_s');
const fO = document.getElementById('form_o');
const fA = document.getElementById('form_a');
const fP = document.getElementById('form_p');
const fI = document.getElementById('form_i');

let formMode = 'create';
let editRef = { waktu_dokumen: null };

function log(...args) { console.log('[KBJ]', ...args); }

function setConnected() {
  isConnected = true;
  statusEl.textContent = 'Connected';
  statusEl.classList.remove('bg-danger'); statusEl.classList.add('bg-success');
  log('STATUS Connected');
}

function setOffline() {
  isConnected = false;
  statusEl.textContent = 'Offline';
  statusEl.classList.remove('bg-success'); statusEl.classList.add('bg-danger');
  log('STATUS Offline');
}

function connectWebSocket() {
  if (socket && (socket.readyState === WebSocket.OPEN || socket.readyState === WebSocket.CONNECTING)) return;

  const proto = location.protocol === 'https:' ? 'wss:' : 'ws:';
  socket = new WebSocket(`${proto}//${location.host}/ws`);

  socket.addEventListener('open', () => {
    setConnected();
    flushPending();
  });

  socket.addEventListener('close', () => {
    setOffline();
    if (navigator.onLine) setTimeout(connectWebSocket, 2000);
  });

  socket.addEventListener('error', () => {
    setOffline();
    try { socket.close(); } catch {}
  });

  socket.addEventListener('message', async (ev) => {
    try {
      const msg = JSON.parse(ev.data);
      if (msg.type === 'seed') {
        const { kunjungan, soapi } = msg.payload || { kunjungan: [], soapi: [] };
        log('CLIENT receive seed:', { kunjungan: kunjungan.length, soapi: soapi.length });
        await cache.trashAll();
        await cache.putKunjungan(kunjungan);
        await cache.putSoapi(soapi);
        renderKunjungan(await cache.getKunjunganAll());
      } else if (msg.type === 'soapi.created' || msg.type === 'soapi.edit') {
        const row = msg.payload;
        log('CLIENT receive soapi:', row);
        await cache.deactiveOldSoapi(row.id_kunjungan, row.waktu_dokumen);
        await cache.addSoapi(row);
        await cache.delSoapi(msg.temp_id);
        await pending.done(msg.client_id);
        renderCurrentSoapiList();
      } else if (msg.type === 'error') {
        log('SERVER ERROR for client_id:', msg.client_id, msg.error);
      }
    } catch (e) {
      log('Parse message failed', e);
    }
  });
}

let currentPatient = { no_rm: null, nama: null };

async function renderKunjungan(kunjungan) {
  cardsEl.innerHTML = '';
  kunjungan.forEach(k => {
    const col = document.createElement('div');
    col.className = 'col';
    col.innerHTML = `
      <div class="card h-100 shadow-sm border-0">
        <div class="card-body">
          <div class="small text-muted">No.RM: ${k.no_rm}</div>
          <h6 class="card-title mb-1">${k.nama || '-'}</h6>
          <div class="text-secondary small">${k.alamat || '-'}</div>
        </div>
        <div class="card-footer bg-white border-0 d-flex justify-content-between">
          <button class="btn btn-sm btn-outline-primary" data-action="riwayat" data-no_rm="${k.no_rm}">Riwayat SOAPI</button>
          <button class="btn btn-sm btn-primary" data-action="tambah" data-id_kunjungan="${k.id_kunjungan}" data-no_rm="${k.no_rm}" data-nama="${k.nama||''}">Tambah SOAPI</button>
        </div>
      </div>
    `;
    cardsEl.appendChild(col);
  });
}

cardsEl.addEventListener('click', async (e) => {
  const btn = e.target.closest('button[data-action]');
  if (!btn) return;
  const act = btn.getAttribute('data-action');
  if (act === 'riwayat') {
    const no_rm = btn.getAttribute('data-no_rm');
    await showSoapiForPatient(no_rm);
  } else if (act === 'tambah') {
    const id_kunjungan = parseInt(btn.getAttribute('data-id_kunjungan'), 10);
    openModalTambah(id_kunjungan);
  }
});

soapiListEl.addEventListener('click', (e) => {
  const btn = e.target.closest('button[data-action="edit-soapi"]');
  if (!btn) return;

  const id_kunjungan = parseInt(btn.getAttribute('data-id_kunjungan'), 10);
  const waktu_dokumen = btn.getAttribute('data-waktu_dokumen');
  const s = decodeURIComponent(btn.getAttribute('data-s') || '');
  const o = decodeURIComponent(btn.getAttribute('data-o') || '');
  const a = decodeURIComponent(btn.getAttribute('data-a') || '');
  const p = decodeURIComponent(btn.getAttribute('data-p') || '');
  const i = decodeURIComponent(btn.getAttribute('data-i') || '');

  fIdKunj.value = id_kunjungan;
  fS.value = s; fO.value = o; fA.value = a; fP.value = p; fI.value = i;

  formMode = 'edit';
  editRef.waktu_dokumen = waktu_dokumen;

  bsModal.show();
});


async function showSoapiForPatient(no_rm) {
  currentPatient.no_rm = String(no_rm);
  const all = await cache.getSoapiAll();
  const list = all.filter(s => String(s.no_rm) === String(no_rm));

  soapiListEl.innerHTML = '';
  if (!list.length) {
    soapiListEl.innerHTML = `<div class="text-muted small">Belum ada SOAPI.</div>`;
    return;
  }
  list.forEach(s => {
    if (!s.aktif) return;
    const item = document.createElement('div');
    item.className = 'list-group-item';
    item.innerHTML = `
      <div class="d-flex justify-content-between align-items-start">
      <div><strong>${new Date(s.waktu_dokumen).toLocaleString()}</strong></div>
        <div class="text-end">
          <button class="btn btn-sm btn-outline-secondary mt-1"
            data-action="edit-soapi"
            data-id_soapi="${s.id_soapi}"
            data-id_kunjungan="${s.id_kunjungan}"
            data-waktu_dokumen="${s.waktu_dokumen}"
            data-s="${encodeURIComponent(s.s)}"
            data-o="${encodeURIComponent(s.o)}"
            data-a="${encodeURIComponent(s.a)}"
            data-p="${encodeURIComponent(s.p)}"
            data-i="${encodeURIComponent(s.i)}"
          >Edit</button>
        </div>
      </div>
      <div><b>S:</b> ${s.s}</div>
      <div><b>O:</b> ${s.o}</div>
      <div><b>A:</b> ${s.a}</div>
      <div><b>P:</b> ${s.p}</div>
      <div><b>I:</b> ${s.i}</div>
    `;
    soapiListEl.appendChild(item);
  });
}

async function renderCurrentSoapiList() {
  if (currentPatient.no_rm) await showSoapiForPatient(currentPatient.no_rm);
}

function openModalTambah(id_kunjungan) {
  fIdKunj.value = id_kunjungan;
  fS.value = ''; fO.value = ''; fA.value = ''; fP.value = ''; fI.value = '';
  formMode = 'create';
  editRef.waktu_dokumen = null;
  bsModal.show();
}

form.addEventListener('submit', async (e) => {
  e.preventDefault();

  const temp_id = 'TPM'+ Date.now();

  const basePayload = {
    id_kunjungan: parseInt(fIdKunj.value, 10),
    temp_id : temp_id,
    s: fS.value.trim(), o: fO.value.trim(), a: fA.value.trim(), p: fP.value.trim(), i: fI.value.trim()
  };
  for (const k of ['s','o','a','p','i']) {
    if (!basePayload[k]) { alert(`Kolom ${k.toUpperCase()} wajib diisi.`); return; }
  }

  let payload, kind;
  if (formMode === 'edit') {
    payload = { type: 'soapi.edit', ...basePayload, waktu_dokumen_ref: editRef.waktu_dokumen };
    kind = 'soapi.edit';
  } else {
    payload = { type: 'soapi.create', ...basePayload };
    kind = 'soapi.create';
  }

  const optimistic = {
    id_soapi: temp_id,
    id_user: 1,
    no_rm: currentPatient.no_rm,
    id_kunjungan: basePayload.id_kunjungan,
    waktu_dibuat: new Date().toISOString(),
    waktu_dokumen: (formMode === 'edit' && editRef.waktu_dokumen) ? editRef.waktu_dokumen : new Date().toISOString(),
    s: basePayload.s, o: basePayload.o, a: basePayload.a, p: basePayload.p, i: basePayload.i,
    aktif: true
  };


  const opId = await pending.add({ kind, payload });
  log('CLIENT queue op:', opId, payload);

  if (formMode === 'edit') {
    await cache.deactiveOldSoapi(optimistic.id_kunjungan, editRef.waktu_dokumen);
  }

  await cache.addSoapi(optimistic);
  renderCurrentSoapiList();

  bsModal.hide();

  if (isConnected && socket && socket.readyState === WebSocket.OPEN) {
    try {
      socket.send(JSON.stringify({ ...payload, client_id: opId }));
      log('CLIENT send to server:', { opId, payload });
    } catch (err) {
      log('CLIENT send failed:', err);
    }
  } else {
    log('CLIENT offline, kept pending:', opId);
  }
});

async function flushPending() {
  if (!isConnected || !socket || socket.readyState !== WebSocket.OPEN) return;
  const ops = await pending.all();
  if (!ops.length) { log('FLUSH none'); return; }

  for (const op of ops) {
    if (op.kind === 'soapi.create' || op.kind === 'soapi.edit') {
      try {
        socket.send(JSON.stringify({ ...op.payload, client_id: op.id }));
        log('FLUSH send', op.id);
      } catch (e) {
        log('FLUSH failed', op.id, e);
        break;
      }
    }
  }
}

modalEl.addEventListener('show.bs.modal', () => {
  modalEl.querySelector('.modal-title').textContent =
    (formMode === 'edit') ? 'Edit SOAPI' : 'Tambah SOAPI';
});

window.addEventListener('online', () => {
  log('BROWSER online: try reconnect');
  connectWebSocket();
});
window.addEventListener('offline', () => setOffline());

window.addEventListener('load', async () => {
  setOffline();
  const cachedK = await cache.getKunjunganAll();
  if (cachedK.length) renderKunjungan(cachedK);

  if (navigator.onLine) connectWebSocket();
});

if ('serviceWorker' in navigator) {
  navigator.serviceWorker.register('/service-worker.js').catch(e => console.warn('SW failed', e));
}
