# Content pipeline (`fetch-content`)

Build-time step that produces the bundled `gita.json`. It runs **during development only** — the
shipped app never makes network calls for content (gita-security.md §1, §5).

## What it does

`fetch.py` pulls two files from the open-source [`gita/gita`](https://github.com/gita/gita) dataset
and transforms them into the flat array the app decodes:

```
verse.json        ─┐
translation.json  ─┴─►  Packages/GitaKit/Sources/GitaKit/Resources/gita.json
```

Each output record matches `GitaKit/Models/Shloka.swift`:

```json
{ "chapter": 2, "number": 47, "transliteration": "karmaṇy-evādhikāras te …", "meaning": "Your right is only to work, …" }
```

- **transliteration** — the dataset's IAST transliteration (inner line breaks preserved).
- **meaning** — the English translation by **Swami Sivananda** (PRD §10.3 decision: plain, standard
  phrasing that reads well for newcomers and devotees alike).

## Why this source (no RapidAPI key)

The RapidAPI `bhagavad-gita3` endpoint is a wrapper over this exact dataset. The dataset is released
into the **public domain** (Unlicense), so we fetch it directly from GitHub:

- No API key, no `.secrets` file, nothing to keep out of the public repo.
- Fully reproducible — anyone (and CI) can regenerate `gita.json` from scratch.
- No secret could ever leak into the binary, because there is none.

If you ever need the RapidAPI path instead, the data shape is identical; only the fetch URLs change.

## Regenerate

```sh
python3 Tools/fetch-content/fetch.py
```

Requires only Python 3 (standard library). Re-run when you want to pick up upstream corrections;
review the `git diff` on `gita.json` before committing. The script fails loudly if the chapter count
isn't 18 or any verse is missing a Sivananda translation.

## Output facts

- **701 shlokas** across all 18 chapters. (The traditional count is 700; this dataset numbers
  chapter 13 with one extra verse — we keep the source's numbering verbatim.)
