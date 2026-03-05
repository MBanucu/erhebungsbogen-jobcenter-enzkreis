#!/usr/bin/env bash

set -euo pipefail

tectonic main.tex --outdir=build

# convert pdf to jpg
for file in build/*.pdf; do
    echo "Converting $file to ${file%.pdf}.jpg"
    magick -density 600 -quality 50 "$file" "${file%.pdf}.jpg"
done