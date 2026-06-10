#!/usr/bin/env python3
"""Build-time content pipeline for Daily Gita (impl plan §7 Milestone 1, gita-security.md §5).

Produces the flat `gita.json` the app bundles by joining two public-domain sources:

  - transliteration + speaker: the padapātha IAST verses in `transliteration.json`, decoded from the
    source PDF by `decode_pdf.py` (one pāda per line, daṇḍa marks `|`/`||N||` baked in).
  - meaning:                   the English translation by MEANING_AUTHOR, pulled from the open-source
                               `gita/gita` dataset (plain, standard phrasing — PRD §10.3: Sivananda).

No API key, no secret, no runtime network calls: the output is committed and shipped read-only
(gita-security.md §1, §5). The meanings are a deliberate, swappable choice — replacing them later
(e.g. with a different edition) is a drop-in change keyed by `chapter.number`, untouched by the UI.

Each output record is a `Shloka` (GitaKit/Models/Shloka.swift):
    { "chapter": Int, "number": Int, "speaker": String?, "transliteration": String, "meaning": String }

  - speaker:         the "<name> uvāca" label when the verse opens a speech (else omitted → nil).
  - transliteration: the decoded pāda lines joined by "\\n"; ends with the verse's "||N||".

Usage:
    python3 Tools/fetch-content/decode_pdf.py   # regenerate transliteration.json from the PDF (rare)
    python3 Tools/fetch-content/fetch.py [--out PATH]

Defaults to writing the GitaKit resource at
    Packages/GitaKit/Sources/GitaKit/Resources/gita.json
Idempotent and safe to re-run (CI may regenerate to detect upstream drift).
"""
from __future__ import annotations

import argparse
import json
import re
import sys
import urllib.request
from pathlib import Path

# Pinned to a commit-agnostic branch ref; the dataset is stable/public-domain (Unlicense).
BASE = "https://raw.githubusercontent.com/gita/gita/main/data"
VERSE_URL = f"{BASE}/verse.json"
TRANSLATION_URL = f"{BASE}/translation.json"

# Which English translation becomes the on-screen "meaning". See PRD §10.3.
MEANING_AUTHOR = "Swami Sivananda"
MEANING_LANG = "english"

# Chapter 13 textual variant: the dataset opens chapter 13 with Arjuna's question, which is absent
# from some recensions (e.g. the one Adi Shankara commented on, giving the traditional 700-verse
# count). We keep that verse but number it 13.0 so the remaining verses retain their canonical
# numbers (13.1 = "idaṁ śharīraṁ…"), matching how every other Gita reference numbers chapter 13.
VARIANT_CHAPTER = 13
VARIANT_NOTE = (
    "This opening verse — Arjuna's question — is not found in all recensions of the Gita. "
    "It is numbered 13.0 here so the remaining verses keep their traditional numbers."
)

REPO_ROOT = Path(__file__).resolve().parents[2]
DEFAULT_OUT = REPO_ROOT / "Packages/GitaKit/Sources/GitaKit/Resources/gita.json"
TRANSLITERATION = Path(__file__).resolve().parent / "transliteration.json"

# Glyphs/digraphs that must never survive into the shipped IAST: legacy display-font cipher glyphs
# and the upstream dataset's extra-h romanization. Their presence means a decode/source regression.
# NB: ñ (U+00F1) is NOT forbidden — in the *decoded* text it is the legitimate palatal nasal
# (sañjaya); it was only a cipher *source* glyph (ï→ñ), fully consumed by decoding.
FORBIDDEN = ["ä", "¹", "à", "ù", "º", "ç", "Ç", "é", "ë", "å", "ï", "ü", "ö", "ì", "ò", "è",
             "kṣh", "ṣh", "śh", "ṛi", "uvācha"]


def fetch_json(url: str):
    print(f"  fetching {url}", file=sys.stderr)
    with urllib.request.urlopen(url, timeout=60) as resp:
        return json.load(resp)


def as_records(blob):
    """The dataset ships either a list or an id-keyed object; normalize to a list."""
    return blob if isinstance(blob, list) else list(blob.values())


def clean(text: str) -> str:
    """Trim outer whitespace and normalize line endings; keep meaningful inner line breaks."""
    lines = [ln.rstrip() for ln in text.replace("\r\n", "\n").strip().split("\n")]
    return "\n".join(ln for ln in lines).strip()


def build(verses, translations, translit: dict) -> list[dict]:
    # Index the chosen author's English translation by verse_id.
    meaning_by_verse: dict[int, str] = {}
    for t in translations:
        if t.get("lang") == MEANING_LANG and t.get("authorName") == MEANING_AUTHOR:
            meaning_by_verse[t["verse_id"]] = clean(t["description"])

    shlokas = []
    missing_meaning, missing_translit = [], []
    seen_keys = set()
    for v in verses:
        chapter = v["chapter_number"]
        # Shift chapter 13 down by one so Arjuna's question becomes 13.0 (see VARIANT_NOTE).
        number = v["verse_number"] - 1 if chapter == VARIANT_CHAPTER else v["verse_number"]
        key = f"{chapter}.{number}"
        seen_keys.add(key)

        meaning = meaning_by_verse.get(v["id"])
        entry = translit.get(key)
        if not meaning:
            missing_meaning.append(key)
            continue
        if not entry:
            missing_translit.append(key)
            continue

        record = {"chapter": chapter, "number": number}
        if entry.get("speaker"):
            record["speaker"] = entry["speaker"]
        record["transliteration"] = "\n".join(entry["lines"])
        record["meaning"] = meaning
        if chapter == VARIANT_CHAPTER and number == 0:
            record["note"] = VARIANT_NOTE
        shlokas.append(record)

    if missing_meaning:
        raise SystemExit(f"FATAL: {len(missing_meaning)} verses missing a '{MEANING_AUTHOR}' meaning: {missing_meaning[:10]}…")
    if missing_translit:
        raise SystemExit(f"FATAL: {len(missing_translit)} verses missing transliteration in transliteration.json: {missing_translit[:10]}…")
    orphans = sorted(set(translit) - seen_keys)
    if orphans:
        raise SystemExit(f"FATAL: {len(orphans)} transliteration entries have no matching verse/meaning: {orphans[:10]}…")

    # Integrity guards: clean IAST only, every verse terminates with a daṇḍa number.
    for s in shlokas:
        text = (s.get("speaker") or "") + "\n" + s["transliteration"]
        bad = [g for g in FORBIDDEN if g in text]
        if bad:
            raise SystemExit(f"FATAL: {s['chapter']}.{s['number']} contains forbidden glyph(s) {bad}")
        if not re.search(r"\|\|\d+\|\|\s*$", s["transliteration"]):
            raise SystemExit(f"FATAL: {s['chapter']}.{s['number']} does not end with a ||N|| marker")

    shlokas.sort(key=lambda s: (s["chapter"], s["number"]))
    return shlokas


def main() -> int:
    ap = argparse.ArgumentParser(description="Generate gita.json from the public-domain gita/gita dataset.")
    ap.add_argument("--out", type=Path, default=DEFAULT_OUT, help=f"output path (default: {DEFAULT_OUT})")
    args = ap.parse_args()

    print(f"Daily Gita content pipeline — meaning author: {MEANING_AUTHOR}", file=sys.stderr)
    if not TRANSLITERATION.exists():
        raise SystemExit(f"FATAL: {TRANSLITERATION.name} not found — run decode_pdf.py first.")
    translit = json.loads(TRANSLITERATION.read_text(encoding="utf-8"))
    verses = as_records(fetch_json(VERSE_URL))
    translations = as_records(fetch_json(TRANSLATION_URL))

    shlokas = build(verses, translations, translit)

    chapters = sorted({s["chapter"] for s in shlokas})
    print(f"  built {len(shlokas)} shlokas across chapters {chapters[0]}–{chapters[-1]} ({len(chapters)} chapters)", file=sys.stderr)
    if len(chapters) != 18:
        raise SystemExit(f"FATAL: expected 18 chapters, got {len(chapters)}")

    args.out.parent.mkdir(parents=True, exist_ok=True)
    # Compact-but-readable, stable ordering so diffs are meaningful when the source updates.
    args.out.write_text(json.dumps(shlokas, ensure_ascii=False, indent=1) + "\n", encoding="utf-8")
    print(f"  wrote {args.out.relative_to(REPO_ROOT)} ({args.out.stat().st_size:,} bytes)", file=sys.stderr)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
