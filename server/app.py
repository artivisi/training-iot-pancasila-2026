"""Server penampung data sensor IoT — FastAPI + Supabase (Postgres).

ESP32 mengirim data lewat HTTP POST (JSON) ke /api/readings. Server memvalidasi
lalu meng-INSERT ke database Postgres yang di-host di Supabase. Halaman /
menampilkan data terbaru.

Supabase = Postgres terkelola. Server ini memakai connection string Postgres-nya
langsung (driver psycopg, SQL Postgres mentah) — BUKAN lewat REST/SDK Supabase.
Jadi kodenya sama persis seperti memakai Postgres biasa.

Jalankan:
    export API_KEY="token-acak-panjang"        # WAJIB, tidak ada default
    export DATABASE_URL="postgresql://..."     # WAJIB, ambil dari Supabase
    pip install -r requirements.txt
    uvicorn app:app --host 0.0.0.0 --port 8000     # dev
Produksi (VPS): gunicorn + uvicorn worker + reverse proxy (lihat README.md).

Prinsip: tidak ada nilai default tersembunyi. Field kurang / salah tipe -> error
422 eksplisit (validasi Pydantic), bukan disimpan dengan angka asal-asalan.
"""

import hmac
import html
import json
import os
from contextlib import asynccontextmanager
from typing import Any

from fastapi import Depends, FastAPI, Header, HTTPException
from fastapi.responses import HTMLResponse
from psycopg.types.json import Jsonb
from psycopg_pool import ConnectionPool
from pydantic import BaseModel, Field

# --- Konfigurasi WAJIB lewat environment (tidak ada default tersembunyi) ---
API_KEY = os.environ.get("API_KEY")
if not API_KEY:
    raise RuntimeError(
        "Environment variable API_KEY belum di-set. "
        'Contoh: export API_KEY="$(openssl rand -hex 24)"'
    )

# Connection string Postgres dari Supabase (Project Settings -> Database ->
# Connection string -> URI). Tanpa ini server menolak jalan.
DATABASE_URL = os.environ.get("DATABASE_URL")
if not DATABASE_URL:
    raise RuntimeError(
        "Environment variable DATABASE_URL belum di-set. Ambil dari Supabase: "
        "Project Settings -> Database -> Connection string (URI)."
    )

SCHEMA = """
CREATE TABLE IF NOT EXISTS readings (
    id         BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    device     TEXT NOT NULL,
    kind       TEXT NOT NULL,
    payload    JSONB NOT NULL,                       -- field-field sensor
    created_at TIMESTAMPTZ NOT NULL DEFAULT now()    -- waktu diisi server (UTC)
);
CREATE INDEX IF NOT EXISTS idx_readings_device ON readings(device);
"""

# Pool koneksi Postgres. open=False -> dibuka saat startup (lifespan), bukan saat
# import, supaya error koneksi muncul jelas di log startup.
pool = ConnectionPool(DATABASE_URL, min_size=1, max_size=4, open=False)


@asynccontextmanager
async def lifespan(app: FastAPI):
    pool.open()
    with pool.connection() as conn:
        conn.execute(SCHEMA)  # buat tabel kalau belum ada
    yield
    pool.close()


app = FastAPI(title="Server Data Sensor IoT", lifespan=lifespan)


def require_api_key(x_api_key: str = Header(default="")):
    """Bandingkan header X-API-Key dengan API_KEY. compare_digest = tahan timing attack."""
    if not hmac.compare_digest(x_api_key, API_KEY):
        raise HTTPException(status_code=401, detail="X-API-Key salah atau tidak ada")


class Reading(BaseModel):
    # Tidak ada default -> ketiga field WAJIB. Pydantic menolak (422) kalau
    # kurang atau salah tipe. min_length=1 menolak string kosong.
    device: str = Field(min_length=1)
    kind: str = Field(min_length=1)
    data: dict[str, Any]


@app.post("/api/readings", status_code=201, dependencies=[Depends(require_api_key)])
def ingest(reading: Reading):
    with pool.connection() as conn:
        row = conn.execute(
            "INSERT INTO readings (device, kind, payload) VALUES (%s, %s, %s) "
            "RETURNING id, created_at",
            (reading.device, reading.kind, Jsonb(reading.data)),
        ).fetchone()
    return {"id": row[0], "created_at": row[1].isoformat()}


@app.get("/api/readings")
def list_readings(device: str | None = None, limit: int = 50):
    limit = max(1, min(limit, 500))
    sql = "SELECT id, device, kind, payload, created_at FROM readings"
    params: list[Any] = []
    if device:
        sql += " WHERE device = %s"
        params.append(device)
    sql += " ORDER BY id DESC LIMIT %s"
    params.append(limit)

    with pool.connection() as conn:
        rows = conn.execute(sql, params).fetchall()
    # payload kolom JSONB -> psycopg mengembalikannya sebagai dict Python.
    return [
        {"id": r[0], "device": r[1], "kind": r[2], "payload": r[3],
         "created_at": r[4].isoformat()}
        for r in rows
    ]


PAGE = """<!doctype html><meta charset="utf-8">
<title>Data Sensor IoT</title>
<style>
  body {{ font-family: system-ui, sans-serif; margin: 2rem; color: #1e293b; }}
  h1 {{ color: #1e3a8a; }}
  table {{ border-collapse: collapse; width: 100%; font-size: 0.9rem; }}
  th {{ background: #1e3a8a; color: #fff; text-align: left; padding: 0.5rem 0.8rem; }}
  td {{ padding: 0.5rem 0.8rem; border-bottom: 1px solid #e2e8f0; }}
  tr:nth-child(even) td {{ background: #f8fafc; }}
  code {{ font-family: ui-monospace, monospace; }}
</style>
<h1>Data Sensor IoT</h1>
<p>{count} data terbaru.</p>
<table>
  <tr><th>ID</th><th>Device</th><th>Kind</th><th>Payload</th><th>Waktu (UTC)</th></tr>
  {rows}
</table>
"""


@app.get("/", response_class=HTMLResponse)
def dashboard():
    with pool.connection() as conn:
        rows = conn.execute(
            "SELECT id, device, kind, payload, created_at FROM readings "
            "ORDER BY id DESC LIMIT 50"
        ).fetchall()
    trs = "".join(
        "<tr>"
        f"<td>{r[0]}</td><td>{html.escape(r[1])}</td><td>{html.escape(r[2])}</td>"
        f"<td><code>{html.escape(json.dumps(r[3], ensure_ascii=False))}</code></td>"
        f"<td>{r[4].isoformat()}</td>"
        "</tr>"
        for r in rows
    )
    return PAGE.format(count=len(rows), rows=trs)
