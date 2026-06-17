// =====================================================================
// SERTIFIKAT PELATIHAN — Pelatihan IoT (PkM)
// STMIK Tazkia x Universitas Pancasila 2026
//
// Gaya mengikuti sertifikat LSP Universitas Pancasila (permintaan mitra):
// judul skrip, ornamen sudut geometris (oranye/merah/hitam), struktur
// "Dengan hormat diberikan kepada".
//
// Output: A4 landscape PDF, satu halaman per peserta.
// Nama peserta dibaca dari "names.txt" (satu nama per baris).
//   - names.txt TIDAK di-commit (data pribadi) -> lihat names.txt.example.
//   - Salin: cp names.txt.example names.txt, lalu isi nama asli.
// Build: make   (atau: typst compile --root .. certificate.typ)
// =====================================================================

// ---- Isi sesuai acara (edit di sini) ----
#let kegiatan = "Pelatihan Internet of Things (IoT) berbasis ESP32"
#let kota = "Jakarta"
#let tanggal = "14 & 16 Juni 2026"
#let tempat = "Kampus Universitas Pancasila, Jakarta"
#let nomor-prefix = "PkM-IoT/UP/VI/2026"   // format nomor sertifikat

// ---- Sumber nama peserta ----
// File nama bisa ditentukan saat compile: typst compile --input names=<file>.
// Tanpa itu, pakai names.txt (yang harus dibuat dari names.txt.example).
#let names-file = sys.inputs.at("names", default: "names.txt")
#let names = (
  read(names-file).split("\n").map(s => s.trim()).filter(s => s != "")
)

// ---- Gaya ----
// Palet warna korporat STMIK Tazkia + ArtiVisi (bukan warna sertifikat acuan):
//   STMIK  -> biru #194189, oranye #ee7b1d
//   ArtiVisi -> indigo #2e3192, hijau #58c034
#let navy = rgb("#194189")    // STMIK — warna utama (judul, nama, header tabel)
#let indigo = rgb("#2e3192")  // ArtiVisi — ornamen sudut
#let orange = rgb("#ee7b1d")  // STMIK — aksen (garis, ornamen)
#let green = rgb("#58c034")   // ArtiVisi — aksen ornamen
#let dark = rgb("#1f2937")    // teks isi (netral, agar mudah dibaca)
#let mute = rgb("#475569")
#let script = ("Snell Roundhand", "Savoye LET", "Apple Chancery")
#let sans = ("Helvetica Neue", "Arial")

#set page(paper: "a4", flipped: true, margin: 0pt)
#set text(font: sans, fill: dark)

// Dimensi halaman A4 landscape (dipakai untuk menempatkan ornamen sudut).
#let pw = 29.7cm
#let ph = 21cm

// Ornamen halaman: bingkai ganda korporat (navy + oranye) dengan aksen sudut
// dua-warna — oranye (STMIK) & hijau (ArtiVisi). Desain sendiri, bukan acuan.
#let tri(col, ..pts) = place(top + left, polygon(fill: col, ..pts))

#let ornament = {
  // Aksen sudut: segitiga navy + tip warna brand, di dalam bingkai.
  let m = 1.3cm    // jarak dari tepi halaman
  let s = 2.6cm    // panjang kaki segitiga navy
  let t = 1.15cm   // panjang kaki tip aksen
  // basis navy di tiap sudut
  tri(navy, (m, m), (m + s, m), (m, m + s))
  tri(navy, (pw - m, m), (pw - m - s, m), (pw - m, m + s))
  tri(navy, (m, ph - m), (m + s, ph - m), (m, ph - m - s))
  tri(navy, (pw - m, ph - m), (pw - m - s, ph - m), (pw - m, ph - m - s))
  // tip aksen: oranye (kiri-atas, kanan-bawah), hijau (kanan-atas, kiri-bawah)
  tri(orange, (m, m), (m + t, m), (m, m + t))
  tri(green, (pw - m, m), (pw - m - t, m), (pw - m, m + t))
  tri(green, (m, ph - m), (m + t, ph - m), (m, ph - m - t))
  tri(orange, (pw - m, ph - m), (pw - m - t, ph - m), (pw - m, ph - m - t))
  // bingkai ganda di atas aksen
  place(top + left, dx: 0.7cm, dy: 0.7cm,
    rect(width: 100% - 1.4cm, height: 100% - 1.4cm, stroke: 1.8pt + navy, radius: 6pt))
  place(top + left, dx: 1.0cm, dy: 1.0cm,
    rect(width: 100% - 2.0cm, height: 100% - 2.0cm, stroke: 0.7pt + orange, radius: 4pt))
}

// ---- Daftar materi pelatihan (halaman 2, mengikuti gaya "Daftar Unit") ----
// Total 16 jam (2 hari). Edit di sini bila kurikulum berubah.
#let materi-rows = (
  ("1", "Arduino IDE, ESP32, driver USB, akun Blynk",
   "Fundamental IoT & Instalasi Perangkat Lunak", "3 Jam"),
  ("2", "Breadboard, LED, sensor, WiFi",
   "Dasar Elektronika: Menyalakan LED, Membaca Sensor, Koneksi WiFi & Pengiriman Data ke Blynk", "3 Jam"),
  ("3", "ESP32, MQ-2/flame, DHT, buzzer, relay",
   "Lab Fire Detector: Sensor Gas/Asap, Ambang Batas, Notifikasi & Aktuasi", "4 Jam"),
  ("4", "ESP32, RFID RC522, OLED, buzzer",
   "Lab Smart Absensi: SPI, Pembacaan Kartu RFID, Pengiriman Log ke Cloud", "4 Jam"),
  ("5", "ESP32, soil moisture sensor, pompa",
   "Demonstrasi Smart Irrigation & Sesi Penutup", "2 Jam"),
)

#let ttd(jabatan, nama, instansi) = align(center)[
  // Nama & instansi dirapatkan ke garis; spasi besar di atas (antara jabatan
  // dan nama) adalah ruang tanda tangan digital + QR code.
  #set par(spacing: 0.12cm)
  #text(size: 10pt, fill: mute)[#jabatan]
  #v(2.3cm)
  #text(size: 12pt, weight: "bold")[#nama]
  #line(length: 5.2cm, stroke: 0.6pt + mute)
  #text(size: 9.5pt, fill: mute)[#instansi]
]

#let cert(no, nama) = {
  ornament

  // Nomor sertifikat, kecil, di bawah blok tengah.
  place(bottom + center, dy: -1.15cm,
    text(size: 8.5pt, fill: mute)[No: #no])

  block(width: 100%, height: 100%, inset: (x: 3.4cm, top: 1.2cm, bottom: 1.2cm))[
    #set align(center)
    #box(image("assets/logo-stmik.svg", height: 1.0cm))
    #h(1.0cm)
    #box(baseline: 0.2cm, image("assets/logo-artivisi.svg", height: 0.68cm))

    #v(0.05cm)
    #text(font: script, size: 34pt, weight: "bold", fill: navy)[Sertifikat Pelatihan]
    #v(-0.05cm)
    #line(length: 6cm, stroke: 0.8pt + orange)

    #v(0.15cm)
    #text(size: 10.5pt, fill: mute)[Dengan hormat diberikan kepada,]

    #v(0.15cm)
    #text(font: sans, size: 28pt, weight: 800, fill: navy)[#nama]

    #v(0.18cm)
    #text(size: 10.5pt, fill: mute)[Yang Telah Mengikuti Kegiatan :]
    #v(0.06cm)
    #text(size: 14pt, weight: "bold", fill: navy)[#kegiatan]

    #v(0.16cm)
    #text(size: 10.5pt, fill: mute)[Yang Diselenggarakan Oleh :]
    #v(0.06cm)
    #block(width: 22cm)[
      #text(size: 10.5pt)[
        #text(weight: "bold")[STMIK Tazkia] bekerja sama dengan
        #text(weight: "bold")[Universitas Pancasila], didukung oleh
        PT ArtiVisi Intermedia. Kegiatan Pengabdian kepada Masyarakat (PkM),
        meliputi lab Fire Detector (monitoring kualitas udara) dan
        Smart Absensi berbasis ESP32.
      ]
    ]

    #v(1fr)
    #text(size: 10.5pt, fill: mute)[Pada tanggal #tanggal, bertempat di #tempat]
    #v(0.2cm)
    #block(width: 22cm)[
      #grid(columns: (1fr, 1fr), align: center + horizon,
        ttd("Pelaksana PkM / Trainer", "Endy Muhardin", "STMIK Tazkia · PT ArtiVisi Intermedia"),
        ttd("Mengetahui, Mitra", "Iman Paryudi", "Universitas Pancasila"),
      )
    ]
  ]
}

// Header logo dipakai di kedua halaman.
#let header-logo = [
  #box(image("assets/logo-stmik.svg", height: 1.25cm))
  #h(1.0cm)
  #box(baseline: 0.2cm, image("assets/logo-artivisi.svg", height: 0.85cm))
]

// Halaman 2: lampiran daftar materi (mengikuti gaya "Daftar Unit Kompetensi").
#let materi(no, nama) = {
  ornament

  block(width: 100%, height: 100%, inset: (x: 2.8cm, top: 1.3cm, bottom: 1.3cm))[
    #set align(center)
    #header-logo

    #v(0.25cm)
    #text(size: 20pt, weight: "bold", fill: navy, tracking: 1pt)[DAFTAR MATERI PELATIHAN]
    #v(0.1cm)
    #text(size: 10.5pt, fill: mute)[Lampiran Sertifikat No: #no — a.n. #text(weight: "bold", fill: navy)[#nama]]

    #v(0.4cm)
    #set text(size: 10pt)
    #table(
      columns: (1.3cm, 7cm, 1fr, 2.6cm),
      inset: 6.5pt,
      stroke: 0.6pt + rgb("#94a3b8"),
      align: (center + horizon, left + horizon, left + horizon, center + horizon),
      fill: (_, row) => if row == 0 { navy },
      table.header(
        text(fill: white, weight: "bold")[NO],
        text(fill: white, weight: "bold")[KOMPONEN UTAMA],
        text(fill: white, weight: "bold")[MATERI / KONSEP],
        text(fill: white, weight: "bold")[DURASI],
      ),
      ..materi-rows.map(r => (
        text(weight: "bold")[#r.at(0)], [#r.at(1)], [#r.at(2)],
        align(center)[#r.at(3)],
      )).flatten(),
      table.cell(colspan: 3, align: right)[#text(weight: "bold")[Total Durasi Pelatihan]],
      align(center)[#text(weight: "bold")[16 Jam]],
    )

    #v(1fr)
    #block(width: 22cm)[
      #grid(columns: (1fr, 1fr), align: center + horizon,
        ttd("Pelaksana PkM / Trainer", "Endy Muhardin", "STMIK Tazkia · PT ArtiVisi Intermedia"),
        ttd("Mengetahui, Mitra", "Iman Paryudi", "Universitas Pancasila"),
      )
    ]
  ]
}

#for (i, nama) in names.enumerate() {
  if i > 0 { pagebreak() }
  let no = nomor-prefix
  let urut = str(i + 1)
  while urut.len() < 3 { urut = "0" + urut }
  let full-no = urut + "/" + no
  cert(full-no, nama)
  pagebreak()
  materi(full-no, nama)
}
