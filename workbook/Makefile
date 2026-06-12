TYPST_SOURCES := WORKBOOK.typ
PDFS := $(TYPST_SOURCES:.typ=.pdf)

DOCS_DIR := ../docs
DOCS_PDFS := $(addprefix $(DOCS_DIR)/,$(PDFS))

MMD_SOURCES := $(wildcard diagrams/*.mmd)
PNG_DIAGRAMS := $(MMD_SOURCES:.mmd=.png)

PUPPETEER_CONFIG := diagrams/puppeteer-config.json
MERMAID_CONFIG := diagrams/mermaid-config.json

# Firmware di-embed ke workbook lewat read() -> jadikan dependency supaya
# perubahan kode otomatis memicu recompile PDF.
FIRMWARE := ../firmware/fire-detector/fire-detector.ino \
	../firmware/smart-absensi/smart-absensi.ino

.PHONY: all watch clean diagrams

all: $(PDFS) $(DOCS_PDFS)

# --root .. supaya read() bisa embed firmware dari ../firmware (di luar workbook/
# tapi masih di dalam repo).
%.pdf: %.typ $(PNG_DIAGRAMS) $(FIRMWARE)
	typst compile --root .. $<

$(DOCS_DIR)/%.pdf: %.pdf
	cp $< $@

diagrams: $(PNG_DIAGRAMS)

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
	rm -f $(PDFS) $(DOCS_PDFS)
