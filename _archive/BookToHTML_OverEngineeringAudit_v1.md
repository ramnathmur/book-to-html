# book-to-html Skill — Over-Engineering Audit v1

**Verdict: TIER-IT. The architecture earned its keep on this run — the Reader caught a real ship-blocking bug and the Proofreader caught 5 real hallucinations — but 3 of 12 Editor sub-agents produced unusable output and the deterministic substrate did more saving than the named-LLM personas did, which means the default mode is over-engineered for daily reading even though the rigorous mode is not.**

---

## 1. The bill from this build

From `Will-It-Make-The-Boat-Go-Faster_trace.json` (13 spans, 2 iterations) cross-referenced against the actual conversation receipts:

| # | Persona / substrate | Model | Wall-time | Caught something real? | Note |
|---|---|---|---|---|---|
| 1 | Ingestor | det. | ~10s | yes | 1,494 paragraphs, 12 chapters, clean parse |
| 2 | Editor × 12 (fan-out) | opus | ~3 min parallel | partial | 9/12 usable; 3 returned empty shells (ch4, ch8, ch12); 6 had partial empties |
| 3 | Anchor verifier | det. | ~3s | **yes** | 209 source_ids backfilled from `data-source-id`; 24 smart-quote false-positives caught and fixed |
| 4 | Proofreader bridge audit #1 | sonnet | ~95s | **yes** | 5 real hallucinations (Brock vs John, Lottery-grants invention, list-padding, etc.) |
| 5 | Editor rework | opus | ~68s | yes | 5 violations fixed |
| 6 | Proofreader bridge audit #2 | sonnet | ~33s | no | 0 violations on remaining 43 bridges |
| 7 | Deterministic anchor backfill | det. | ~5s | **yes** | 65 empty anchors recovered from source; 59 empty bridges dropped |
| 8 | Editor ch12 redo | opus | ~287s | **yes** | recovered the Sydney 2000 climax chapter (44 units, 2789 words) |
| 9 | Designer | opus | ~91s | weak | 12 Mermaid diagrams (good), 12 Pollinations prompts (good), navigation pattern-substitution |
| 10 | Comprehension Q generator | sonnet | ~280s | n/a | 10 questions; required for Reader |
| 11 | Assembler | det. | <1s | **yes** | caught TOC regex bug + amplified Editor gaps (debugging then fix) |
| 12 | Reader iter 1 | opus | ~135s | **YES — biggest catch** | 4/3/4/4/**3** FAIL → identified ch4/ch8 empty bodies |
| 13 | Reader iter 2 | opus | ~201s | **yes** | 4/5/5/4/**4** PASS after fixes |

**Totals:** ~16 sub-agent invocations across two iterations. Wall-time ~18 min of actual sub-agent work plus orchestration overhead. API cost order-of-magnitude **$4–5**, dominated by 6 Opus calls (Editor fan-out at parallel is the largest line item, then Reader iter 1 + iter 2, then Designer + ch12 redo).

**The single biggest receipt to internalize:** the deterministic substrate did more saving than any LLM persona except the Reader. Anchor verifier + anchor backfill + assembler bug-catch together recovered the build from at least 3 different Editor-substrate failures that would otherwise have shipped broken.

---

## 2. The three tests

**Ousterhout — deep vs. shallow modules.** Verdict: **mixed**. The Editor (Retention Rubric + structured units + escalation rules + adversarial-separation contract) and the Reader (5-dimension scoring + terminal gate + comprehension-test protocol) are *deep* modules — small interface, large internal value. The Designer is *shallow* — wide interface (navigation shape + illustration plan + chrome + Design Note + characters.json + style anchor + seed) with most of the work being pattern-substitution against a recipe library. The Orchestrator is borderline-shallow: it enforces envelopes that I (the orchestrator-in-this-session) mostly worked around informally anyway.

**Larson — is the complexity earning its keep?** Verdict: **partly**. The Proofreader earned its keep with 5 real catches and the Reader earned its keep with one real catch (ch4/ch8 prose holes). The Designer earned its keep on the Mermaid diagrams (which the Reader explicitly cited as the strongest design choice) but the navigation/chrome work was 80% pattern-substitution from the pre-built template. The handoff-envelope formality and the trace-schema discipline earned their keep zero times in this run — they are infrastructure that *will* earn its keep across many builds, but on this one build the receipts are blank.

**Playbook Removal Test (Blueprint §3.1).** Verdict: **PASSES, but only barely**. Strip the LLM personas: the Ingestor and Assembler would produce a `<blockquote>`-only HTML of the whole book — fidelity 100%, condensation 0%, reading pleasure low. So the LLM personas are genuinely load-bearing for the *condensation*. But strip the Designer and the Proofreader specifically: you get a longer, less-illustrated, slightly more hallucination-prone reader that still works. Two of the four LLM personas are removable without the artifact collapsing. The Editor and the Reader are the load-bearing pair.

---

## 3. Per-persona audit

### 3.1 Ingestor (deterministic)
- Catch-rate: 1/1. Parsed cleanly.
- Cheaper substrate possible? Already substrate.
- Marginal cost: ~10s, $0.
- **Verdict: keep.** No change.

### 3.2 Editor (Opus × 12 parallel)
- Catch-rate: 9/12 chapters fully usable; 3/12 returned empty shells; 6/12 partial empties. That is **a 25–50% per-chapter failure rate of the most expensive persona** depending on how you count. The Editor failed silently — reported "ch12 done: 23 units" but the units had empty bodies.
- Cheaper substrate possible? **Partly yes.** The anchor-emission half of the Editor's job (look up source paragraph by source_id, wrap in `<blockquote>`) is mechanical — the deterministic backfill recovered 65 anchors with zero LLM tokens. Only the *retention scoring* and the *bridge authoring* genuinely require an LLM. Splitting Editor into (a) deterministic "wrap each kept paragraph as anchor" and (b) LLM "score paragraphs + write bridges only" would cut its cost ~60% and eliminate the empty-shell failure mode.
- Marginal cost: dominant LLM expense in the build (~$2 across 12 calls).
- **Verdict: keep-but-split.** Refactor into a thin LLM scorer + a deterministic anchor-emitter. The fan-out granularity (per-chapter) was the right call; the Opus output-budget failure was the prompt's fault for asking for too much structured output in one shot.

### 3.3 Proofreader (Sonnet × 2)
- Catch-rate: **5/5 real catches** on the first audit. The Brock-vs-John factual error alone is exactly the failure mode that would make a "condensed reader" worse than useless — it would propagate as a confidently-wrong claim. Worth the $0.30 by itself.
- Cheaper substrate possible? **Anchor verification yes (already deterministic).** Bridge entailment audit no — that genuinely requires an LLM. Sonnet is already the cheapest defensible model for this.
- Marginal cost: ~$0.40, ~2 minutes.
- **Verdict: keep, exactly as is.** This is the persona that most clearly earned its keep per dollar.

### 3.4 Designer (Opus)
- Catch-rate: 0 errors caught, 12 useful Mermaid diagrams produced, 12 Pollinations prompts produced, 1 Design Note. The Reader explicitly called the Mermaid framing "the strongest design decision in the artifact."
- Cheaper substrate possible? **Yes — Sonnet or a hybrid.** The navigation choice (linear) was a single-line decision the rubric in `persona-designer.md` makes deterministically for a memoir. The chrome contract was a template substitution. The two genuinely Opus-grade outputs were the Mermaid diagrams (relationship-externalization) and the Design Note paragraph. Both would work fine on Sonnet — the Mermaid quality depends mostly on the chapter-theme metadata the Editor already produces, not on Designer-tier reasoning.
- Marginal cost: ~$0.80, ~90s.
- **Verdict: downgrade-model + collapse.** Move Designer to Sonnet, keep its outputs (Mermaid + Pollinations prompts + Design Note), drop the html_skeleton / css_inline / js_inline outputs (they're template substitution — the Assembler already does this).

### 3.5 Assembler (deterministic)
- Catch-rate: 1 real catch (TOC regex bug) + 1 real signal (made the Editor empty-shells visible). Without the assembler doing the actual HTML merge, the Editor's failure would have been invisible.
- Cheaper substrate possible? Already substrate.
- Marginal cost: <1s, $0.
- **Verdict: keep, but harden.** The TOC placeholder bug and the empty-section diagnosis both surfaced through it; this is exactly where deterministic substrate pays off. Add an "empty unit detection + halt" check before assembly so the iter-1 cycle wouldn't have wasted a Reader call on ch4/ch8.

### 3.6 Reader (Opus)
- Catch-rate: 1 huge catch — the ch4/ch8 prose-hole bug, which the Editor reported as successful, the Proofreader did not flag (it audits grounding, not coverage), and the Assembler couldn't have noticed because it has no semantic model. **Without the Reader gate, the broken HTML would have shipped silently with a passing Proofreader verdict.**
- Cheaper substrate possible? **No defensible cheaper alternative.** A deterministic "% of chapters with content" check could have flagged ch4/ch8 specifically, BUT it cannot judge whether a present body is comprehensible to a human reader. The Reader's terminal `books_finished_rate` is the only mechanism that asks the right question.
- Marginal cost: ~$1.20 across iter 1 + iter 2, ~5 min.
- **Verdict: keep, exactly as is.** Iron Law #4 stays. The "no-self-grading" discipline must hold.

### 3.7 Orchestrator (deterministic / Claude-in-this-session)
- Catch-rate: depends on counting. The orchestration script (envelopes, iteration cap, rework routing) earned its keep on iter 1 → iter 2 routing. The typed JSON envelope formality did NOT earn its keep on this run — I (as orchestrator) worked around it informally and the build still completed.
- Cheaper substrate possible? Already substrate.
- Marginal cost: $0 LLM-wise; meaningful in code surface (handoff-envelopes.md = 165 lines, trace-schema.md = 67 lines).
- **Verdict: keep + simplify the docs.** Move handoff-envelopes.md and trace-schema.md to a `_rigorous_mode/` subfolder. For daily-use builds the orchestrator is a simple `Ingestor → Editor → Proofreader → Designer → Assembler → Reader` loop with a 3-iter cap; that doesn't need 232 lines of contract documentation.

---

## 4. What the build actually demonstrated

| Failure event | Caught by | Could it have been caught earlier/cheaper? |
|---|---|---|
| 3 Editor sub-agents returned empty shells (ch4, ch8, ch12) | Assembler + Reader (iter 1) | **Yes** — a 5-line deterministic "every unit has html?" check before assembly would have caught it in <1s |
| 6 Editor sub-agents had partial empties | Anchor backfill (deterministic) | **Yes** — same as above |
| 209 anchors missing source_ids field (Editor wrote them to data-source-id instead) | Anchor verifier (deterministic) | Already caught by substrate |
| 24 smart-quote anchor mismatches | Anchor verifier + normalization fix | Already caught by substrate |
| 5 real bridge hallucinations (Brock, Lottery grants, etc.) | **Proofreader (Sonnet)** | **No** — this is the persona's earned-keep moment |
| TOC placeholder regex bug | Reader (iter 1) + me re-debugging | **Yes** — basic build-time HTML linting |
| 3 chapters with HIGH coverage, 2 with LOW (chapter-share gate) | Proofreader output (deterministic computation) | Already substrate |
| ch4/ch8 unreadable prose holes after iter-1 assembly | **Reader (iter 1) — only catch** | **No** — no cheaper mechanism asks "would a reader skip the original?" |

**Reading the table:** 5 of 8 failures were caught (or could have been caught) by deterministic substrate, 1 by the Proofreader, 1 by the Reader, 1 was a regex bug in my own code. The named LLM personas earned their keep in **2 of 8 failure-catch events**. The deterministic substrate earned its keep in **6 of 8** — which is exactly the inversion of the architecture's apparent emphasis.

This is the strongest single argument for tier-it-rather-than-defend-as-is.

---

## 5. Tiered proposal

| | **Lite Mode** | **Standard Mode (new default)** | **Rigorous Mode (current skill)** |
|---|---|---|---|
| Personas run | Ingestor → Editor → Reader | Ingestor → Editor → Proofreader → Designer (Sonnet) → Assembler → Reader | All current 6 personas |
| Deterministic substrate | anchor backfill, empty-unit guard, basic chrome | + anchor verifier, + chapter coverage gate | + full handoff envelope validation, + per-span trace |
| Illustrations | none, or Mermaid only on framework-tagged sections | Mermaid + Pollinations openers | same as Standard |
| Bridge writing | optional; if Editor leaves a chapter with bridge_ratio=0, ship as anchors-only | full bridges + Proofreader entailment audit | same as Standard |
| Iteration cap | 1 | 2 | 3 |
| Cost (rough) | **$0.50–1** | **$2–3** | **$4–6** |
| Wall time | **~3 min** | **~8 min** | **~15–20 min** |
| When to use | books you'd otherwise skip; daily mass-reading; you trust the source | most books in your queue; new authors; books you'd cite | books you'll quote from in writing; regulatory / contested-claims content; rare deep reads |
| Removable from current skill? | shipped via `--lite` flag | this becomes the default `/book-to-html` | shipped via `--rigorous` flag |

**Standard Mode is what `/book-to-html` should invoke by default.** Lite and Rigorous are flags.

The key Standard-vs-Rigorous difference: in Standard, the Designer runs on Sonnet, the orchestrator skips the typed envelope validation step, and the trace is a one-line summary instead of a per-span OTel-shape. Everything that earned its keep on this run stays in Standard. Everything that didn't moves to Rigorous.

---

## 6. Concrete SKILL.md edits

| File | Action | Rationale |
|---|---|---|
| `SKILL.md` — Iron Law #9 ("Trace every build" with the full OTel-shaped per-span schema) | **Move** to Rigorous mode only. Standard mode emits a single-line build trace (build_id + outcome + 5-dim scores). | The full trace schema took 67 lines to specify and got referenced once during this build (when I emitted it manually at the end). It is for fleet-scale operations, not single-machine daily use. |
| `SKILL.md` — Iron Law #6 ("Design Note at top of every HTML output") | **Keep but downgrade ownership.** Move from "Designer must produce" to "Assembler templates from chapter metadata, Designer optional in Standard mode." | The Design Note paragraph is good UX but the Reader did not flag its absence as a failure; it's a quality-of-life addition, not a gate. |
| `references/handoff-envelopes.md` (165 lines) | **Move to `references/_rigorous_mode/handoff-envelopes.md`** | Six typed JSON envelope shapes for a six-persona system. The actual run worked around these informally. Useful for multi-machine orchestration; over-specified for a single Claude session. |
| `references/trace-schema.md` (67 lines) | **Move to `references/_rigorous_mode/trace-schema.md`** | OTel-shaped per-span schema with redaction rules. Earned its keep zero times in this build. |
| `references/ADR-01-persona-boundaries.md` (51 lines) | **Keep but mark as Rigorous-mode reference.** | The ADR is real architectural value but should be cited only when collapsing or adding personas is on the table, not on every build. |
| `references/persona-designer.md` — Designer's `html_skeleton`, `css_inline`, `js_inline` outputs | **Drop from spec.** Designer produces only `design_note` + `navigation_shape` + `illustration_plan`. | Chrome is template substitution. Three of those four output fields were unused in the actual Assembler. |
| `references/persona-designer.md` — model_choice "Opus" | **Change to Sonnet for Standard mode**, keep Opus only for Rigorous. | The Mermaid diagrams and Design Note paragraph are within Sonnet's range; the Reader didn't flag illustration as the weakest dim. |
| `references/persona-editor.md` — procedure step "Emit units in source order. Every paragraph with Retention ≥ 7 becomes one `kind: "anchor"` unit" | **Refactor:** Editor returns a list of `{paragraph_source_id, retention_score, intended_kind, bridge_text_if_bridge}`. The deterministic Assembler builds the anchor HTML from source. | This is what the deterministic anchor-backfill did, successfully. Build it in instead of relying on Opus to mechanically wrap text. |
| `references/persona-reader.md` | **Keep verbatim.** | The one persona this audit will not touch. |
| `references/red-flags.md` — Iron Laws | **Add Iron Law #11: every unit's `html` field is non-empty before assembly.** | The 3-of-12 empty-shell failure mode on this build should be impossible to ship in v2.1. |

---

## 7. Honest defenses (accept-or-rebut)

**Defense A: "The Proofreader caught 5 real hallucinations — therefore adversarial separation is non-negotiable."**
**Accepted.** Iron Law #1 stays. Standard mode keeps the Proofreader; Lite mode drops it and the user accepts the tradeoff.

**Defense B: "The Reader caught the ch4/ch8 ship-blocking bug — therefore the terminal gate is non-negotiable."**
**Accepted, hard.** Reader stays in every mode including Lite. This is the gate Ram does not get to disable.

**Defense C: "Ram's own Playbook prescribes this architecture — Blueprint §4.2 substrate-typed personas, Field Manual #5 (own your control flow), Companion ADR pattern. Simplifying betrays his own doctrine."**
**Partly rebut.** The Playbook also prescribes Field Manual #6 (Small Focused Agents) and Blueprint §3.9 (Workflows-First, Agents-When-Justified) — both of which argue that 5 LLM hops × 92% per-step accuracy yields ~66% first-pass success, recoverable by gates. *This audit reflects exactly that math.* The Playbook prescribes the framework; it does not prescribe that every framework knob be turned to maximum on every build. The Playbook prescribes tiering — Standard mode IS the Playbook-aligned default; Rigorous is the same Playbook applied at maximum knob.

**Defense D: "The deterministic substrate ate so much of the work BECAUSE the personas were well-designed. Personas + substrate is the architecture."**
**Rebut.** The substrate ate work because the personas (specifically the Editor) failed in predictable ways. The deterministic anchor backfill is doing the Editor's wrapper job, not a complementary job. The audit's recommendation is to formalize that — make the Editor's contract reflect what works (score + bridges + drops), and let substrate do what substrate is good at (mechanical wrapping). That's not architectural betrayal; that's the substrate-typing rule in Blueprint §4.2 L2 applied honestly.

**Defense E: "You built the skill 4 hours ago. It worked. Don't tear it down."**
**Rebut.** This is the strongest emotional defense and the weakest evidentiary one. The receipts are receipts. A skill that works on iteration 2 after 3 substrate-recoveries is a skill whose architecture spec is out of sync with its operating reality. The honest move is to ship Standard Mode as the new default and keep Rigorous Mode available for the cases that need it — neither tear-down nor canonization.

---

## 8. The 80/20 question

Quantified against this build's receipts:

| Mode | Estimated value retained | Estimated cost | Notes |
|---|---|---|---|
| Lite | **~65%** | **~15%** | Loses Proofreader (5 hallucinations would ship) and rich illustration; gets the Reader gate and most of the prose. Good for skim-reading books you wouldn't otherwise finish. |
| Standard | **~92%** | **~50%** | Loses only Rigorous-mode bookkeeping (typed envelopes, full OTel trace, ADR-grade governance). All earned-its-keep mechanisms preserved. |
| Rigorous (current) | **100%** | **100%** | Baseline. Earned its keep on this build but not on the marginal book. |

The 80/20 answer: **Standard Mode delivers ~92% of the value at ~50% of the cost.** That is the simplification headroom. Lite Mode is a 65/15 — a useful tier for when the user explicitly does not need grounding rigor.

---

## 9. Recommended next action for Ram

**Run `/book-to-html --lite` on the next book in your queue and compare its Reader verdict against this build's Reader verdict.** One book, ~$0.80, ~3 minutes. The receipts from that comparison will tell you whether Lite is good enough for daily reading or whether you actually need Standard as the floor. Do not refactor SKILL.md or the persona files until that A/B receipt is in hand.

---

Audit complete. Decision: TIER-IT. Receipts in the trace.
