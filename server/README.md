# Server Penampung Data Sensor (Flask + SQLite)

Menerima data sensor dari ESP32 lewat HTTP POST (JSON), menyimpannya ke SQLite,
dan menampilkannya di halaman web sederhana.

## Endpoint

| Method | Path | Fungsi |
|--------|------|--------|
| `POST` | `/api/readings` | Terima 1 data sensor (butuh header `X-API-Key`) |
| `GET`  | `/api/readings?device=&limit=` | Ambil data (JSON) |
| `GET`  | `/` | Dashboard HTML, 50 data terbaru |

Body POST:

```json
{ "device": "esp32-grup1", "kind": "fire", "data": { "gas": 1234, "suhu": 30.1 } }
```

Validasi ketat: `device`, `kind` (string), dan `data` (object) wajib ada — kalau
kurang server balas `400`, bukan menyimpan data setengah jadi.

## Jalankan lokal (uji dulu)

```sh
cd server
python3 -m venv .venv && . .venv/bin/activate
pip install -r requirements.txt
export API_KEY="$(openssl rand -hex 24)"   # WAJIB; tidak ada default
python app.py                              # http://localhost:5000
```

Uji tanpa ESP32:

```sh
curl -X POST http://localhost:5000/api/readings \
  -H "Content-Type: application/json" -H "X-API-Key: $API_KEY" \
  -d '{"device":"uji","kind":"fire","data":{"gas":1500,"suhu":31.2,"lembap":58}}'
# -> {"created_at":"...","id":1}
```

Buka `http://localhost:5000` — data muncul di tabel.

## Deploy di VPS

1. Salin folder `server/` ke VPS, buat venv + install requirements (sama seperti di atas).
2. Buat `.env` dari `.env.example`, isi `API_KEY` dengan token acak. Muat:
   `set -a; . ./.env; set +a`
3. Jalankan dengan gunicorn (bukan dev server):

   ```sh
   gunicorn -w 2 -b 127.0.0.1:5000 app:app
   ```

4. Pasang reverse proxy (nginx) di depan gunicorn untuk **HTTPS** (mis. via
   Let's Encrypt). ESP32 bisa POST ke `http://` untuk lab, tapi untuk data
   beneran pakai `https://`.
5. Jadikan service permanen dengan `systemd` (contoh unit di bawah).
6. Buka port HTTP/HTTPS di firewall; **jangan** ekspos port 5000 gunicorn langsung.

Contoh `/etc/systemd/system/sensor.service`:

```ini
[Unit]
Description=Sensor ingest server
After=network.target

[Service]
WorkingDirectory=/opt/sensor/server
EnvironmentFile=/opt/sensor/server/.env
ExecStart=/opt/sensor/server/.venv/bin/gunicorn -w 2 -b 127.0.0.1:5000 app:app
Restart=on-failure

[Install]
WantedBy=multi-user.target
```

## Ganti ke PostgreSQL/MySQL

SQLite cukup untuk skala lab. Untuk produksi/beberapa device aktif, ganti
`sqlite3` dengan driver Postgres (`psycopg`) atau MySQL: ubah `get_db()` dan
placeholder query (`?` → `%s`). Skema tabel sama.

## Keamanan

- `.env` (token) ada di `.gitignore` — jangan di-commit.
- File `*.db` juga di-ignore (berisi data, bisa besar).
- `X-API-Key` adalah otentikasi minimal. Untuk publik, tambah rate limiting +
  HTTPS wajib.
