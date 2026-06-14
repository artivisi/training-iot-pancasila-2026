ASSETS := assets/logo-stmik.svg assets/logo-artivisi.svg

.PHONY: all sample clean

# Sertifikat asli: butuh names.txt (data pribadi, tidak di-commit).
all: certificate.pdf

certificate.pdf: certificate.typ names.txt $(ASSETS)
	typst compile --root .. certificate.typ certificate.pdf

names.txt:
	@echo "==> names.txt belum ada (berisi nama peserta -> tidak di-commit)."
	@echo "    Salin contoh lalu isi nama asli, satu nama per baris:"
	@echo "      cp names.txt.example names.txt"
	@exit 1

# Pratinjau desain dengan nama placeholder (boleh di-commit).
sample: certificate-sample.pdf

certificate-sample.pdf: certificate.typ names.txt.example $(ASSETS)
	typst compile --root .. --input names=names.txt.example certificate.typ certificate-sample.pdf

clean:
	rm -f certificate.pdf certificate-sample.pdf
