"""Check the action/object missingness pattern: transitive vs intransitive vs none."""
from pathlib import Path
import pandas as pd

BASE = Path(
    "C:/Users/juami/Dropbox/RAships/2-Folklore-Nathan-Project/"
    "EA-Maps-Nathan-project/Measures_work"
)
CSV = BASE / "data" / "raw" / "ACT_measures" / "triplets_and_characterizations_unrolled_scores_merged.csv"

df = pd.read_csv(CSV)

has_action = df["action"].notna() & (df["action"].astype("string").str.strip() != "")
has_object = df["object"].notna() & (df["object"].astype("string").str.strip() != "")

print(f"Total rows: {len(df):,}\n")
print(f"{'':40s} {'count':>8s}  {'share':>7s}")
print(f"  action + object  (transitive)        : {(has_action & has_object).sum():>8,}  {(has_action & has_object).mean():>6.1%}")
print(f"  action, no object (intransitive)     : {(has_action & ~has_object).sum():>8,}  {(has_action & ~has_object).mean():>6.1%}")
print(f"  no action, no object (characterize)  : {(~has_action & ~has_object).sum():>8,}  {(~has_action & ~has_object).mean():>6.1%}")
print(f"  no action, has object  (data oddity?): {(~has_action & has_object).sum():>8,}  {(~has_action & has_object).mean():>6.1%}")

print("\n--- Examples: action present, object MISSING (likely intransitive) ---")
ex = df.loc[has_action & ~has_object, ["subject", "action", "object", "sentence"]].head(10)
print(ex.to_string())

print("\n--- Examples: action MISSING, object MISSING (likely 'X is Y' characterizations) ---")
ex = df.loc[~has_action & ~has_object, ["subject", "action", "object", "characterization", "sentence"]].head(10)
print(ex.to_string())

print("\n--- Examples: 'transitive' rows (action + object both present) ---")
ex = df.loc[has_action & has_object, ["subject", "action", "object", "sentence"]].head(5)
print(ex.to_string())
