# Folklore-environment

Analysis of folklore motifs and their relationship to environmental/ecological measures at the ethnolinguistic group level. Part of the broader "EA-Maps-Nathan-Project" (Ethnographic Atlas + Ethnologue).

## Repo layout (code only)

This Git repo contains **only code**. Data, maps, plots, tables, deliveries, and documentation live outside the repo (see "External data root" below).

```
code/
├── build/        Python/Jupyter notebooks — build environmental measures per Ethnologue polygon
└── analysis/     Stata .do files — regressions on folklore × environmental measures
```

### build/ (Python, geospatial)
Notebooks compute zonal statistics of raster environmental layers over Ethnologue language polygons:
- `bii_ethnologue.ipynb` — Biodiversity Intactness Index
- `forestloss_ethnologue.ipynb` — Forest loss
- `ghg_ethnologue.ipynb` — Greenhouse gas
- `hii_ethnologue.ipynb` — Human Influence Index
- `kgclimzones_ethnologue.ipynb` — Köppen–Geiger climate zones
- `nl_ethnologue.ipynb` — Night lights
- `protectedland_ethnologue.ipynb` — Protected land
- `waterchange_ethnologue.ipynb` — Surface water change
- `environment.yml` — conda env `geo_clean` (python 3.11, geopandas, rioxarray, rasterstats, etc.)

### analysis/ (Stata)
- `create_data_natureonly.do` — assembles the final regression dataset
- `regressions_envmeasures*.do` — regressions, with variants for ACT/AES scoring, nature-only, supernatural, human vs. nature object/subject splits, and replication

## External data root

All data, maps, and outputs live under:

```
C:\Users\juami\Dropbox\RAships\2-Folklore-Nathan-Project\EA-Maps-Nathan-project\Measures_work
```

Structure:
- `data/raw/` — source inputs: `ethnographic_atlas/`, `ethnologue/`, `folklore_motifs/`, `ancestral_characteristics/`, `ACT_measures/`, `verbs_dictionaries/`, `replication_folklore_data/`
- `data/interim/` — intermediate csv/dta/shp files (motif tabulations, triplet classifications, ethnologue intersections, etc.)
- `data/final/` — `data_natureonly_replication.dta` (regression-ready)
- `maps/` — raster/vector inputs (e.g. `maps/raw/BII/bii-2000_v2-1-1.tif`) and derived polygon-level csvs
- `plots/`, `tables/`, `deliveries/`, `invoice/`, `literature/`, `documentation/`

## Path conventions

**Python (build/):** hardcoded absolute `Path("C:/Users/juami/Dropbox/...")`, then `base_path / "data" / ...` or `base_path / "maps" / ...`.

**Stata (analysis/):** user-switch on `c(username)`:
```stata
if c(username) == "juami" {
    gl localpath "C:\Users/`c(username)'\Dropbox\RAships\2-Folklore-Nathan-Project\EA-Maps-Nathan-project\Measures_work"
    gl do "C:\Github\ethnographic-atlas\code"
}
gl data "${localpath}\data"
gl maps "${localpath}\maps"
```
Note the `${do}` global points at a separate repo (`C:\Github\ethnographic-atlas\code`), not this one.

## Working with this project

- When editing notebooks, preserve the existing `base_path` pattern so outputs land in Dropbox, not the repo.
- When editing .do files, keep the `c(username)` switch — other collaborators add their own branches.
- Don't commit data, rasters, shapefiles, or output artifacts to this repo. Only code.
- Unit of analysis is typically the Ethnologue language polygon or an Ethnographic Atlas society; joins between the two happen via `Motifs_EA_WESEE_*` interim files.
