# Project Context

Material training IoT untuk **Universitas Pancasila**. Engagement: STMIK Tazkia
(trainer Endy Muhardin + asisten mahasiswa) mengajar mahasiswa Univ. Pancasila.

Training berbiaya rendah. Target kualitas **pragmatis**: peserta pulang dengan
prototype yang jalan. BUKAN kedalaman seperti corporate training. Material lean,
reuse berat dari batch IoT STMIK Tazkia yang sudah ada. Jangan gold-plating.

## Framing PkM (Pengabdian kepada Masyarakat)

Kegiatan ini dibingkai sebagai **PkM** dosen STMIK Tazkia (Endy Muhardin) —
untuk angka kredit / BKD. Konsekuensi pada dokumentasi:

- **Mitra:** Universitas Pancasila (penerima manfaat: mahasiswanya).
- **Pelaksana:** dosen STMIK Tazkia + pelibatan mahasiswa sebagai asisten
  (poin plus PkM: keterlibatan mahasiswa).
- **Pendukung:** ArtiVisi (Endy juga praktisi industri di ArtiVisi).
- Materi (deck + workbook) harus mencantumkan identitas PkM: judul kegiatan,
  pelaksana, mitra, tanggal, logo STMIK Tazkia + ArtiVisi.
- Siapkan struktur untuk **laporan PkM** sebagai output (judul, tujuan, mitra,
  metode, peserta, luaran, dokumentasi) — bisa di-generate dari repo nanti.

## Peserta

- 8 peserta, latar belakang teknis minimal (asumsikan belum pernah coding /
  elektronika). Organizer sudah bagi jadi 4 kelompok x 2 orang.
- Tiap step harus eksplisit: wiring, instalasi tool, kode ditulis lengkap dan
  bisa copy-paste. Tidak ada langkah yang diasumsikan "sudah tahu".

## Asisten & pembagian peran mengajar

Asisten = mahasiswa STMIK Tazkia yang sudah pernah membangun prototype kasus
ini di mata kuliahnya. Jumlah cukup banyak; skill belum dalam, tapi backstop
trainer kuat:

- Tiap asisten ditugaskan menyusun material training versinya sendiri. Tujuan:
  melatih mindset mengajar/membimbing, BUKAN dipakai di kelas. Material kanonik
  = repo ini (punya trainer).
- Trainer (Endy) standby; eskalasi yang asisten tidak bisa jawab langsung
  ditangani trainer di tempat.

Pembagian peran saat training:

- **Trainer**: konsep umum IoT, apa itu ESP/Arduino/breadboard, komponen utama
  (sesi fundamental, plenary).
- **Asisten**: pandu lab — wiring detail, info per-hardware, jawab pertanyaan
  sebisanya; eskalasi ke trainer kalau mentok.

Implikasi material (tetap rapi, tanpa over-engineering):

- Bagian lab self-contained: firmware copy-paste, wiring pin-to-pin, diagram.
- **TIDAK ada panduan fasilitator terpisah.** Asisten pakai workbook yang sama
  dengan peserta. Titik gagal umum (salah COM port, MQ warm-up, RC522 3.3V,
  token Blynk, WiFi kampus) ditulis inline di langkah workbook sebagai catatan
  "kalau error".
- Dry-run sebelum hari-H berguna tapi bukan blocker — trainer backstop live.

## Studi Kasus

Klien minta "Monitoring Kualitas Udara" + "Smart Absensi". Air quality
di-deliver lewat lab Fire Detector (arsitektur sensor gas sama).

**2 lab hands-on (berjalan konkuren):**

| Lab | = Batch | Komponen inti | Konsep |
|-----|---------|---------------|--------|
| Fire Detector (mencakup kualitas udara) | S09 FireShield | ESP32, MQ-2/flame, DHT, buzzer, relay | analog gas sensor, threshold, alert, aktuasi |
| Smart Absensi | S08 | ESP32, RFID RC522, OLED, buzzer | SPI, baca kartu, kirim log ke cloud |

**Demo / diskusi saja (BUKAN lab hands-on peserta):**

- Smart Irrigation (S04 Smart Plant) — soil moisture + kontrol pompa. Untuk
  diskusi dengan organizer + demo singkat ke audience. Cukup 1 prototype jadi +
  bahan penjelasan; TIDAK perlu material lab lengkap untuk peserta.

Sumber material asal (reuse hardware list, wiring, konsep dari sini):
`/Users/endymuhardin/workspace/stmik/hasil-project-mahasiswa/2026-genap/`
(`rekap-studi-kasus.md`, `proposals/`)

## Stack (sudah diputuskan)

- Board: **ESP32**
- Toolchain: **Arduino IDE** (paling ramah pemula)
- Cloud/dashboard: **Blynk**
- Bahasa pengantar material: **Indonesia**
- No hidden fallback/default: kalau sensor gagal baca atau WiFi putus, tampilkan
  error eksplisit di Serial Monitor / indikator, jangan diam dengan nilai palsu.

## Format Training

Model peer-led, trainer supervisi:

1. **Setengah hari pertama** — fundamental IoT + setup (Arduino IDE, driver USB,
   akun Blynk, breadboard, blink LED, baca 1 sensor, konek WiFi, kirim 1 data) +
   overview studi kasus.
2. **Pembagian kelompok** ke 2 lab (berjalan **konkuren**). 4 kelompok x 2 orang
   (split organizer) -> 2 kelompok per lab.
3. **Hands-on dipandu asisten** (yang sudah punya prototype jadi). Trainer
   *floating* antara 2 lab: supervisi + tangani eskalasi. Konsep universal
   (WiFi, datastream Blynk, baca sensor) -> pause kedua lab, plenary singkat,
   lalu lanjut konkuren.
4. **Sesi penutup** — demo swap antar kelompok + demo singkat Smart Irrigation
   (soil sensor) ke seluruh audience.

Durasi target ~2 hari (fleksibel).

## Deliverable & Toolchain

Mengikuti pola repo `bsi-islamic-ecosystem-ai` (template yang sudah terbukti):

- **Deck**: `docs/index.html` — single-file standalone HTML (CSS/JS embedded,
  navigasi panah/spasi). Tanpa build. Dipublikasi via GitHub Pages.
- **Workbook**: `workbook/WORKBOOK.typ` → PDF (Typst). **SATU file** berisi
  fundamental + detail kedua lab. Dipakai peserta DAN asisten, kedua kelompok
  pakai workbook yang sama. PDF di-commit agar HEAD = yang dibagikan.
- **Build**: `workbook/Makefile` — `make` / `make watch` / `make clean`.
- **Diagram arsitektur/alur**: Mermaid `.mmd` → PNG via `mmdc`.
- **Diagram wiring breadboard**: Fritzing atau foto beranotasi (Mermaid tidak
  cocok untuk wiring). Simpan di `workbook/diagrams/`.
- Logo PkM (`logo-stmik.svg`, `logo-artivisi.svg`) ada di `docs/assets/` dan
  `workbook/assets/` — pasang di cover deck & workbook.

### File Map

| Path | Isi |
|------|-----|
| `docs/index.html` | Deck instruktur, standalone HTML, GitHub Pages |
| `docs/assets/` | Logo (STMIK Tazkia, ArtiVisi), gambar deck |
| `workbook/WORKBOOK.typ` + `.pdf` | Workbook tunggal: fundamental + 2 lab |
| `workbook/Makefile` | Build pipeline Typst + diagram |
| `workbook/diagrams/` | Source `.mmd`/Fritzing + hasil render |
| `workbook/assets/` | Logo untuk workbook |
| `README.md` | Isi repo, cara build, format, instruktur (pola BSI) |

Isi workbook (urutan bab): fundamental (setup tool, breadboard, blink, WiFi,
Blynk) -> Lab Fire Detector -> Lab Smart Absensi. Tiap lab: tujuan, BOM +
estimasi biaya, wiring pin-to-pin, firmware copy-paste, langkah, catatan error.

## Aturan Penulisan Material

- No marketing lingo, strictly teknis, tidak bertele-tele.
- No fallback / default tersembunyi — error harus eksplisit.
- Kode disertai penjelasan baris yang relevan untuk pemula.
- Cantumkan BOM + estimasi biaya komponen per lab.
- Reuse dari batch STMIK; jangan tulis ulang dari nol kalau sudah ada.
- **Istilah teknis IoT/hardware (ESP32, breadboard, GPIO, sensor, SPI) memang
  diajarkan** — kenalkan + jelaskan saat pertama muncul. Yang dihindari hanya
  jargon dev yang tidak relevan untuk pemula (deploy, framework, CI/CD, commit).

## Do Not

- Jangan commit secret: token Blynk, password WiFi. Pakai `secrets.h`
  (sudah di `.gitignore`). Di material, tunjukkan placeholder + cara isi.
- Jangan tulis ulang material dari nol kalau batch STMIK (S08/S09/S04) sudah
  punya wiring/BOM/konsepnya.
- Repo berpotensi publik (GitHub Pages) — jangan masukkan data pribadi peserta
  Univ. Pancasila.
