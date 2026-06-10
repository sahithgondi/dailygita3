#!/usr/bin/env python3
"""One-off transliteration extractor for Daily Gita.

Decodes the padapātha (quarter-verse) IAST transliteration out of a source PDF whose Sanskrit is
stored in a legacy display-font encoding (a deterministic 1:1 character cipher — e.g. `Çrémad` =
`Śrīmad`). The PDF already lays each verse out exactly as we want — one pāda per line, the 2nd/4th
indented, a single daṇḍa `|` at the hemistich, `||N||` at the end — so once decoded there is no OCR
and no syllable-split heuristic: the structure is taken verbatim.

Output: `transliteration.json`, keyed "<chapter>.<number>" → {"speaker": str|null, "lines": [str,…]}.
`fetch.py` then joins this (public-domain verse text) with the Swami Sivananda English meanings to
produce the bundled `gita.json`.

The PDF itself is NOT committed (public repo, possibly a copyrighted compilation). Romanized
transliteration of public-domain scripture is the original text, not original authorship, so the
decoded verses in `transliteration.json` are committed as a reproducible intermediate.

Usage:
    python3 Tools/fetch-content/decode_pdf.py --pdf ~/Downloads/SrimadBhagawadGeeta_English.pdf
"""
from __future__ import annotations

import argparse
import json
import re
import subprocess
import sys
from pathlib import Path

REPO_ROOT = Path(__file__).resolve().parents[2]
DEFAULT_PDF = Path.home() / "Downloads" / "SrimadBhagawadGeeta_English.pdf"
DEFAULT_OUT = Path(__file__).resolve().parent / "transliteration.json"

# Legacy display-font glyph → IAST. Derived and verified against known verses (see plan).
CIPHER = {
    "ä": "ā", "Ä": "Ā", "¹": "e", "à": "ṁ", "ù": "ḥ", "º": "o",
    "ç": "ś", "Ç": "Ś", "ñ": "ṣ", "Ñ": "Ṣ", "é": "ī", "É": "Ī",
    "ë": "ṇ", "å": "ṛ", "ï": "ñ", "ü": "ū", "ö": "ṭ", "ì": "ṅ",
    "ò": "ḍ", "è": "ṝ",
}

# Verses are 1..N within each chapter. Expected traditional counts (ch13 = 35 here iff this edition
# includes Arjuna's opening question; validated at runtime).
EXPECTED = {1: 47, 2: 72, 3: 43, 4: 42, 5: 29, 6: 47, 7: 30, 8: 28, 9: 34,
            10: 42, 11: 55, 12: 20, 13: 35, 14: 27, 15: 20, 16: 24, 17: 28, 18: 78}

SPEAKERS = ("dhṛtarāṣṭra", "sañjaya", "arjuna", "bhagavān", "hṛṣīkeśa")
# Verse terminator: ||N||, with an optional '*' marking the chapter-13 variant verse (||0*||).
TERM = re.compile(r"\|\|(\d+)\*?\|\|")
# A leading "<name> uvāca" speaker label; 'uvāca' may be glued to the name ("bhagavānuvāca").
SPEAKER_RE = re.compile(r"^\s*(śrī\s*)?(" + "|".join(SPEAKERS) + r")\s*uvāca\s+(.*)$")


def decode(s: str) -> str:
    return "".join(CIPHER.get(c, c) for c in s)


def extract_text(pdf: Path) -> str:
    out = subprocess.run(
        ["pdftotext", "-enc", "UTF-8", str(pdf), "-"],
        check=True, capture_output=True, text=True,
    ).stdout
    return decode(out)


def is_noise(line: str) -> bool:
    """Running headers, page numbers, chapter titles, and the Atha/colophon markers — not verse text."""
    s = line.strip()
    if not s:
        return True
    if s.isdigit():                       # bare page number
        return True
    if "Bhagavad-Gītā" in s:              # running header "Śrīmad-Bhagavad-Gītā"
        return True
    if "Yoga" in s and "|" not in s:      # chapter title line (e.g. "1. Arjuna-Viṣāda-Yogaḥ")
        return True
    return False


def split_speaker(first_line: str):
    """Pull a leading '<name> uvāca' off the first pāda; return (speaker, remaining_first_pada).

    Note: 'dhyāya' words (svādhyāya, dhyāyanta) are legitimate verse text, so the chapter-marker
    filter must not key off 'dhyāya' — the Atha markers are already excluded as chapter boundaries.
    """
    m = SPEAKER_RE.match(first_line)
    if m:
        name = m.group(2)
        speaker = "śrī bhagavān uvāca" if name == "bhagavān" else f"{name} uvāca"
        return speaker, m.group(3).strip()
    return None, first_line


def parse(text: str) -> dict:
    lines = text.split("\n")
    # Chapter markers delimit the body; everything before the first one is front matter (Gītā Dhyānam).
    atha = [i for i, l in enumerate(lines) if "Atha" in l and "dhyāya" in l]
    assert len(atha) == 18, f"expected 18 chapter markers, found {len(atha)}"
    atha.append(len(lines))

    verses: dict[str, dict] = {}
    for chapter, (start, end) in enumerate(zip(atha, atha[1:]), start=1):
        buf: list[str] = []
        for raw in lines[start + 1:end]:
            if is_noise(raw):
                continue
            line = raw.strip()
            m = TERM.search(line)
            if m:
                line = TERM.sub(f"||{int(m.group(1))}||", line)  # drop the variant '*' from display
            buf.append(line)
            if not m:
                continue
            number = int(m.group(1))
            speaker, buf[0] = split_speaker(buf[0])
            verses[f"{chapter}.{number}"] = {"speaker": speaker, "lines": buf}
            buf = []
    return verses


def main() -> int:
    ap = argparse.ArgumentParser(description="Decode padapātha IAST transliteration from the source PDF.")
    ap.add_argument("--pdf", type=Path, default=DEFAULT_PDF, help=f"source PDF (default: {DEFAULT_PDF})")
    ap.add_argument("--out", type=Path, default=DEFAULT_OUT, help=f"output JSON (default: {DEFAULT_OUT})")
    args = ap.parse_args()

    if not args.pdf.exists():
        raise SystemExit(f"FATAL: PDF not found at {args.pdf}")
    print(f"Decoding transliteration from {args.pdf.name}", file=sys.stderr)

    verses = parse(extract_text(args.pdf))

    # Per-chapter validation.
    by_ch: dict[int, list[int]] = {}
    for key in verses:
        c, n = (int(x) for x in key.split("."))
        by_ch.setdefault(c, []).append(n)
    ok = True
    for c in range(1, 19):
        nums = sorted(by_ch.get(c, []))
        # Chapter 13 includes Arjuna's opening question as verse 0 (the ||0*|| variant) → 0..34.
        expected_nums = list(range(0, 35)) if c == 13 else list(range(1, EXPECTED[c] + 1))
        flag = "" if nums == expected_nums else "  <-- CHECK"
        if flag:
            ok = False
        span = f"{nums[0]}..{nums[-1]}" if nums else "-"
        print(f"  ch{c:>2}: {len(nums):>2} verses ({span}){flag}", file=sys.stderr)
    print(f"  total: {len(verses)} verses", file=sys.stderr)

    args.out.write_text(json.dumps(verses, ensure_ascii=False, indent=1) + "\n", encoding="utf-8")
    print(f"  wrote {args.out.relative_to(REPO_ROOT)}", file=sys.stderr)
    return 0 if ok else 2


if __name__ == "__main__":
    raise SystemExit(main())
