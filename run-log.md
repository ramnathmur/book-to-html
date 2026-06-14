# book-to-html Run Log

Newest row first.

| Book | Built (UTC) | Iter | Wall (min) | Tokens | Cost USD | Approvals | Retained / Source | Bridge % | Renderer | Register | Reader gate | Lowest dim | HTML bytes | Output folder |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| The Craft of Sourdough | 2026-06-02T01:55:00Z | 1 | 4.2 | 46,700 | 0.95 | 7 (popups 0 + questions 7) | 868 / 757 | 4.15 | htmler | editorial-balanced | pass (5/5 books_finished_rate) | visual_pleasure | 20,363 | `C:\Claude Cowork\CLAUDE OUTPUTS\book-to-html\The-Craft-of-Sourdough\` |

## Evaluation & Recommendations — 2026-06-02

**Signal-to-noise:** clean end-to-end run on a tiny (~757-word) expository fixture. Editor retained near-1:1 (correct behavior — the multiplier band degenerates at this scale), Proofreader passed all 14 anchors char-for-char with bridge ratio 4.15 %, htmler editorial-balanced shipped a 20 KB single-file HTML with sticky-top nav + terracotta accents + 3 illustrations (1 svg-diagram, 1 card-grid, 1 accordion), Reader scored 10/10 comprehension and 5/5 on the terminal gate. One JSON typo in fragments.json caught and fixed in one edit; one schema warning (missing `block_ids` on accordion) caught by htmler's deterministic validator.

**Worth adding to next builds:** (a) `serializer_warnings_count` (the editor_to_md.py warnings about bridge units with empty source_ids are useful drift signals); (b) `htmler_qa_retries` (this run was 1 — track when fragments.json validation forces a re-issue); (c) `htmler_illustration_kinds` as a small array, since 3 kinds is the minimum-honest density floor and the mix matters for register-fit. **Not worth capturing:** per-paragraph retention scores — they belong in the Editor's intermediate file, not the run-log.
