# Pelatihan IoT — STMIK Tazkia × Universitas Pancasila 2026

Materi pelatihan **Internet of Things berbasis ESP32** untuk mahasiswa
Universitas Pancasila. Kegiatan ini berformat **Pengabdian kepada Masyarakat
(PkM)**: pelaksana dosen STMIK Tazkia (Endy Muhardin) + asisten mahasiswa,
mitra Universitas Pancasila, didukung PT ArtiVisi Intermedia.

Dua lab hands-on berjalan **konkuren**:

| Lab | Komponen inti | Konsep |
|-----|---------------|--------|
| **Fire Detector** (mencakup monitoring kualitas udara) | ESP32, MQ-2, flame sensor, DHT11, buzzer, relay | Sensor gas analog, ambang, alert, aktuasi relay |
| **Smart Absensi** | ESP32, RFID RC522, OLED, buzzer | SPI, baca UID kartu, kirim log ke cloud |

Smart Irrigation hanya **didemokan** trainer di sesi penutup (bukan lab peserta).

## Isi Repo

| Path | Untuk siapa | Format |
|------|-------------|--------|
| `docs/index.html` | Instruktur (proyeksi di kelas) | Standalone HTML — buka di browser, dipublikasi via GitHub Pages |
| `workbook/WORKBOOK.typ` + `.pdf` | Peserta & asisten | Typst → PDF. Fundamental + 2 lab. Satu file, dipakai bersama |
| `firmware/fire-detector/` | Lab Fire Detector | Sketch Arduino `.ino` + `secrets.h.example` |
| `firmware/smart-absensi/` | Lab Smart Absensi | Sketch Arduino `.ino` + `secrets.h.example` |
| `workbook/diagrams/*.mmd` | Diagram arsitektur | Mermaid → PNG (via mmdc), di-embed ke workbook & deck |
| `workbook/Makefile` | Build pipeline | `make` |

Firmware adalah satu-satunya sumber kode: workbook meng-embed-nya lewat
`read()`, jadi tidak ada duplikasi kode antara workbook dan `.ino`.

## Build

### Workbook (Typst ≥ 0.14)

```sh
brew install typst        # sekali saja
cd workbook
make                      # generate WORKBOOK.pdf + salin ke ../docs
make watch                # live recompile
make diagrams             # re-render Mermaid kalau .mmd diubah
make clean
```

Diagram Mermaid sudah ter-commit sebagai `.png`. Re-render hanya perlu kalau
mengubah `.mmd` — butuh `mmdc` + Chrome (path di `diagrams/puppeteer-config.json`).

### Deck

Tidak perlu build — `docs/index.html` single-file HTML:

```sh
open docs/index.html
```

Navigasi: panah/spasi (next), panah kiri (prev), Home/End (loncat).

## Sertifikat Peserta

Sertifikat keikutsertaan (A4 landscape PDF, 1 halaman per peserta) digenerate
dari `certificate/`:

```sh
cd certificate
cp names.txt.example names.txt    # isi nama peserta, satu per baris
make                              # -> certificate.pdf (semua peserta)
make sample                       # -> certificate-sample.pdf (nama placeholder)
```

`names.txt` dan `certificate.pdf` (berisi nama asli) **tidak di-commit** —
data pribadi, repo ini publik. Yang di-commit hanya template + pratinjau
`certificate-sample.pdf`. Edit judul kegiatan/tanggal/nomor di bagian atas
`certificate.typ`. Sertifikat **tidak** dipublikasi ke GitHub Pages.

## GitHub Pages & Download Materi

Repo dipublikasi via **GitHub Pages dari folder `docs/`** (branch `main`).
Seluruh materi yang bisa di-download ada di `docs/` supaya bisa diakses
langsung dari URL Pages:

| Materi | URL (relatif ke Pages) |
|--------|------------------------|
| Deck (slide) | `index.html` |
| Workbook PDF | `WORKBOOK.pdf` |
| Firmware Fire Detector | `firmware/fire-detector.zip` |
| Firmware Smart Absensi | `firmware/smart-absensi.zip` |

Slide **"Materi Download"** di deck menaut ke file-file ini. PDF & zip
di-generate `make` dan ikut di-commit, jadi HEAD = yang dibagikan.

Mengaktifkan Pages (sekali): repo **Settings → Pages → Source: Deploy from a
branch → Branch: `main` / folder `/docs`**. URL terbit di
`https://<owner>.github.io/training-iot-pancasila-2026/`.

### Firmware

Buka folder sketch di Arduino IDE 2.x (board **ESP32 Dev Module**). Sebelum
compile, salin `secrets.h.example` → `secrets.h` lalu isi token Blynk & WiFi.
Library yang dibutuhkan tercantum di komentar tiap `.ino` dan di workbook.

## Format Pelatihan

- ~2 hari, peer-led (asisten memandu lab, trainer floating + eskalasi).
- 8 peserta → 4 kelompok @2 orang → 2 kelompok per lab, konkuren.
- Latar belakang teknis minimal — tiap langkah eksplisit & copy-paste.

## Catatan Keamanan

- `secrets.h` (token Blynk, password WiFi) ada di `.gitignore` — jangan
  di-commit. Material hanya memuat placeholder + cara mengisi.
- Repo berpotensi publik (GitHub Pages) — tanpa data pribadi peserta.

## Instruktur

Endy Muhardin · Dosen STMIK Tazkia · PT ArtiVisi Intermedia
[software.endy.muhardin.com](https://software.endy.muhardin.com)
