#!/usr/bin/env bash
# Build every region in regions.json. One-time extraction from the 7 GB OFF
# parquet into a small intermediate, then a fast per-country pass over that.
# Usage: build_all.sh [parquet_src]
#   PYTHON=...           python with duckdb+pycountry (for gen_regions, optional)
#   REGEN_REGIONS=1      regenerate regions.json from the parquet first
set -euo pipefail
DIR="$(cd "$(dirname "$0")" && pwd)"
SRC="${1:-$DIR/.cache/food.parquet}"
EXTRACT="$DIR/.cache/extracted.parquet"
OUTDIR="$DIR/out"
PYTHON="${PYTHON:-python3}"
mkdir -p "$OUTDIR" "$(dirname "$SRC")"

if [ ! -f "$SRC" ]; then
  echo "downloading OFF food.parquet ..."
  curl -fSL -o "$SRC" \
    "https://huggingface.co/datasets/openfoodfacts/product-database/resolve/main/food.parquet"
fi

if [ "${REGEN_REGIONS:-0}" = "1" ]; then
  echo "regenerating regions.json ..."
  OFF_PARQUET="$SRC" "$PYTHON" "$DIR/gen_regions.py"
fi

echo "extracting intermediate from $(basename "$SRC") ..."
# Escape backslash, the | delimiter, and & (sed whole-match) — a checkout
# path containing any of them would otherwise corrupt the generated SQL.
sed_esc() { printf '%s' "$1" | sed -e 's/[\\&|]/\\&/g'; }
sed "s|__SRC__|$(sed_esc "$SRC")|g; s|__EXTRACT__|$(sed_esc "$EXTRACT")|g" \
  "$DIR/build_extract.sql.tmpl" | duckdb
echo "intermediate -> $EXTRACT ($(du -h "$EXTRACT" | cut -f1))"

# Free the 7 GB source after extraction (useful on disk-limited CI runners).
if [ "${FREE_SRC:-0}" = "1" ]; then rm -f "$SRC"; fi

mapfile -t ROWS < <(python3 -c "import json;[print(r['tag'],r['code']) for r in json.load(open('$DIR/regions.json'))]")
for row in "${ROWS[@]}"; do
  # shellcheck disable=SC2086
  set -- $row
  "$DIR/build_pack.sh" "$1" "$2" "$OUTDIR" "$EXTRACT"
done
echo "Built ${#ROWS[@]} region(s) into $OUTDIR"
