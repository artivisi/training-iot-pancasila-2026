# Server Penampung Data Sensor (FastAPI + Supabase/Postgres)

Menerima data sensor dari ESP32 lewat HTTP POST (JSON), menyimpannya ke database
Postgres yang di-host di **Supabase**, dan menampilkannya di halaman web sederhana.

Supabase = Postgres terkelola. Server ini memakai **connection string Postgres**
Supabase langsung (driver `psycopg`, SQL Postgres mentah) — bukan REST/SDK
Supabase. Jadi kodenya sama persis seperti memakai Postgres biasa; Supabase hanya
yang meng-host database-nya.

## Endpoint

| Method | Path | Fungsi |
|--------|------|--------|
| `POST` | `/api/readings` | Terima 1 data sensor (butuh header `X-API-Key`) |
| `GET`  | `/api/readings?device=&limit=` | Ambil data (JSON) |
| `GET`  | `/` | Dashboard HTML, 50 data terbaru |
| `GET`  | `/docs` | Dokumentasi API otomatis (Swagger UI bawaan FastAPI) |

Body POST:

```json
{ "device": "esp32-grup1", "kind": "fire", "data": { "gas": 1234, "suhu": 30.1 } }
```

Validasi ketat (Pydantic): `device`, `kind` (string non-kosong), dan `data`
(object) wajib ada — kalau kurang/salah tipe server balas `422` dengan detail
field mana yang salah, bukan menyimpan data setengah jadi.

## Siapkan database Supabase

1. Buat project gratis di [supabase.com](https://supabase.com).
2. Buka **Project Settings → Database → Connection string → URI**, salin.
   Pakai mode **Connection pooler** (port `6543`) untuk aplikasi.
3. Ganti `[YOUR-PASSWORD]` di string itu dengan password database project.
   String inilah nilai `DATABASE_URL`.

Tabel `readings` dibuat otomatis saat server pertama kali start. Datanya bisa
dilihat juga lewat **Table Editor** di dashboard Supabase.

## Jalankan lokal (uji dulu)

```sh
cd server
python3 -m venv .venv && . .venv/bin/activate
pip install -r requirements.txt
export API_KEY="$(openssl rand -hex 24)"          # WAJIB; tidak ada default
export DATABASE_URL="postgresql://...supabase..." # WAJIB; dari Supabase
uvicorn app:app --host 0.0.0.0 --port 8000        # http://localhost:8000
```

Uji tanpa ESP32:

```sh
curl -X POST http://localhost:8000/api/readings \
  -H "Content-Type: application/json" -H "X-API-Key: $API_KEY" \
  -d '{"device":"uji","kind":"fire","data":{"gas":1500,"suhu":31.2,"lembap":58}}'
# -> {"id":1,"created_at":"..."}
```

Buka `http://localhost:8000` — data muncul di tabel.

## Deploy di VPS

1. Salin folder `server/` ke VPS, buat venv + install requirements (sama seperti di atas).
2. Buat `.env` dari `.env.example`, isi `API_KEY` (token acak) dan `DATABASE_URL`
   (dari Supabase). Muat: `set -a; . ./.env; set +a`
3. Jalankan dengan gunicorn + uvicorn worker (bukan dev server):

   ```sh
   gunicorn -w 2 -k uvicorn.workers.UvicornWorker -b 127.0.0.1:8000 app:app
   ```

4. Pasang reverse proxy (nginx) di depan gunicorn untuk **HTTPS** (mis. via
   Let's Encrypt). ESP32 bisa POST ke `http://` untuk lab, tapi untuk data
   beneran pakai `https://`.
5. Jadikan service permanen dengan `systemd` (contoh unit di bawah).
6. Buka port HTTP/HTTPS di firewall; **jangan** ekspos port 8000 gunicorn langsung.

Contoh `/etc/systemd/system/sensor.service`:

```ini
[Unit]
Description=Sensor ingest server
After=network.target

[Service]
WorkingDirectory=/opt/sensor/server
EnvironmentFile=/opt/sensor/server/.env
ExecStart=/opt/sensor/server/.venv/bin/gunicorn -w 2 -k uvicorn.workers.UvicornWorker -b 127.0.0.1:8000 app:app
Restart=on-failure

[Install]
WantedBy=multi-user.target
```

## Catatan database

- Database = Postgres di Supabase; query pakai SQL Postgres mentah (`psycopg`,
  placeholder `%s`). Tidak ada ORM.
- Kolom `payload` bertipe `JSONB` — bisa menampung field sensor apa pun tanpa
  ubah skema.
- Self-host Postgres sendiri juga bisa: cukup ganti `DATABASE_URL`, kode tidak berubah.

## Keamanan

- `.env` (token + `DATABASE_URL`) ada di `.gitignore` — jangan di-commit.
- `X-API-Key` adalah otentikasi minimal. Untuk publik, tambah rate limiting +
  HTTPS wajib.
- Jangan pakai connection string `service_role`/admin untuk app ini; cukup user
  database biasa.
