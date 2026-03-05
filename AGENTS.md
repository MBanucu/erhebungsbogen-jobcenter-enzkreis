# AGENTS.md

## Project Overview

This project recreates a scanned 4-page German government form ("Erhebungsbogen" for Jobcenter Enzkreis) as a LaTeX document. The goal is to produce a PDF whose visual output matches the original scanned pages as closely as possible.

- **Language**: LaTeX (German content, `ngerman` babel)
- **License**: GPL-3.0
- **Single source file**: `main.tex` (all 4 pages)

## Environment Setup

The project uses **Nix flakes** with **direnv** for reproducible tooling. Entering the directory (with direnv allowed) automatically loads the dev shell.

Key tools provided by the flake:
- `tectonic` -- LaTeX compiler (replaces pdflatex/lualatex, auto-downloads packages)
- `texlab` -- LSP server for editor integration
- `imagemagick` + `ghostscript` -- PDF-to-JPG conversion
- `zathura` -- PDF viewer

If direnv is not set up, run `nix develop` manually.

## Build Commands

### Full build (PDF + JPG previews)

```bash
bash build.sh
```

This runs:
1. `tectonic main.tex --outdir=build` -- compiles `main.tex` to `build/main.pdf`
2. `magick -density 600 -quality 75 build/main.pdf build/main.jpg` -- renders each PDF page as a 600 DPI JPG (`build/main-0.jpg` through `build/main-3.jpg`)

### LaTeX only

```bash
tectonic main.tex --outdir=build
```

### Watch mode (live rebuild)

```bash
tectonic --watch main.tex
```

Note: watch mode does not produce JPGs. Run the full `build.sh` when you need to compare visual output.

## Directory Structure

```
.
├── main.tex                  # LaTeX source (all 4 pages)
├── build.sh                  # Build script (tectonic + magick)
├── build/                    # Build output (gitignored)
│   ├── main.pdf              # Compiled PDF
│   ├── main-0.jpg            # Page 1 render (600 DPI)
│   ├── main-1.jpg            # Page 2 render
│   ├── main-2.jpg            # Page 3 render
│   ├── main-3.jpg            # Page 4 render
│   └── ocr-original.txt      # OCR text extracted from original scans
├── original/                 # Scanned original form pages (reference)
│   ├── IMG_20251029_125921_592.jpg   # Page 1
│   ├── IMG_20251029_125943_079.jpg   # Page 2
│   ├── IMG_20251029_125959_135.jpg   # Page 3
│   └── IMG_20251029_130018_500.jpg   # Page 4
├── flake.nix                 # Nix flake (dev environment)
├── flake.lock
├── .envrc                    # direnv config ("use flake")
├── .gitignore
├── LICENSE                   # GPL-3.0
└── README.md
```

## Working on `main.tex`

### General approach

1. View the original scan for the target page (`original/IMG_*.jpg`)
2. View the current build output (`build/main-N.jpg` where N = page - 1)
3. Edit `main.tex` to bring the build closer to the original
4. Run `bash build.sh` to recompile and re-render
5. Compare again; iterate

### LaTeX conventions used

- **Font**: Helvetica (`helvet` package, `\sfdefault`)
- **Base font size**: 10pt on A4 paper
- **Margins**: 1.5cm left/right/bottom, 1.8cm top
- **No paragraph indent** (`\parindent=0pt`, `\parskip=0pt`)
- **Form sections** (`\formsection{...}`): bold text headings, NOT boxed
- **Form subsections** (`\formsubsection{...}`): bold text inside bordered boxes
- **Bordered boxes**: Use `\fbox{\begin{minipage}...}` pattern for content areas
- **Checkboxes**: `\cb` for empty (`$\square$`), `\cbx` for checked (`$\boxtimes$`)
- **Underline fields**: `\formline{<width>}` (e.g., `\formline{8cm}`)
- **Tables**: Use `tabularx` with `X` columns for flexible width
- **Page headers/footers**: `fancyhdr` -- no header rule, right footer shows "Seite N"

### Page structure in `main.tex`

| Lines (approx) | Content |
|---|---|
| 1-52 | Preamble, packages, custom commands, page style |
| 53-162 | **Page 1**: Header, Aktenzeichen, Teil 1 (4 bordered boxes) |
| 163-253 | **Page 2**: Teil 2 -- Berufliche Daten (bordered heading box, checkboxes, tables) |
| 254-310 | **Page 3**: Sprachkenntnisse (bordered box) + Teil 3 -- Vorbereitung Vermittlungsgespr\"ach (bordered box with tables + famili\"ares Umfeld) |
| 311-363 | **Page 4**: Teil 4 -- Migrationshintergrund (tables + Zus\"atzliche Fragen box) |

### Current status

- **Page 1**: Complete -- matches original.
- **Page 2**: Complete -- matches original.
- **Page 3**: Complete -- matches original.
- **Page 4**: Rewritten to match original. Note: `main.tex` includes a signature line (Ort, Datum / Unterschrift) at the bottom that does NOT appear on the original scan -- may need removal.

### Common pitfalls

- Tectonic auto-downloads packages on first use; needs internet for initial build.
- `\fbox` adds `\fboxsep` and `\fboxrule` to width -- use `\dimexpr\textwidth-2\fboxsep-2\fboxrule\relax` for full-width minipages inside `\fbox`.
- The `formgray` color is defined as white (`{1,1,1}`) -- it is used by `\rowcolor{formgray}` in tables on pages 2-4. Do not remove it.
- German special characters: use `\"a`, `\"o`, `\"u`, `{\ss}` (or `\ss`) for umlauts and eszett. The document uses `inputenc` with UTF-8 but the source currently uses LaTeX escape sequences.
- Underfull/overfull hbox warnings are common with form layouts; minor ones are acceptable. Fix any that cause visible layout issues.

### Visual comparison tips

- The original scans are phone photos of a printed form -- expect slight perspective distortion, shadows, and uneven lighting. Focus on structural layout, not pixel-perfect matching.
- Key things to match: box borders, field positions, label text, spacing between sections, header/footer placement, checkbox alignment.
- The `build/ocr-original.txt` file contains OCR-extracted text from the originals, useful for verifying exact label wording.
