"""
Add passive-voice indicators to the triplet × motif file.

Input:
    {data}/raw/ACT_measures/triplets_and_characterizations_unrolled_scores_merged.csv

Output:
    {data}/raw/ACT_measures/triplets_and_characterizations_unrolled_scores_merged_passive.csv

For each row (triplet), looks up the original `sentence`, finds the token
whose lemma matches `action`, and inspects its dependency children to flag:
    is_passive       — 1 if the action verb has an `auxpass` or `nsubjpass`
                       child (i.e. the clause is in passive voice).
    agent_captured   — 1 if the action verb additionally has an `agent` child
                       (i.e. there is a `by X` phrase identifying the agent).

Both columns are 0 / 1 integers; 0 for missing or unmatched rows.

Requires:
    pip install spacy pandas
    python -m spacy download en_core_web_sm
"""

from pathlib import Path

import pandas as pd
import spacy
from tqdm import tqdm

# -----------------------------------------------------------------------------
# Paths
# -----------------------------------------------------------------------------
BASE = Path(
    "C:/Users/juami/Dropbox/RAships/2-Folklore-Nathan-Project/"
    "EA-Maps-Nathan-project/Measures_work"
)
CSV_IN  = BASE / "data" / "raw" / "ACT_measures" / "triplets_and_characterizations_unrolled_scores_merged.csv"
CSV_OUT = BASE / "data" / "raw" / "ACT_measures" / "triplets_and_characterizations_unrolled_scores_merged_passive.csv"


# -----------------------------------------------------------------------------
# Load
# -----------------------------------------------------------------------------
print(f"Reading {CSV_IN.name} ...")
df = pd.read_csv(CSV_IN)
print(f"  -> {len(df):,} rows, {df.shape[1]} columns")

# Coerce key fields to clean lowercase strings (matches the Stata cleaning step)
for col in ("subject", "action", "object", "sentence"):
    if col in df.columns:
        df[col] = df[col].astype("string").str.strip().str.lower()


# -----------------------------------------------------------------------------
# Pre-parse unique sentences with spaCy
# (many triplets come from the same sentence — parse once, look up many times)
# -----------------------------------------------------------------------------
print("Loading spaCy model en_core_web_sm ...")
nlp = spacy.load("en_core_web_sm", disable=["ner", "lemmatizer"] if False else [])

unique_sentences = (
    df["sentence"].dropna().unique().tolist()
)
print(f"Parsing {len(unique_sentences):,} unique sentences ...")

# Use nlp.pipe for speed; batch over sentences.
parsed: dict[str, "spacy.tokens.Doc"] = {}
for sent, doc in tqdm(
    zip(unique_sentences, nlp.pipe(unique_sentences, batch_size=256)),
    total=len(unique_sentences),
):
    parsed[sent] = doc


# -----------------------------------------------------------------------------
# For each row, find the matching verb and check passive / agent dependencies
# -----------------------------------------------------------------------------
def passive_flags(sentence: str | float, action: str | float) -> tuple[int, int]:
    """Return (is_passive, agent_captured) ∈ {0, 1}² for a single (sentence, action) pair."""
    if not isinstance(sentence, str) or not isinstance(action, str):
        return 0, 0

    doc = parsed.get(sentence)
    if doc is None:
        return 0, 0

    action_norm = action.strip().lower()
    if not action_norm:
        return 0, 0

    is_passive = 0
    agent_captured = 0

    # Find every token whose lemma OR surface form matches the action.
    # spaCy splits multi-word actions, so also try the head word.
    action_tokens = action_norm.split()
    head_word = action_tokens[-1] if action_tokens else ""

    for token in doc:
        lemma = token.lemma_.lower()
        text  = token.text.lower()
        if lemma == action_norm or text == action_norm or lemma == head_word or text == head_word:
            # Walk children to look for passive markers and a by-agent phrase.
            for child in token.children:
                if child.dep_ in ("auxpass", "nsubjpass"):
                    is_passive = 1
                if child.dep_ == "agent":
                    agent_captured = 1
            if is_passive:
                # Found a passive use of this verb — stop here.
                break

    # If the verb wasn't found in passive form, agent_captured stays 0
    # (by convention: agent is only meaningful when there IS a passive).
    if not is_passive:
        agent_captured = 0

    return is_passive, agent_captured


print("Annotating rows ...")
flags = [
    passive_flags(s, a)
    for s, a in tqdm(zip(df["sentence"], df["action"]), total=len(df))
]
df["is_passive"]     = [f[0] for f in flags]
df["agent_captured"] = [f[1] for f in flags]


# -----------------------------------------------------------------------------
# Summary + save
# -----------------------------------------------------------------------------
print("\nDistribution:")
print(f"  is_passive == 1     : {df['is_passive'].sum():>8,}  ({df['is_passive'].mean():.1%})")
print(f"  agent_captured == 1 : {df['agent_captured'].sum():>8,}  ({df['agent_captured'].mean():.1%})")
print(f"  passive WITH agent  : {((df['is_passive']==1) & (df['agent_captured']==1)).sum():>8,}")
print(f"  passive NO agent    : {((df['is_passive']==1) & (df['agent_captured']==0)).sum():>8,}")

print(f"\nWriting {CSV_OUT.name} ...")
df.to_csv(CSV_OUT, index=False)
print(f"  -> {len(df):,} rows written")
