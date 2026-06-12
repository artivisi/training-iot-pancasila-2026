# Project Context

Material training IoT untuk **Universitas Pancasila**. Engagement: STMIK Tazkia
(trainer Endy Muhardin + asisten mahasiswa) mengajar mahasiswa Univ. Pancasila.

Training berbiaya rendah. Target kualitas **pragmatis**: peserta pulang dengan
prototype yang jalan. BUKAN kedalaman seperti corporate training. Material lean,
reuse berat dari batch IoT STMIK Tazkia yang sudah ada. Jangan gold-plating.

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

- Lab self-contained: firmware copy-paste, wiring pin-to-pin, diagram bila perlu.
- `fasilitator.md` ringkas: daftar titik gagal umum + fix cepat (salah COM port,
  MQ warm-up, RC522 3.3V, token Blynk, WiFi kampus). Bantu asisten, bukan ganti
  trainer.
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

## Struktur Repo (rencana)

```
fundamentals/        -- modul bersama: setup tool, breadboard, blink, wifi, blynk
labs/                -- 2 lab hands-on
  fire-detector/
  smart-absensi/
    README.md        -- overview, hasil akhir
    hardware.md      -- BOM + wiring pin-to-pin + estimasi biaya
    firmware/        -- kode ESP32 (copy-paste ready)
    langkah.md       -- step-by-step untuk peserta
    fasilitator.md   -- panduan asisten + daftar titik gagal & fix
demo/
  smart-irrigation/  -- prototype + bahan demo/diskusi (bukan lab peserta lengkap)
```

## Aturan Penulisan Material

- No marketing lingo, strictly teknis, tidak bertele-tele.
- No fallback / default tersembunyi — error harus eksplisit.
- Kode disertai penjelasan baris yang relevan untuk pemula.
- Cantumkan BOM + estimasi biaya komponen per lab.
- Reuse dari batch STMIK; jangan tulis ulang dari nol kalau sudah ada.
