#!/usr/bin/env bash

set -euo pipefail

now=$(date +%Y%m%dT-%H%M%S%z)
build_dir=build/$now
mkdir -p $build_dir
cp mwe.tex $build_dir/mwe.tex
(
    tectonic $build_dir/mwe.tex --outdir=$build_dir --keep-intermediates -Z search-path=./fonts
    cp $build_dir/mwe.pdf build/mwe.pdf
) > $build_dir/build.log 2>&1 &