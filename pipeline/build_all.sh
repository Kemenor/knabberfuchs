#!/usr/bin/env bash
# Build every region in regions.json from the OFF parquet (downloads it if not
# cached). Usage: build_all.sh [parquet_src]
set -euo pipefail
DIR="$(cd "$(dirname "$0")" && pwd)"
SRC="${1:-$DIR/.cache/food.parquet}"
OUTDIR="$DIR/out"
mkdir -p "$OUTDIR" "$(dirname "$SRC")"

if [ ! -f "$SRC" ]; then
  echo "downloading OFF food.parquet ..."
  curl -fSL -o "$SRC" \
    "https://huggingface.co/datasets/openfoodfacts/product-database/resolve/main/food.parquet"
fi

mapfile -t ROWS < <(python3 -c "import json;[print(r['tag'],r['code']) for r in json.load(open('$DIR/regions.json'))]")
for row in "${ROWS[@]}"; do
  # shellcheck disable=SC2086
  set -- $row
  "$DIR/build_pack.sh" "$1" "$2" "$OUTDIR" "$SRC"
done
echo "Built ${#ROWS[@]} region(s) into $OUTDIR"
