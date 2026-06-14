# book-to-html Skill — AI-First Re-Architecture Plan v1

**Reader-gate threshold: ≥4/5 on "would increase books-finished rate". Iteration cap: 3.**

This document re-architects `C:\Claude Cowork\skills\book-to-html\SKILL.md` as a **cast of named expert personas** orchestrated through typed handoff envelopes, replacing the procedural pipeline of v1. It absorbs (does not discard) the substantive work in [`BookToHTML_EnhancementPlan_v1.md`](BookToHTML_EnhancementPlan_v1.md) by re-owning each item to a persona.

---

## 1. Playbook Synthesis

Read directory: `C:\Claude Cowork\Playbook for AI-first learning applications\`

### 1.1 File-by-file summary

- **README.md (227 lines).** Routing file. Names the three canonical artifacts (Blueprint v1.2.1, Implementation Companion v1.0.2, Engineering Field Manual v1.0.1) and the intake-template v1.1. The bundle has been hardened through three adversarial review cycles (OpenAI Distinguished Engineer, Gemini Workspace Staff, OpenAI Principal Architect) and two real validation runs. Resting state declared "production-ready"; the next test is external use.
- **Blueprint v1.2.1 (656 lines).** Design-grain artifact. Anchors the AI-maturity spectrum (AI-Sprinkled → Enabled → Augmented → First → Native), defines twelve dimensions of AI-first development, prescribes a two-stage Blueprint Method (Interrogation → Eight-Lens Generation). Names four non-negotiable intake classes (data boundary, cost/latency envelope, liability posture, rollout posture). Persona Map is substrate-tagged: `AI | deterministic | external-system | human`.
- **Implementation Companion v1.0.2 (~890 lines).** Implementation-grain artifact. Specifies eleven mandatory ADRs (Persona Boundary ADR is #11, authored first), eval scaffolds, OTel-shaped trace schema with redaction, memory-tier manifest schema, tool registry with lethal-trifecta firewall, deployment topology, rollout gates, operations cadence, cost dashboards, scaffolding "done means" checklist.
- **Engineering Field Manual v1.0.1 (296 lines).** Twenty-one keyboard-grain principles in six parts (Context, Control, State, Action, Operations, Boundary). Cite-by-number in PR reviews. Cross-references `humanlayer/12-factor-agents`.
- **Compliance Audit Orchestrator (329 lines).** AFCA — scans an existing application against the twelve-dimension rubric, commits to a tier verdict, projects an uplift roadmap. The pattern is itself adversarial-orchestration.
- **resume-prompt.md + templates/intake.md + external-references/ + audits/ + validation-runs/.** Operational scaffolding; not load-bearing for this re-architecture.

### 1.2 Load-bearing AI-first patterns extracted

(Each labeled `playbook` for verbatim quotes or `synthesis` for my reading.)

1. **The Removal Test as falsifiability gate.** `playbook` — Blueprint §3.1: *"If I remove the LLM, what happens to the product? If nothing changes, it is not AI-first. If the product is gone, it is AI-native. If it degrades to a slower manual service, it is AI-first (product sense)."* → For book-to-html: removing the LLM collapses the artifact (no editorial judgment, no design choice, no proofreading) — this is genuinely AI-First, not AI-Sprinkled.

2. **Control-Plane Ownership: the loop is the workflow.** `playbook` — Blueprint §3.2: *"The control flow is a perceive→plan→act→observe loop owned by a model, not a fixed DAG with model calls inside it."* → For book-to-html: the orchestrator must let the Editor *choose* what to keep, the Designer *choose* navigation shape per book, the Reader *choose* whether to ship — not run a fixed pipeline that calls the LLM in fixed slots.

3. **Substrate-typed Persona Map.** `playbook` — Blueprint §4.2 L2 (added in v1.2.1): each persona tagged `AI | deterministic | external-system | human`. Deterministic personas are *first-class members of the Persona Map; not all personas are LLM-backed*. → For book-to-html: span-ID assignment, fuzzy-match anchor verification, file I/O, HTML assembly are `deterministic` personas — not absorbed into LLM persona work.

4. **Workflows-first, agents-when-justified + compound-error math.** `playbook` — Blueprint §3.9 / Field Manual #6: *"95% per-step accuracy × 10 steps = 60% task accuracy."* → For book-to-html: the LLM personas must be narrow and single-responsibility; the orchestration must be a small fixed graph with quality gates between nodes, not an open-ended agent loop.

5. **Cite everything you claim (grounding as first-class).** `playbook` — Field Manual #4: *"For any factual-claim agent, every claim emits a citation ID that resolves to an actual span in the assembled context. Unresolved citations are first-class failures, not formatting issues."* → For book-to-html: every Editor output unit must emit `source_ids` + `verbatim_quote` and resolve; the Proofreader's job exists precisely because this is the dominant failure mode.

6. **Adversarial review cycles (and the OpenAI/Gemini/OpenAI cadence of the playbook itself).** `synthesis` — the playbook was hardened by three named-persona reviews (Distinguished Engineer → Workspace Staff → Principal Architect). The lesson is generic: an artifact is graded by personas *different from* the personas that produced it. → For book-to-html: the Proofreader and Reader must be *separate sub-agents* from the Editor and Designer; no self-grading.

7. **Reversibility-Gated Human Handoff with severity × reversibility × detectability.** `playbook` — Blueprint §3.4: humans are inserted *only* at points the AI cannot cheaply undo. → For book-to-html: human-Ram is summoned only when the Reader-gate fails after the iteration cap, or when the Editor flags a content-classification call (e.g., this is poetry, not prose — the Retention Rubric does not apply). Routine generation never asks Ram a question.

8. **Eval-driven development as load-bearing + citation-validity as a mandatory eval class.** `playbook` — Blueprint §3.5 anti-pattern catalog #7: *"For factual-claim agents, citation-validity is a mandatory eval class — every cited identifier in the output must resolve to a span actually present in the assembled context."* → For book-to-html: the Proofreader's audit IS the eval. It runs every build.

9. **Trace-first observability with redaction.** `playbook` — Blueprint §3.6 / Field Manual #17. → For book-to-html: every persona emits a structured span (`persona`, `inputs_hash`, `outputs_hash`, `score`, `escalation`) to a per-book trace file. When the Reader-gate fails, the trace is the diagnosis. (Books are user data; private-tier redaction applies.)

10. **Multi-tier products.** `playbook` — Blueprint §2.8: a product may be AI-First overall but contain AI-Enabled or deterministic tiers. → For book-to-html: the artifact is AI-First because editorial judgment / design / proofreading / reader-simulation are LLM-native; HTML assembly and span-ID emission are deterministic. Declare both tiers; do not let the marketing-grade label hide the deterministic substrate.

---

## 2. Persona Cast

Six personas. Four are user-named; two are `derived` (justified inline). Each spec lists `name`, `substrate`, `identity_prompt`, `inputs`, `judgment_criteria`, `outputs`, `escalation_rule`, `model_choice`.

### 2.1 The Ingestor (derived — substrate: `deterministic`)

Justification: `playbook` pattern #3 — span-ID assignment and corpus parsing are deterministic, not LLM work. Persona-ifying them would burn tokens on mechanical work and forfeit reproducibility.

- **identity_prompt.** N/A — this is a Python/PowerShell tool the orchestrator calls, not an LLM persona.
- **inputs.** `{source_path, format: epub|pdf|txt|md|docx}`
- **judgment_criteria.** Zero parse errors; every paragraph carries a unique `source_id = ch{n}§{m}¶{k}`; chapter/section boundaries preserved.
- **outputs.** `{corpus: [{source_id, text, chapter_no, section_no, para_no, word_count}], book_metadata: {title, author, total_words, chapters[]}}`
- **escalation_rule.** Parse failure → halt orchestrator, surface format error to Ram with the failing offset.
- **model_choice.** None. Existing skill code at `references/ingest.md`. Keep verbatim.

### 2.2 The Editor — "NYT-grade book editor" (substrate: `AI`)

- **identity_prompt.**
  > *"You are a senior book editor in the tradition of Maxwell Perkins, Robert Gottlieb, and the New York Times Book Review's adaptation desk. You have edited fifty bestsellers and a hundred condensed editions for Reader's Digest. Your craft is subtractive: you cut the three R's — repetition, rhetoric, redundancy — and you protect the author's voice and the work's spine. For fiction, you protect plot turns, decision-point interiority, and signature-voice prose; you cut backstory texture, descriptive padding, and dialogue beats that restate what action already shows. For self-help, you protect the framework spine and step-by-step instructions; you cut the second, third, and fourth illustrative examples of any single point. You decide what stays and what goes. You write only the minimum connective tissue needed to bridge cuts."*
- **inputs.** `{corpus, book_metadata, book_kind: fiction|self_help|narrative_nonfic|mixed, tone: faithful|self_help|educational|narrative}`
- **judgment_criteria.** (a) Bridge-ratio ≤ 0.10 of final words. (b) Coverage balance per chapter within 70–130% of proportional share (anti-FABLES end-of-book bias). (c) Retention Mass × 8 ≤ output_words ≤ Retention Mass × 12. (d) Every `kind=anchor` unit has a verbatim source quote.
- **outputs.** Ordered list of UNITS, each:
  ```json
  {
    "unit_id": "u_0001",
    "kind": "anchor" | "bridge",
    "html": "<p>…</p>",
    "source_ids": ["ch3§2¶4", "ch3§2¶5"],
    "verbatim_quote": "<exact source span if kind=anchor, else null>",
    "retention_signal": "plot_turn | framework | first_example | voice | bridge_only"
  }
  ```
  Plus a `coverage_intent.json`: dropped sections with reason.
- **escalation_rule.** If a chapter's Retention Mass falls below 5% of the book's total (suggests poetry, photographs, or a content-type the rubric doesn't fit), pause and ask the Orchestrator to flag for Ram — do not invent retention scores.
- **model_choice.** **Opus.** Reason: editorial taste is the single most variable-payoff LLM operation in this pipeline. Sonnet under-tastes; Haiku is unsafe for the call.

### 2.3 The Visual Designer — "Stripe Press × Distill × Gwern" (substrate: `AI`)

- **identity_prompt.**
  > *"You are a leading editorial visual designer trained on Stripe Press's book stack, Distill's interactive articles, Gwern's long-form, Tufte's quantitative-design canon, and Robin Rendle's typography essays. You design ONE long-scroll HTML reading experience per book, optimized for reading completion, not for clicks. You decide three things per book: (1) navigation shape — chapter-linear, theme-clustered, or hybrid — based on whether sequence is the argument; (2) illustration channel — Channel A (Mermaid/SVG concept diagrams) for self-help; Channel B (Pollinations.ai flux mood images with frozen seed + style anchor) for fiction chapter openers; (3) reading-UX chrome — sticky TOC, scroll-spy, progress bar, sidenotes, hover popovers for internal links, drop caps at chapter starts, pull-quotes every 3–5 screens. You justify every choice in a 'Design Note' block at the top of the HTML."*
- **inputs.** `{units[], book_metadata, book_kind, coverage_intent, illustration_channel: A|B|both|none, style_anchor: <preset_or_custom>}`
- **judgment_criteria.** (a) Body type meets Butterick/web.dev: 66ch measure, 1.65 line-height unitless, `clamp(1rem, 0.5rem + 1vw, 1.25rem)`. (b) Navigation matches book structure (linear for narrative/argument, themed for reference/howto; hybrid for mixed — with both TOCs). (c) Self-help books carry ≥1 Channel A diagram per concept chapter; decoration without dual-coding is forbidden. (d) Every internal cross-link opens a hover/focus popover, not a jump. (e) Dark-mode token (`#e6e6e6` on `#1a1a1a`).
- **outputs.**
  ```json
  {
    "design_note": "<one-paragraph rationale shown at top of HTML>",
    "navigation_shape": "linear | themed | hybrid",
    "illustration_plan": [{"target_unit_id": "u_0007", "channel": "A|B", "prompt_or_mermaid": "..."}],
    "html_skeleton": "<full HTML with placeholders for units and illustrations>",
    "css_inline": "<inline CSS>",
    "js_inline": "<scroll-spy, progress bar, popover script>"
  }
  ```
- **escalation_rule.** If book is poetry, screenplay, or a heavily formula-driven textbook (math, music notation), pause and ask Orchestrator to surface — the standard chrome may misfit.
- **model_choice.** **Opus.** Reason: design choices are taste calls; Sonnet ships defensible defaults but misses the per-book judgment that distinguishes a memorable artifact from a generic one.

### 2.4 The Proofreader / Fact-Checker — "adversarial NYT standards-desk auditor" (substrate: `AI`)

- **identity_prompt.**
  > *"You are an adversarial fact-checker on the New York Times standards desk. Your single job is to find hallucination. You read every unit of output against ONLY the source paragraphs cited in its `source_ids`. You flag every name, number, date, quoted phrase, named entity, causal claim, or attribution that is NOT supported by the cited spans. You do not care if the output reads well. You do not care if the author's voice survives. You care whether each claim resolves to its citation. You enumerate violations as a structured list; you do not rewrite. You are the gate that prevents the build from shipping unsourced content."*
- **inputs.** `{units[], corpus, source_id_index}`
- **judgment_criteria.** Zero unsupported claims. The Proofreader passes only when the violation list is empty. Cannot be the same agent that produced the units (adversarial separation per playbook pattern #6).
- **outputs.**
  ```json
  {
    "violations": [
      {"unit_id": "u_0042", "span": "the 1953 study by Kahneman", "issue": "not_in_source", "evidence": "no mention of Kahneman in cited paragraphs ch3§1¶2-3"}
    ],
    "anchor_verification": [{"unit_id": "u_0007", "fuzzy_match_score": 0.97, "status": "pass"}],
    "bridge_ratio": 0.083,
    "chapter_coverage": [{"ch": 1, "pct": 0.85}, …],
    "gate_status": "pass | fail"
  }
  ```
- **escalation_rule.** If the same unit fails proofread three times after Editor rework, raise to Orchestrator as `editor_unresolvable` — do not paper over.
- **model_choice.** **Sonnet.** Reason: high-throughput audit over many units; deterministic-judgment task with explicit rubric; cheaper than Opus, and Sonnet's adversarial reading is empirically strong on entailment-style checks (cf. SummaC / AlignScore patterns).

### 2.5 The Reader — "Ram-as-user simulator" (substrate: `AI`)

- **identity_prompt.**
  > *"You are simulating Ram, a senior AI builder who reads condensed books to expand his working knowledge faster than he could by reading originals. You read the HTML artifact end-to-end as if it were your only exposure to the book. You score five dimensions on a 1–5 scale: (1) visual reading pleasure — would you keep scrolling? (2) navigation utility — did you find your way without friction? (3) comprehension equivalence — could you answer ten questions about the book? (4) illustration relevance — did the visuals help or distract? (5) THE TERMINAL QUESTION — would this artifact measurably increase the number of books you finish per week, versus reading the original? You write a one-paragraph verdict explaining each score. You are not impressed by polish; you grade against the bar that you will read MORE BOOKS because of this artifact."*
- **inputs.** `{rendered_html, comprehension_test_questions, book_metadata}`
- **judgment_criteria.** Dimensions 1–4 each ≥ 3; dimension 5 (terminal) ≥ 4. Lower on any → fail. Cannot be the same agent as the Editor or the Designer (adversarial separation).
- **outputs.**
  ```json
  {
    "scores": {"visual_pleasure": 5, "navigation": 4, "comprehension": 4, "illustration": 3, "books_finished_rate": 4},
    "verdict": "<paragraph per dimension>",
    "lowest_dimension": "illustration",
    "gate_status": "pass | fail",
    "would_skip_original": true
  }
  ```
- **escalation_rule.** After 3 iterations still failing → surface to Ram with the trace and ask: ship-as-is / override / abandon.
- **model_choice.** **Opus.** Reason: the terminal-gate judgment is the most consequential call in the build; the model that grades must be at least as capable as the models that produced.

### 2.6 The Orchestrator (derived — substrate: `deterministic`)

Justification: `playbook` pattern #4 — *workflows-first*. The persona-handoff graph is a small fixed DAG with quality gates; LLM autonomy lives *inside* persona nodes, not in the routing.

- **identity_prompt.** N/A — Python/PowerShell tool or Claude Code agent harness.
- **inputs.** `{source_path, book_kind, illustration_channel_pref, style_anchor_pref}`
- **judgment_criteria.** Enforces handoff envelopes; runs personas in order; routes failures to the lowest-scoring persona's owner for one rework pass; caps iteration at 3; emits a per-book trace.
- **outputs.** Final HTML file at `CLAUDE OUTPUTS\book-to-html\<Title>_Reader_v1.html`, sidecar `coverage.json`, sidecar `trace.json`, sidecar `reader_verdict.json`.
- **escalation_rule.** Iteration cap exceeded → surface to Ram with full trace + Reader verdict. Persona escalation (Editor flag, Designer flag, Proofreader unresolvable) → surface immediately.
- **model_choice.** None.

---

## 3. Orchestration Pipeline

### 3.1 Flow diagram

```
       ┌────────────┐
Ram ──▶│  Intake Q  │ (3 questions: book_kind, illustration_channel, style_anchor)
       └─────┬──────┘
             │
             ▼
       ┌────────────┐    corpus + book_metadata
       │  Ingestor  │ ─────────────────────────────────┐
       │ (det.)     │                                  │
       └─────┬──────┘                                  │
             │                                         │
             ▼                                         │
       ┌────────────┐    units[] + coverage_intent     │
       │   Editor   │ ─────────────┐                   │
       │  (Opus)    │              │                   │
       └─────┬──────┘              │                   │
             │                     │                   │
             ▼                     │                   │
       ┌────────────┐              ▼                   │
       │ Proofreader│ ◀── checks units against corpus ─┤
       │  (Sonnet)  │                                  │
       └─────┬──────┘                                  │
       fail  │ pass                                    │
        ╲    ▼                                         │
         ╲ ┌────────────┐    html_skeleton+css+js      │
          ╲│  Designer  │ ──────────┐                  │
           │  (Opus)    │           │                  │
           └─────┬──────┘           │                  │
                 │                  │                  │
                 ▼                  ▼                  │
           ┌─────────────┐     deterministic HTML      │
           │  Assembler  │ ◀── merge units + skeleton ─┤
           │  (det.)     │                             │
           └─────┬───────┘                             │
                 │                                     │
                 ▼                                     │
           ┌────────────┐    rendered_html             │
           │   Reader   │                              │
           │  (Opus)    │                              │
           └─────┬──────┘                              │
           fail  │ pass ≥4/5 on terminal               │
            ╲   ▼                                      │
             ╲ Deliver to CLAUDE OUTPUTS               │
              ╲    ─────────────────────────────────── │
               ╲ rework lowest dim → route to owner ───┘ (cap 3)
```

### 3.2 Worked example handoff envelope — Editor → Designer

```json
{
  "envelope_version": "book-to-html-handoff/1.0",
  "from_persona": "editor",
  "to_persona": "visual_designer",
  "build_id": "20260527-001-thinking-fast-and-slow",
  "book_metadata": {
    "title": "Thinking, Fast and Slow",
    "author": "Daniel Kahneman",
    "book_kind": "self_help",
    "total_words": 159000,
    "chapters": [{"no": 1, "title": "The Characters of the Story", "words": 4200}, "…"]
  },
  "units": [
    {
      "unit_id": "u_0001",
      "kind": "anchor",
      "html": "<blockquote class=\"anchor\" data-source-id=\"ch1§1¶3\">…</blockquote>",
      "source_ids": ["ch1§1¶3"],
      "verbatim_quote": "I describe mental life by the metaphor of two agents, called System 1 and System 2…",
      "retention_signal": "framework"
    },
    "…"
  ],
  "coverage_intent": {
    "source_coverage_pct": 0.34,
    "dropped_sections": [{"source_id_range": "ch4§3¶1-12", "reason": "third illustrative example of priming effect"}]
  },
  "editor_design_hints": {
    "structural_recommendation": "linear",
    "concept_chapters": [1, 2, 5, 8, 11, 17, 19, 22, 26, 29, 32, 35]
  }
}
```

The Designer reads this envelope and produces the HTML skeleton + illustration plan. The envelope is the contract; either persona refusing to honor the contract triggers an Orchestrator escalation, not a silent paper-over.

---

## 4. Iteration & Terminal Gate

```text
function build(source, prefs):
    corpus, meta = Ingestor.run(source)                              # det.
    intake = ask_ram(book_kind, illustration_channel, style_anchor)  # 3 q's only

    iter = 0
    rework_target = "editor"  # first pass starts at the Editor

    while iter < 3:
        if rework_target in {"editor", null}:
            units, coverage = Editor.run(corpus, meta, intake)        # Opus
            proof = Proofreader.run(units, corpus)                    # Sonnet
            while proof.gate_status == "fail" and proof.attempts < 3:
                units = Editor.rework(units, proof.violations)
                proof = Proofreader.run(units, corpus)
            if proof.gate_status == "fail":
                escalate_to_ram("editor_unresolvable", proof.violations)
                return

        if rework_target in {"designer", "editor", null}:
            design = Designer.run(units, meta, intake)                # Opus

        html = Assembler.merge(units, design)                         # det.
        verdict = Reader.run(html, meta)                              # Opus

        scorecard = score_against_benchmark(proof, verdict)
        if verdict.scores.books_finished_rate >= 4 and verdict.gate_status == "pass":
            deliver(html, coverage, trace, verdict)
            return

        rework_target = persona_owning(verdict.lowest_dimension)
        # comprehension → Editor; visual_pleasure/navigation/illustration → Designer
        iter += 1

    escalate_to_ram_with_trace(verdict, proof, html, ask=["ship_as_is", "override", "abandon"])
```

**Rework-routing table** (the orchestrator uses this to pick the owner of the failing dimension):

| Lowest dimension | Owner |
|---|---|
| `comprehension` | Editor |
| `visual_pleasure` | Designer |
| `navigation` | Designer |
| `illustration` | Designer |
| `books_finished_rate` (terminal, no specific sub-dim) | Designer first; if still failing on iter 2, Editor |

---

## 5. Mapping from Prior Plan

Every substantive item from [`BookToHTML_EnhancementPlan_v1.md`](BookToHTML_EnhancementPlan_v1.md) accounted for:

| v1 item | Persona owner (v2) | Disposition |
|---|---|---|
| Retention Score rubric (§2.1) | Editor — internal `judgment_criteria` | **Re-shaped.** Becomes the Editor's internal scoring framework, not a global rubric injected at every stage. Editor model is trusted with the rubric; it does not need to be a runtime artifact. |
| Anti-Hallucination Grounding Protocol (§2.2) | Proofreader | **Preserved as-is.** Every sub-step (fuzzy match, NLI audit, bridge-ratio gate, chapter-coverage quota) becomes a Proofreader output field. |
| AI Illustration Pipeline / Channel A + B (§2.3) | Designer | **Preserved.** Channel routing becomes Designer's `illustration_plan` output. Style anchor and seed frozen at intake. |
| Comprehension-Equivalence Test (§2.4) | Reader — `comprehension` dimension | **Re-shaped.** The 10-question self-test is now the Reader's `comprehension` score; the Reader is the terminal gate, not a side check. |
| 40-point benchmark (§3) | Replaced by Reader's 5-dimension verdict | **Re-shaped.** v1's 8-dimension/40-point rubric is collapsed into the Reader's five dimensions with the terminal "books_finished_rate" gate. Fewer numbers, sharper terminal call. The lost detail (e.g., chapter-coverage %, bridge-ratio) moves to the Proofreader's structured output. |
| Reading-UX template — typography, TOC, scroll-spy, popovers, sidenotes (§5 Edit 6) | Designer | **Preserved as Designer reference file.** Becomes `references/reading-ux-template.html` that the Designer copies and adapts per book. |
| Structured-tuple generation (§5 Edit 3) | Editor — `outputs` schema | **Preserved.** The unit JSON in §2.2 above. |
| Quantitative QA thresholds (§5 Edit 5) | Proofreader — `judgment_criteria` + `outputs` | **Preserved.** Fuzzy-match ≥95, bridge-ratio ≤0.10, chapter-coverage 70–130%, etc. |
| Daily-use enhancements: queue manifest, streak telemetry, mobile preview, re-ingest mode (§7) | Orchestrator scope (deterministic) | **Preserved as Orchestrator features.** Not persona-ified — these are operational tooling around the persona graph. |
| Cross-book concept linking (§7 item 2) | New — flagged as v3 (see §10 open question) | **Deferred.** Crosses book boundaries; needs design before assigning a persona. |
| Five open questions from v1 §8 | Re-asked in §10 below where still relevant | Some now answered by AI-first lens; others carried forward. |

---

## 6. Second Skill Review (AI-First Lens)

Quoting `C:\Claude Cowork\skills\book-to-html\SKILL.md`:

> **L10–14: Core principle: GROUNDING IS NON-NEGOTIABLE … No section ships until the QA gate (Stage 6) returns zero unsourced spans.**

Persona owner: **Proofreader.** Preserve the philosophy; replace "Stage 6" framing with "the Proofreader's gate." Grounding becomes a *persona's accountability*, not a stage in a pipeline.

> **L25: 1 Ingest → 2 Interrogate → 3 Outline (checkpoint) → 4 Generate → 5 Visuals → 6 QA gate → 7 Deliver**

**Must be replaced.** This is procedural-pipeline language. Replace with: "The orchestrator invokes the persona cast (Ingestor → Editor → Proofreader → Designer → Assembler → Reader), with rework routing on terminal-gate failure." See §3 above.

> **L31–39: Stage 2 — Interrogate. Ask these FOUR questions … Tone / Length / Words-per-page cap / Visual density.**

**Must be replaced.** AI-first lens says: the AI decides length (Editor + Reader-gate); the AI decides density (Designer). Ram answers three intake questions only: `book_kind`, `illustration_channel_pref`, `style_anchor_pref`. Everything else is delegated.

> **L48: Stage 5 — Visuals. Build visuals per density setting using SVG/CSS only (no raster, no external/AI images).**

**Must be replaced.** Designer persona decides per book (Channel A vs. B); the SVG/CSS-only ban contradicts the user's stated desire for AI illustrations.

> **L50–56: Stage 6 — QA gate. Grounding pass / Adversarial review (sub-agent) / Fix loop / Coverage report.**

Persona owner: **Proofreader.** Preserve the *adversarial-review-as-sub-agent* idea — it is exactly the playbook's adversarial-separation pattern. Promote the sub-agent from a stage-6 step to a first-class persona.

> **L70–84: Common Mistakes + Red Flags.**

**Preserve verbatim.** These are recital-grade Field Manual-style disciplines. Move into a new `references/red-flags.md`; cite from every persona's identity prompt.

**Bottom line:** the v1 skill nailed the grounding philosophy but encoded it procedurally. The AI-first lens preserves the philosophy, names the personas that own it, and lets each persona exercise judgment within a typed handoff contract.

---

## 7. Recommended Skill File Restructure

Propose this new SKILL.md skeleton (≤200 lines per Ram's global checklist):

```markdown
---
name: book-to-html
description: <updated trigger list — same as v1 — adds "AI-first persona orchestration" framing>
---

# book-to-html

## Overview
ONE-paragraph description of the artifact + the AI-first persona orchestration pattern.

## Persona Registry
A table of the six personas (Ingestor, Editor, Designer, Proofreader, Reader, Orchestrator)
with substrate tag and one-line responsibility. Points to per-persona reference files.

## Intake (3 questions only)
1. book_kind: fiction | self_help | narrative_nonfic | mixed
2. illustration_channel_pref: A_only | A_and_B | none
3. style_anchor_pref: preset_list_or_custom (only asked if Channel B)

## Orchestration
ASCII flow diagram + the rework-routing table. Reader's terminal-gate threshold stated explicitly.

## Iron Laws
1. Adversarial separation — no persona grades its own output.
2. Every claim cites a source_id (Field Manual #4).
3. Bridge ratio ≤ 0.10.
4. Reader-gate ≥ 4/5 on books_finished_rate or surface to Ram.
5. Iteration cap = 3.
6. The Designer's Design Note is shown at the top of every HTML output.

## Quick Reference
| Need | Read |
|------|------|
| Ingestion (epub/pdf/txt/docx) | references/ingest.md |
| Editor identity, retention rubric, escalation rules | references/persona-editor.md |
| Designer identity, channel routing, UX template | references/persona-designer.md |
| Proofreader identity, audit rubric, NLI patterns | references/persona-proofreader.md |
| Reader identity, terminal-gate scoring | references/persona-reader.md |
| Channel B prompt template + style-anchor presets | references/illustration-channels.md |
| HTML reading-UX template (Stripe/Distill/Gwern stack) | references/reading-ux-template.html |
| Red flags + common mistakes (preserved from v1) | references/red-flags.md |
| Trace schema (per-build trace.json shape) | references/trace-schema.md |

## Common Mistakes / Red Flags
Inline summary of references/red-flags.md.
```

**New sibling files to create** (none deleted):

- `references/persona-editor.md`
- `references/persona-designer.md`
- `references/persona-proofreader.md`
- `references/persona-reader.md`
- `references/illustration-channels.md` (carried over from v1 plan)
- `references/reading-ux-template.html` (carried over from v1 plan)
- `references/red-flags.md` (extracted from current SKILL.md)
- `references/trace-schema.md`
- `references/handoff-envelopes.md` (the typed JSON contracts between adjacent personas)

Keep: `references/ingest.md`, `references/qa-grounding.md` (re-attribute to Proofreader), `references/design-system.md` (fold into reading-ux-template.html or keep as Designer reference).

---

## 8. What's Different vs. v1 Plan

| Dimension | v1 plan | v2 AI-first plan |
|---|---|---|
| **Architectural shape** | Procedural 7-stage pipeline. | Six-persona cast on a small fixed DAG; LLM judgment lives inside personas, control flow is deterministic. |
| **Grounding ownership** | "Stage 6 QA gate" with adversarial sub-agent. | **Proofreader persona** — first-class adversarial role with its own identity prompt and structured violations output. |
| **Editorial framework** | Retention Rubric as a global lookup table. | Editor's internal `judgment_criteria`; the rubric is the Editor's professional formation, not a runtime artifact passed through prompts. |
| **Length decision** | Comprehension-equivalence test as Stage 4.5. | Editor proposes via Retention Mass × 8–12; **Reader** is the terminal gate via "books_finished_rate ≥ 4" — the comprehension test is one of the Reader's five dimensions, not a separate sub-process. |
| **Illustration** | Two-channel pipeline as Stage 5. | Designer persona owns channel routing; Designer's `illustration_plan` is a structured output, not a stage artifact. |
| **Reading-UX** | Stage 7 reading-UX contract. | Designer persona's `judgment_criteria`; the template becomes a reference file the Designer copies from. |
| **Quality benchmark** | 40-point rubric across 8 dimensions. | **Reader's 5-dimension verdict** with `books_finished_rate` as terminal gate. Detail moves to Proofreader's structured output. Fewer numbers, sharper terminal call. |
| **Adversarial separation** | Implicit (Stage 6 sub-agent). | **Explicit, mandatory.** Codified as Iron Law #1. Proofreader ≠ Editor; Reader ≠ Designer/Editor. |
| **Model routing** | Not specified. | Explicit: Editor=Opus, Designer=Opus, Proofreader=Sonnet, Reader=Opus, Ingestor/Orchestrator/Assembler=deterministic code. |
| **Handoff contracts** | Free-form between stages. | Typed JSON envelopes (`book-to-html-handoff/1.0`) between every adjacent persona. |
| **Observability** | Coverage report sidecar. | Per-build `trace.json` with one span per persona invocation + the coverage and verdict sidecars (Field Manual #17 alignment). |
| **Iteration loop** | Generate → benchmark → regenerate lowest dim. | Same shape; **rework target is a persona, not a sub-stage.** Editor reworks for comprehension; Designer reworks for visual/navigation/illustration. |

**Preserved (verbatim or near-verbatim) from v1:** anti-hallucination protocol mechanics, two-channel illustration pipeline, reading-UX template, daily-use queue mode, red-flag list.

**Dropped from v1:** the 40-point rubric (collapsed into Reader's 5 dimensions); the "Stage 4.5 comprehension-equivalence test" as a discrete sub-process (now lives inside Reader).

---

## 9. Alignment Check Against the Playbook

| Playbook pattern (from §1) | Architecture alignment |
|---|---|
| 1. Removal Test as falsifiability | ✅ Removing the LLM collapses the Editor, Designer, Proofreader, Reader. Skill is genuinely AI-First. |
| 2. Control-Plane Ownership | ✅ Each LLM persona owns its decision (what to keep, how to design, what to flag, whether to ship); the Orchestrator is a deterministic DAG, not a model-driven loop — consistent with Field Manual #5/#6 (workflows-first, small focused agents). |
| 3. Substrate-typed Persona Map | ✅ Six personas, each tagged. Ingestor / Assembler / Orchestrator marked `deterministic`; Editor / Designer / Proofreader / Reader marked `AI`. No persona miscategorized. |
| 4. Workflows-first + compound-error math | ✅ Five LLM hops (Editor → [Proofreader-loop] → Designer → Reader, with rework). With Opus/Sonnet calibration, expected per-step accuracy is high enough that 5 steps × ~92% ≈ 66% first-pass, with the Reader-gate-and-rework recovering the remainder. Compound-error reality respected; iteration cap prevents runaway. |
| 5. Cite everything you claim | ✅ Editor's output schema forces `source_ids` + `verbatim_quote` per unit. Proofreader's gate is precisely citation-validity. |
| 6. Adversarial review cycles | ✅ Iron Law #1: no self-grading. Proofreader ≠ Editor. Reader ≠ Designer or Editor. Three distinct model instances at minimum. |
| 7. Reversibility-Gated Human Handoff | ✅ Ram is summoned only after 3 failed iterations OR on Editor / Designer / Proofreader explicit escalation. Routine generation never blocks on Ram. |
| 8. Evals as load-bearing | ✅ Proofreader IS the eval, run every build. Reader IS the user-facing eval, run every build. Citation-validity is enforced by Proofreader as a mandatory check class. |
| 9. Trace-first observability with redaction | ✅ Per-build `trace.json` records every persona invocation with input/output hashes, scores, escalations. Book contents are user-data tier — redaction policy carries from `qa-grounding.md`. |
| 10. Multi-tier products | ✅ The artifact is AI-First overall (Editor/Designer/Proofreader/Reader are LLM-native value props); the Ingestor and Assembler tiers are deterministic. Both declared in the Persona Registry. |

**Divergences:** none material. One borderline: the playbook prescribes 11 mandatory ADRs for any AI-First project (Companion §3.2). For a single skill (not a multi-quarter product), the persona-registry + iron-laws function as a compressed ADR analog. ⚠️ Flag for Ram: if this skill is treated as a *product* rather than a *workflow*, formalize a Persona Boundary ADR.

---

## 10. Open Questions for Ram

1. **Cross-book concept linking** (the "Wikipedia-style across my personal library" idea from v1 §7.2). Treat as v3? Or include in v2 by giving the Designer an optional `cross_book_concepts.json` input that lets it emit links into prior-finished books' HTMLs? My recommendation: **v3.** It needs its own persona (a Librarian) and a separate design pass.

2. **Pollinations.ai dependency.** Comfortable with one external (free, keyless) image API? Or strict zero-network → Channel A only? My recommendation: **enable Channel B** with the documented fallback to anchor-blockquote on failure.

3. **Model-routing budget.** The proposed cast spends Opus calls on Editor + Designer + Reader. For a book-per-day cadence, this is roughly $3–8 per book in API cost (rough order-of-magnitude). Acceptable, or should Designer drop to Sonnet to halve the cost? My recommendation: **keep Designer on Opus** — taste calls are where Opus pays back.

4. **Reader-gate threshold.** `books_finished_rate ≥ 4/5` is the proposed bar. Higher (≥5/5 strict) costs more iterations; lower (≥3) ships faster but weakens the daily-reading-velocity claim. My recommendation: **≥4** as proposed.

5. **Persona Boundary ADR.** Should we formalize the persona-registry-and-iron-laws as a proper ADR (Companion §3.2 #11 pattern) inside the skill folder? My recommendation: **yes** — single page, named `references/ADR-01-persona-boundaries.md`. It pays for itself the first time a future skill-tweak proposes collapsing two personas.

---

**Reader-gate threshold: ≥4/5 on "would increase books-finished rate". Iteration cap: 3.**
