{
  description = "LaTeX-Entwicklungsumgebung mit Tectonic (modernes TeX)";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs =
    {
      self,
      nixpkgs,
      flake-utils,
    }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = import nixpkgs {
          inherit system;
          # config.allowUnfree = true;   # falls du später unfree-Pakete brauchst (z. B. bestimmte Fonts)
        };
      in
      {
        # ────────────────────────────────────────────────
        # Entwicklungsshell → nix develop
        # ────────────────────────────────────────────────
        devShells.default = pkgs.mkShell {
          name = "latex-tectonic-shell";

          packages = with pkgs; [
            tectonic # der Star: selbstständiges LaTeX → tectonic main.tex
            texlab # LSP-Server → gut für neovim, helix, vscode + latex-workshop
            # latexindent          # Formatter (optional)
            # tex-fmt              # alternativer Formatter

            # Hilfreiche Tools
            zathura # leichter PDF-Viewer mit SyncTeX-Unterstützung
            # okular               # alternativer Viewer mit mehr Features
            graphviz # falls du dot-Grafiken in LaTeX einbindest
            # pandoc             # für Markdown → LaTeX Konvertierungen

            # file watcher
            entr

            bashInteractive
          ];

          shellHook = ''
            echo "Tectonic-LaTeX-Umgebung geladen"
            echo "  → tectonic main.tex          (einmalig kompilieren + Abhängigkeiten holen)"
            echo "  → tectonic --watch main.tex   (live watch + rebuild)"
            echo "  → ./build.sh                  (PDF + JPGs bauen)"
            echo "  → echo main.tex | entr -s './build.sh'  (auto-rebuild bei Änderungen)"
            echo ""
            echo "Tipp für VSCode / Neovim:"
            echo "  Stelle latex-workshop oder texlab auf tectonic ein"
          '';
        };

        # Optional: Wenn du das PDF direkt als flake-Package bauen möchtest
        # (z. B. für CI oder nix build .#document)
        packages.document = pkgs.stdenvNoCC.mkDerivation {
          name = "my-latex-document";
          src = ./.;

          buildInputs = with pkgs; [ tectonic ];

          buildPhase = ''
            tectonic main.tex
          '';

          installPhase = ''
            mkdir -p $out
            cp main.pdf $out/
          '';

          meta.description = "Mein LaTeX-Dokument, gebaut mit Tectonic";
        };

        # ────────────────────────────────────────────────
        # Standard-Ausgaben
        # ────────────────────────────────────────────────
        apps.default = flake-utils.lib.mkApp {
          drv = self.packages.${system}.document;
        };

      }
    );
}
