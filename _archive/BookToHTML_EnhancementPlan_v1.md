# book-to-html Skill — Enhancement Plan v1

**Benchmark threshold: 32/40. Iteration cap: 3.**

---

## 1. Research Brief

Four parallel sub-agents commissioned. Load-bearing findings:

### 1.1 Editorial practice (traditional abridgment)
Investigated Reader's Digest Condensed Books, Penguin Classics, audio-abridgment trade practice, and developmental editing heuristics.
- **The dominant rule is "cut the three R's": repetition, rhetoric, redundancy.** Abridgment is subtractive before it is generative ([Wikipedia: Abridgement](https://en.wikipedia.org/wiki/Abridgement)).
- **Hybrid (anchor + connective tissue) is the professional default.** Practitioner rule-of-thumb: ≥90% original-author words, ≤10% editor-written bridges. Pure paraphrase is the lowest-fidelity tier and used only for ESL / children's classics / audio.
- **Compression ratios in the wild:** Reader's Digest historically cut ~50–60% for print; abridged audio cuts ~85–90% ([Reader's Digest Condensed Books](https://en.wikipedia.org/wiki/Reader%27s_Digest_Condensed_Books); [Authorlink editor commentary](https://authorlink.com/writing-insights/how-much-content-is-cut-when-an-author-edits-a-book-for-publication-2023/)).
- **Fiction vs. self-help heuristics differ.** Fiction: protect plot turns, decision-point interiority, signature-voice prose; cut backstory, descriptive padding once setting is established, restating dialogue. Self-help: protect framework + step-by-step instructions; cut the 2nd/3rd/4th illustrative example per concept, recap chapters, throat-clearing.

### 1.2 Faithfulness & hallucination prevention (AI summarization SOTA, 2023–2026)
Investigated QAGS, SummaC, AlignScore, FActScore, G-Eval, BooookScore, FABLES, positional-bias work.
- **No single metric suffices for book-length.** Winning stack = hierarchical chunk-then-merge generation with explicit `(claim, source_span_id, verbatim_quote)` tuples, followed by FActScore-style atomic-fact decomposition + AlignScore/NLI entailment audit ([AlignScore](https://github.com/yuh-zha/AlignScore), [FActScore arXiv 2305.14251](https://arxiv.org/abs/2305.14251)).
- **Hallucination spikes at the END of long generations** ([Liu 2025: Hallucinate at the Last](https://arxiv.org/html/2505.15291)) and in the MIDDLE of long inputs ([Positional Bias of Faithfulness 2024](https://arxiv.org/pdf/2410.23609)). Mitigations: chunked outputs + per-chapter quotas in the merge step + RAG refinement over middle chunks.
- **FABLES** documents that LLM book summaries systematically over-weight endings and under-cover middles ([FABLES 2024](https://arxiv.org/pdf/2404.01261)).
- **BooookScore (ICLR 2024)** confirms hierarchical merging beats incremental updating for coherence on 100k+ token books ([BooookScore](https://arxiv.org/pdf/2310.00785)).

### 1.3 AI-illustration pipelines for long-form text
Investigated illumination_pipeline, Beinorius's ebook POC, IP-Adapter, Pollinations.ai, Mermaid, dual-coding research.
- **Standard prompt-from-passage recipe:** extract `{scene, mood, characters[name+persistent_traits], objects, style_anchor}` per chunk → emit single-sentence visual prompt with **fixed style suffix in fixed position** → image API → embed.
- **Placement hierarchy (highest leverage first):** chapter openers (verso-illustration / recto-text spread) > scene breaks > concept anchors > inline decoration ([MIBLART: Chapter Openers](https://miblart.com/blog/chapter-openers-design/)).
- **For self-help, concept diagrams beat decorative art** — Paivio/Mayer dual-coding literature shows learning gains come from diagrams that externalize *relationships* (causal chains, 2×2 trade-offs, feedback loops); "seductive detail" decorative imagery measurably *reduces* recall ([PMC: Creating visual explanations](https://pmc.ncbi.nlm.nih.gov/articles/PMC5256450/)).
- **Free, Windows + Claude Code-callable options ranked:** (a) Claude-authored inline SVG — deterministic, zero dependency, best for self-help frameworks; (b) **Mermaid** fenced blocks — frameworks, flowcharts, sequence diagrams; (c) [Pollinations.ai](https://image.pollinations.ai/) — keyless GET endpoint, seed-stable, Flux model, best for representational/mood images; (d) Hugging Face Inference API; (e) Unsplash/Pexels for stock metaphors.
- **Style consistency techniques:** frozen style-anchor suffix + seed reuse + (optional) IP-Adapter for character/style locking.

### 1.4 Long-form HTML reading UX
Investigated Butterick, web.dev typography, Gwern, Distill, Stripe Press, Tufte CSS, endowed-progress-effect research.
- **Typography levers in order:** measure `66ch`, line-height `1.65` unitless, size `clamp(1rem, 0.5rem + 1vw, 1.25rem)`, humanist font ([Butterick: Line length](https://practicaltypography.com/line-length.html); [web.dev/learn/design/typography](https://web.dev/learn/design/typography)).
- **Navigation that drives completion:** sticky side-rail TOC + `IntersectionObserver` scroll-spy + thin top progress bar + per-section reading-time estimate. The progress bar exploits the *endowed progress effect* — measurably increases completion ([Page Flows: Progress Bar UX](https://pageflows.com/resources/progress-bar-ux/)).
- **Wikipedia-style internal links work if implemented as hover/focus POPOVERS, not jumps** — Gwern's `popups.js` pattern. Jumps discard scroll position and break flow; popovers preserve it ([Gwern: Sidenotes / design](https://gwern.net/design)).
- **Sidenotes > footnotes** for marginalia; the single highest-leverage move for "feels like a book."
- **Structural rule:** narrative/argument books → preserve chapter order (sequence IS the argument). Reference / how-to / framework stacks → re-cluster by theme. Mixed → linear + alternate thematic TOC.
- **Drop caps, pull-quotes every 3–5 screens, progressive disclosure (`<details>`)** all reset reader attention budget.

---

## 2. Synthesized Framework

### 2.1 Retention Framework (the rubric the AI scores every paragraph with)

For each source paragraph, compute a **Retention Score** = sum of the applicable rows below. Keep verbatim if score ≥ 7, paraphrase-condense if 4–6, drop if ≤ 3.

| Signal | Fiction weight | Self-help weight |
|---|---|---|
| Contains a plot turn / decision point | +5 | — |
| Contains the author's signature voice or a quotable line | +4 | +3 |
| Introduces a named framework, model, or rule | — | +5 |
| Contains a step-by-step instruction | — | +4 |
| Contains the FIRST example of a concept | +2 | +3 |
| Contains the 2nd+ example of an already-illustrated concept | −2 | −3 |
| Character interiority at a decision point | +3 | — |
| Descriptive padding after setting is established | −2 | −1 |
| Recap / "what we'll cover" / "what we just covered" | −3 | −4 |
| Repeats a point already made this chapter | −2 | −3 |
| Foreshadows or pays off something later in the book | +3 | +1 |

Hard rules layered on top: **(1) every "kept" paragraph survives as anchor-quote (verbatim, in a `<blockquote class="anchor">` with `data-source-id`); (2) author-written connective tissue is ≤10% of final word count.**

### 2.2 Anti-Hallucination Grounding Protocol

Pipeline, mandatory:

1. **Ingest with span IDs.** Every paragraph gets `source_id = ch{n}§{m}¶{k}`. Already in the current skill; keep it.
2. **Generate as structured tuples, not prose.** Each unit of output emits:
   ```json
   {
     "kind": "anchor" | "bridge",
     "html": "<p>...</p>",
     "source_ids": ["ch3§2¶4", "ch3§2¶5"],
     "verbatim_quote": "<exact source span if kind=anchor, else null>"
   }
   ```
3. **Anchor verification.** For every `kind=anchor`, fuzzy-match `verbatim_quote` against the concatenated paragraphs at `source_ids` (rapidfuzz token_set_ratio ≥ 95). Fail → regenerate that unit.
4. **Bridge entailment audit.** For every `kind=bridge`, run a self-NLI check via Claude in a fresh sub-agent ("Given ONLY these source paragraphs, does this bridge sentence add any name/number/claim not present? List violations."). Any violation → regenerate.
5. **Per-chapter coverage quota.** Each chapter must contribute ≥ `(chapter_words / book_words) × 0.7` of the final-output word count, ±20%. Prevents the FABLES end-of-book over-weighting bug.
6. **Bridge-ratio gate.** Sum of `kind=bridge` words ÷ total words ≤ 0.10. Above → re-pass with stricter "compress, don't bridge" instruction.
7. **Surface, don't hide.** Output a `coverage.json` sidecar: % of source covered, list of dropped sections with reason, per-chapter contribution %.

### 2.3 AI Illustration Pipeline

**Two illustration channels, chosen per content type:**

**Channel A — Mermaid / inline SVG (default for self-help).**
At outline time (Stage 3), tag every section as `framework | process | comparison | timeline | none`. For tagged sections, the AI emits a Mermaid block or hand-rolled SVG that externalizes the relationship in the source paragraph. Rendered client-side (Mermaid.js) or inlined at build time.

**Channel B — Pollinations.ai (default for fiction / chapter openers / mood).**
- Endpoint: `https://image.pollinations.ai/prompt/{url-encoded-prompt}?model=flux&seed={book_seed}&width=1280&height=720&nologo=true`.
- One image per chapter opener + one per scene-break the Retention Score flagged as a major beat.
- **Prompt-from-passage template:**
  ```
  {scene}, {mood}, {characters_with_persistent_traits}, {key_objects}, STYLE: {style_anchor}
  ```
  Where `style_anchor` is decided ONCE per book at Stage 2 (e.g. "watercolor, muted ochre palette, soft edges, 1950s children's book illustration") and frozen as a fixed suffix on EVERY image prompt. `book_seed` is also frozen per book for sampler determinism.
- **Failure mode handling:** Pollinations occasionally times out or returns censored placeholders. Retry once with a different seed; on second failure, fall back to a captioned `<blockquote class="anchor">` of the passage being illustrated (text is always safer than a broken image).
- **No-API fallback flag.** If the user sets `visuals: none` or no network access, Channel A only.

**Style-consistency rules across the book:** style anchor frozen → seed frozen → character descriptors maintained in a `characters.json` carried across all prompts (e.g. "Anna, 30s, short black hair, navy raincoat" appears identically in every prompt about Anna).

### 2.4 Adaptive Length Decision Rule (the AI decides the size)

The AI does **not** receive a pages/word-cap from the user anymore (replaces current Stage 2 Q2 + Q3). Instead it runs a **comprehension-equivalence test**:

1. Compute the **Retention Mass** = sum of Retention Scores ≥ 4 across the whole book.
2. Target word budget = Retention Mass × 8 words per retention-point (empirical anchor: yields ~15–40% compression on typical books — fiction lands lower, self-help higher).
3. Generate a draft at that budget.
4. **Self-test:** spin up a fresh sub-agent that has *only* the condensed HTML (not the source) and ask it 10 questions auto-generated from the original Retention-Score≥7 paragraphs. Score the sub-agent's answers against the source paragraphs (fuzzy match + key-entity recall).
5. **Pass criterion:** ≥ 85% of questions answered correctly from the condensed version. Fail → identify which chapters scored worst, raise their word budget by 25%, regenerate those chapters only, re-test. Cap at 3 iterations.
6. If still failing after 3 iterations, surface the failing chapters and ask the user whether to (a) ship at current length with the deficit noted, or (b) override the comprehension test and budget manually.

The AI shows the user the chosen budget + the rationale ("Comprehension-equivalence test passed at 28% compression; framework chapters expanded by 25% on iteration 2") in the Stage 3 outline checkpoint.

---

## 3. Quality Benchmark (rubric, 40 points)

Score each dimension 1–5. **Pass = ≥ 32/40 AND no dimension below 3.**

| # | Dimension | Pass criterion (≥ 4) |
|---|---|---|
| 1 | **Fidelity to source** | Zero unsourced claims (Stage 6 returns clean). |
| 2 | **Hybrid ratio** | 85–95% anchor (verbatim) / 5–15% bridge. Both extremes fail. |
| 3 | **Continuity** | Reader can follow the narrative/argument without consulting source. Self-test ≥ 85%. |
| 4 | **Visual reading pleasure** | Typography meets the Butterick/web.dev brief (66ch, 1.65 leading, clamp size, humanist font, dark-mode token). |
| 5 | **Navigation utility** | Sticky TOC + scroll-spy + progress bar + reading-time estimates per section. Hover popovers on every internal link. |
| 6 | **Illustration relevance** | Self-help: ≥ 1 framework diagram per concept chapter. Fiction: ≥ 1 chapter-opener image with consistent style anchor. Zero decorative-only images in self-help. |
| 7 | **Coverage balance** | No chapter contributes < 70% of its proportional share (anti-FABLES). |
| 8 | **"I would skip the original" reader confidence** | Subjective. The Stage-6 self-test sub-agent gives a 1–5 verdict; user gives the final 1–5 at delivery. Both ≥ 4 to pass. |

**Iteration loop:** if total < 32 or any dimension < 3, identify the lowest dimension, regenerate ONLY the artifact owned by that dimension (e.g., dimension 5 → regenerate the HTML chrome, not the prose), re-score. Cap 3. Then surface remaining deficits.

---

## 4. Current Skill Review

Quoting `C:\Claude Cowork\skills\book-to-html\SKILL.md`:

> **L10–14: Core principle: GROUNDING IS NON-NEGOTIABLE. … Iron law: No section ships until the QA gate (Stage 6) returns zero unsourced spans.**

✅ **Strength.** This is exactly the right top-level frame. Research backs it: hierarchical-chunk + citation-required + post-hoc audit is the SOTA stack.

> **L25: 1 Ingest → 2 Interrogate → 3 Outline (checkpoint) → 4 Generate → 5 Visuals → 6 QA gate → 7 Deliver**

✅ **Strength** — the staged pipeline matches BooookScore's "hierarchical merging beats incremental" finding.
⚠️ **Gap 1.** Stage 4 ("Generate") doesn't specify the structured-tuple output form. Right now it implies free-prose generation, which makes the QA gate in Stage 6 a post-hoc rescue rather than a build-time guarantee.
⚠️ **Gap 2.** No Retention Score rubric — Stage 4 says "compressing/restating ONLY its mapped corpus content" without telling the model HOW to decide what to compress vs. drop. Editorial framework absent.
⚠️ **Gap 3.** No anchor-vs-bridge distinction. The skill treats the whole output as one register; the research says the hybrid (verbatim anchors + minimal bridges) is the high-fidelity professional default.

> **L34–37: 2. Length — total "page count" → becomes the total word budget. 3. Words-per-page cap — density per scroll section.**

⚠️ **Gap 4.** The user has asked the AI to decide the length. The current skill makes the human decide pages × cap. This needs to flip to a comprehension-equivalence test.

> **L48: Stage 5 — Visuals. Build visuals per density setting using SVG/CSS only (no raster, no external/AI images).**

⚠️ **Gap 5.** Hard ban on raster/AI images conflicts with the user's stated requirement to incorporate AI-generated illustrations. Need to relax this and add the Pollinations.ai channel + Channel-A/Channel-B routing.

> **L52–56: Stage 6 QA gate: Grounding pass / Adversarial review / Fix loop / Coverage report.**

✅ **Strength.** Adversarial-reviewer-as-sub-agent is exactly the FABLES-style protocol.
⚠️ **Gap 6.** No quantitative gates — no NLI score threshold, no coverage % floor, no anti-end-weighting per-chapter quota.

> **L60: assembled one self-contained, responsive HTML file (inline CSS + inline SVG).**

⚠️ **Gap 7.** No typography spec. No navigation spec. No reading-UX requirements. The current skill could ship a single `<body>` of dumped paragraphs and pass.

> **L70–84: Common Mistakes + Red Flags.**

✅ **Strength.** The red-flag list is well-shaped. Keep verbatim.

**Overall verdict:** the skill nails the *grounding philosophy* and has good bones. It is under-specified on (a) editorial retention logic, (b) the anchor/bridge hybrid form, (c) AI-illustration channels, (d) length-by-comprehension, (e) reading-UX quality bar, and (f) quantitative QA gates.

---

## 5. Recommended Skill Edits

### Edit 1 — Replace Stage 2 (Interrogate) length questions with a comprehension-equivalence path

**Before (L32–39):**
```
Ask these FOUR questions, one AskUserQuestion popup each, in order.
1. Tone / genre …
2. Length — total "page count" → becomes the total word budget.
3. Words-per-page cap — density per scroll section.
4. Visual density — …
```
**After:**
```
Ask these THREE questions, one AskUserQuestion popup each:
1. Tone / genre — Self-help · Educational · Narrative · Faithful-voice.
2. Visuals channel — Channel A only (Mermaid/SVG, framework diagrams) · Channel A + B (also Pollinations.ai chapter openers and mood images) · None.
3. Style anchor (only if Channel B picked) — pick from preset list or describe: e.g. "watercolor, muted ochre, 1950s children's book."

Length is AI-decided via the comprehension-equivalence test (see Stage 4.5 below).
The user does NOT pre-specify pages or words.
```

### Edit 2 — Add a Retention Score rubric to Stage 3 (Outline)

**Insert after L42:**
```
Stage 3.1 — Score every source paragraph 1–10 using the Retention Rubric
in references/retention-rubric.md. Tag each paragraph in the corpus with
its score and dominant signal (plot-turn / framework / first-example /
recap / etc.). The outline maps Retention ≥ 7 paragraphs to anchor blocks
and Retention 4–6 paragraphs to bridge-condensation targets. Retention
≤ 3 are dropped (and listed in coverage.json with reason).
```

### Edit 3 — Require structured-tuple generation in Stage 4

**Before (L44–46):**
```
Stage 4 — Generate
Write each section by compressing/restating ONLY its mapped corpus content…
```
**After:**
```
Stage 4 — Generate
Emit each section as an ordered list of UNITS. Each unit is JSON:
  { kind: "anchor"|"bridge", html, source_ids[], verbatim_quote }
- Anchor units carry verbatim source text in a <blockquote class="anchor"
  data-source-id="…">. NO paraphrasing.
- Bridge units are AI-authored transitions ≤ 2 sentences each.
  Total bridge words ÷ total words ≤ 0.10.
- Tone (Stage 2 Q1) affects bridge phrasing only. Anchors are immutable.

Stage 4.5 — Comprehension-equivalence sizing loop
1. Compute target budget = Retention Mass × 8 words/retention-point.
2. Generate at that budget.
3. Spin a fresh sub-agent given ONLY the condensed HTML; ask it 10
   auto-generated questions derived from Retention ≥ 7 paragraphs.
4. Pass = ≥ 85% correct. Fail → expand worst-scoring chapters by +25%,
   regenerate those only, re-test. Cap 3 iterations.
5. If still failing, surface deficits to user; do NOT lower the bar.
```

### Edit 4 — Replace Stage 5 (Visuals) with two-channel illustration pipeline

**Before (L48):** the SVG/CSS-only ban.
**After:**
```
Stage 5 — Visuals (two channels, routed at outline time)

Channel A — Mermaid + inline SVG. Default for self-help and any section
tagged framework/process/comparison/timeline. Externalizes relationships
(Mayer/Paivio dual-coding). Zero external calls. Always available.

Channel B — Pollinations.ai (Flux). Default for fiction chapter openers
and major scene beats. Endpoint:
  https://image.pollinations.ai/prompt/{url-encoded}?model=flux&seed={book_seed}&width=1280&height=720&nologo=true
Prompt template: {scene}, {mood}, {characters_with_persistent_traits},
{key_objects}, STYLE: {style_anchor}. Style anchor and book_seed frozen
at Stage 2; characters carried in a characters.json across all prompts.
On HTTP/timeout failure, retry once with a different seed; on second
failure, fall back to an anchor blockquote of the passage.

Disable Channel B if user chose "None" or "Channel A only" at Stage 2.
Caption every image with the source_id of the passage it illustrates.

Anti-decoration rule (self-help): no Channel B image MAY ship in a
self-help section unless a Channel A diagram also ships in the same
section. Decoration without dual-coding loses learning gains.

Patterns + style presets: references/illustration-channels.md.
```

### Edit 5 — Tighten Stage 6 QA gate with quantitative thresholds

**Before (L50–56):** prose description of grounding pass + adversarial review.
**After:**
```
Stage 6 — QA gate (quantitative)
1. Anchor verification — fuzzy match (rapidfuzz token_set_ratio ≥ 95)
   verbatim_quote vs. concatenated source at source_ids. Any miss → regenerate.
2. Bridge entailment audit — fresh sub-agent reads ONLY the bridge sentence
   + its cited source paragraphs; flags every name/number/claim not in source.
   Any flag → regenerate that bridge.
3. Bridge-ratio gate — bridge_words / total_words ≤ 0.10.
4. Chapter-coverage gate — each chapter contributes (chapter_words/book_words) × 0.7
   to (chapter_words/book_words) × 1.3 of the output's words. Prevents FABLES
   end-of-book bias and middle-chapter drop-out.
5. Comprehension-equivalence test — see Stage 4.5. ≥ 85%.
6. Coverage report — write coverage.json: source_coverage_pct,
   per_chapter_contribution_pct, dropped_sections[{source_id, reason}].
   The coverage report ships alongside the HTML.

No section ships until 1–5 all pass. Iron law unchanged.
```

### Edit 6 — Add Stage 7 reading-UX contract

**Before (L59–60):** "assemble one self-contained, responsive HTML file."
**After:**
```
Stage 7 — Deliver
Self-contained HTML with these MANDATORY chrome features (template in
references/reading-ux-template.html):
- Body: max-inline-size: 66ch; line-height: 1.65; font-size: clamp(1rem, 0.5rem + 1vw, 1.25rem); humanist serif or sans.
- Sticky side-rail TOC (or top disclosure on narrow viewports), with
  IntersectionObserver scroll-spy highlighting current section.
- 2–3px top progress bar fed by scrollY/scrollHeight.
- Per-H2 reading-time estimate ("8 min read"); document-level "X% / Y min left".
- Hover/focus popovers for every internal cross-link (Gwern popups.js
  pattern, inlined). On mobile, long-press opens the popover.
- Sidenotes via Tufte-CSS .sidenote pattern; collapse to <details> on narrow.
- Drop cap at every chapter opener (::first-letter).
- Pull-quote every 3–5 screens (data-driven from Retention ≥ 9 paragraphs).
- prefers-color-scheme dark mode with #e6e6e6 on #1a1a1a (no pure white/black).
- Structural choice rule: narrative/argument books preserve chapter order;
  reference/how-to/framework books offer linear + thematic alternate TOC.
  The AI decides per book at outline time and shows a one-line "Design
  Note" at the top of the HTML explaining the choice.

Save to CLAUDE OUTPUTS\<project>\<Book-Title>_Reader_v1.html.
```

### Edit 7 — Update the description-front-matter triggers

**Before (L3):** "…does NOT fetch external images;…"
**After:** "…fetches images ONLY from Pollinations.ai (Channel B) when explicitly enabled by the user at Stage 2 and only with frozen seed + style anchor; never from arbitrary external URLs;…"

### Edit 8 — New sibling files (none deleted, all added)

| New file | Content |
|---|---|
| `references/retention-rubric.md` | The full Retention Score table + worked example on a sample chapter. |
| `references/illustration-channels.md` | Channel A Mermaid recipe library; Channel B prompt template + curl examples + style-anchor presets. |
| `references/reading-ux-template.html` | The full HTML chrome (CSS variables, TOC scroll-spy JS, popover script, sidenotes). Skill copies this and fills the `<article>`. |
| `references/comprehension-test.md` | The 10-question generation prompt + scoring rubric for Stage 4.5. |
| `references/quality-benchmark.md` | The 40-point rubric from §3 above. |

### Edit 9 — Add Common Mistakes / Red Flags entries

Append to the existing list:
- **Letting "bridge" register creep above 10% of total.** The hybrid breaks; you're now writing a paraphrase, not abridging.
- **Skipping Channel A in self-help because Channel B looks prettier.** Decorative images without dual-coding diagrams measurably *reduce* concept recall.
- **Shipping without the comprehension-equivalence test.** Pretty ≠ comprehensive.
- **Hardcoding a length when the AI was supposed to decide.** Re-run Stage 4.5.

---

## 6. Iteration Loop Specification

```text
function build_book_html(source, build_spec):
    corpus = ingest(source)                              # Stage 1
    score_paragraphs(corpus, retention_rubric)           # Stage 3.1
    outline = build_outline(corpus, build_spec)          # Stage 3
    user_approve(outline)                                # Stage 3 checkpoint

    iteration = 0
    while iteration < 3:
        draft = generate_structured_units(outline)       # Stage 4
        ce_score = comprehension_equivalence_test(draft) # Stage 4.5
        qa = run_qa_gate(draft)                          # Stage 6
        scorecard = score_against_benchmark(draft, qa, ce_score)

        if scorecard.total >= 32 and scorecard.min >= 3:
            break

        worst = scorecard.lowest_dimension()
        regenerate_artifact_for(worst, draft)
        iteration += 1

    if scorecard.total < 32:
        surface_deficits_to_user(scorecard, draft)
        ask: "Ship as-is / override / abandon?"
    else:
        assemble_html(draft, reading_ux_template)        # Stage 7
        write_coverage_report()
        deliver()
```

Cap is hard. Iterations consume tokens; runaway is the failure mode. After 3, the user sees the deficit and chooses — the skill never silently lowers its bar.

---

## 7. Daily-Use Enhancements (for sustained habit)

To turn this from "occasional skill" into "I read a condensed book every day":

1. **Reading queue manifest.** `CLAUDE OUTPUTS\book-to-html\_queue.yaml` lists pending source files with priority + style-anchor preference. A new `/book-to-html next` mode picks the top entry, runs the pipeline, and moves the entry to `_finished.yaml` with the date and the comprehension-equivalence score.
2. **"Books finished" log with cross-book concept linking.** Each finished book emits a `concepts.json` of named frameworks/characters. The skill's next run gets the cumulative concepts.json injected, so internal cross-links can point not only within a book but to concepts already encountered in prior books. (Wikipedia-style across your personal library.)
3. **Daily 15-minute slot mode.** Optional `--time-budget 15min` overrides the comprehension test with a length that fits a 15-minute read at the user's measured reading speed (default 250 wpm → 3750 words). Coverage falls; the skill ships a "skim" build with a clearly marked banner and saves the full build alongside for later.
4. **Style-anchor presets library** in `references/illustration-channels.md` (six presets: muted watercolor, technical line-art, mid-century children's, noir charcoal, photographic-realism, hand-drawn cartoon). User picks once per book; reused across.
5. **Reading-streak telemetry.** A `_streak.json` in the queue folder records books-finished-per-week; the skill shows a one-line streak banner ("Book 4 this week — streak holds") at delivery. Behavioral nudge, not a metric.
6. **Mobile-first preview check.** Stage 7 emits a 375px-wide screenshot via `/browse` (if installed) and a 1280px-wide one; the user sees both before approving delivery.
7. **Re-ingest mode for updated source.** If a source file changes, re-running the skill detects the diff via content hash and re-runs only changed chapters — preserving the rest verbatim.

---

## 8. Open Questions for the User

Only items that genuinely need your taste:

1. **Default visual channel for self-help vs. fiction** — adopt the research default (self-help = Channel A primary + B sparingly; fiction = Channel B chapter openers + A for any framework asides)? Or override?
2. **Pollinations dependency** — comfortable with one external (free, keyless) image API, or strict zero-network and SVG/Mermaid only?
3. **Style-anchor library** — do you want the six presets shipped, or do you want to define your own?
4. **Comprehension-test threshold** — 85% is the proposed pass. Tighter (90%) makes outputs longer; looser (75%) faster but riskier.
5. **Daily-use queue mode** — implement `_queue.yaml` + `/book-to-html next` in this iteration, or defer to v2?

---

**Benchmark threshold: 32/40. Iteration cap: 3.**
