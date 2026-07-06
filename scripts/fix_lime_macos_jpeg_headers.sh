#!/usr/bin/env bash
set -euo pipefail

lime_path="$(haxelib libpath lime | tail -n 1)"

if [[ -z "$lime_path" || ! -d "$lime_path" ]]; then
  echo "Unable to locate the installed lime haxelib" >&2
  exit 1
fi

if [[ -f "$lime_path/lib/jpeg/jpeglib.h" || -f "$lime_path/lib/custom/jpeg/jpeglib.h" ]]; then
  echo "Lime already has bundled JPEG headers"
  exit 0
fi

jpeg_prefix=""
for formula in jpeg libjpeg-turbo; do
  if prefix="$(brew --prefix "$formula" 2>/dev/null)" && [[ -f "$prefix/include/jpeglib.h" ]]; then
    jpeg_prefix="$prefix"
    break
  fi
done

if [[ -z "$jpeg_prefix" ]]; then
  echo "Installing Homebrew jpeg headers for Lime rebuild"
  brew install jpeg
  jpeg_prefix="$(brew --prefix jpeg)"
fi

for include_dir in "$lime_path/lib/jpeg" "$lime_path/lib/custom/jpeg"; do
  mkdir -p "$include_dir"
  cp "$jpeg_prefix/include"/j*.h "$include_dir"/
done

echo "Copied JPEG headers from $jpeg_prefix into $lime_path/lib/jpeg and $lime_path/lib/custom/jpeg"
