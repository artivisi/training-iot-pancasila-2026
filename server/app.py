"""Server penampung data sensor IoT — Flask + SQLite.

ESP32 mengirim data lewat HTTP POST (JSON) ke /api/readings, server memvalidasi
lalu menyimpannya ke database SQLite. Halaman / menampilkan data terbaru.

Jalankan:
    export API_KEY="token-acak-panjang"        # WAJIB, tidak ada default
    pip install -r requirements.txt
    python app.py                              # dev, http://0.0.0.0:5000
Produksi (VPS): pakai gunicorn + reverse proxy (lihat README.md).

Prinsip: tidak ada nilai default tersembunyi. Field yang kurang -> error 400
eksplisit, bukan diisi angka asal-asalan.
"""

import hmac
import json
import os
import sqlite3
from datetime import datetime, timezone

from flask import Flask, g, jsonify, render_template_string, request

DB_PATH = os.environ.get("DB_PATH", "sensor.db")

# API_KEY wajib di-set lewat environment. Tanpa ini server tidak boleh jalan
# (bukan diberi token default yang tidak aman).
API_KEY = os.environ.get("API_KEY")
if not API_KEY:
    raise RuntimeError(
        "Environment variable API_KEY belum di-set. "
        "Contoh: export API_KEY=\"$(openssl rand -hex 24)\""
    )

app = Flask(__name__)

SCHEMA = """
CREATE TABLE IF NOT EXISTS readings (
    id         INTEGER PRIMARY KEY AUTOINCREMENT,
    device     TEXT NOT NULL,
    kind       TEXT NOT NULL,
    payload    TEXT NOT NULL,   -- JSON field-field sensor
    created_at TEXT NOT NULL    -- waktu UTC, diisi server
);
CREATE INDEX IF NOT EXISTS idx_readings_device ON readings(device);
"""


def get_db():
    if "db" not in g:
        g.db = sqlite3.connect(DB_PATH)
        g.db.row_factory = sqlite3.Row
        g.db.execute("PRAGMA journal_mode=WAL;")  # aman untuk akses paralel
    return g.db


@app.teardown_appcontext
def close_db(exc):
    db = g.pop("db", None)
    if db is not None:
        db.close()


def init_db():
    db = sqlite3.connect(DB_PATH)
    db.executescript(SCHEMA)
    db.close()


def authorized(req):
    """Bandingkan X-API-Key dengan API_KEY. compare_digest = tahan timing attack."""
    sent = req.headers.get("X-API-Key", "")
    return hmac.compare_digest(sent, API_KEY)


@app.post("/api/readings")
def ingest():
    if not authorized(request):
        return jsonify(error="X-API-Key salah atau tidak ada"), 401

    # Body harus JSON valid. silent=True -> None kalau bukan JSON, kita tolak.
    body = request.get_json(silent=True)
    if not isinstance(body, dict):
        return jsonify(error="Body harus JSON object"), 400

    device = body.get("device")
    kind = body.get("kind")
    data = body.get("data")
    # Validasi eksplisit — tidak ada default.
    if not isinstance(device, str) or not device:
        return jsonify(error="field 'device' (string) wajib"), 400
    if not isinstance(kind, str) or not kind:
        return jsonify(error="field 'kind' (string) wajib"), 400
    if not isinstance(data, dict):
        return jsonify(error="field 'data' (object) wajib"), 400

    created_at = datetime.now(timezone.utc).isoformat()
    db = get_db()
    cur = db.execute(
        "INSERT INTO readings (device, kind, payload, created_at) VALUES (?, ?, ?, ?)",
        (device, kind, json.dumps(data), created_at),
    )
    db.commit()
    return jsonify(id=cur.lastrowid, created_at=created_at), 201


@app.get("/api/readings")
def list_readings():
    device = request.args.get("device")
    try:
        limit = int(request.args.get("limit", "50"))
    except ValueError:
        return jsonify(error="limit harus angka"), 400
    limit = max(1, min(limit, 500))

    sql = "SELECT id, device, kind, payload, created_at FROM readings"
    params = []
    if device:
        sql += " WHERE device = ?"
        params.append(device)
    sql += " ORDER BY id DESC LIMIT ?"
    params.append(limit)

    rows = get_db().execute(sql, params).fetchall()
    return jsonify([
        {**dict(r), "payload": json.loads(r["payload"])} for r in rows
    ])


PAGE = """<!doctype html><meta charset="utf-8">
<title>Data Sensor IoT</title>
<style>
  body { font-family: system-ui, sans-serif; margin: 2rem; color: #1e293b; }
  h1 { color: #1e3a8a; }
  table { border-collapse: collapse; width: 100%; font-size: 0.9rem; }
  th { background: #1e3a8a; color: #fff; text-align: left; padding: 0.5rem 0.8rem; }
  td { padding: 0.5rem 0.8rem; border-bottom: 1px solid #e2e8f0; }
  tr:nth-child(even) td { background: #f8fafc; }
  code { font-family: ui-monospace, monospace; }
</style>
<h1>Data Sensor IoT</h1>
<p>{{ rows|length }} data terbaru.</p>
<table>
  <tr><th>ID</th><th>Device</th><th>Kind</th><th>Payload</th><th>Waktu (UTC)</th></tr>
  {% for r in rows %}
  <tr>
    <td>{{ r["id"] }}</td><td>{{ r["device"] }}</td><td>{{ r["kind"] }}</td>
    <td><code>{{ r["payload"] }}</code></td><td>{{ r["created_at"] }}</td>
  </tr>
  {% endfor %}
</table>
"""


@app.get("/")
def dashboard():
    rows = get_db().execute(
        "SELECT id, device, kind, payload, created_at FROM readings ORDER BY id DESC LIMIT 50"
    ).fetchall()
    return render_template_string(PAGE, rows=rows)


if __name__ == "__main__":
    init_db()
    # Port bisa diubah lewat env PORT. Di macOS port 5000 sering dipakai
    # "AirPlay Receiver" (balas 403) -> pakai PORT lain, mis. 5055.
    port = int(os.environ.get("PORT", "5000"))
    app.run(host="0.0.0.0", port=port)
