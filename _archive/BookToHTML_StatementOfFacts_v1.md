# book-to-html — Statement of Facts (for PRD intake)

**Purpose of this document:** a self-contained briefing that a downstream skill-development orchestrator (e.g., `/ram-sdlc`, `/sdlc`, or a successor) can read cold and fully understand:
- what we are trying to achieve,
- what artifacts already exist in this folder,
- what each artifact contains,
- where they converge and diverge,
- which open questions Ram must still resolve before locking the PRD.

No new design proposed here. This file is **descriptive**, not prescriptive. The PRD comes next.

---

## 1. Goal

Ram is converting the existing skill at `C:\Claude Cowork\skills\book-to-html\` from its current procedural-pipeline shape into a **next-generation, AI-first skill** in which condensed, illustrated, navigable HTML "reader" versions of books (fiction and self-help in particular) are produced by a cast of named LLM personas orchestrated through typed handoff envelopes — with the explicit success criterion that Ram's books-finished-per-week rate measurably increases because the artifacts are good enough to substitute for the originals.

The path from here:

1. Evaluate the two recommendation files in this folder.
2. Reconcile and freeze the final set of requirements as a PRD.
3. Hand that PRD to Ram's application-development skill (`/ram-sdlc` v2 stack).
4. That skill produces the rewritten `book-to-html` SKILL.md plus its sibling reference files.

---

## 2. Source repository context (background the orchestrator needs)

- **Current skill:** `C:\Claude Cowork\skills\book-to-html\SKILL.md` (85 lines) plus three sibling references: `ingest.md`, `qa-grounding.md`, `design-system.md`. The current skill is grounded, has an iron-law QA gate against hallucination, and runs a 7-stage procedural pipeline. It is *not* AI-first by Ram's playbook definition. The HTML output is constrained to SVG/CSS visuals only — no AI illustrations, no raster.
- **Ram's AI-first reference doctrine:** `C:\Claude Cowork\Playbook for AI-first learning applications\` — the production-ready three-document bundle (Blueprint v1.2.1, Implementation Companion v1.0.2, Engineering Field Manual v1.0.1) plus an intake template. This bundle is the standard the new skill must measure up to.
- **Ram's writing/output rules:** outputs land in `C:\Claude Cowork\CLAUDE OUTPUTS\<project>\`; naming `<project>_<content-type>_v<n>.<ext>`; never delete files; lead with the deliverable.

---

## 3. Folder inventory — `C:\Claude Cowork\CLAUDE OUTPUTS\book-to-html\`

Two recommendation files, produced in sequence in the same session, plus this Statement of Facts.

| File | Lens | What it answers |
|---|---|---|
| `BookToHTML_EnhancementPlan_v1.md` | Research-grounded procedural enhancement of the existing pipeline | What does professional book-abridgment practice say, what does the AI-summarization-faithfulness literature say, how should AI illustrations be wired in, how should the HTML feel — and where does the existing SKILL.md fall short? |
| `BookToHTML_AIFirstPlan_v1.md` | Re-architecture through Ram's AI-first playbook lens | If the same skill were re-built as a cast of named LLM personas with adversarial separation and a Reader-persona terminal gate, what would the shape be — and how do the prior recommendations map onto that shape? |
| `BookToHTML_StatementOfFacts_v1.md` (this file) | Synthesis briefing for the PRD-intake orchestrator | What does the next skill-development pass need to know to draft the PRD without re-reading both files in full? |

---

## 4. What `BookToHTML_EnhancementPlan_v1.md` contains

**Provenance.** Built from four parallel web-research sub-agents commissioned in the same session:

1. *Traditional book abridgment practice* — Reader's Digest Condensed Books, Penguin Classics, Maxwell Perkins line editing, audio-abridgment trade. Key finding: professional abridgment is overwhelmingly a **hybrid** craft — ~90% verbatim "anchor" passages + ≤10% editor-written connective tissue. Cut the "three R's" (repetition, rhetoric, redundancy). Fiction protects plot turns and signature voice; self-help protects the framework spine and prunes the 2nd/3rd/4th example per concept. Compression ratios in the wild: ~50–60% for prestige print; ~85–90% for abridged audio.
2. *AI summarization faithfulness SOTA (2023–2026)* — QAGS, SummaC, AlignScore, FActScore, G-Eval, BooookScore, FABLES, positional-bias literature. Winning stack for book-length = hierarchical chunk-then-merge generation with `(claim, source_span_id, verbatim_quote)` tuples + atomic-fact decomposition + NLI entailment audit. Empirical hazards: hallucination spikes at the END of long generations (Liu 2025); the MIDDLE of long inputs is the most often unfaithful (positional-bias 2024); LLM book summaries systematically over-weight endings (FABLES 2024).
3. *AI-illustration pipelines for long-form text* — illumination_pipeline (GitHub), IP-Adapter style-locking, Pollinations.ai (free, keyless Flux endpoint), Mermaid for self-help frameworks. Dual-coding research (Paivio / Mayer): decorative imagery in self-help measurably reduces concept recall; relationship-externalizing diagrams improve it. Placement hierarchy: chapter openers > scene breaks > concept anchors > inline decoration.
4. *Long-form HTML reading UX* — Butterick, web.dev typography, Gwern's design, Distill, Stripe Press, Tufte CSS. Convergent recipe: 66ch measure, 1.65 unitless line-height, `clamp(1rem, 0.5rem + 1vw, 1.25rem)` size, sticky scroll-spy TOC, top progress bar (endowed-progress effect), Gwern-style hover popovers instead of jump anchors, sidenotes via Tufte CSS, drop caps at chapter starts, pull-quotes every 3–5 screens.

**What the file proposes.** Eight concrete enhancements to the existing procedural pipeline:

1. **Retention Score Rubric** — a 1–10 scoring rubric per source paragraph with fiction-weighted and self-help-weighted signals (plot turn, framework, first example, voice, recap, repetition). Threshold logic: keep verbatim ≥7, paraphrase 4–6, drop ≤3.
2. **Anti-Hallucination Grounding Protocol** — structured-tuple generation (every output unit emits `{kind: anchor|bridge, html, source_ids, verbatim_quote}`); fuzzy-match anchor verification ≥95 token_set_ratio; NLI bridge audit by fresh sub-agent; per-chapter coverage quota to defeat FABLES end-of-book bias; bridge-ratio ≤ 0.10.
3. **AI Illustration Pipeline** — two channels. **Channel A**: Mermaid + inline SVG (free, deterministic, default for self-help framework diagrams). **Channel B**: Pollinations.ai Flux endpoint (free, keyless, frozen seed + frozen style anchor, default for fiction chapter openers and major scene beats). Anti-decoration rule for self-help: no Channel B image ships unless a Channel A diagram ships in the same section.
4. **AI-decided length via comprehension-equivalence test** — Retention Mass × 8 words/point as target; a fresh sub-agent given ONLY the condensed HTML answers 10 questions auto-generated from Retention≥7 paragraphs; pass = ≥85% correct; fail → expand worst-scoring chapters by 25%, regenerate, re-test; cap 3 iterations.
5. **40-point quality benchmark** across 8 dimensions (fidelity, hybrid-ratio, continuity, visual-pleasure, navigation, illustration-relevance, coverage-balance, "I would skip the original"). Pass = ≥32/40 with no dimension below 3.
6. **Reading-UX contract** — the typography, navigation, popover, sidenote, drop-cap, dark-mode requirements above, codified as Stage 7 mandates.
7. **Quantitative QA thresholds** replacing prose QA description.
8. **Daily-use enhancements** — reading queue manifest, books-finished log, cross-book concept linking, daily-15-min skim mode, style-anchor presets, reading-streak telemetry, mobile-first preview check, re-ingest mode for updated sources.

**Open questions left at end of v1:** default visual channel per genre; Pollinations dependency OK?; style-anchor preset library; comprehension-test threshold (85% default); daily-use queue mode now or v2?

**What this file does *not* do:** it remains structurally a procedural pipeline. The personas implied (editor, designer, fact-checker) are not first-class. There is no terminal "would I read more books" gate owned by a Reader persona.

---

## 5. What `BookToHTML_AIFirstPlan_v1.md` contains

**Provenance.** Produced after Ram explicitly asked for an AI-first re-architecture and pointed the session at the playbook directory. The file reads every playbook artifact and extracts ten load-bearing patterns before designing.

**The ten extracted playbook patterns** (verbatim labels):
1. Removal Test as falsifiability gate (Blueprint §3.1).
2. Control-Plane Ownership — the loop is the workflow (Blueprint §3.2).
3. Substrate-typed Persona Map — `AI | deterministic | external-system | human` (Blueprint §4.2 L2).
4. Workflows-first + compound-error math (Blueprint §3.9 / Field Manual #6).
5. Cite everything you claim — citation-validity as mandatory eval class (Field Manual #4).
6. Adversarial review cycles — no self-grading (synthesis from playbook's own review history).
7. Reversibility-Gated Human Handoff (Blueprint §3.4).
8. Eval-driven development as load-bearing (Blueprint §3.5).
9. Trace-first observability with redaction (Blueprint §3.6).
10. Multi-tier products — AI-First + deterministic substrate declared together (Blueprint §2.8).

**What the file proposes — the persona cast (six personas):**

| # | Persona | Substrate | Model | Role |
|---|---|---|---|---|
| 1 | **Ingestor** | deterministic | none | Parses source into a `source_id`-stamped corpus. |
| 2 | **Editor** | AI | Opus | NYT/Perkins/Reader's-Digest editorial voice. Decides what stays vs. cuts. Emits structured units (anchor + bridge). Internal `judgment_criteria` is the Retention Rubric absorbed from v1. |
| 3 | **Visual Designer** | AI | Opus | Stripe Press × Distill × Gwern editorial designer. Picks navigation shape (linear / themed / hybrid), illustration channel (A / B / both / none), reading-UX chrome. Justifies choices in a "Design Note" at top of HTML. |
| 4 | **Proofreader** | AI | Sonnet | Adversarial NYT standards-desk fact-checker. Single job: find hallucination. Reads units ONLY against cited source spans; flags every unsupported name, number, date, quote, claim. Owns the grounding gate. |
| 5 | **Reader** | AI | Opus | Simulates Ram-as-user. Scores five dimensions 1–5 (visual pleasure, navigation, comprehension, illustration, books-finished-rate). **The terminal gate.** `books_finished_rate ≥ 4` is the ship criterion. |
| 6 | **Orchestrator** | deterministic | none | Runs the DAG, enforces typed JSON handoff envelopes (`book-to-html-handoff/1.0`), routes rework to the persona owning the lowest-scoring dimension, caps iteration at 3, emits a per-build `trace.json`. |

**Iron Laws codified:**
1. Adversarial separation — no persona grades its own output.
2. Every claim cites a `source_id`.
3. Bridge ratio ≤ 0.10.
4. Reader-gate ≥ 4/5 on `books_finished_rate` or surface to Ram.
5. Iteration cap = 3.
6. Designer's Design Note shown at top of every HTML output.

**Intake collapses from four questions to three:** `book_kind`, `illustration_channel_pref`, `style_anchor_pref`. Length and density are AI-decided.

**Mapping from v1 → v2** (explicit table in the file):
- Retention Rubric → Editor's internal judgment criterion (re-shaped, not exposed as runtime artifact).
- Anti-hallucination grounding → Proofreader (preserved as-is).
- Two-channel illustrations → Designer's `illustration_plan` output (preserved).
- Comprehension-equivalence test → Reader's `comprehension` dimension (re-shaped — collapsed into the terminal verdict, not a side-process).
- 40-point benchmark → collapsed into Reader's 5-dimension verdict + Proofreader's structured violations (re-shaped).
- Reading-UX template → Designer's reference file (preserved).
- Quantitative QA thresholds → Proofreader's `judgment_criteria` (preserved).
- Daily-use enhancements → Orchestrator features (preserved, deterministic).
- Cross-book concept linking → deferred to v3 (needs its own "Librarian" persona).

**Alignment check against the playbook:** all ten patterns marked ✅. One borderline ⚠️ — if the skill is treated as a *product* not a *workflow*, a Persona Boundary ADR should be formalized.

**Open questions left at end of v2:** five, listed in §10 of that file. They are the ones genuinely needing Ram's judgment.

---

## 6. Convergences (where v1 and v2 already agree)

The orchestrator can treat these as **settled requirements** — they appear in both files with no contradiction.

1. **Grounding is non-negotiable and is owned by an adversarial fact-checker** that is a separate agent from the generator. Every claim resolves to a `source_id`; verbatim quotes match the source char-for-char within a fuzzy-match tolerance.
2. **Hybrid abridgment**, not paraphrase, not copy-paste. Anchor (verbatim) + bridge (AI-written transitions); bridge words ≤ 10% of total.
3. **Two-channel AI illustration.** Channel A = Mermaid/SVG for self-help frameworks; Channel B = Pollinations.ai Flux for fiction chapter openers and mood. Free, keyless. Frozen seed and frozen style anchor per book.
4. **Reading-UX chrome is mandatory and uniform across books.** 66ch measure, 1.65 line-height, `clamp(1rem, 0.5rem + 1vw, 1.25rem)`, sticky scroll-spy TOC, top progress bar, hover popovers (not jump anchors) for internal links, sidenotes via Tufte CSS, drop caps at chapter openers, pull-quotes every 3–5 screens, prefers-color-scheme dark mode.
5. **Anti-FABLES per-chapter coverage quota.** Each chapter contributes 70–130% of its proportional share of the output word count, preventing end-of-book over-weighting and middle-chapter drop-out.
6. **AI decides length.** Ram does not specify page count or word budget. The build runs a comprehension test; the Reader is the final arbiter.
7. **AI decides navigation shape per book.** Narrative/argument books preserve chapter order; reference/how-to/framework books cluster by theme; mixed books offer both. Justified in a Design Note at the top of the HTML.
8. **Iteration cap = 3.** Hard. After 3 failed Reader-gate passes, surface deficits to Ram with the choice ship-as-is / override / abandon.
9. **Daily-use ergonomics matter.** Both files want a reading-queue manifest, a finished-books log, mobile-preview checks, and consistent naming (`<Title>_Reader_v1.html`).
10. **All work outputs to `CLAUDE OUTPUTS\book-to-html\` per Ram's global rules.** No file deletions.

---

## 7. Divergences (where v1 and v2 disagree — Ram must decide)

The orchestrator must NOT treat these as settled.

| # | Dimension | v1 position | v2 position | Decision needed |
|---|---|---|---|---|
| D1 | Architecture | 7-stage procedural pipeline (Ingest → Interrogate → Outline → Generate → Visuals → QA → Deliver) | Six-persona cast on a small fixed DAG with typed JSON handoff envelopes | Lock v2 (Ram's stated intent). v1's stage names become persona-internal sub-steps. |
| D2 | Quality benchmark | 40-point rubric across 8 dimensions, pass ≥32/40, no dim < 3 | Reader's 5-dimension verdict, terminal gate = `books_finished_rate ≥ 4` | v2 is sharper but loses some numerical granularity. Decide whether to keep both (Reader for go/no-go, Proofreader's structured output for the numerical detail) or commit to v2's collapsed form. |
| D3 | Interrogation depth | 4 questions (tone, length, words-per-page cap, visual density) | 3 questions (book_kind, illustration_channel_pref, style_anchor_pref) | Decide intake question set. v2's reduction is intentional — the AI owns the rest. |
| D4 | Model spend | Implicit; not specified | Editor + Designer + Reader on Opus; Proofreader on Sonnet; ~$3–8 per book at order-of-magnitude | Decide model-tier budget and per-book cost ceiling. |
| D5 | Comprehension test | Stage 4.5 explicit sub-process with a 10-question auto-generated quiz | Collapsed into Reader's `comprehension` dimension | Decide whether comprehension test remains a discrete, runnable artifact (useful for telemetry) or is fully internal to Reader. |
| D6 | Cross-book concept linking | "Wikipedia-style across your personal library" daily-use enhancement | Deferred to v3; needs a Librarian persona | Decide v2 or v3. |
| D7 | Persona Boundary ADR | Not mentioned | Recommended as `references/ADR-01-persona-boundaries.md` | Decide whether to formalize the Companion §3.2 #11 pattern inside the skill folder. |
| D8 | Retention Rubric exposure | Runtime artifact in `references/retention-rubric.md` | Internal to Editor's `judgment_criteria`, not a separate file | Decide whether the rubric ships as a reference file (helps reproducibility / human-debugging) or stays in-persona-prompt (cleaner separation). |

---

## 8. Open questions Ram must answer before PRD lock

Aggregated from both files' open-question sections, de-duplicated, and re-stated as binary or short-answer decisions.

1. **Pollinations.ai dependency: enable Channel B?** (Yes / No / Yes-with-fallback-to-anchor-blockquote.) v2 recommends yes-with-fallback.
2. **Style-anchor presets: ship the 6-preset library, or only custom-per-book?** (Six presets named in v1 plan §7 item 4: muted watercolor; technical line-art; mid-century children's; noir charcoal; photographic-realism; hand-drawn cartoon.)
3. **Model-tier budget: keep Designer on Opus or downgrade to Sonnet?** Cost vs. taste trade-off (~halving the per-book API cost).
4. **Reader-gate threshold: `books_finished_rate ≥ 4` (recommended), ≥5 (strict), or ≥3 (lenient)?**
5. **Persona Boundary ADR: formalize as `references/ADR-01-persona-boundaries.md`?** (Yes / No.)
6. **Cross-book concept linking: include in v2 or defer to v3?** v2 recommends defer.
7. **Quality benchmark form: keep v1's 40-point rubric as a sidecar telemetry artifact, OR collapse fully into v2's 5-dimension Reader verdict?**
8. **Comprehension-equivalence test: keep as a discrete, runnable artifact OR fully internal to Reader?**
9. **Retention Rubric exposure: ship as `references/retention-rubric.md` OR embed in Editor identity prompt only?**
10. **Daily-use queue mode (`_queue.yaml` + `/book-to-html next`): in v2 scope or deferred?**

These ten are the only decisions blocking the PRD. Everything else in §6 is locked.

---

## 9. What the orchestrator should produce next

A PRD that:

1. **Adopts the v2 AI-first architecture** as the skeleton (persona cast, typed handoff envelopes, Reader terminal gate, Iron Laws).
2. **Absorbs the v1 substantive content** at the persona-ownership level per the §5 mapping table in `BookToHTML_AIFirstPlan_v1.md`.
3. **Resolves the ten open questions in §8** of this Statement of Facts, either by Ram answering each one explicitly or by the orchestrator presenting them as a single decision popup at PRD intake.
4. **Aligns with the playbook's Blueprint §4.4 PRD shape**: 16 sections including Persona Map, Work Allocation Registry, Interaction & Action Surface, Eval Plan, Trace Schema, Rollout Plan, Ownership Registry, Success Metrics, Open Questions.
5. **Declares the skill multi-tier** per Blueprint §2.8: AI-First overall (Editor / Designer / Proofreader / Reader own the value proposition), with deterministic substrate tiers (Ingestor, Assembler, Orchestrator) declared explicitly.
6. **Hits the Removal Test:** if the LLM personas are removed, the artifact collapses — not just degrades. This is genuinely AI-First, not AI-Sprinkled.

After the PRD is locked, the application-development skill (`/ram-sdlc` v2 or successor) generates:
- The rewritten `C:\Claude Cowork\skills\book-to-html\SKILL.md` (≤200 lines per Ram's checklist).
- Sibling files: `persona-editor.md`, `persona-designer.md`, `persona-proofreader.md`, `persona-reader.md`, `illustration-channels.md`, `reading-ux-template.html`, `red-flags.md`, `trace-schema.md`, `handoff-envelopes.md`, optional `ADR-01-persona-boundaries.md`.
- Preserved-from-current: `ingest.md`, `qa-grounding.md` (re-attributed to Proofreader), `design-system.md` (folded into Designer reference or kept).

---

## 10. Files this Statement of Facts references

- `C:\Claude Cowork\skills\book-to-html\SKILL.md` (current skill — being replaced)
- `C:\Claude Cowork\skills\book-to-html\references\ingest.md`
- `C:\Claude Cowork\skills\book-to-html\references\qa-grounding.md`
- `C:\Claude Cowork\skills\book-to-html\references\design-system.md`
- `C:\Claude Cowork\CLAUDE OUTPUTS\book-to-html\BookToHTML_EnhancementPlan_v1.md` (recommendation file v1)
- `C:\Claude Cowork\CLAUDE OUTPUTS\book-to-html\BookToHTML_AIFirstPlan_v1.md` (recommendation file v2)
- `C:\Claude Cowork\Playbook for AI-first learning applications\` (the reference doctrine — Blueprint v1.2.1, Companion v1.0.2, Field Manual v1.0.1, templates/intake.md)

End of Statement of Facts.
