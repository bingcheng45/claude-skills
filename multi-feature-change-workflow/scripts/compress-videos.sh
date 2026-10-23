#!/usr/bin/env bash
# Compress every .mp4 under a folder for publishing in an artifact.
#   compress-videos.sh <src-dir> <out-dir> [preset]
# Output names are <unit>--<clip>.mp4, where <unit> is the clip's parent folder and <clip> its name.
# Builds export-video.swift once into a temp file, so no ffmpeg is needed. macOS only.
set -euo pipefail
src="${1:-}"; out="${2:-}"; preset="${3:-AVAssetExportPreset1920x1080}"
[ -d "$src" ] && [ -n "$out" ] || { echo "usage: compress-videos.sh <src-dir> <out-dir> [preset]" >&2; exit 1; }
here="$(cd "$(dirname "$0")" && pwd)"
bin="$(mktemp -t export-video)"
swiftc -O "$here/export-video.swift" -o "$bin" 2>/dev/null
mkdir -p "$out"
find "$src" -name '*.mp4' -not -path '*/baseline/*' -print0 | while IFS= read -r -d '' f; do
  unit="$(basename "$(dirname "$f")")"
  clip="$(basename "$f" .mp4)"
  "$bin" "$f" "$out/$unit--$clip.mp4" "$preset" >/dev/null && echo "$unit--$clip.mp4 $(du -h "$out/$unit--$clip.mp4" | cut -f1)"
done
rm -f "$bin"
