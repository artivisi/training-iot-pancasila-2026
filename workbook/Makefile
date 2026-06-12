TYPST_SOURCES := WORKBOOK.typ
PDFS := $(TYPST_SOURCES:.typ=.pdf)

DOCS_DIR := ../docs
DOCS_PDFS := $(addprefix $(DOCS_DIR)/,$(PDFS))

MMD_SOURCES := $(wildcard diagrams/*.mmd)
PNG_DIAGRAMS := $(MMD_SOURCES:.mmd=.png)

# Diagram wiring di-generate dari wiring.py (Mermaid tidak cocok untuk wiring).
WIRING_SVGS := diagrams/wiring-fire-detector.svg diagrams/wiring-smart-absensi.svg

PUPPETEER_CONFIG := diagrams/puppeteer-config.json
MERMAID_CONFIG := diagrams/mermaid-config.json

# Firmware di-embed ke workbook lewat read() -> jadikan dependency supaya
# perubahan kode otomatis memicu recompile PDF.
FIRMWARE := ../firmware/fire-detector/fire-detector.ino \
	../firmware/smart-absensi/smart-absensi.ino

# Bundle firmware (.ino + secrets.h.example, TANPA secrets.h) jadi zip yang
# bisa di-download dari GitHub Pages.
DOCS_FW_DIR := $(DOCS_DIR)/firmware
DOCS_ZIPS := $(DOCS_FW_DIR)/fire-detector.zip $(DOCS_FW_DIR)/smart-absensi.zip

.PHONY: all watch clean diagrams

all: $(PDFS) $(DOCS_PDFS) $(DOCS_ZIPS)

# --root .. supaya read() bisa embed firmware dari ../firmware (di luar workbook/
# tapi masih di dalam repo).
%.pdf: %.typ $(PNG_DIAGRAMS) $(WIRING_SVGS) $(FIRMWARE)
	typst compile --root .. $<

# Recipe meng-generate kedua SVG sekaligus; idempotent kalau make memanggil
# ulang per-target (make 3.81 di macOS belum punya grouped target '&:').
$(WIRING_SVGS): diagrams/wiring.py
	cd diagrams && python3 wiring.py

$(DOCS_DIR)/%.pdf: %.pdf
	cp $< $@

# Zip dibuat dari dalam ../firmware supaya entри teratas = nama folder lab
# (mis. fire-detector/fire-detector.ino), siap dibuka di Arduino IDE.
$(DOCS_FW_DIR)/fire-detector.zip: ../firmware/fire-detector/fire-detector.ino ../firmware/fire-detector/secrets.h.example
	@mkdir -p $(DOCS_FW_DIR)
	@rm -f $@
	cd ../firmware && zip -rq "$(CURDIR)/$(DOCS_FW_DIR)/fire-detector.zip" fire-detector -x 'fire-detector/secrets.h'

$(DOCS_FW_DIR)/smart-absensi.zip: ../firmware/smart-absensi/smart-absensi.ino ../firmware/smart-absensi/secrets.h.example
	@mkdir -p $(DOCS_FW_DIR)
	@rm -f $@
	cd ../firmware && zip -rq "$(CURDIR)/$(DOCS_FW_DIR)/smart-absensi.zip" smart-absensi -x 'smart-absensi/secrets.h'

diagrams: $(PNG_DIAGRAMS) $(WIRING_SVGS)

diagrams/%.png: diagrams/%.mmd $(MERMAID_CONFIG) $(PUPPETEER_CONFIG)
	mmdc -i $< -o $@ -b white -w 1800 -c $(MERMAID_CONFIG) -p $(PUPPETEER_CONFIG)

$(PUPPETEER_CONFIG):
	@echo "==> $(PUPPETEER_CONFIG) belum ada."
	@echo "    Diagram Mermaid butuh Chrome untuk render via mmdc. Buat file:"
	@echo '    { "executablePath": "/Applications/Google Chrome.app/Contents/MacOS/Google Chrome" }'
	@exit 1

watch:
	typst watch --root .. WORKBOOK.typ

clean:
	rm -f $(PDFS) $(DOCS_PDFS) $(DOCS_ZIPS)
