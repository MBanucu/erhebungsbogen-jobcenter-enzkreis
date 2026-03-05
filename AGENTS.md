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
│   └── main-3.jpg            # Page 4 render
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

### Current status

- **Page 1**: Complete -- matches original.
- **Page 2**: Complete -- matches original.
- **Page 3**: Complete -- matches original.
- **Page 4**: Complete -- matches original.

### Common pitfalls

- Tectonic auto-downloads packages on first use; needs internet for initial build.
- `\fbox` adds `\fboxsep` and `\fboxrule` to width -- use `\dimexpr\textwidth-2\fboxsep-2\fboxrule\relax` for full-width minipages inside `\fbox`.

### Visual comparison tips

- The original scans are phone photos of a printed form -- expect slight perspective distortion, shadows, and uneven lighting. Focus on structural layout, not pixel-perfect matching.
- Key things to match: box borders, field positions, label text, spacing between sections, header/footer placement, checkbox alignment.
