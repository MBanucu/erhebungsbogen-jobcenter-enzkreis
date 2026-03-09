#!/usr/bin/env bash

set -euo pipefail

mkdir -p build
tectonic main.tex --outdir=build --keep-intermediates -Z search-path=./fonts
