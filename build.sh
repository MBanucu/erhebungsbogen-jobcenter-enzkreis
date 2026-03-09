#!/usr/bin/env bash

set -euo pipefail

now=$(date +%Y%m%dT-%H%M%S%z)
build_dir=build/$now
mkdir -p $build_dir
cp main.tex $build_dir/main.tex
(
    tectonic $build_dir/main.tex --outdir=$build_dir --keep-intermediates -Z search-path=./fonts
    cp $build_dir/main.pdf build/main.pdf
) > $build_dir/build.log 2>&1 &