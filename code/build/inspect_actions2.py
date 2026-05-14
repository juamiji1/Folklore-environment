"""Inspect what the rows with missing actions actually look like."""
from pathlib import Path
import pandas as pd

BASE = Path(
    "C:/Users/juami/Dropbox/RAships/2-Folklore-Nathan-Project/"
    "EA-Maps-Nathan-project/Measures_work"
)
CSV = BASE / "data" / "raw" / "ACT_measures" / "triplets_and_characterizations_unrolled_scores_merged.csv"

df = pd.read_csv(CSV)
print("Columns:", list(df.columns))
print(f"\nTotal rows: {len(df):,}")

print("\n--- Counts of empty/NA per key column ---")
for c in ("subject", "action", "object", "sentence"):
    if c in df.columns:
        s = df[c].astype("string").str.strip()
        print(f"  {c:10s}: NA={s.isna().sum():,}   empty={(s == '').sum():,}")

print("\n--- Examples of rows with missing action ---")
mask_no_action = df["action"].isna() | (df["action"].astype("string").str.strip() == "")
print(f"Rows with missing action: {mask_no_action.sum():,}")
print(df.loc[mask_no_action, ["subject", "action", "object", "sentence"]].head(10).to_string())

print("\n--- Examples of rows WITH action ---")
print(df.loc[~mask_no_action, ["subject", "action", "object", "sentence"]].head(5).to_string())

print("\n--- Examples of rows where action is non-empty but didn't match (first 5) ---")
# Quick re-check without spaCy: just look at substring presence as a crude proxy
sample = df.loc[~mask_no_action].copy()
sample["action_lc"] = sample["action"].astype("string").str.strip().str.lower()
sample["sent_lc"] = sample["sentence"].astype("string").str.lower()
sample["substr_match"] = sample.apply(
    lambda r: isinstance(r["sent_lc"], str) and isinstance(r["action_lc"], str)
              and r["action_lc"] in r["sent_lc"], axis=1
)
print("Rows where action is not a substring of sentence:", (~sample["substr_match"]).sum())
print(sample.loc[~sample["substr_match"], ["action", "sentence"]].head(10).to_string())
