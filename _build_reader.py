"""Build the Atomic Habits HTML reader from corpus + template."""
import json, os, html as ihtml
from collections import defaultdict

CORPUS = r"C:/Claude Cowork/CLAUDE OUTPUTS/book-to-html/atomic_habits_corpus.json"
TEMPLATE = r"C:/Claude Cowork/skills/book-to-html/references/reading-ux-template.html"
OUT = r"C:/Claude Cowork/CLAUDE OUTPUTS/book-to-html/Atomic-Habits_Reader_v1.html"

with open(CORPUS, "r", encoding="utf-8") as f:
    data = json.load(f)

chapters = data["book_metadata"]["chapters"]
units = data["units"]
chapter_titles = {c["no"]: c["title"] for c in chapters}
chapter_words   = {c["no"]: c["words"] for c in chapters}

# Group units by chapter, preserve order
by_chap = defaultdict(list)
for u in units:
    by_chap[u["chapter_no"]].append(u)

# Mermaid diagrams for concept chapters
DIAGRAMS = {
    2: ("""flowchart LR
  A["Day 0 baseline (1.00)"] -->|+1% daily x 365| B["37.78x better"]
  A -->|-1% daily x 365| C["0.03x — near zero"]
  B --- D["Plateau of Latent Potential:<br/>work is stored before<br/>the breakthrough"]
  C --- D""", "ch2§2¶1", "Compounding 1% gains vs losses over a year, and the Plateau of Latent Potential where stored effort precedes visible results."),
    3: ("""flowchart TB
  O["Outcomes (what you get)"] --> P["Process (what you do)"]
  P --> I["Identity (what you believe)"]
  I -->|every action is a vote| H["Habits"]
  H -->|build evidence| I
  classDef core fill:#fff3e6,stroke:#b54300;
  class I core;""", "ch3§2¶1", "Three layers of change. Identity-based habits form a reinforcing loop: each action is a vote that thickens belief."),
    4: ("""flowchart LR
  C["Cue"] -->|1st Law: Make it Obvious| Cr["Craving"]
  Cr -->|2nd Law: Make it Attractive| R["Response"]
  R -->|3rd Law: Make it Easy| Rw["Reward"]
  Rw -->|4th Law: Make it Satisfying| C""", "ch4§3¶2", "The habit loop — cue, craving, response, reward — with each of the Four Laws of Behavior Change attached to its corresponding step."),
    6: ("""flowchart LR
  A["Vague intention:<br/>'I will exercise more'"] -.weak.-> X["Often skipped"]
  B["Implementation intention:<br/>I will [BEHAVIOR] at [TIME]<br/>in [LOCATION]"] ==strong==> Y["Executed automatically"]
  B --> S["Habit stacking:<br/>After [CURRENT HABIT],<br/>I will [NEW HABIT]"]""", "ch6§1¶1", "Implementation intentions and habit stacking — tying a new behavior to a specific time, location, or existing cue."),
    9: ("""flowchart LR
  D["Dopamine spike on<br/>ANTICIPATION (not reward)"] --> Cr["Craving"]
  Cr --> R["Response"]
  T["Temptation bundling:<br/>pair WANT with NEED"] --> Cr
  R --> Rw["Reward"]""", "ch9§1¶1", "Dopamine fires on the anticipation of reward, not its receipt; temptation bundling pairs a want with a need to hijack that anticipation."),
    13: ("""flowchart TB
  H["Desired habit"] --> E{"Friction in<br/>environment?"}
  E -->|High friction| Skip["Skipped"]
  E -->|Low friction| Do["Performed"]
  ED["Environment design:<br/>reduce steps,<br/>prime the space"] --> E
  classDef good fill:#e8f5e8,stroke:#2a7a2a;
  class Do good;""", "ch13§1¶1", "The Law of Least Effort: behavior follows the path of lowest friction; environment design lowers the activation cost of good habits."),
    14: ("""flowchart TB
  H["New habit"] --> Q{"Takes more<br/>than 2 minutes?"}
  Q -->|Yes| S["Scale DOWN to<br/>a 2-minute version"]
  Q -->|No| D["Do it"]
  S --> D
  D --> M["Master showing up<br/>before optimizing"]""", "ch14§1¶1", "The Two-Minute Rule: shrink any new habit to under two minutes, standardize before you optimize."),
    15: ("""flowchart LR
  N["Now: present self"] -->|commitment device| L["Locked-in future choice"]
  L --> F["Future self forced<br/>into good behavior"]
  N --> A["One-time automation<br/>(auto-deposit, unsubscribe,<br/>remove app)"]
  A --> F""", "ch15§1¶1", "Commitment devices and one-time automations: use present-you to lock future-you into the better path."),
    16: ("""flowchart LR
  Do["Do the habit"] --> Tr["Track it<br/>(checkbox / streak)"]
  Tr --> See["Visible evidence<br/>of progress"]
  See --> Sat["Satisfying"]
  Sat --> Do
  Miss{"Missed a day?"} -.->|never miss twice| Do""", "ch16§1¶1", "Habit tracking closes the loop by making progress visible and satisfying; the rule is 'never miss twice.'"),
    19: ("""flowchart LR
  Easy["Too easy<br/>(boredom)"] -.-> Drop["Disengage"]
  Hard["Too hard<br/>(anxiety)"] -.-> Drop
  G["Goldilocks zone:<br/>~4% beyond ability"] ==>|peak motivation| Flow["Sustained effort"]""", "ch19§1¶1", "The Goldilocks Rule: motivation peaks when a task sits just beyond current ability — challenging but achievable."),
    21: ("""flowchart LR
  H["Habits<br/>(automatic baseline)"] --> P["Deliberate practice<br/>(effortful refinement)"]
  P --> Re["Reflection &<br/>review"]
  Re --> H
  classDef auto fill:#eef,stroke:#446;
  classDef effort fill:#fee,stroke:#a33;
  class H auto;
  class P effort;""", "ch21§1¶1", "Habits handle the baseline so attention is freed for deliberate practice; reflection feeds improvements back into the habit layer."),
}

# Pull-quote bands: ranges of chapters
PULL_BANDS = [(1,4),(5,9),(10,14),(15,18),(19,22)]

def pick_pullquote(chap_range):
    lo, hi = chap_range
    best = None
    for c in range(lo, hi+1):
        for u in by_chap.get(c, []):
            if u["kind"] != "anchor": continue
            score = u.get("retention_score") or 0
            if best is None or score > best.get("retention_score", 0):
                best = u
    return best

# Pre-select pull quotes (which chapter they appear after, last chapter of band)
pull_after = {}
for band in PULL_BANDS:
    pq = pick_pullquote(band)
    if pq:
        pull_after[band[1]] = pq

# Sidenotes: short, taken once per chapter from a high-retention bridge or anchor
# Keep simple: one sidenote per chapter from a hand-chosen short phrase derived from corpus voice
SIDENOTES = {
    2: "Voice cue: <em>habits are the compound interest of self-improvement.</em>",
    3: "The onion: outcomes → process → identity. Deeper layers, harder to change, more durable.",
    4: "The Four Laws map 1:1 onto the Habit Loop — cue, craving, response, reward.",
    6: "If-Then: <em>When situation X arises, I will perform response Y.</em>",
    9: "Dopamine fires on anticipation, not on reward — that's the lever.",
    13: "Friction is a force you can engineer in either direction.",
    14: "Standardize before you optimize.",
    16: "Never miss twice. One miss is an accident; two is the start of a new habit.",
    19: "Just-manageable difficulty is where motivation lives.",
    21: "Without reflection, habits ossify.",
}

WORDS_PER_MIN = 200

# Word count helper
import re
def word_count(s):
    text = re.sub(r"<[^>]+>", " ", s)
    return len(re.findall(r"\b\w+\b", text))

# Build article body
body_parts = []
total_words_out = 0

for c in chapters:
    n = c["no"]
    title = c["title"]
    units_c = by_chap.get(n, [])
    # Compute chapter words from units
    cwords = sum(word_count(u["html"]) for u in units_c)
    total_words_out += cwords
    rt = max(1, round(cwords / WORDS_PER_MIN))
    body_parts.append(f'<h2 id="ch-{n}">{n}. {ihtml.escape(title)} <span class="reading-time">~{rt} min</span></h2>')

    # Sidenote — placed early
    if n in SIDENOTES:
        body_parts.append(f'<aside class="sidenote">{SIDENOTES[n]}</aside>')

    # Units, with diagram after first anchor for concept chapters
    inserted_diagram = False
    first_anchor_done = False
    for u in units_c:
        body_parts.append(u["html"])
        if u["kind"] == "anchor":
            if not first_anchor_done:
                first_anchor_done = True
                if n in DIAGRAMS and not inserted_diagram:
                    diag, src, cap = DIAGRAMS[n]
                    body_parts.append(
                        f'<figure class="diagram"><div class="mermaid">{diag}</div>'
                        f'<figcaption>Diagram — {ihtml.escape(cap)} <span style="opacity:0.7">(source: {src})</span></figcaption></figure>'
                    )
                    inserted_diagram = True

    # Pull-quote at end of band
    if n in pull_after:
        pq = pull_after[n]
        q = pq.get("verbatim_quote") or ""
        sid = pq["source_ids"][0]
        body_parts.append(
            f'<aside class="pullquote">&ldquo;{ihtml.escape(q)}&rdquo; <span style="font-size:0.55em;font-style:normal;display:block;margin-top:0.5rem;opacity:0.7">— {sid}</span></aside>'
        )

article_body = "\n".join(body_parts)

# TOC
toc_entries = "\n        ".join(
    f'<li><a href="#ch-{c["no"]}">{c["no"]}. {ihtml.escape(c["title"])}</a></li>'
    for c in chapters
)

total_min = max(1, round(total_words_out / WORDS_PER_MIN))

design_note = (
    "Linear navigation because in Atomic Habits sequence IS the argument: the Four Laws stack on the Habit Loop, "
    "and each chapter assumes the prior one. The TOC mirrors chapter order rather than clustering by theme. "
    "Diagrams are Mermaid only (Channel A) and appear only where a concept has a relationship worth externalizing "
    "— compounding math, the habit loop, the Goldilocks zone, the Two-Minute Rule. Pull-quotes break the page "
    "every 3–5 chapters and are drawn from the highest-retention anchor in that band, so the reader's eye is "
    "rewarded with Clear's own voice, not editorial summary. Tufte-style sidenotes carry one cue per chapter; "
    "drop caps mark chapter openers; a 3px progress bar plus scroll-spy TOC give a constant sense of where you "
    "are in a 22-chapter argument. The body measure is locked at 66ch to keep saccades short — this is a book "
    "to finish, not skim."
)

# Read template
with open(TEMPLATE, "r", encoding="utf-8") as f:
    tmpl = f.read()

# Replacements
replacements = {
    "{{ BOOK_TITLE }}": "Atomic Habits: Tiny Changes, Remarkable Results",
    "{{ BOOK_AUTHOR }}": "James Clear",
    "{{ BUILD_DATE }}": "2026-05-27",
    "{{ TOTAL_MIN }}": str(total_min),
    "{{ TOTAL_WORDS }}": str(total_words_out),
    "{{ DESIGNER_DESIGN_NOTE }}": design_note,
    "{{ COVERAGE_PCT }}": "16",
    "{{ BRIDGE_RATIO }}": "0.014",
    "{{ BUILD_ID }}": "20260527-001-atomic-habits",
}
for k,v in replacements.items():
    tmpl = tmpl.replace(k, v)

# Insert TOC entries — replace the comment placeholder line
tmpl = tmpl.replace(
    "<!-- {{ TOC_ENTRIES }} : <li><a href=\"#sec-1\">1. Chapter Title</a></li> -->",
    toc_entries
)

# Insert article body
tmpl = tmpl.replace(
    "<!-- {{ ARTICLE_BODY }} : the merged units (anchor blockquotes + bridge prose + illustrations) -->",
    article_body
)

# Enable Mermaid script (uncomment)
tmpl = tmpl.replace(
    '<!-- <script src="https://cdn.jsdelivr.net/npm/mermaid/dist/mermaid.min.js"></script>\n       <script>mermaid.initialize({startOnLoad:true, theme:\'neutral\'});</script> -->',
    '<script src="https://cdn.jsdelivr.net/npm/mermaid/dist/mermaid.min.js"></script>\n  <script>mermaid.initialize({startOnLoad:true, theme:\'neutral\'});</script>'
)

with open(OUT, "w", encoding="utf-8") as f:
    f.write(tmpl)

size_kb = os.path.getsize(OUT) / 1024
n_diagrams = len(DIAGRAMS)
n_pullquotes = len(pull_after)
print(f"WROTE {OUT}")
print(f"SIZE_KB={size_kb:.1f}")
print(f"DIAGRAMS={n_diagrams}")
print(f"PULLQUOTES={n_pullquotes}")
print(f"TOTAL_WORDS_BODY={total_words_out}")
print(f"TOTAL_MIN={total_min}")
print("DESIGN_NOTE:")
print(design_note)
