#!/usr/bin/env bash

tectonic main.tex --outdir=build

# convert pdf to png
for file in build/*.pdf; do \
    magick -density 600 -quality 75 \"\$file\" \"\${file%.pdf}.jpg\"; \
done"