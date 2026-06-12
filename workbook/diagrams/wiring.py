#!/usr/bin/env python3
"""Generate schematic wiring diagrams (SVG) for each lab from a pin map.

Mermaid tidak cocok untuk wiring (lihat CLAUDE.md), jadi diagram wiring
di-author sebagai SVG dari struktur data pin di bawah. Tiap koneksi
diberi warna sesuai PERAN kabel supaya pemula gampang menelusuri:

    5V  = merah        3.3V = oranye      GND = abu gelap
    sinyal/data = biru, hijau, ungu, cyan (dibedakan per koneksi)

Jalankan: python3 wiring.py   ->  menghasilkan wiring-*.svg
"""

# Palet warna per peran kabel.
C = {
    "5v": "#dc2626",
    "3v3": "#ea580c",
    "gnd": "#334155",
    "sig1": "#2563eb",
    "sig2": "#16a34a",
    "sig3": "#9333ea",
    "sig4": "#0891b2",
}
ROLE_LABEL = {"5v": "5V", "3v3": "3.3V", "gnd": "GND"}

W, H = 1200, 820
ESP_X, ESP_W = 470, 260           # board kiri-x, lebar
ESP_TOP, ESP_BOT = 150, 700
PAD_R = 5


def esc(s):
    return s.replace("&", "&amp;").replace("<", "&lt;").replace(">", "&gt;")


def bezier(x1, y1, x2, y2, color, width=3.0):
    # Lengkung horizontal: control point menjorok ke samping.
    dx = max(60, abs(x2 - x1) * 0.45)
    c1x = x1 + (dx if x2 > x1 else -dx)
    c2x = x2 + (-dx if x2 > x1 else dx)
    return (f'<path d="M {x1} {y1} C {c1x} {y1} {c2x} {y2} {x2} {y2}" '
            f'fill="none" stroke="{color}" stroke-width="{width}" '
            f'stroke-linecap="round"/>')


def dot(x, y, color):
    return f'<circle cx="{x}" cy="{y}" r="{PAD_R}" fill="{color}"/>'


def card(x, y, w, name, pins, side):
    """Komponen sebagai kartu. pins = list label baris. Return (svg, anchors).

    anchors: dict label -> (x, y) titik sambung di sisi dalam kartu.
    """
    row_h = 26
    head_h = 30
    h = head_h + row_h * len(pins) + 10
    inner_x = x + w if side == "left" else x      # sisi menghadap ESP32
    svg = [
        f'<rect x="{x}" y="{y}" width="{w}" height="{h}" rx="8" '
        f'fill="#ffffff" stroke="#94a3b8" stroke-width="1.5"/>',
        f'<rect x="{x}" y="{y}" width="{w}" height="{head_h}" rx="8" '
        f'fill="#1e3a8a"/>',
        f'<rect x="{x}" y="{y+head_h-8}" width="{w}" height="8" fill="#1e3a8a"/>',
        f'<text x="{x+w/2}" y="{y+20}" text-anchor="middle" '
        f'fill="#ffffff" font-size="14" font-weight="700">{esc(name)}</text>',
    ]
    anchors = {}
    for i, (label, role) in enumerate(pins):
        cy = y + head_h + row_h * i + row_h / 2 + 4
        tx = x + 12 if side == "left" else x + w - 12
        anchor = "start" if side == "left" else "end"
        svg.append(f'<text x="{tx}" y="{cy+4}" text-anchor="{anchor}" '
                   f'font-size="12.5" fill="#1e293b">{esc(label)}</text>')
        ax = inner_x
        svg.append(dot(ax, cy, C[role]))
        anchors[label] = (ax, cy)
    return "\n".join(svg), anchors


def esp_board(pads_left, pads_right):
    """Gambar ESP32 + pad pin. pads_* = list (label, role).
    Return (svg, anchors) anchors: label -> (x,y) di tepi board."""
    svg = [
        f'<rect x="{ESP_X}" y="{ESP_TOP}" width="{ESP_W}" '
        f'height="{ESP_BOT-ESP_TOP}" rx="14" fill="#0f172a" '
        f'stroke="#1e3a8a" stroke-width="2"/>',
        f'<text x="{ESP_X+ESP_W/2}" y="{ESP_TOP+34}" text-anchor="middle" '
        f'fill="#e2e8f0" font-size="17" font-weight="700">ESP32 DevKit V1</text>',
        f'<rect x="{ESP_X+ESP_W/2-22}" y="{ESP_TOP+48}" width="44" height="14" '
        f'rx="3" fill="#1e3a8a"/>',
        f'<text x="{ESP_X+ESP_W/2}" y="{ESP_TOP+59}" text-anchor="middle" '
        f'fill="#94a3b8" font-size="9">USB</text>',
    ]
    anchors = {}

    def place(pads, x_edge, side):
        n = len(pads)
        span_top, span_bot = ESP_TOP + 90, ESP_BOT - 30
        gap = (span_bot - span_top) / max(1, n - 1) if n > 1 else 0
        for i, (label, role) in enumerate(pads):
            cy = span_top + gap * i if n > 1 else (span_top + span_bot) / 2
            # pad kecil di tepi board
            px = x_edge
            svg.append(f'<rect x="{px-7 if side=="right" else px-7}" '
                       f'y="{cy-9}" width="14" height="18" rx="3" '
                       f'fill="{C[role]}"/>')
            # Label DI DALAM board (teks terang di atas board gelap).
            tx = x_edge + 14 if side == "left" else x_edge - 14
            anchor = "start" if side == "left" else "end"
            svg.append(f'<text x="{tx}" y="{cy+4}" text-anchor="{anchor}" '
                       f'fill="#e2e8f0" font-size="12.5" '
                       f'font-weight="600">{esc(label)}</text>')
            # Label power/GND bisa muncul di kedua sisi -> simpan sebagai list,
            # nanti dipilih pad yang sesisi dengan komponen.
            anchors.setdefault(label, []).append((x_edge, cy))

    place(pads_left, ESP_X, "left")
    place(pads_right, ESP_X + ESP_W, "right")
    return "\n".join(svg), anchors


def legend(items, x, y):
    svg = [f'<text x="{x}" y="{y-10}" font-size="12" font-weight="700" '
           f'fill="#475569">KETERANGAN WARNA</text>']
    for i, (role, label) in enumerate(items):
        ly = y + i * 22
        svg.append(f'<line x1="{x}" y1="{ly}" x2="{x+26}" y2="{ly}" '
                   f'stroke="{C[role]}" stroke-width="3.5" stroke-linecap="round"/>')
        svg.append(f'<text x="{x+34}" y="{ly+4}" font-size="12" '
                   f'fill="#334155">{esc(label)}</text>')
    return "\n".join(svg)


def build(title, subtitle, pads_left, pads_right, left_cards, right_cards,
          conns, note=None):
    out = [
        f'<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 {W} {H}" '
        f'font-family="Helvetica, Arial, sans-serif">',
        f'<rect width="{W}" height="{H}" fill="#ffffff"/>',
        f'<text x="{W/2}" y="40" text-anchor="middle" font-size="22" '
        f'font-weight="800" fill="#1e3a8a">{esc(title)}</text>',
        f'<text x="{W/2}" y="66" text-anchor="middle" font-size="13" '
        f'fill="#64748b">{esc(subtitle)}</text>',
    ]
    esp_svg, esp_anchors = esp_board(pads_left, pads_right)

    card_anchors = {}
    comp_side = {}
    card_svgs = []
    for (x, y, w, name, pins, side) in left_cards + right_cards:
        s, a = card(x, y, w, name, pins, side)
        card_svgs.append(s)
        card_anchors[name] = a
        comp_side[name] = side

    # Gambar kabel dulu (di belakang kartu & board).
    wire_svgs = []
    for (comp, comp_pin, esp_pin, role) in conns:
        x1, y1 = card_anchors[comp][comp_pin]
        pts = esp_anchors[esp_pin]
        if len(pts) > 1:
            # pad muncul di dua sisi -> pilih yang sesisi dgn komponen.
            pts = sorted(pts, key=lambda p: p[0])
            x2, y2 = pts[0] if comp_side[comp] == "left" else pts[-1]
        else:
            x2, y2 = pts[0]
        wire_svgs.append(bezier(x1, y1, x2, y2, C[role]))

    out += wire_svgs
    out.append(esp_svg)
    out += card_svgs

    legend_items = [("5v", "5V (power)"), ("3v3", "3.3V (power)"),
                    ("gnd", "GND (ground bersama)"), ("sig1", "sinyal / data")]
    out.append(legend(legend_items, 40, H - 92))
    if note:
        out.append(f'<text x="{W-40}" y="{H-30}" text-anchor="end" '
                   f'font-size="12" fill="#b45309">{esc(note)}</text>')
    out.append("</svg>")
    return "\n".join(out)


# ============================================================
# LAB FIRE DETECTOR
# ============================================================
fire = build(
    "Wiring Lab Fire Detector",
    "ESP32 + MQ-2 + Flame + DHT11 -> Buzzer + Relay + LED",
    pads_left=[("5V", "5v"), ("3V3", "3v3"), ("GPIO34", "sig1"),
               ("GPIO35", "sig2"), ("GPIO4", "sig3"), ("GND", "gnd")],
    pads_right=[("5V", "5v"), ("GPIO26", "sig4"), ("GPIO27", "sig2"),
                ("GPIO25", "sig3"), ("GND", "gnd")],
    left_cards=[
        (40, 150, 200, "MQ-2 (gas/asap)",
         [("VCC -> 5V", "5v"), ("AO -> divider 10k", "sig1"),
          ("GND", "gnd")], "left"),
        (40, 330, 200, "Flame sensor",
         [("VCC -> 3.3V", "3v3"), ("DO (digital)", "sig2"),
          ("GND", "gnd")], "left"),
        (40, 510, 200, "DHT11",
         [("VCC -> 3.3V", "3v3"), ("DATA", "sig3"), ("GND", "gnd")], "left"),
    ],
    right_cards=[
        (960, 170, 200, "Relay 5V (aktuator)",
         [("VCC -> 5V", "5v"), ("IN", "sig4"), ("GND", "gnd")], "right"),
        (960, 360, 200, "Buzzer active",
         [("(+)", "sig2"), ("(-)", "gnd")], "right"),
        (960, 520, 200, "LED + R220",
         [("anoda -> R220", "sig3"), ("katoda", "gnd")], "right"),
    ],
    conns=[
        ("MQ-2 (gas/asap)", "VCC -> 5V", "5V", "5v"),
        ("MQ-2 (gas/asap)", "AO -> divider 10k", "GPIO34", "sig1"),
        ("MQ-2 (gas/asap)", "GND", "GND", "gnd"),
        ("Flame sensor", "VCC -> 3.3V", "3V3", "3v3"),
        ("Flame sensor", "DO (digital)", "GPIO35", "sig2"),
        ("Flame sensor", "GND", "GND", "gnd"),
        ("DHT11", "VCC -> 3.3V", "3V3", "3v3"),
        ("DHT11", "DATA", "GPIO4", "sig3"),
        ("DHT11", "GND", "GND", "gnd"),
        ("Relay 5V (aktuator)", "VCC -> 5V", "5V", "5v"),
        ("Relay 5V (aktuator)", "IN", "GPIO26", "sig4"),
        ("Relay 5V (aktuator)", "GND", "GND", "gnd"),
        ("Buzzer active", "(+)", "GPIO27", "sig2"),
        ("Buzzer active", "(-)", "GND", "gnd"),
        ("LED + R220", "anoda -> R220", "GPIO25", "sig3"),
        ("LED + R220", "katoda", "GND", "gnd"),
    ],
    note="MQ-2 AO lewat pembagi tegangan 2x10k sebelum ke GPIO34 (pin ESP32 maks 3.3V).",
)

# ============================================================
# LAB SMART ABSENSI
# ============================================================
absensi = build(
    "Wiring Lab Smart Absensi",
    "ESP32 + RC522 (SPI) + OLED (I2C) -> Buzzer + LED",
    pads_left=[("GPIO5 (SS)", "sig1"), ("GPIO18 (SCK)", "sig1"),
               ("GPIO23 (MOSI)", "sig1"), ("GPIO19 (MISO)", "sig1"),
               ("GPIO4 (RST)", "sig1"), ("3V3", "3v3"), ("GND", "gnd")],
    pads_right=[("GPIO21 (SDA)", "sig4"), ("GPIO22 (SCL)", "sig4"),
                ("GPIO25", "sig2"), ("GPIO26", "sig3"),
                ("GPIO27", "sig2"), ("3V3", "3v3"), ("GND", "gnd")],
    left_cards=[
        (30, 150, 220, "RC522 (RFID, SPI)",
         [("SDA/SS", "sig1"), ("SCK", "sig1"), ("MOSI", "sig1"),
          ("MISO", "sig1"), ("RST", "sig1"), ("3.3V (JANGAN 5V)", "3v3"),
          ("GND", "gnd")], "left"),
    ],
    right_cards=[
        (950, 150, 220, "OLED 0.96 (I2C)",
         [("VCC -> 3.3V", "3v3"), ("GND", "gnd"), ("SDA", "sig4"),
          ("SCL", "sig4")], "right"),
        (950, 360, 220, "LED hijau / merah",
         [("hijau -> R220", "sig2"), ("merah -> R220", "sig3"),
          ("katoda (2x)", "gnd")], "right"),
        (950, 540, 220, "Buzzer active",
         [("(+)", "sig2"), ("(-)", "gnd")], "right"),
    ],
    conns=[
        ("RC522 (RFID, SPI)", "SDA/SS", "GPIO5 (SS)", "sig1"),
        ("RC522 (RFID, SPI)", "SCK", "GPIO18 (SCK)", "sig1"),
        ("RC522 (RFID, SPI)", "MOSI", "GPIO23 (MOSI)", "sig1"),
        ("RC522 (RFID, SPI)", "MISO", "GPIO19 (MISO)", "sig1"),
        ("RC522 (RFID, SPI)", "RST", "GPIO4 (RST)", "sig1"),
        ("RC522 (RFID, SPI)", "3.3V (JANGAN 5V)", "3V3", "3v3"),
        ("RC522 (RFID, SPI)", "GND", "GND", "gnd"),
        ("OLED 0.96 (I2C)", "VCC -> 3.3V", "3V3", "3v3"),
        ("OLED 0.96 (I2C)", "GND", "GND", "gnd"),
        ("OLED 0.96 (I2C)", "SDA", "GPIO21 (SDA)", "sig4"),
        ("OLED 0.96 (I2C)", "SCL", "GPIO22 (SCL)", "sig4"),
        ("LED hijau / merah", "hijau -> R220", "GPIO25", "sig2"),
        ("LED hijau / merah", "merah -> R220", "GPIO26", "sig3"),
        ("LED hijau / merah", "katoda (2x)", "GND", "gnd"),
        ("Buzzer active", "(+)", "GPIO27", "sig2"),
        ("Buzzer active", "(-)", "GND", "gnd"),
    ],
    note="RC522 wajib 3.3V. SPI = GPIO5/18/23/19, I2C OLED = GPIO21/22.",
)

with open("wiring-fire-detector.svg", "w") as f:
    f.write(fire)
with open("wiring-smart-absensi.svg", "w") as f:
    f.write(absensi)
print("wrote wiring-fire-detector.svg, wiring-smart-absensi.svg")
