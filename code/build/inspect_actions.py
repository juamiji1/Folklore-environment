"""Quick diagnostic: how many triplet actions are verbs vs. not?"""
from pathlib import Path
import pandas as pd
import spacy

BASE = Path(
    "C:/Users/juami/Dropbox/RAships/2-Folklore-Nathan-Project/"
    "EA-Maps-Nathan-project/Measures_work"
)
CSV = BASE / "data" / "raw" / "ACT_measures" / "triplets_and_characterizations_unrolled_scores_merged.csv"

df = pd.read_csv(CSV)
for c in ("subject", "action", "object", "sentence"):
    if c in df.columns:
        df[c] = df[c].astype("string").str.strip().str.lower()

print(f"Total rows: {len(df):,}")
print(f"  action missing/empty : {df['action'].isna().sum() + (df['action'].fillna('') == '').sum():,}")
print(f"  sentence missing     : {df['sentence'].isna().sum():,}")

nlp = spacy.load("en_core_web_sm")

unique_sents = df["sentence"].dropna().unique().tolist()
parsed = {s: d for s, d in zip(unique_sents, nlp.pipe(unique_sents, batch_size=256))}

n_verb, n_nonverb, n_not_found, n_skipped = 0, 0, 0, 0
pos_counter = {}

for _, row in df.iterrows():
    s, a = row["sentence"], row["action"]
    if not isinstance(s, str) or not isinstance(a, str) or not a.strip():
        n_skipped += 1
        continue
    doc = parsed.get(s)
    if doc is None:
        n_skipped += 1
        continue
    head = a.strip().split()[-1]
    matches = [t for t in doc if t.lemma_.lower() == a or t.text.lower() == a
               or t.lemma_.lower() == head or t.text.lower() == head]
    if not matches:
        n_not_found += 1
        continue
    pos_tags = {t.pos_ for t in matches}
    for p in pos_tags:
        pos_counter[p] = pos_counter.get(p, 0) + 1
    if "VERB" in pos_tags or "AUX" in pos_tags:
        n_verb += 1
    else:
        n_nonverb += 1

print(f"\nAction-token matching:")
print(f"  matched as verb (incl. AUX) : {n_verb:,} ({n_verb/len(df):.1%})")
print(f"  matched as non-verb only    : {n_nonverb:,} ({n_nonverb/len(df):.1%})")
print(f"  no match in sentence        : {n_not_found:,} ({n_not_found/len(df):.1%})")
print(f"  skipped (missing/empty)     : {n_skipped:,} ({n_skipped/len(df):.1%})")
print(f"\nPOS tags of matched tokens (any match counted):")
for p, c in sorted(pos_counter.items(), key=lambda x: -x[1]):
    print(f"  {p:8s}: {c:,}")
