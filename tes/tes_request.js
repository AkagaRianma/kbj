const WebSocket = require('ws');
const readline = require('readline');
const { Pool } = require('pg');

const pool = new Pool({
  host: process.env.DB_HOST || '127.0.0.1',
  port: process.env.DB_PORT || 8888,
  user: process.env.DB_USER || 'kbjuser',
  password: process.env.DB_PASS || 'kbjpass',
  database: process.env.DB_NAME || 'kbj_db'
});

const nowClientISO = () => {
  const parts = new Intl.DateTimeFormat('sv-SE', {
    timeZone: 'Asia/Jakarta',
    year: 'numeric',
    month: '2-digit',
    day: '2-digit',
    hour: '2-digit',
    minute: '2-digit',
    second: '2-digit',
    fractionalSecondDigits: 3
  }).formatToParts(new Date());
  const get = type => parts.find(p => p.type === type)?.value || '';
  const date = `${get('year')}-${get('month')}-${get('day')}`;
  const time = `${get('hour')}:${get('minute')}:${get('second')}.${get('fractionalSecond') || '000'}`;
  return `${date} ${time}`;
};

const rl = readline.createInterface({ input: process.stdin, output: process.stdout });
const ask = (q, d) => new Promise(res => rl.question(`${q}${d ? ` (${d})` : ''}: `, v => res(v.trim() || d)));

(async () => {
  const wsUrl = await ask('WS url', 'ws://localhost/ws');
  const waktuDibuat = await ask('waktu_dibuat (ISO)', nowClientISO());
  const connectionCount = parseInt(await ask('Jumlah koneksi', '10'), 10);
  rl.close();
  
  const last_dok = await pool.query(
    `SELECT id_kunjungan, waktu_dokumen::varchar AS waktu_dokumen
    FROM soapi
    WHERE aktif = true
    ORDER BY waktu_dokumen DESC`
  );

  const idKunjungan = last_dok.rows.length > 0 ? last_dok.rows[0].id_kunjungan : 1;
  const waktuDokumen = last_dok.rows.length > 0 ? last_dok.rows[0].waktu_dokumen : nowClientISO();

  let sent = 0, ok = 0, errs = 0;

  const seedWaiters = [];
  const buildMessage = (connIdx) => ({
    type: 'soapi.edit',
    id_kunjungan: idKunjungan,
    s: `s-${connIdx}`,
    o: `o-${connIdx}`,
    a: `a-${connIdx}`,
    p: `p-${connIdx}`,
    i: `i-${connIdx}`,
    waktu_dokumen_ref: waktuDokumen,
    waktu_dibuat: waktuDibuat,
    temp_id: `temp-${connIdx}-${Date.now()}`,
    client_id: `client-${connIdx}`
  });

  const ready = [];
  for (let i = 0; i < connectionCount; i++) {
    let resolveSeed;
    seedWaiters.push(new Promise(res => { resolveSeed = res; }));
    ready.push(new Promise(resolve => {
      const ws = new WebSocket(wsUrl);
      ws.on('open', () => resolve(ws));
      ws.on('message', data => {
        try {
          const msg = JSON.parse(data.toString());
          if (msg.type === 'seed') resolveSeed();
          if (msg.type === 'error') errs++;
        } catch (_) {}
      });
      ws.on('error', err => console.error(`[${i}] socket error:`, err.message));
    }));
  }

  console.log(`Opening ${connectionCount} connections...`);
  const sockets = await Promise.all(ready);
  console.log('All connections open. Waiting for seed messages...');
  await Promise.all(seedWaiters);
  console.log('All seed messages received. Sending payloads...');

  const batch = [];
  sockets.forEach((ws, connIdx) => {
    batch.push({ ws, payload: buildMessage(connIdx) });
  });
  batch.forEach(({ ws, payload }) => {
    ws.send(JSON.stringify(payload));
    sent++;
  });

  console.log(`Sent ${sent} soapi.edit messages. Waiting for replies...`);
  setTimeout(() => {
    console.log(`Done. Sent=${sent}, errors=${errs}`);
    sockets.forEach(ws => ws.close());
  }, 4000);
})();
