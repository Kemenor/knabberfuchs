# Swiss Food Composition Database → bundled catalog

Builds `assets/swiss_foods.csv.gz` (the multilingual whole-food catalog seeded
on first launch) from the **Swiss Food Composition Database**, published by the
**Federal Food Safety and Veterinary Office (FSVO/BLV)**, naehrwertdaten.ch.

This replaced the old English-only USDA generic-foods layer: the Swiss DB ships
curated names in **DE / FR / IT / EN** (exactly the app's UI locales) plus
per-language synonyms, so search and display work natively in every language —
no machine translation needed.

## License / attribution

Free for commercial use "subject to acknowledgment of the source." The app
credits it in Settings → About. Do **not** strip that credit.
See <https://naehrwertdaten.ch/en/informations/>.

## Source files

The DB is published as one Excel file per language, all sharing a stable numeric
`ID` column (the join key). Place them next to this script as `de.xlsx`,
`fr.xlsx`, `it.xlsx`, `en.xlsx`. They are git-ignored (large binaries).

Current generation (2023/08, "corrected version 17.08.2023", ~1109 generic
foods). The live host `naehrwertdaten.ch` is geo-restricted / intermittently
down; these were retrieved via the Internet Archive:

```sh
WB=https://web.archive.org/web
curl -L -o de.xlsx "$WB/20250407204953id_/https://naehrwertdaten.ch/wp-content/uploads/2023/08/Schweizer_Nahrwertdatenbank.xlsx"
curl -L -o fr.xlsx "$WB/20240423194012id_/https://naehrwertdaten.ch/wp-content/uploads/2023/08/Base_de_donnees_suisse_des_valeurs_nutritives.xlsx"
curl -L -o en.xlsx "$WB/20231222230532id_/https://naehrwertdaten.ch/wp-content/uploads/2023/08/Swiss_food_composition_database.xlsx"
# it.xlsx: not archived by the Wayback Machine. Fetch from the live site when
# reachable (Italian /it/downloads/ page) — likely
#   https://naehrwertdaten.ch/wp-content/uploads/2023/08/Banca_dati_svizzera_dei_valori_nutritivi.xlsx
# Until then, Italian names fall back to English (nameIt stays null).
```

## Build

```sh
pip install --user openpyxl
python3 tool/swiss_fcdb/build.py      # writes ../../assets/swiss_foods.csv.gz
```

Then bump `swissDatasetVersion` in `lib/data/sources/swiss_seed.dart` so existing
installs re-import. CSV columns: `id, name_en, name_de, name_fr, name_it,
kcal100, protein100, carb100, fat100, fiber100, sugar100, satfat100,
sodium_mg100, search_text`. English is the canonical/fallback `name`; the others
override per locale. `search_text` is every language's name + synonyms,
lower-cased, so search is language-agnostic.

**To add Italian later:** drop `it.xlsx` in, re-run `build.py`, bump the version.
The ID join slots the Italian names straight in — no code changes.
