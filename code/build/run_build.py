"""
Master runner for build-stage notebooks.

Runs every notebook in code/build/ as a subprocess using the `geo_clean`
conda environment (via `conda run`).

Two stages:
  1. downloads  - GEE export notebooks (*_download.ipynb). Each one calls
                  ee.batch.Export.image.toDrive(...).start(), which queues
                  the export on Google's side.
  2. local      - *_ethnologue.ipynb notebooks that read rasters from disk
                  and compute zonal statistics per Ethnologue polygon.

IMPORTANT: GEE exports are asynchronous. After stage 1 finishes starting
tasks, you must wait for them to complete at
    https://code.earthengine.google.com/tasks
and sync the resulting .tif files from Google Drive into
    ...\\Measures_work\\maps\\raw\\<layer>\\
BEFORE running stage 2. Running --stage all back-to-back will NOT work
end-to-end because of this.

Usage:
  python code/run_build.py --stage downloads
  python code/run_build.py --stage local
  python code/run_build.py --stage all            # starts downloads then runs local
                                                  # (only useful if rasters already on disk)
  python code/run_build.py --stage local --only bii_ethnologue.ipynb
"""

from __future__ import annotations

import argparse
import subprocess
import sys
from pathlib import Path

BUILD_DIR = Path(__file__).resolve().parent
ENV_NAME = "geo_clean"

# Downloads are one-shot — leave commented unless you actually want to
# re-trigger a GEE export. Uncomment only the ones you need.
DOWNLOAD_NOTEBOOKS = [
    # "forestloss_download.ipynb",
    # "hansen_loss_download.ipynb",
    # "mod44b_download.ipynb",
    # "srtm_elevation_download.ipynb",
    # "nl_download.ipynb",
    # "waterchange_download.ipynb",
]

LOCAL_NOTEBOOKS = [
    "bii_ethnologue.ipynb",
    "hii_ethnologue.ipynb",
    "ghg_ethnologue.ipynb",
    "kgclimzones_ethnologue.ipynb",
    "protectedland_ethnologue.ipynb",
    "forestloss_ethnologue.ipynb",
    "forestloss_ethnologue_fixed.ipynb",
    "treecover_modis_ethnologue.ipynb",
    "nl_ethnologue.ipynb",
    "waterchange_ethnologue.ipynb",
    "ruggedness_ethnologue.ipynb",
]


def run_notebook(nb_name: str) -> int:
    nb_path = BUILD_DIR / nb_name
    if not nb_path.exists():
        print(f"!! missing: {nb_path}", flush=True)
        return 1

    print(f"\n=== Running {nb_name} ===", flush=True)
    cmd = [
        "conda", "run", "-n", ENV_NAME, "--no-capture-output",
        "jupyter", "nbconvert",
        "--to", "notebook",
        "--execute", str(nb_path),
        "--inplace",
    ]
    result = subprocess.run(cmd)
    if result.returncode != 0:
        print(f"!! {nb_name} failed (exit {result.returncode})", flush=True)
    return result.returncode


def run_group(title: str, notebooks: list[str], stop_on_error: bool) -> int:
    print(f"\n########## {title} ##########", flush=True)
    failures = 0
    for nb in notebooks:
        rc = run_notebook(nb)
        if rc != 0:
            failures += 1
            if stop_on_error:
                return rc
    return 0 if failures == 0 else 1


def main() -> int:
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("--stage", choices=["downloads", "local", "all"], default="all")
    ap.add_argument("--only", nargs="+", metavar="NB", help="Run only these notebook filenames (overrides stage list).")
    ap.add_argument("--keep-going", action="store_true", help="Continue past failures instead of stopping at the first.")
    args = ap.parse_args()

    stop_on_error = not args.keep_going

    if args.only:
        return run_group("Selected notebooks", list(args.only), stop_on_error)

    rc = 0
    if args.stage in ("downloads", "all"):
        rc = run_group("Stage 1: GEE downloads", DOWNLOAD_NOTEBOOKS, stop_on_error)
        if rc != 0 and stop_on_error:
            return rc
    if args.stage in ("local", "all"):
        rc = run_group("Stage 2: local operations", LOCAL_NOTEBOOKS, stop_on_error)
    return rc


if __name__ == "__main__":
    sys.exit(main())
