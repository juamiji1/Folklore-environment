# Folklore-environment

Code for the analysis of folklore motifs in relation to environmental and ecological measures at the ethnolinguistic-group level. Part of the broader EA-Maps-Nathan-Project (Ethnographic Atlas + Ethnologue).

> This repository contains **only code**. All raw data, rasters, intermediate files, and outputs live outside the repo (see [Data](#data)).

## Repository layout

```
code/
├── build/      Python notebooks — download environmental rasters from GEE
│               and compute zonal statistics per Ethnologue language polygon
└── analysis/   Stata .do files — regressions on folklore × environment
```

### `code/build/` — Python (geospatial)

Download notebooks (one-shot; trigger Earth Engine exports to Google Drive):

| Notebook | Source |
|---|---|
| `forestloss_download.ipynb` | Hansen Global Forest Change — `treecover2000` |
| `hansen_loss_download.ipynb` | Hansen Global Forest Change — `loss` (cumulative 2001–2024) |
| `mod44b_download.ipynb` | MODIS MOD44B — `Percent_Tree_Cover` (year 2000) |
| `srtm_elevation_download.ipynb` | SRTM GL1 — `elevation` |
| `nl_download.ipynb` | Harmonized DMSP-OLS Nighttime Lights (2000) |
| `waterchange_download.ipynb` | JRC Global Surface Water (perm/loss/change_norm/change_abs) |

Local processing notebooks (read rasters from disk, compute per-Ethnologue-polygon measures, write CSVs):

| Notebook | Measure |
|---|---|
| `bii_ethnologue.ipynb` | Biodiversity Intactness Index |
| `forestloss_ethnologue.ipynb` | Forest cover & loss (original) |
| `forestloss_ethnologue_fixed.ipynb` | Forest cover & loss with corrected km² and no uint8 truncation |
| `treecover_modis_ethnologue.ipynb` | MODIS-based tree cover (validation) |
| `ghg_ethnologue.ipynb` | Greenhouse gas |
| `hii_ethnologue.ipynb` | Human Influence Index |
| `kgclimzones_ethnologue.ipynb` | Köppen–Geiger climatic zones |
| `nl_ethnologue.ipynb` | Night-light intensity |
| `protectedland_ethnologue.ipynb` | Protected land |
| `waterchange_ethnologue.ipynb` | Surface water change |
| `ruggedness_ethnologue.ipynb` | Terrain Ruggedness Index (Riley/Nunn–Puga) |

`run_build.py` is a master runner that executes the notebooks in order via `conda run -n geo_clean jupyter nbconvert --execute`.

### `code/analysis/` — Stata

| File | Purpose |
|---|---|
| `create_data_natureonly.do` | Assemble the regression-ready dataset |
| `regressions_envmeasures.do` | Baseline regressions |
| `regressions_envmeasures_aes*.do` | Variants: AES scoring, nature-only, supernatural, human-vs-nature object/subject splits, replication |

The `.do` files use a `c(username)` switch for paths and reference a separate repo (`C:\Github\ethnographic-atlas\code`) via the `${do}` global.

## Data

All data and outputs live outside the repo at:

```
C:\Users\juami\Dropbox\RAships\2-Folklore-Nathan-Project\EA-Maps-Nathan-project\Measures_work
```

Subfolder layout:

- `data/raw/` — source inputs (`ethnographic_atlas/`, `ethnologue/`, `folklore_motifs/`, `ancestral_characteristics/`, `ACT_measures/`, `verbs_dictionaries/`, `replication_folklore_data/`)
- `data/interim/` — intermediate csv/dta/shp files
- `data/final/` — `data_natureonly_replication.dta` (regression-ready)
- `maps/raw/` — raster inputs by layer (`Hansen_forest/`, `MODIS/`, `DEM/`, `BII/`, `HII/`, `NL/`, `Water_surface/`, `KG_climatic_zones/`, `Protected_land/`, …) and derived polygon-level CSVs
- `plots/`, `tables/`, `deliveries/`, `documentation/`

The Ethnologue language polygons used as the unit of analysis come from `data/raw/ethnologue/.../langa_no_overlap_biggest_clean.shp`.

## Environment

Python (geospatial) environment is defined in [`code/build/environment.yml`](code/build/environment.yml):

```bash
conda env create -f code/build/environment.yml      # first build
conda env update -f code/build/environment.yml --prune   # update existing
conda activate geo_clean
```

Key dependencies: `geopandas`, `rasterio`, `rasterstats`, `rioxarray`, `xarray`, `earthengine-api`, `geemap`, `matplotlib`, `mapclassify`, `rapidfuzz`.

Stata 17+ is required for the `.do` files in `code/analysis/`.

## Typical workflow

1. **Authenticate** Earth Engine (one-time): in Python, `import ee; ee.Authenticate()`.
2. **Run download notebooks** (start GEE exports to Google Drive). Wait for the [GEE Task Manager](https://code.earthengine.google.com/tasks) to finish, then sync the resulting tiles into `maps/raw/<layer>/` in Dropbox.
3. **Run local processing notebooks** to compute per-Ethnologue-polygon measures and export CSVs into `maps/raw/<layer>/`.
4. **Run Stata `.do` files** to assemble the regression dataset and run regressions.

`code/build/run_build.py` automates step 3 (and step 2 by uncommenting download entries):

```bash
python code/build/run_build.py --stage local
python code/build/run_build.py --stage downloads      # only after uncommenting in the file
python code/build/run_build.py --only ruggedness_ethnologue.ipynb
```

## Notes

- **Don't commit data.** Rasters, shapefiles, and zonal-stat CSVs all belong in Dropbox, not in this repo.
- **Path conventions.** Python notebooks hardcode `base_path = Path("C:/Users/juami/Dropbox/...")`. Stata `.do` files use a `c(username)` switch — keep both patterns intact when collaborating.
- **GEE exports are asynchronous.** `task.start()` only queues the export; the `.tif` files don't appear on disk until the GEE task finishes and you sync from Drive.
