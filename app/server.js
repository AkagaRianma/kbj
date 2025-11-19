const express = require('express');
const http = require('http');
const path = require('path');
const WebSocket = require('ws');
const { Pool } = require('pg');

const app = express();
const server = http.createServer(app);
const wss = new WebSocket.Server({ server, path: '/ws' });

const PORT = process.env.PORT || 3000;

// ====== DB POOL ======
const pool = new Pool({
  host: process.env.DB_HOST || '127.0.0.1',
  port: process.env.DB_PORT || 5432,
  user: process.env.DB_USER || 'kbjuser',
  password: process.env.DB_PASS || 'kbjpass',
  database: process.env.DB_NAME || 'kbj_db'
});

// hardcode user id per requirement
const FIXED_USER_ID = 1;

// ====== SQL HELPERS ======
async function loadSeedForUser(userId) {
  // Ambil unit milik user
  const units = await pool.query(
    `SELECT id_unit FROM unit_user WHERE id_user = $1`,
    [userId]
  );
  const unitIds = units.rows.map(r => r.id_unit);
  if (unitIds.length === 0) {
    return { kunjungan: [], pasienMap: {}, soapi: [] };
  }
  const kunj = await pool.query(
    `SELECT k.id AS id_kunjungan, k.id_unit, k.no_rm, k.waktu_masuk, k.waktu_keluar,
            p.nama, p.alamat
     FROM kunjungan k
     JOIN pasien p ON p.no_rm = k.no_rm
     WHERE k.id_unit = ANY($1)
       AND k.waktu_masuk::date = CURRENT_DATE
     ORDER BY p.nama ASC`,
    [unitIds]
  );

  const noRMs = [...new Set(kunj.rows.map(r => r.no_rm))];
  let soapiRows = [];
  if (noRMs.length > 0) {
    const s = await pool.query(
      `SELECT s.id_soapi, s.id_user, s.id_kunjungan, s.waktu_dibuat, s.waktu_dokumen,
              s.s, s.o, s.a, s.p, s.i, s.aktif, k.no_rm
       FROM soapi s
       JOIN kunjungan k ON k.id = s.id_kunjungan
       WHERE k.no_rm = ANY($1)
       AND s.aktif = true
       ORDER BY s.waktu_dokumen DESC, s.id_soapi DESC`,
      [noRMs]
    );
    soapiRows = s.rows;
  }

  return {
    kunjungan: kunj.rows,
    soapi: soapiRows
  };
}

async function insertSoapi({ id_kunjungan, s, o, a, p, i, id_user = FIXED_USER_ID, waktu_dokumen }) {
  const fields = { s, o, a, p, i };
  for (const [k, v] of Object.entries(fields)) {
    if (typeof v !== 'string' || v.trim() === '') {
      const err = new Error(`Field ${k} tidak boleh kosong`);
      err.code = 'VALIDATION';
      throw err;
    }
  }

  const hasOverride = !!waktu_dokumen;
  const sql = hasOverride
    ? `INSERT INTO soapi (id_user, id_kunjungan, s, o, a, p, i, aktif, waktu_dokumen)
       VALUES ($1,$2,$3,$4,$5,$6,$7,false,$8)
       RETURNING id_soapi, id_user, id_kunjungan, waktu_dibuat, waktu_dokumen, s, o, a, p, i, aktif`
    : `INSERT INTO soapi (id_user, id_kunjungan, s, o, a, p, i, aktif)
       VALUES ($1,$2,$3,$4,$5,$6,$7,false)
       RETURNING id_soapi, id_user, id_kunjungan, waktu_dibuat, waktu_dokumen, s, o, a, p, i, aktif`;

  const params = hasOverride
    ? [id_user, id_kunjungan, s.trim(), o.trim(), a.trim(), p.trim(), i.trim(), new Date(waktu_dokumen)]
    : [id_user, id_kunjungan, s.trim(), o.trim(), a.trim(), p.trim(), i.trim()];

  const q = await pool.query(sql, params);
  const output = await pool.query(
      `SELECT s.id_soapi, s.id_user, s.id_kunjungan, s.waktu_dibuat, s.waktu_dokumen,
              s.s, s.o, s.a, s.p, s.i, s.aktif, k.no_rm
       FROM soapi s
       JOIN kunjungan k ON k.id = s.id_kunjungan
       WHERE s.id_soapi = ANY($1)
       ORDER BY s.waktu_dokumen DESC, s.id_soapi DESC`,
      [[q.rows[0].id_soapi]]
    );
  return output.rows[0];
}

// ====== STATIC ======
app.use(express.static(path.join(__dirname, 'public')));
app.use(express.json());

app.post('/api/soapi', async (req, res) => {
  try {
    const body = req.body || {};
    const row = await insertSoapi(body);
    res.json({ ok: true, data: row });
  } catch (e) {
    res.status(400).json({ ok: false, error: e.message || 'error' });
  }
});

// ====== WEBSOCKET ======
wss.on('connection', async (ws) => {
  ws.isAlive = true;
  console.log('[WS] client connected');

  ws.on('pong', () => (ws.isAlive = true));

  try {
    const seed = await loadSeedForUser(FIXED_USER_ID);
    ws.send(JSON.stringify({ type: 'seed', payload: seed }));
    console.log('[WS] seed sent (kunjungan:', seed.kunjungan.length, ', soapi:', seed.soapi.length, ')');
  } catch (e) {
    console.error('[WS] error sending seed:', e);
  }

  ws.on('message', async (raw) => {
    try {
      const msg = JSON.parse(raw.toString());
      if (msg.type === 'soapi.create') {
        try {
          const created = await insertSoapi(msg);
          ws.send(JSON.stringify({
            type: 'soapi.created',
            temp_id: msg.temp_id || null,
            payload: created,
            client_id: msg.client_id || null
          }));
          console.log('[WS] soapi created id=', created.id_soapi);
        } catch (e) {
          ws.send(JSON.stringify({
            type: 'error',
            error: e.code === 'VALIDATION' ? e.message : 'Insert failed',
            client_id: msg.client_id || null
          }));
          console.error('[WS] create error:', e.message);
        }
      }
      if (msg.type === 'soapi.edit') {
        try {
          const created = await insertSoapi({
            id_kunjungan: msg.id_kunjungan,
            s: msg.s, o: msg.o, a: msg.a, p: msg.p, i: msg.i,
            waktu_dokumen: msg.waktu_dokumen_ref 
          });
          ws.send(JSON.stringify({
            type: 'soapi.edit',
            temp_id: msg.temp_id || null,
            payload: created,
            client_id: msg.client_id || null
          }));
          console.log('[WS] soapi EDIT->INSERT id=', created.id_soapi);
        } catch (e) {
          ws.send(JSON.stringify({
            type: 'error',
            error: e.code === 'VALIDATION' ? e.message : 'Insert failed',
            client_id: msg.client_id || null
          }));
          console.error('[WS] edit->insert error:', e.message);
        }
      }
    } catch (e) {
      console.error('[WS] invalid message', e);
    }
  });

  ws.on('close', () => console.log('[WS] client disconnected'));
});

// ping-pong
setInterval(() => {
  wss.clients.forEach((ws) => {
    if (!ws.isAlive) return ws.terminate();
    ws.isAlive = false;
    ws.ping();
  });
}, 30000);

server.listen(PORT, () => {
  console.log(`Server running at http://0.0.0.0:${PORT}`);
});
