#!/usr/bin/env python3
"""Build-time content pipeline for Daily Gita (impl plan §7 Milestone 1, gita-security.md §5).

Pulls the Bhagavad Gita text from the open-source, public-domain `gita/gita` dataset — the same
data the RapidAPI `bhagavad-gita3` endpoint wraps — and transforms it into the flat `gita.json`
the app bundles. No API key, no secret, no runtime network calls: the output is committed and
shipped read-only (gita-security.md §1, §5).

Each output record is a `Shloka` (GitaKit/Models/Shloka.swift):
    { "chapter": Int, "number": Int, "transliteration": String, "meaning": String }

  - transliteration: the dataset's `transliteration` (Sanskrit in IAST), inner line breaks kept.
  - meaning:         the English translation by MEANING_AUTHOR (chosen for plain, standard phrasing
                     approachable to newcomers — PRD §10.3, decided: Swami Sivananda).

Usage:
    python3 Tools/fetch-content/fetch.py [--out PATH]

Defaults to writing the GitaKit resource at
    Packages/GitaKit/Sources/GitaKit/Resources/gita.json
Idempotent and safe to re-run (CI may regenerate to detect upstream drift).
"""
from __future__ import annotations

import argparse
import json
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

REPO_ROOT = Path(__file__).resolve().parents[2]
DEFAULT_OUT = REPO_ROOT / "Packages/GitaKit/Sources/GitaKit/Resources/gita.json"


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


def build(verses, translations) -> list[dict]:
    # Index the chosen author's English translation by verse_id.
    meaning_by_verse: dict[int, str] = {}
    for t in translations:
        if t.get("lang") == MEANING_LANG and t.get("authorName") == MEANING_AUTHOR:
            meaning_by_verse[t["verse_id"]] = clean(t["description"])

    shlokas = []
    missing = []
    for v in verses:
        meaning = meaning_by_verse.get(v["id"])
        if not meaning:
            missing.append(v["id"])
            continue
        shlokas.append({
            "chapter": v["chapter_number"],
            "number": v["verse_number"],
            "transliteration": clean(v["transliteration"]),
            "meaning": meaning,
        })

    if missing:
        raise SystemExit(f"FATAL: {len(missing)} verses missing a '{MEANING_AUTHOR}' translation: {missing[:10]}…")

    shlokas.sort(key=lambda s: (s["chapter"], s["number"]))
    return shlokas


def main() -> int:
    ap = argparse.ArgumentParser(description="Generate gita.json from the public-domain gita/gita dataset.")
    ap.add_argument("--out", type=Path, default=DEFAULT_OUT, help=f"output path (default: {DEFAULT_OUT})")
    args = ap.parse_args()

    print(f"Daily Gita content pipeline — meaning author: {MEANING_AUTHOR}", file=sys.stderr)
    verses = as_records(fetch_json(VERSE_URL))
    translations = as_records(fetch_json(TRANSLATION_URL))

    shlokas = build(verses, translations)

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
