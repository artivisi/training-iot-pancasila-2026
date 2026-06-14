// =====================================================================
// SERTIFIKAT KEIKUTSERTAAN — Pelatihan IoT (PkM)
// STMIK Tazkia x Universitas Pancasila 2026
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
#let tanggal = "Juni 2026"
#let nomor-prefix = "PkM-IoT/UP/VI/2026"   // format nomor sertifikat

// ---- Sumber nama peserta ----
// File nama bisa ditentukan saat compile: typst compile --input names=<file>.
// Tanpa itu, pakai names.txt (yang harus dibuat dari names.txt.example).
#let names-file = sys.inputs.at("names", default: "names.txt")
#let names = (
  read(names-file).split("\n").map(s => s.trim()).filter(s => s != "")
)

// ---- Gaya ----
#let brand = rgb("#1e3a8a")
#let accent = rgb("#ea580c")
#let mute = rgb("#475569")
#let serif = ("Georgia", "Times New Roman")

#set page(paper: "a4", flipped: true, margin: 0pt)
#set text(font: ("Helvetica Neue", "Arial"), fill: rgb("#0f172a"))

#let ttd(jabatan, nama, instansi) = align(center)[
  #text(size: 11pt, fill: mute)[#jabatan]
  #v(1.1cm)
  #text(size: 13pt, weight: "bold")[#nama]
  #line(length: 5.5cm, stroke: 0.6pt + mute)
  #text(size: 10pt, fill: mute)[#instansi]
]

#let cert(no, nama) = {
  // Bingkai ganda
  place(top + left, dx: 0.9cm, dy: 0.9cm,
    rect(width: 100% - 1.8cm, height: 100% - 1.8cm,
      stroke: 2.2pt + brand, radius: 8pt))
  place(top + left, dx: 1.2cm, dy: 1.2cm,
    rect(width: 100% - 2.4cm, height: 100% - 2.4cm,
      stroke: 0.8pt + accent, radius: 6pt))

  // Nomor sertifikat (pojok kanan atas, di dalam bingkai)
  place(top + right, dx: -1.7cm, dy: 1.7cm,
    text(size: 9pt, fill: mute)[No: #no])

  // Seluruh isi dalam satu kolom setinggi halaman; v(1fr) mendorong
  // blok tanda tangan ke bawah sehingga tidak pernah bertabrakan.
  block(width: 100%, height: 100%, inset: (x: 2.2cm, top: 1.5cm, bottom: 1.9cm))[
    #set align(center)
    #box(image("assets/logo-stmik.svg", height: 1.5cm))
    #h(1.1cm)
    #box(baseline: 0.2cm, image("assets/logo-artivisi.svg", height: 1.0cm))

    #v(0.5cm)
    #text(font: serif, size: 38pt, weight: "bold", fill: brand,
      tracking: 3pt)[SERTIFIKAT]
    #v(0.05cm)
    #text(size: 12pt, fill: accent, weight: "bold",
      tracking: 1pt)[KEIKUTSERTAAN · CERTIFICATE OF ATTENDANCE]

    #v(0.5cm)
    #text(size: 11pt, fill: mute)[Diberikan kepada]
    #v(0.25cm)
    #text(font: serif, size: 30pt, weight: "bold", fill: brand)[#nama]
    #v(-0.1cm)
    #line(length: 13cm, stroke: 0.8pt + accent)

    #v(0.5cm)
    #block(width: 23cm)[
      #set par(justify: false)
      #text(size: 12pt)[
        atas keikutsertaannya dalam #text(weight: "bold")[#kegiatan],
        kegiatan Pengabdian kepada Masyarakat (PkM) yang diselenggarakan oleh
        #text(weight: "bold")[STMIK Tazkia] bekerja sama dengan
        #text(weight: "bold")[Universitas Pancasila], didukung oleh
        PT ArtiVisi Intermedia. Meliputi lab Fire Detector (monitoring kualitas
        udara) dan Smart Absensi berbasis ESP32.
      ]
    ]

    #v(0.45cm)
    #text(size: 11pt, fill: mute)[#kota, #tanggal]

    #v(1fr)
    #block(width: 22cm)[
      #grid(columns: (1fr, 1fr), align: center + horizon,
        ttd("Pelaksana PkM / Trainer", "Endy Muhardin", "STMIK Tazkia · PT ArtiVisi Intermedia"),
        ttd("Mengetahui, Mitra", " ", "Universitas Pancasila"),
      )
    ]
  ]
}

#for (i, nama) in names.enumerate() {
  if i > 0 { pagebreak() }
  let no = nomor-prefix
  let urut = str(i + 1)
  while urut.len() < 3 { urut = "0" + urut }
  cert(urut + "/" + no, nama)
}
