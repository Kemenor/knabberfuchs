#!/usr/bin/env python3
"""Emit JSON {"pieces": [...], "densities": [...]} of Swiss FCDB foods that
plausibly deserve a natural-portion weight or a liquid density and aren't
covered yet. The curation workflow runs this, then assigns/verifies values.
Exact catalog English names are used so the join in build.py stays precise."""
import gzip, csv, json, os

HERE = os.path.dirname(os.path.abspath(__file__))
ASSET = os.path.join(HERE, "..", "..", "assets", "swiss_foods.csv.gz")
rows = list(csv.DictReader(gzip.open(ASSET, "rt", encoding="utf-8")))
covered = {r["name_en"].lower() for r in rows if r.get("serving_g") or r.get("density")}
rem = [r for r in rows if r["name_en"].lower() not in covered]


def low(r):
    return r["name_en"].lower()


NOISE = ["cooked", "prepared", "steamed", "baked", "fried", "canned", "pie",
         "gratin", "salad", "quiche", "ragout", "stew", "roasted", "grilled",
         "boiled", "breaded", "with addition", "dressing", "soup", "risotto",
         "casserole", "mashed", "filled"]
MEAT = ["beef", "pork", "veal", "chicken", "lamb", "turkey", "fish", "salmon",
        "tuna", "sardine", "meat", "offal", "liver", "kidney", "ham", "bacon",
        "duck", "goose", "rabbit", "horse", "game", "herring", "trout"]


def clean(r):
    return not any(n in low(r) for n in NOISE)


produce = [r for r in rem if (low(r).endswith(", raw") or low(r).endswith(", fresh")
           or low(r).endswith(", dried")) and clean(r)
           and not any(m in low(r) for m in MEAT)]
COUNT = ["sausage", "wurst", "cervelat", "schüblig", "schublig", "landjäger",
         " roll", "croissant", "cookie", "biscuit", " bun", "pretzel", "muffin",
         "waffle", "tortilla", "crispbread", "rice cake", "egg, ", "leckerli",
         "amaretti", "brunsli", "donut", "macaroon", "madeleine", "for slicing"]
countable = [r for r in rem if any(k in low(r) for k in COUNT) and clean(r)]

pieces = sorted({r["name_en"] for r in produce} | {r["name_en"] for r in countable})

DRINK = ["drink", "juice", "beer", "wine", "cola", "soda", "lemonade", "nectar",
         "milk", "oil", "syrup", "vinegar", "cream", "yogurt drink", "kefir",
         "liqueur", "spirit", "smoothie", "sauce", "ketchup", "mayonnaise",
         "tea", "coffee", "cocoa", "water,", "champagne", "cider", "whisky",
         "vodka", "rum", "gin", "schnapps"]
densities = sorted({r["name_en"] for r in rem
                    if any(k in low(r) for k in DRINK) and clean(r)
                    and not any(m in low(r) for m in MEAT)}
                   - set(pieces))

import sys
LISTS = {"pieces": pieces, "densities": densities}
a = sys.argv[1:]
if a and a[0] == "counts":
    print(json.dumps({k: len(v) for k, v in LISTS.items()}))
elif a and a[0] == "slice":  # slice <kind> <start> <count>
    kind, start, count = a[1], int(a[2]), int(a[3])
    print(json.dumps(LISTS[kind][start:start + count]))
else:
    print(json.dumps(LISTS))
