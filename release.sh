#!/usr/bin/env bash

set -euo pipefail

if [[ ! -f build/main.pdf ]]; then
  echo "Error: build/main.pdf not found. Run build.sh first."
  exit 1
fi

echo "Select version increase:"
echo "1) patch (e.g. v0.0.1 -> v0.0.2)"
echo "2) minor (e.g. v0.0.1 -> v0.1.0)"
echo "3) major (e.g. v0.0.1 -> v1.0.0)"
read -p "Choice (1/2/3): " choice

case $choice in
  1) increment=patch ;;
  2) increment=minor ;;
  3) increment=major ;;
  *) echo "Invalid choice"; exit 1 ;;
esac

current_tag=$(git describe --tags --abbrev=0 2>/dev/null || echo "v0.0.0")
current_version=${current_tag#v}

read maj min pat <<<$(echo $current_version | tr '.' ' ')

case $increment in
  patch) pat=$((pat + 1)) ;;
  minor) min=$((min + 1)); pat=0 ;;
  major) maj=$((maj + 1)); min=0; pat=0 ;;
esac

new_version="v${maj}.${min}.${pat}"
echo "Current version: $current_tag"
echo "New version: $new_version"

cp build/main.pdf docs/
git add docs/main.pdf
git commit -m "docs: update PDF to $new_version"
git tag "$new_version"

echo ""
echo "Run 'git push && git push --tags' to publish."
