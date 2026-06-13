#set document(
  title: "Workbook IoT — PkM STMIK Tazkia x Universitas Pancasila 2026",
  author: "Endy Muhardin",
)

#set page(
  paper: "a4",
  margin: (x: 2.2cm, top: 2.5cm, bottom: 2cm),
  numbering: "1 / 1",
  number-align: center,
)

#set text(
  font: ("Helvetica Neue", "Arial"),
  size: 10.5pt,
  lang: "id",
)

#set par(justify: true, leading: 0.65em)

#let brand = rgb("#1e3a8a")
#let accent = rgb("#ea580c")
#let mute = rgb("#64748b")

#show heading.where(level: 1): it => [
  #pagebreak(weak: true)
  #v(0.5em)
  #text(fill: brand, size: 22pt, weight: "bold")[#it.body]
  #v(0.3em)
  #line(length: 100%, stroke: 1pt + accent)
  #v(0.8em)
]

#show heading.where(level: 2): it => block(
  sticky: true, above: 1.5em, below: 0.7em, breakable: false,
)[#text(fill: brand, size: 14pt, weight: "bold")[#it.body]]

#show heading.where(level: 3): it => block(
  sticky: true, above: 1.1em, below: 0.5em, breakable: false,
)[#text(fill: accent, size: 11.5pt, weight: "bold")[#it.body]]

#show raw.where(block: true): it => block(
  fill: rgb("#f1f5f9"),
  inset: 10pt,
  radius: 4pt,
  width: 100%,
  breakable: true,
  text(font: ("Menlo", "Courier New"), size: 8pt, it),
)

#show raw.where(block: false): it => box(
  fill: rgb("#f1f5f9"),
  inset: (x: 4pt, y: 1pt),
  outset: (y: 2pt),
  radius: 2pt,
  text(font: ("Menlo", "Courier New"), size: 9.5pt, it),
)

// ---- Kotak callout ----
#let callout(label, lc, bg, body) = block(
  fill: bg,
  stroke: (left: 3pt + lc),
  inset: 10pt,
  radius: 2pt,
  width: 100%,
  breakable: true,
  [#text(fill: lc, size: 9pt, weight: "bold")[#upper(label)]\ #body],
)
#let err(body)  = callout("Kalau error", rgb("#dc2626"), rgb("#fef2f2"), body)
#let tip(body)  = callout("Tips", rgb("#1d4ed8"), rgb("#eff6ff"), body)
#let warn(body) = callout("Penting", rgb("#b45309"), rgb("#fffbeb"), body)

// ============================================================
// COVER
// ============================================================
#set page(numbering: none, margin: (x: 2.5cm, y: 2.5cm))

#align(center)[
  #v(0.5cm)
  #box(image("assets/logo-stmik.svg", height: 2cm))
  #h(1.2cm)
  #box(image("assets/logo-artivisi.svg", height: 1.4cm))
  #v(1cm)
  #text(fill: accent, size: 11pt, weight: "bold")[#upper[Workbook Peserta & Asisten]]
  #v(0.4em)
  #text(fill: brand, size: 26pt, weight: "bold")[
    Pelatihan Internet of Things
  ]
  #v(0.2em)
  #text(fill: brand, size: 15pt)[
    Fire Detector (Monitoring Kualitas Udara) \ & Smart Absensi berbasis ESP32
  ]
  #v(1.2cm)
  #line(length: 35%, stroke: 1.5pt + accent)
  #v(0.6em)
  #text(fill: mute, size: 10.5pt)[
    *Kegiatan Pengabdian kepada Masyarakat (PkM)* \
    Pelaksana: Dosen STMIK Tazkia (Endy Muhardin) + asisten mahasiswa \
    Mitra: Universitas Pancasila #sym.dot.c Pendukung: PT ArtiVisi Intermedia \
    Juni 2026
  ]
  #v(1cm)
  #align(left)[
    #block(fill: rgb("#f1f5f9"), inset: 12pt, radius: 4pt, width: 100%)[
      #text(size: 9.5pt)[
        Workbook ini dipakai oleh *peserta* maupun *asisten* — isinya sama.
        Tiap langkah ditulis lengkap dan bisa di-copy-paste. Catatan
        *"Kalau error"* ada inline di tiap langkah; kalau mentok, panggil
        trainer.
      ]
    ]
  ]
]

#pagebreak()

#set page(numbering: "1 / 1", margin: (x: 2.2cm, top: 2.5cm, bottom: 2cm))
#counter(page).update(1)

#text(fill: brand, size: 22pt, weight: "bold")[Daftar Isi]
#v(0.3em)
#line(length: 100%, stroke: 1pt + accent)
#v(1em)
#outline(title: none, indent: auto, depth: 2)

// ============================================================
= Cara Pakai Workbook
// ============================================================

Pelatihan ini berformat *peer-led*: asisten memandu lab, trainer mengawasi dan
menangani eskalasi. Alurnya:

#table(
  columns: (auto, 1fr),
  inset: 7pt,
  stroke: 0.5pt + rgb("#cbd5e1"),
  [*Setengah hari pertama*], [Fundamental IoT + setup tool (Bab 1). Semua peserta
    barengan, dipandu trainer.],
  [*Pembagian kelompok*], [4 kelompok (masing-masing 2 orang) dibagi ke 2 lab, berjalan
    *konkuren*: 2 kelompok Fire Detector, 2 kelompok Smart Absensi.],
  [*Hands-on*], [Tiap kelompok kerjakan lab-nya (Bab 2 atau Bab 3) dipandu
    asisten. Konsep universal (WiFi, Blynk) dijelaskan plenary singkat.],
  [*Penutup*], [Demo swap antar kelompok + demo Smart Irrigation (Lampiran B).],
)

== Konvensi penulisan

- Kotak abu-abu = kode untuk di-copy-paste persis.
- #text(fill: rgb("#dc2626"), weight: "bold")[Kalau error] = titik gagal umum +
  cara perbaiki, ditulis tepat di langkah yang rawan.
- #text(fill: rgb("#b45309"), weight: "bold")[Penting] = hal yang kalau salah
  bisa *merusak komponen* (mis. tegangan 3.3V vs 5V). Baca pelan-pelan.

== Soal token & password

Token Blynk dan password WiFi *tidak* ditulis di kode yang di-commit. Kode
membaca file `secrets.h`. Tiap folder firmware sudah berisi `secrets.h.example`
— salin jadi `secrets.h`, lalu isi. Detailnya di #link(<setup-secrets>)[bagian _Mengisi secrets.h_].

// ============================================================
= Fundamental IoT & Setup
// ============================================================

== Apa itu IoT, dan kenapa ESP32

*Internet of Things (IoT)* = menghubungkan alat fisik (sensor, lampu, motor) ke
internet supaya datanya bisa dipantau dan dikontrol dari jarak jauh. Pola dasar
tiap proyek IoT di pelatihan ini sama:

#align(center)[*Sensor #sym.arrow.r Mikrokontroler #sym.arrow.r WiFi #sym.arrow.r Cloud #sym.arrow.r Smartphone*]

*Mikrokontroler* = komputer mungil satu chip yang menjalankan satu program.
Kita pakai *ESP32 DevKit V1*: murah, sudah ada *WiFi* bawaan, dan punya banyak
kaki (*pin*) untuk dicolok sensor.

- *GPIO* (General Purpose Input/Output) = pin serbaguna ESP32. Tiap pin punya
  nomor (mis. GPIO27). Lewat program, satu pin bisa jadi *input* (baca sensor)
  atau *output* (nyalakan buzzer/LED).
- *Pin analog (ADC)* = pin yang bisa baca tegangan bertingkat (bukan cuma
  on/off). ESP32 membacanya sebagai angka 0–4095. Dipakai untuk sensor seperti
  MQ-2 yang outputnya "seberapa banyak", bukan sekadar ada/tidak.
- *Pin digital* = hanya baca/tulis dua kondisi: HIGH (#sym.tilde.op 3.3V) atau
  LOW (0V).

== Breadboard

*Breadboard* = papan untuk merangkai komponen tanpa menyolder. Lubang-lubangnya
terhubung di dalam dengan pola:

- Dua jalur panjang di tepi (bertanda + dan #sym.minus) = jalur *power*. Biasa
  dipakai untuk membagikan 3.3V/5V dan GND ke banyak komponen.
- Lubang di tengah terhubung *per kolom* (5 lubang vertikal jadi satu),
  terpisah oleh celah tengah.

#warn[*GND harus nyambung jadi satu (common ground).* Semua GND komponen +
GND ESP32 disatukan di jalur #sym.minus breadboard. Kalau tidak, sensor baca
nilai ngaco.]

== Install Arduino IDE + dukungan ESP32 <setup-ide>

+ Download *Arduino IDE 2.x* dari #link("https://www.arduino.cc/en/software")[arduino.cc/en/software], install seperti aplikasi biasa.
+ Buka *File #sym.arrow.r Preferences*. Di kolom *Additional boards manager URLs*,
  tempel: `https://espressif.github.io/arduino-esp32/package_esp32_index.json`
+ Buka *Tools #sym.arrow.r Board #sym.arrow.r Boards Manager*, cari *esp32*,
  install paket *"esp32 by Espressif Systems"*.
+ Colok ESP32 ke USB. Pilih *Tools #sym.arrow.r Board #sym.arrow.r ESP32 Arduino
  #sym.arrow.r "ESP32 Dev Module"*.
+ Pilih *Tools #sym.arrow.r Port* #sym.arrow.r port yang muncul (mis.
  `/dev/cu.SLAB_USBtoUART` atau `COM3`).

#err[*Port tidak muncul / ESP32 tidak terdeteksi.* ESP32 butuh driver USB-serial.
Cek chip di sebelah port USB board: *CP2102* #sym.arrow.r install driver Silicon
Labs CP210x; *CH340* #sym.arrow.r install driver CH340. Setelah install, cabut-colok
ulang kabel. Pastikan kabel USB-nya kabel *data*, bukan kabel charge-only.]

== Install library

Buka *Sketch #sym.arrow.r Include Library #sym.arrow.r Manage Libraries*, lalu
install (ketik nama, klik Install, terima kalau diminta install dependency):

#table(
  columns: (1fr, 1.4fr),
  inset: 6pt,
  stroke: 0.5pt + rgb("#cbd5e1"),
  align: left,
  [*Library*], [*Dipakai di*],
  [Blynk (by Volodymyr Shymanskyy)], [Semua — kirim data ke cloud],
  [DHT sensor library (Adafruit) + Adafruit Unified Sensor], [Fire Detector],
  [MFRC522 (by GithubCommunity)], [Smart Absensi — baca RFID],
  [Adafruit SSD1306 + Adafruit GFX Library], [Smart Absensi — OLED],
)

#err[*Saat compile/upload muncul `... No such file or directory` (file header
tidak ketemu).* Header bukan berarti hilang dari komputer — biasanya board atau
library belum disiapkan:
- `WiFi.h` *bukan* library yang di-install terpisah. Ia ikut di dalam *paket
  board ESP32* dan hanya muncul kalau *board ESP32 dipilih*. Kalau error ini
  muncul: pastikan paket _esp32 by Espressif_ sudah ter-install
  (#link(<setup-ide>)[bagian _Install Arduino IDE + dukungan ESP32_]) *dan*
  Tools #sym.arrow.r Board diset ke *ESP32 Dev Module* (bukan Arduino Uno/AVR).
- `BlynkSimpleEsp32.h` berasal dari library *Blynk* (Volodymyr Shymanskyy) di
  tabel ini. Kalau tidak ketemu, library Blynk belum ter-install.
- Pola sama untuk header lain: `DHT.h` #sym.arrow.r library DHT Adafruit;
  `MFRC522.h` #sym.arrow.r library MFRC522; `Adafruit_SSD1306.h` #sym.arrow.r
  library Adafruit SSD1306.
]

== Buat akun & device Blynk <setup-blynk>

*Blynk* = layanan cloud + app smartphone untuk dashboard IoT. Data dari ESP32
dikirim ke *Virtual Pin* (V0, V1, ...) lalu ditampilkan sebagai widget.

+ Daftar di #link("https://blynk.cloud")[blynk.cloud] (gratis untuk pemakaian kecil).
+ *Developer Zone #sym.arrow.r Templates #sym.arrow.r New Template*. Beri nama
  (mis. "Fire Detector"), Hardware = *ESP32*, Connection = *WiFi*.
+ Tab *Datastreams #sym.arrow.r New Datastream #sym.arrow.r Virtual Pin*. Buat
  pin sesuai tabel di tiap lab (V0, V1, ...). Set tipe data (Integer/Double/String)
  dan range sesuai tabel.
+ Tab *Web Dashboard*: tarik widget (Gauge, Label, LED) dan hubungkan ke
  datastream tadi. Ini yang Anda lihat saat alat jalan.
+ Menu *Devices #sym.arrow.r New Device #sym.arrow.r From template* #sym.arrow.r
  pilih template tadi. Buka device, *Device Info* berisi `BLYNK_TEMPLATE_ID`,
  `BLYNK_TEMPLATE_NAME`, dan `BLYNK_AUTH_TOKEN`.
+ Install app *Blynk IoT* di HP, login akun sama, untuk lihat dashboard dari HP.

== Mengisi secrets.h <setup-secrets>

Tiap folder firmware berisi `secrets.h.example`. Salin jadi `secrets.h` (di
folder yang sama), buka di Arduino IDE, isi nilainya:

```cpp
#define BLYNK_TEMPLATE_ID    "TMPLxxxxxxxx"
#define BLYNK_TEMPLATE_NAME  "Fire Detector"
#define BLYNK_AUTH_TOKEN     "isi-token-device-dari-blynk"
#define WIFI_SSID  "nama-wifi"
#define WIFI_PASS  "password-wifi"
```

#warn[`secrets.h` sudah masuk `.gitignore` supaya token & password tidak ikut
ter-upload ke GitHub. Jangan menaruh token langsung di file `.ino`.]

#err[*WiFi kampus pakai halaman login (captive portal).* ESP32 tidak bisa
mengisi form login web. Solusi: pakai *hotspot HP* sebagai gantinya — isikan
SSID & password hotspot di `secrets.h`.]

== Latihan 1: Blink LED bawaan

Sebelum menyentuh sensor, pastikan rantai "tulis kode #sym.arrow.r upload
#sym.arrow.r jalan" sudah benar. ESP32 punya LED bawaan di GPIO2.

```cpp
void setup() {
  pinMode(2, OUTPUT);
}
void loop() {
  digitalWrite(2, HIGH);  // LED nyala
  delay(500);
  digitalWrite(2, LOW);   // LED mati
  delay(500);
}
```

Klik tombol *Upload* (panah kanan). Saat muncul "Connecting...", kalau gagal,
*tahan tombol BOOT* di ESP32 beberapa detik sampai upload mulai. LED bawaan
akan kedip tiap 0.5 detik.

#err[*Upload gagal / "Failed to connect / Timed out waiting for packet header".*
Tahan tombol *BOOT* saat muncul "Connecting....". Pastikan Port benar dan tidak
ada Serial Monitor lain yang sedang membuka port itu.]

== Latihan 2: Konek WiFi + kirim 1 data ke Blynk

Ini fondasi kedua lab. Buat device Blynk (#link(<setup-blynk>)[bagian _Buat akun & device Blynk_]) dengan 1
datastream `V0` (Integer). Buat `secrets.h` di folder sketch ini. Kode:

```cpp
#include "secrets.h"
#include <WiFi.h>
#include <BlynkSimpleEsp32.h>

BlynkTimer timer;
int hitung = 0;

void kirim() {
  hitung++;
  Blynk.virtualWrite(V0, hitung);     // kirim angka naik ke V0
  Serial.print("kirim V0 = "); Serial.println(hitung);
}

void setup() {
  Serial.begin(115200);
  Blynk.begin(BLYNK_AUTH_TOKEN, WIFI_SSID, WIFI_PASS);
  timer.setInterval(2000L, kirim);
}

void loop() {
  Blynk.run();
  timer.run();
}
```

Buka *Tools #sym.arrow.r Serial Monitor*, set baud *115200*. Harusnya muncul log
koneksi WiFi lalu "Ready", lalu angka naik tiap 2 detik. Tambahkan widget *Label*
ke V0 di dashboard Blynk — angkanya ikut naik.

#err[*Serial Monitor isinya karakter aneh / kotak-kotak.* Baud rate salah. Set
ke *115200* di pojok kanan bawah Serial Monitor.]

#err[*Macet di "Connecting to wifi..." terus.* SSID/password salah, atau WiFi
captive portal (lihat catatan di #link(<setup-secrets>)[bagian _Mengisi secrets.h_]). ESP32 hanya support
WiFi *2.4GHz*, bukan 5GHz.]

#err[*"Invalid auth token".* `BLYNK_AUTH_TOKEN` salah ketik atau token device
lain. Salin ulang dari Blynk #sym.arrow.r Device #sym.arrow.r Device Info.]

// ============================================================
= Lab Fire Detector
// ============================================================

== Tujuan & konsep

Membangun pendeteksi kebakaran + monitoring kualitas udara: baca *gas/asap*
(MQ-2, sensor analog), *api* (flame sensor, digital), dan *suhu/kelembapan*
(DHT11). Kalau gas melewati ambang ATAU api terdeteksi #sym.arrow.r bunyikan
buzzer, nyalakan LED, aktifkan relay (mensimulasikan kipas exhaust / pompa), dan
kirim status ke Blynk.

Konsep yang dilatih: *baca sensor analog (ADC) + ambang batas (threshold)*,
aktuasi via relay, dan kirim telemetri ke cloud. Arsitektur sensor gas ini sama
dengan use-case *monitoring kualitas udara* yang diminta — bedanya hanya ambang
& interpretasi.

#figure(image("diagrams/arsitektur-fire-detector.png", width: 100%))

== Daftar komponen (BOM) & estimasi biaya

#table(
  columns: (auto, 1.6fr, 1.4fr, auto),
  inset: 6pt,
  stroke: 0.5pt + rgb("#cbd5e1"),
  align: (center, left, left, right),
  [*No*], [*Komponen*], [*Fungsi*], [*Estimasi*],
  [1], [ESP32 DevKit V1], [Mikrokontroler + WiFi], [Rp 65.000],
  [2], [Sensor MQ-2], [Deteksi gas LPG & asap (analog)], [Rp 15.000],
  [3], [Flame sensor IR], [Deteksi lidah api (digital)], [Rp 8.000],
  [4], [DHT11], [Suhu & kelembapan], [Rp 20.000],
  [5], [Relay module 5V 1ch], [Saklar aktuator (kipas/pompa)], [Rp 12.000],
  [6], [Buzzer active], [Alarm suara], [Rp 5.000],
  [7], [LED + resistor 220#sym.Omega], [Indikator visual], [Rp 5.000],
  [8], [Resistor 10k#sym.Omega (2 pcs)], [Pembagi tegangan MQ-2], [Rp 2.000],
  [9], [Breadboard + kabel jumper], [Perakitan tanpa solder], [Rp 40.000],
  table.cell(colspan: 3, align: right)[*Total estimasi per kelompok*], [*Rp 172.000*],
)

== Wiring pin-to-pin

#warn[Susun rangkaian saat ESP32 *tidak* terhubung USB/power. Colok power baru
setelah semua kabel terpasang dan dicek ulang.]

#figure(image("diagrams/wiring-fire-detector.svg", width: 100%))

Warna kabel pada diagram = peran (merah 5V, oranye 3.3V, abu GND, biru sinyal).
Tabel di bawah adalah rujukan pasti pin-per-pin.

*MQ-2 (sensor gas, analog).* MQ-2 perlu 5V untuk elemen pemanasnya. Tapi
output AO bisa mendekati 5V saat asap pekat, padahal pin ESP32 maksimal *3.3V*.
Karena itu AO dilewatkan *pembagi tegangan* 2 resistor 10k#sym.Omega dulu.

#table(
  columns: (1.3fr, 1.7fr),
  inset: 6pt, stroke: 0.5pt + rgb("#cbd5e1"), align: left,
  [*Pin MQ-2*], [*Ke*],
  [VCC], [5V (pin `VIN`/`5V` ESP32)],
  [GND], [GND],
  [AO], [titik tengah pembagi tegangan #sym.arrow.r GPIO34],
)
Pembagi tegangan: AO #sym.arrow.r `R1 (10k)` #sym.arrow.r titik-tengah
#sym.arrow.r `R2 (10k)` #sym.arrow.r GND. Titik-tengah inilah yang ke GPIO34.
Ini memotong tegangan jadi setengah (#sym.tilde.op aman di bawah 3.3V).

*Flame, DHT11, output:*
#table(
  columns: (1.3fr, 1fr, 1.4fr),
  inset: 6pt, stroke: 0.5pt + rgb("#cbd5e1"), align: left,
  [*Komponen*], [*Pin komponen*], [*Ke ESP32*],
  [Flame sensor], [VCC / GND / DO], [3.3V / GND / GPIO35],
  [DHT11], [VCC / GND / DATA], [3.3V / GND / GPIO4],
  [Relay 5V], [VCC / GND / IN], [5V / GND / GPIO26],
  [Buzzer active], [(+) / (#sym.minus)], [GPIO27 / GND],
  [LED indikator], [anoda (kaki panjang) / katoda], [GPIO25 lewat resistor 220#sym.Omega / GND],
)

#warn[GPIO34 & GPIO35 *input-only* — benar, keduanya memang dipakai sebagai
input di sini. Jangan dipakai sebagai output.]

== Setup datastream Blynk

Buat template "Fire Detector" (lihat #link(<setup-blynk>)[bagian _Buat akun & device Blynk_]) dengan datastream:

#table(
  columns: (auto, 1.3fr, 1fr, 1.4fr),
  inset: 6pt, stroke: 0.5pt + rgb("#cbd5e1"), align: left,
  [*Pin*], [*Nama*], [*Tipe*], [*Widget saran*],
  [V0], [Gas], [Integer (0–4095)], [Gauge],
  [V1], [Suhu], [Double (0–60)], [Label / Gauge],
  [V2], [Kelembapan], [Double (0–100)], [Label],
  [V3], [Status bahaya], [Integer (0–1)], [LED],
)

== Firmware

Buka `firmware/fire-detector/fire-detector.ino`. Pastikan `secrets.h` sudah diisi
dan datastream di atas sudah dibuat. Kode lengkap:

#raw(read("../firmware/fire-detector/fire-detector.ino"), lang: "cpp", block: true)

== Menjalankan & kalibrasi ambang

+ Upload sketch. Buka Serial Monitor (115200). Tunggu MQ-2 *warm-up* #sym.tilde.op 30–60 detik.
+ Catat nilai `GAS=` di udara bersih (mis. 600–900). Dekatkan asap korek/pemantik
  (jangan api langsung ke sensor) #sym.arrow.r nilai naik tajam.
+ Set `AMBANG_GAS` di kode (baris `const int AMBANG_GAS = ...`) ke nilai di
  antara kondisi bersih dan berasap. Upload ulang.
+ Uji flame sensor: dekatkan korek (nyala kecil, jarak aman) #sym.arrow.r
  `API=YA`, buzzer + LED + relay aktif.

#err[*`GAS=` selalu 0 atau 4095.* 0 = AO tidak nyambung ke GPIO34 / pembagi
tegangan salah. 4095 = AO langsung ke 3.3V tanpa pembagi, atau masih warm-up.
Cek lagi rangkaian pembagi tegangan.]

#err[*`ERROR: DHT11 gagal dibaca`.* Kabel DATA longgar, atau DHT diberi 5V
(pakai 3.3V). DHT11 juga lambat — wajar sesekali gagal, tapi kalau terus-terusan
berarti wiring.]

#err[*Relay bunyi "klik" terus / kebalik.* Sebagian modul relay aktif-LOW.
Kalau aktuasi kebalik, tukar logika di kode (`HIGH`#sym.harpoons.ltrb`LOW` pada
`digitalWrite(PIN_RELAY, ...)`).]

#err[*Buzzer diam padahal status BAHAYA.* Ada buzzer *active* (cukup diberi
HIGH, dipakai di sini) dan *passive* (perlu nada/tone). Pastikan pakai buzzer
*active*. Cek juga polaritas (+)/(#sym.minus).]

== Pengayaan (opsional): servo memutar sensor untuk cari arah api

#text(fill: mute, size: 9.5pt)[_Bagian ini opsional — bukan langkah wajib lab.
Cocok untuk kelompok yang sudah selesai duluan, atau sebagai demo._]

*Apakah benar-benar bisa dipakai?* Ya, tapi dengan batasan. Sensor IR bersifat
*directional* (punya arah pandang #sym.tilde.op 60°), jadi kalau diputar pelan
dengan servo sambil membaca output *analog (AO)*, sudut dengan nilai IR paling
ekstrem = *perkiraan kasar* arah api. Yang realistis didapat hanya *arah kasar*
(#sym.plus.minus 15–30°), bukan penunjukan presisi. Ini bagus sebagai latihan
*kontrol servo + scan analog + cari nilai maksimum*, tetapi *bukan* sistem
penarget api yang andal. Pakai di kondisi terkontrol: satu sumber api, cahaya
ruangan redup, jarak dekat (#sym.lt.eq 50 cm).

#warn[*Tiga syarat supaya tidak mengecewakan:*
- *Daya servo terpisah.* Servo SG90 menarik arus sentakan besar. Jangan ambil
  dari pin ESP32 — board bisa _brownout_ / restart (apalagi saat WiFi nyala).
  Beri servo 5V dari sumber terpisah (mis. baterai/adaptor) dengan *GND
  disatukan* ke ESP32.
- *Cahaya terkontrol.* Sensor IR juga menangkap *matahari, lampu pijar/halogen,
  pantulan*. Di ruang terang, lampu bisa "menang" atas api kecil #sym.arrow.r
  arah salah.
- *Gerak lalu diam, baru baca.* Putar servo ke sudut, tunggu #sym.tilde.op 250 ms
  supaya diam, baru `analogRead`. Kalau dibaca sambil bergerak, nilainya kabur.]

*Wiring tambahan* (di atas rangkaian Fire Detector):
#table(
  columns: (1.3fr, 1.7fr),
  inset: 6pt, stroke: 0.5pt + rgb("#cbd5e1"), align: left,
  [*Bagian*], [*Ke*],
  [Servo SG90 — sinyal (oranye)], [GPIO13],
  [Servo SG90 — VCC (merah)], [5V *sumber terpisah* (bukan pin ESP32)],
  [Servo SG90 — GND (coklat)], [GND bersama dengan ESP32],
  [Flame sensor — AO (analog)], [GPIO32 (ADC1)],
)
Pasang flame sensor di "kepala" servo supaya ikut berputar. Untuk scanning,
baca pin *AO* (analog), bukan DO. Butuh library *ESP32Servo* (Manage Libraries).

#err[*Servo bergetar / ESP32 restart saat servo bergerak.* Daya servo masih
diambil dari ESP32. Pisahkan 5V servo ke sumber sendiri, satukan GND.]

Logika scan (gabungkan ke sketch utama, atau uji terpisah dulu):

```cpp
#include <ESP32Servo.h>

const int PIN_SERVO    = 13;   // sinyal servo
const int PIN_FLAME_AO = 32;   // AO flame sensor (analog)
Servo servo;

int cariArahApi() {
  int sudutTerbaik = 90, aoMaks = 0;
  for (int sudut = 0; sudut <= 180; sudut += 10) {
    servo.write(sudut);
    delay(250);                       // tunggu servo diam DULU
    int ao = analogRead(PIN_FLAME_AO);
    if (ao > aoMaks) { aoMaks = ao; sudutTerbaik = sudut; }
  }
  return sudutTerbaik;                 // sudut IR terkuat = perkiraan arah api
}

void setup() {
  Serial.begin(115200);
  servo.attach(PIN_SERVO);
}

void loop() {
  int arah = cariArahApi();
  Serial.print("Perkiraan arah api di sudut "); Serial.println(arah);
  servo.write(arah);                   // arahkan kepala/nozzle ke sana
  delay(2000);
}
```

#warn[*Polaritas AO berbeda antar modul.* Pada sebagian modul flame, makin dekat
api nilai AO makin *kecil* (bukan besar). Cek dulu: dekatkan api dan lihat
Serial Monitor. Kalau nilainya turun, ubah pencarian jadi *minimum* (`ao < aoMin`,
mulai dari `aoMin = 4095`).]

// ============================================================
= Lab Smart Absensi
// ============================================================

== Tujuan & konsep

Membangun absensi berbasis kartu RFID: tempel kartu #sym.arrow.r ESP32 baca
nomor unik kartu (*UID*) lewat *RC522*, tampilkan di *OLED*, bunyikan buzzer +
LED hijau, lalu kirim UID + nomor urut tap ke dashboard Blynk.

Konsep yang dilatih: komunikasi *SPI* (RC522) dan *I2C* (OLED) — dua protokol
standar menghubungkan modul ke mikrokontroler — serta mengirim *data string*
(bukan cuma angka) ke cloud.

- *SPI* = protokol cepat 4 kabel (SCK clock, MOSI, MISO, SS). Dipakai RC522.
- *I2C* = protokol 2 kabel (SDA data, SCL clock), tiap perangkat punya alamat.
  Dipakai OLED (alamat `0x3C`).

#figure(image("diagrams/arsitektur-smart-absensi.png", width: 100%))

== Daftar komponen (BOM) & estimasi biaya

#table(
  columns: (auto, 1.6fr, 1.4fr, auto),
  inset: 6pt, stroke: 0.5pt + rgb("#cbd5e1"),
  align: (center, left, left, right),
  [*No*], [*Komponen*], [*Fungsi*], [*Estimasi*],
  [1], [ESP32 DevKit V1], [Mikrokontroler + WiFi], [Rp 65.000],
  [2], [RFID reader RC522 + kartu], [Baca UID kartu (SPI)], [Rp 40.000],
  [3], [Kartu/keytag RFID tambahan], [Identitas peserta], [Rp 5.000],
  [4], [OLED 0.96" I2C (SSD1306)], [Tampilkan UID & status], [Rp 35.000],
  [5], [Buzzer active], [Notifikasi suara], [Rp 5.000],
  [6], [LED hijau + merah + resistor 220#sym.Omega], [Indikator OK / gagal], [Rp 5.000],
  [7], [Breadboard + kabel jumper], [Perakitan tanpa solder], [Rp 40.000],
  table.cell(colspan: 3, align: right)[*Total estimasi per kelompok*], [*Rp 195.000*],
)

== Wiring pin-to-pin

#warn[*RC522 HANYA boleh diberi 3.3V.* Memberi 5V akan merusak modul. Ini
kesalahan paling umum di lab ini — cek dua kali sebelum colok power.]

#figure(image("diagrams/wiring-smart-absensi.svg", width: 100%))

Warna kabel pada diagram = peran (oranye 3.3V, abu GND, biru SPI, cyan I2C).
Tabel di bawah adalah rujukan pasti pin-per-pin.

*RC522 (SPI):*
#table(
  columns: (1fr, 1fr),
  inset: 6pt, stroke: 0.5pt + rgb("#cbd5e1"), align: left,
  [*Pin RC522*], [*Ke ESP32*],
  [SDA (SS)], [GPIO5],
  [SCK], [GPIO18],
  [MOSI], [GPIO23],
  [MISO], [GPIO19],
  [RST], [GPIO4],
  [3.3V], [3V3 #text(fill: rgb("#dc2626"))[(JANGAN 5V)]],
  [GND], [GND],
  [IRQ], [tidak dipakai (biarkan kosong)],
)

*OLED (I2C) & output:*
#table(
  columns: (1.3fr, 1fr, 1.4fr),
  inset: 6pt, stroke: 0.5pt + rgb("#cbd5e1"), align: left,
  [*Komponen*], [*Pin*], [*Ke ESP32*],
  [OLED SSD1306], [VCC / GND], [3.3V / GND],
  [OLED SSD1306], [SDA / SCL], [GPIO21 / GPIO22],
  [LED hijau], [anoda / katoda], [GPIO25 lewat 220#sym.Omega / GND],
  [LED merah], [anoda / katoda], [GPIO26 lewat 220#sym.Omega / GND],
  [Buzzer active], [(+) / (#sym.minus)], [GPIO27 / GND],
)

== Setup datastream Blynk

Buat template "Smart Absensi" dengan datastream:

#table(
  columns: (auto, 1.3fr, 1fr, 1.4fr),
  inset: 6pt, stroke: 0.5pt + rgb("#cbd5e1"), align: left,
  [*Pin*], [*Nama*], [*Tipe*], [*Widget saran*],
  [V0], [UID kartu], [String], [Label],
  [V1], [Nomor tap], [Integer], [Label / Gauge],
)

#tip[Blynk gratis tidak menyimpan riwayat tabel absensi. Untuk lab ini cukup
tampilkan UID & jumlah tap real-time. Mengirim ke database absensi sungguhan
(Google Sheets / web server) adalah pengembangan lanjutan — di luar scope lab.]

== Firmware

Buka `firmware/smart-absensi/smart-absensi.ino`. Pastikan `secrets.h` terisi dan
datastream sudah dibuat. Kode lengkap:

#raw(read("../firmware/smart-absensi/smart-absensi.ino"), lang: "cpp", block: true)

== Menjalankan

+ Upload sketch. Buka Serial Monitor (115200). Harusnya muncul `RC522 OK, versi 0x92`
  (atau `0x91`), lalu OLED menampilkan "Siap. Tempel kartu".
+ Tempel kartu ke RC522. Serial & OLED menampilkan UID (mis. `A1B2C3D4`), buzzer
  beep, LED hijau nyala. Dashboard Blynk V0/V1 ikut update.
+ Coba beberapa kartu berbeda — tiap kartu UID-nya unik. Inilah "identitas" yang
  dipakai untuk absensi.

#err[*`ERROR: RC522 tidak terdeteksi` / versi `0x00` atau `0xFF`.* Hampir selalu
wiring: cek 7 kabel SPI sesuai tabel, dan pastikan power *3.3V bukan 5V*. Kabel
jumper murah sering putus di dalam — coba ganti kabel.]

#err[*`ERROR: OLED tidak terdeteksi di 0x3C`.* SDA/SCL tertukar (SDA=21, SCL=22),
atau alamat I2C modul Anda `0x3D`. Ganti `OLED_ADDR` jadi `0x3D` kalau perlu.]

#err[*Kartu ditempel tapi tidak ada reaksi.* Jarak terlalu jauh — tempelkan
menyentuh modul. Kartu Mifare 13.56MHz yang didukung; kartu akses gedung
125kHz tidak akan terbaca.]

#err[*OLED tampil tapi RC522 mati (atau sebaliknya).* Power 3.3V ESP32 kadang
kurang arus untuk dua modul. Bagikan 3.3V & GND lewat jalur power breadboard,
jangan menumpuk jumper di satu lubang pin ESP32.]

// ============================================================
= Lampiran A — Troubleshooting umum
// ============================================================

#table(
  columns: (1.2fr, 1.8fr),
  inset: 7pt, stroke: 0.5pt + rgb("#cbd5e1"), align: left,
  [*Gejala*], [*Cek ini*],
  [`WiFi.h` / `BlynkSimpleEsp32.h` `No such file`], [`WiFi.h` ikut paket board ESP32 (pilih board *ESP32 Dev Module*); `BlynkSimpleEsp32.h` dari library *Blynk* — install dulu],
  [Port tidak muncul], [Driver USB (CP210x / CH340), kabel data bukan charge-only],
  [Upload "Failed to connect"], [Tahan tombol BOOT saat "Connecting...", pastikan Serial Monitor lain tertutup],
  [Serial Monitor karakter aneh], [Baud rate set ke 115200],
  [Macet "Connecting to wifi"], [SSID/pass salah, WiFi 5GHz (ESP32 cuma 2.4GHz), captive portal kampus #sym.arrow.r pakai hotspot HP],
  [Invalid auth token], [Salin ulang `BLYNK_AUTH_TOKEN` dari Device Info],
  [Sensor nilai ngaco], [GND belum common — satukan semua GND],
  [Modul mati/panas], [Salah tegangan 3.3V vs 5V — RC522 & DHT pakai 3.3V],
)

// ============================================================
= Lampiran B — Demo Smart Irrigation
// ============================================================

Smart Irrigation *bukan* lab hands-on peserta — hanya didemokan trainer di sesi
penutup sebagai pembanding. Peserta cukup mengamati dan diskusi. Bagian ini
menjelaskan cara kerjanya supaya peserta paham bahwa pola IoT yang sama dipakai
ulang untuk kasus berbeda.

== Tujuan & konsep

Menyiram tanaman otomatis: baca *kelembapan tanah*, kalau tanah *kering*
melewati ambang #sym.arrow.r nyalakan *pompa* untuk menyiram, lalu matikan saat
tanah sudah cukup *lembap*. Inti konsepnya identik dengan Lab Fire Detector —
*baca sensor analog (ADC) #sym.arrow.r ambang #sym.arrow.r aktuasi via relay* —
hanya sensor dan aktuatornya yang berbeda. Inilah poin diskusi: sekali paham
pola ini, peserta bisa menukar sensor/aktuator untuk membuat use-case baru.

#figure(image("diagrams/arsitektur-smart-irrigation.png", width: 95%))

== Daftar komponen (BOM) & estimasi biaya

#table(
  columns: (auto, 1.6fr, 1.5fr, auto),
  inset: 6pt, stroke: 0.5pt + rgb("#cbd5e1"),
  align: (center, left, left, right),
  [*No*], [*Komponen*], [*Fungsi*], [*Estimasi*],
  [1], [ESP32 DevKit V1], [Mikrokontroler + WiFi], [Rp 65.000],
  [2], [Capacitive Soil Moisture v1.2], [Sensor kelembapan tanah (analog, anti-karat)], [Rp 21.500],
  [3], [DHT11], [Suhu & kelembapan udara (konteks)], [Rp 20.000],
  [4], [Relay 5V 1ch], [Saklar daya pompa], [Rp 23.000],
  [5], [Pompa celup mini 5V], [Aktuator penyiram], [Rp 21.000],
  [6], [Selang 8mm], [Salurkan air ke pot], [Rp 10.000],
  [7], [2x baterai 18650 + holder], [Power mandiri 7.4V], [Rp 32.000],
  [8], [LM2596 step-down], [Turunkan 7.4V #sym.arrow.r 5V untuk ESP32], [Rp 9.000],
  [9], [Breadboard + jumper], [Perakitan tanpa solder], [Rp 40.000],
  table.cell(colspan: 3, align: right)[*Total estimasi*], [*Rp 241.500*],
)

#tip[Beda dengan 2 lab utama yang ditenagai USB, Smart Irrigation memakai
*baterai 18650* + *LM2596 step-down* supaya portabel (taruh di pot tanpa colokan).
18650 seri = 7.4V, diturunkan ke 5V untuk ESP32. Inilah konsep tambahan yang
didemokan: *IoT bertenaga baterai*.]

== Cara kerja & logika kontrol

Sensor kapasitif mengeluarkan tegangan analog: *kering #sym.arrow.r nilai ADC
tinggi*, *basah #sym.arrow.r nilai ADC rendah* (tidak ada arus lewat tanah, jadi
tahan korosi — lebih awet dari sensor resistif). ESP32 membaca nilai ini lalu
menerapkan logika ambang. Untuk mencegah pompa hidup-mati cepat di sekitar
ambang, dipakai *dua ambang (histeresis)*:

```cpp
const int KERING = 2800;   // di atas ini = tanah kering -> siram
const int BASAH  = 2200;   // di bawah ini = cukup basah -> stop
bool pompaNyala = false;

void loop() {
  int tanah = analogRead(34);          // baca soil moisture (GPIO34)
  if (tanah > KERING) pompaNyala = true;   // kering -> pompa ON
  if (tanah < BASAH)  pompaNyala = false;  // basah -> pompa OFF
  digitalWrite(26, pompaNyala ? HIGH : LOW);  // relay -> pompa
  delay(1000);
}
```

Angka `KERING`/`BASAH` *wajib dikalibrasi*: ukur nilai `analogRead` saat sensor
di udara/tanah kering vs saat ujung sensor dicelup air, lalu pilih dua angka di
antaranya. Nilai pasti berbeda per sensor dan per media tanam.

#warn[Pompa *jangan* ditenagai dari pin ESP32 — arusnya terlalu besar dan akan
merusak board. Pompa diberi daya langsung dari baterai/5V, dan ESP32 hanya
mengontrol *relay* (sinyal kecil) yang menyambung/memutus daya pompa. Pola ini
sama dengan relay di Lab Fire Detector.]

== Paralel dengan lab utama

#table(
  columns: (1fr, 1fr, 1fr),
  inset: 6pt, stroke: 0.5pt + rgb("#cbd5e1"), align: left,
  [*Peran*], [*Fire Detector*], [*Smart Irrigation*],
  [Sensor analog], [MQ-2 (gas)], [Soil moisture (kelembapan)],
  [Logika], [gas > ambang #sym.arrow.r bahaya], [tanah > ambang #sym.arrow.r kering],
  [Aktuator (relay)], [kipas/pompa exhaust], [pompa penyiram],
  [Cloud], [Blynk], [Blynk],
)

Strukturnya identik. Yang berubah hanya *makna* angka sensor dan *apa* yang
diaktuasi — bukti bahwa satu pola IoT bisa dipakai ulang lintas kasus.
