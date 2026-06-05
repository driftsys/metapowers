#!/usr/bin/env bash
# Usage: check-aspect.sh <file.d2>
# Renders <file.d2> with the elk engine, reads the ROOT <svg> viewBox, and:
#   - prints the long/short aspect ratio to stdout (machine-readable)
#   - prints a human summary to stderr
#   - exits 0 iff ratio <= 2.5 (coarse "egregious strip" backstop)
# No network, no vision. Requires `d2` on PATH. Renders to a temp dir (never
# writes an SVG into the repo).
set -euo pipefail
d2f="${1:?usage: check-aspect.sh <file.d2>}"
tmp="$(mktemp -d)"; trap 'rm -rf "$tmp"' EXIT
svg="$tmp/out.svg"
D2_LAYOUT=elk d2 --omit-version "$d2f" "$svg" >/dev/null
vb="$(grep -o 'viewBox="[^"]*"' "$svg" | head -1 | sed 's/viewBox="//;s/"//')"
[[ -n "$vb" ]] || { echo "ERROR: no viewBox in render of $d2f (did d2 fail?)" >&2; exit 1; }
W="$(awk '{print $3}' <<<"$vb")"; H="$(awk '{print $4}' <<<"$vb")"
ratio="$(awk -v w="$W" -v h="$H" 'BEGIN{printf "%.2f",(w>h)?w/h:h/w}')"
threshold=2.5
band="$(awk -v r="$ratio" -v t="$threshold" 'BEGIN{print (r<=t)?"IN":"OUT"}')"
echo "$ratio"
echo "${d2f}: ${W}x${H} long/short=${ratio} band=${band}" >&2
awk -v r="$ratio" -v t="$threshold" 'BEGIN{exit !(r<=t)}'
