#!/usr/bin/env bash
# Build one per-country OFF pack from the extracted intermediate parquet:
#   build_pack.sh <country_tag> <country_code> <out_dir> <extracted.parquet>
#   e.g. build_pack.sh en:switzerland ch out/ .cache/extracted.parquet
# (Run build_all.sh to produce the intermediate first.) Produces
# <out_dir>/region_<cc>.sqlite(.gz) with a products table + FTS5 index, and
# prints row count + gzip size + sha256.
set -euo pipefail

TAG="$1"; CC="$2"; OUTDIR="$3"
SRC="${4:-.cache/extracted.parquet}"
DIR="$(cd "$(dirname "$0")" && pwd)"
OUT="$OUTDIR/region_${CC}.sqlite"

mkdir -p "$OUTDIR"
rm -f "$OUT" "$OUT.gz"

echo "[$CC] building from $(basename "$SRC") ..."
# Escape backslash, the | delimiter, and & (sed whole-match) — a checkout
# path containing any of them would otherwise corrupt the generated SQL.
sed_esc() { printf '%s' "$1" | sed -e 's/[\\&|]/\\&/g'; }
sed "s|__SRC__|$(sed_esc "$SRC")|g; s|__COUNTRY_TAG__|$(sed_esc "$TAG")|g; s|__OUT__|$(sed_esc "$OUT")|g" \
  "$DIR/build_region.sql.tmpl" | duckdb

echo "[$CC] dedup + index + FTS5 ..."
N=$(python3 "$DIR/finalize_pack.py" "$OUT")
gzip -9 -n -k -f "$OUT"  # -n: no timestamp/name -> deterministic bytes
SHA=$(sha256sum "$OUT.gz" | cut -d' ' -f1)
echo "[$CC] rows=$N  sqlite=$(du -h "$OUT" | cut -f1)  gz=$(du -h "$OUT.gz" | cut -f1)  sha256=$SHA"
