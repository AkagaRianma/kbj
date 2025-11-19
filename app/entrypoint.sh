#!/bin/bash
set -e

DB_USER=${DB_USER:-kbjuser}
DB_PASS=${DB_PASS:-kbjpass}
DB_NAME=${DB_NAME:-kbj_db}

# --- locate postgres binaries robustly ---
find_initdb() {
  if command -v initdb >/dev/null 2>&1; then command -v initdb; return; fi
  for f in /usr/lib/postgresql/*/bin/initdb; do
    [ -x "$f" ] && echo "$f" && return
  done
}
INITDB_BIN="$(find_initdb || true)"
if [ -z "$INITDB_BIN" ]; then
  echo "[ERROR] initdb not found. Is PostgreSQL installed?"
  exit 1
fi
PG_BIN_DIR="$(dirname "$INITDB_BIN")"
PG_CTL_BIN="$PG_BIN_DIR/pg_ctl"
PSQL_BIN="$PG_BIN_DIR/psql"

echo "[INFO] Using:"
echo "  initdb: $INITDB_BIN"
echo "  pg_ctl: $PG_CTL_BIN"
echo "  psql  : $PSQL_BIN"

echo "[INIT] PGDATA: $PGDATA"

# Init database if missing
if [ ! -s "$PGDATA/PG_VERSION" ]; then
  echo "[INIT] Initializing PostgreSQL at $PGDATA"
  su -s /bin/bash postgres -c "$INITDB_BIN -D $PGDATA -E UTF8"
fi

echo "[INIT] Starting PostgreSQL..."
su -s /bin/bash postgres -c "$PG_CTL_BIN -D $PGDATA -o \"-c listen_addresses='*' -p 5432\" -w start"

echo "[INIT] Ensuring role & database..."
# Create role if missing
su -s /bin/bash postgres -c "$PSQL_BIN -p 5432 -d postgres -tAc \"SELECT 1 FROM pg_roles WHERE rolname='${DB_USER}'\"" | grep -q 1 || \
  su -s /bin/bash postgres -c "$PSQL_BIN -p 5432 -d postgres -c \"CREATE USER ${DB_USER} WITH PASSWORD '${DB_PASS}';\""

# Create DB if missing
su -s /bin/bash postgres -c "$PSQL_BIN -p 5432 -d postgres -tAc \"SELECT 1 FROM pg_database WHERE datname='${DB_NAME}'\"" | grep -q 1 || \
  su -s /bin/bash postgres -c "$PSQL_BIN -p 5432 -d postgres -c \"CREATE DATABASE ${DB_NAME} OWNER ${DB_USER};\""

echo "[INIT] Running Node.js app..."
npm install --omit=dev
npx nodemon server.js &
NODE_PID=$!

shutdown() {
  echo "[SHUTDOWN] Stopping Node and PostgreSQL"
  kill "$NODE_PID" 2>/dev/null || true
  su -s /bin/bash postgres -c "$PG_CTL_BIN -D $PGDATA -m fast stop"
  exit 0
}
trap shutdown SIGTERM SIGINT

wait "$NODE_PID"
