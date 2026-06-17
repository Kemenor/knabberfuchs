#!/usr/bin/env python3
"""Publish built region packs + a manifest to the Hugging Face dataset.

Usage: HF_TOKEN=... python publish.py [out_dir] [version]
  version defaults to today's date (YYYYMMDD).

Reads regions.json for code/name/tag. The HF dataset is PUBLIC, so the app
downloads anonymously; only this upload needs the write token.
"""
import datetime
import hashlib
import json
import os
import sqlite3
import sys

from huggingface_hub import HfApi

REPO = os.environ.get("HF_REPO", "Knabberfuchs/offline-packs")
HERE = os.path.dirname(os.path.abspath(__file__))
OUTDIR = sys.argv[1] if len(sys.argv) > 1 else os.path.join(HERE, "out")
VERSION = sys.argv[2] if len(sys.argv) > 2 else datetime.date.today().strftime("%Y%m%d")
REGIONS = json.load(open(os.path.join(HERE, "regions.json")))

api = HfApi(token=os.environ["HF_TOKEN"])
api.create_repo(REPO, repo_type="dataset", exist_ok=True, private=False)


def sha256(path):
    h = hashlib.sha256()
    with open(path, "rb") as f:
        for chunk in iter(lambda: f.read(1 << 20), b""):
            h.update(chunk)
    return h.hexdigest()


regions_meta = []
for r in REGIONS:
    cc = r["code"]
    gz = os.path.join(OUTDIR, f"region_{cc}.sqlite.gz")
    sq = os.path.join(OUTDIR, f"region_{cc}.sqlite")
    if not os.path.exists(gz):
        print(f"skip {cc}: no pack at {gz}")
        continue
    count = sqlite3.connect(sq).execute("SELECT count(*) FROM products").fetchone()[0]
    path_in_repo = f"packs/{cc}/{VERSION}/region_{cc}.sqlite.gz"
    print(f"uploading {cc} ({count} products, {os.path.getsize(gz)} bytes) -> {path_in_repo}")
    api.upload_file(path_or_fileobj=gz, path_in_repo=path_in_repo,
                    repo_id=REPO, repo_type="dataset",
                    commit_message=f"pack {cc} {VERSION}")
    regions_meta.append({
        "code": cc, "name": r["name"], "country_tag": r["tag"],
        "version": VERSION, "products": count,
        "file": path_in_repo, "size": os.path.getsize(gz),
        "sha256": sha256(gz), "deltas": [],
    })

manifest = {
    "schema": 1,
    "updatedAt": datetime.datetime.now(datetime.timezone.utc).isoformat(),
    "baseUrl": f"https://huggingface.co/datasets/{REPO}/resolve/main",
    "attribution": "Product data from Open Food Facts (https://openfoodfacts.org), ODbL.",
    "regions": regions_meta,
}
mpath = os.path.join(OUTDIR, "manifest.json")
json.dump(manifest, open(mpath, "w"), indent=2)
api.upload_file(path_or_fileobj=mpath, path_in_repo="manifest.json",
                repo_id=REPO, repo_type="dataset", commit_message=f"manifest {VERSION}")
print(f"\nPublished {len(regions_meta)} region(s) to {REPO} (version {VERSION}).")
