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

## Studi Kasus (3 lab)

Klien minta "Monitoring Kualitas Udara" + "Smart Absensi". Air quality
di-deliver lewat lab Fire Detector (arsitektur sensor gas sama). Ditambah
Smart Irrigation atas minat organizer pada soil sensor.

| Lab | = Batch | Komponen inti | Konsep |
|-----|---------|---------------|--------|
| Fire Detector (mencakup kualitas udara) | S09 FireShield | ESP32, MQ-2/flame, DHT, buzzer, relay | analog gas sensor, threshold, alert, aktuasi |
| Smart Absensi | S08 | ESP32, RFID RC522, OLED, buzzer | SPI, baca kartu, kirim log ke cloud |
| Smart Irrigation | S04 Smart Plant | ESP32, soil moisture capacitive, relay, pump | baca kelembapan, threshold, kontrol pompa |

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
   overview ketiga studi kasus.
2. **Pembagian kelompok** ke 3 lab (berjalan **konkuren**).
3. **Hands-on dipandu asisten** (yang sudah punya prototype jadi). Trainer
   *floating*: supervisi + jelaskan konsep penting saat ada teachable moment.
   Untuk konsep universal (WiFi, datastream Blynk, baca sensor) → pause semua
   lab, plenary singkat, lalu lanjut konkuren.
4. **Sesi penutup — demo swap**: tiap kelompok demo + jelaskan prototype-nya ke
   kelompok lain. Supaya semua peserta lihat ketiga kasus, bukan hanya miliknya.

Durasi target ~2 hari (fleksibel). Pemetaan 8 peserta ke 3 lab BELUM final —
konfirmasi ke user (regroup jadi 3 track, atau peserta rotasi).

## Struktur Repo (rencana)

```
fundamentals/        -- modul bersama: setup tool, breadboard, blink, wifi, blynk
labs/
  fire-detector/
  smart-absensi/
  smart-irrigation/
    README.md        -- overview, hasil akhir
    hardware.md      -- BOM + wiring pin-to-pin + estimasi biaya
    firmware/        -- kode ESP32 (copy-paste ready)
    langkah.md       -- step-by-step untuk peserta
    fasilitator.md   -- panduan asisten + daftar titik gagal & fix
```

## Aturan Penulisan Material

- No marketing lingo, strictly teknis, tidak bertele-tele.
- No fallback / default tersembunyi — error harus eksplisit.
- Kode disertai penjelasan baris yang relevan untuk pemula.
- Cantumkan BOM + estimasi biaya komponen per lab.
- Reuse dari batch STMIK; jangan tulis ulang dari nol kalau sudah ada.
