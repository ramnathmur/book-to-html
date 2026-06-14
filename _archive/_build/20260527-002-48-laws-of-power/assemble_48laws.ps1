#requires -Version 7
# Assembler — Lite mode, 48 Laws of Power
# No Mermaid diagrams, no Pollinations images (Lite = no Designer/Channel B)
param(
  [string]$Base     = "C:\Claude Cowork\CLAUDE OUTPUTS\book-to-html\_build\20260527-002-48-laws-of-power",
  [string]$Template = "C:\Claude Cowork\skills\book-to-html\references\reading-ux-template.html",
  [string]$OutDir   = "C:\Claude Cowork\CLAUDE OUTPUTS\book-to-html",
  [string]$OutName  = "48-Laws-Of-Power_Reader_v1.html"
)
$ErrorActionPreference = 'Stop'

$design = Get-Content (Join-Path $Base "design_plan.json") -Raw | ConvertFrom-Json
$tpl    = Get-Content $Template -Raw

# Load all 48 law units in order
$chapters        = @{}
$totalOutWords   = 0
$totalBridgeWords= 0
$totalSourceWords= 217223
$allDropped      = [System.Collections.Generic.List[object]]::new()

for ($n = 1; $n -le 48; $n++) {
  $obj = Get-Content (Join-Path $Base "units\ch$n`_units.json") -Raw | ConvertFrom-Json
  $chapters[$n] = $obj
  $totalOutWords   += $obj.coverage_intent.chapter_output_words
  $bridgeW = [int]($obj.coverage_intent.chapter_output_words * [double]$obj.coverage_intent.bridge_ratio)
  $totalBridgeWords += $bridgeW
  if ($obj.coverage_intent.dropped_sections) {
    foreach ($d in $obj.coverage_intent.dropped_sections) { $allDropped.Add($d) | Out-Null }
  }
}

$totalBridgeRatio = [math]::Round($totalBridgeWords / [math]::Max($totalOutWords, 1), 3)
$coveragePct      = [math]::Round($totalOutWords / $totalSourceWords * 100, 1)
$totalMin         = [math]::Round($totalOutWords / 220)

# Build TOC
$tocEntries = ($design.toc | ForEach-Object {
  '        <li><a href="#{0}">{1}</a> <span style="color:var(--muted);font-size:0.75rem">{2} min</span></li>' -f `
    $_.anchor, ($_.chapter_title -replace '&','&amp;' -replace '<','&lt;'), $_.read_minutes
}) -join "`n"

# Build article body — one <section> per law
$sb = [System.Text.StringBuilder]::new()
foreach ($n in 1..48) {
  $ch      = $chapters[$n]
  $tocItem = $design.toc | Where-Object { $_.law_no -eq $n } | Select-Object -First 1
  $anchor  = $tocItem.anchor
  $title   = $tocItem.chapter_title -replace '&','&amp;' -replace '<','&lt;'
  $readMin = $tocItem.read_minutes

  [void]$sb.AppendLine('')
  [void]$sb.AppendLine("      <section class=""chapter"" id=""$anchor-section"">")
  [void]$sb.AppendLine("        <h2 id=""$anchor"">$title<span class=""reading-time"">$readMin min read</span></h2>")

  # Render units (Lite: no Channel B images, no Mermaid — pass HTML directly)
  foreach ($u in $ch.units) {
    [void]$sb.AppendLine("        " + $u.html)
  }

  [void]$sb.AppendLine("      </section>")
}

$articleBody = $sb.ToString()

# ── Placeholder substitution ──────────────────────────────────────────────────
$buildId   = "20260527-002-48-laws-of-power"
$buildDate = (Get-Date).ToString("yyyy-MM-dd")
$bookTitle = "The 48 Laws of Power"
$bookAuthor= "Robert Greene"
$designNote= "Lite mode — Ingestor + Editor only. No Channel B illustrations, no Mermaid diagrams."

$html = $tpl
$html = $html.Replace('{{ BOOK_TITLE }}',             $bookTitle)
$html = $html.Replace('{{ BOOK_AUTHOR }}',            $bookAuthor)
$html = $html.Replace('{{ BUILD_DATE }}',             $buildDate)
$html = $html.Replace('{{ TOTAL_MIN }}',              "$totalMin")
$html = $html.Replace('{{ TOTAL_WORDS }}',            "$totalOutWords")
$html = $html.Replace('{{ DESIGNER_DESIGN_NOTE }}',   $designNote)
$html = $html.Replace('{{ COVERAGE_PCT }}',           "$coveragePct")
$html = $html.Replace('{{ BRIDGE_RATIO }}',           "$totalBridgeRatio")
$html = $html.Replace('{{ BUILD_ID }}',               $buildId)

# Insert TOC and body (find comment anchors, replace)
function ReplaceFirst([string]$haystack, [string]$pattern, [string]$replacement) {
  $rx = [regex]::new($pattern, [System.Text.RegularExpressions.RegexOptions]::Singleline)
  $m  = $rx.Match($haystack)
  if (-not $m.Success) { return $haystack }
  return $haystack.Substring(0, $m.Index) + $replacement + $haystack.Substring($m.Index + $m.Length)
}
$html = ReplaceFirst $html '<!--\s*\{\{\s*TOC_ENTRIES\s*\}\}[\s\S]*?-->'  $tocEntries
$html = ReplaceFirst $html '<!--\s*\{\{\s*ARTICLE_BODY\s*\}\}[\s\S]*?-->' $articleBody

# Inject anchor/blockquote styles (Lite mode only uses these — no opener/diagram classes needed)
$liteStyles = @"

    /* Lite mode — anchor blockquotes */
    blockquote.anchor {
      border-left: 3px solid var(--accent, #c9a44b);
      margin: 1.25rem 0;
      padding: 0.6rem 1rem;
      background: rgba(201,164,75,0.06);
      border-radius: 0 4px 4px 0;
    }
    blockquote.anchor p { margin: 0; font-style: italic; }
    section.chapter { margin-bottom: 2rem; }

"@
$html = $html.Replace('    /* Footer */', $liteStyles + "    /* Footer */")

# Save HTML
New-Item -ItemType Directory -Path $OutDir -Force | Out-Null
$out = Join-Path $OutDir $OutName
$html | Set-Content -Path $out -Encoding UTF8

# ── Coverage sidecar ─────────────────────────────────────────────────────────
$cov = [pscustomobject]@{
  build_id      = $buildId
  mode          = "lite"
  book_title    = $bookTitle
  book_author   = $bookAuthor
  source_words  = $totalSourceWords
  output_words  = $totalOutWords
  retention_pct = $coveragePct
  bridge_ratio  = $totalBridgeRatio
  total_units   = ($chapters.Values | ForEach-Object { $_.units.Count } | Measure-Object -Sum).Sum
  per_chapter   = (1..48 | ForEach-Object {
    $c = $chapters[$_]
    [pscustomobject]@{
      law           = $_
      title         = $c.chapter_title
      source_words  = $c.coverage_intent.chapter_source_words
      output_words  = $c.coverage_intent.chapter_output_words
      bridge_ratio  = $c.coverage_intent.bridge_ratio
      units         = $c.units.Count
    }
  })
  dropped_sections = $allDropped
}
$cov | ConvertTo-Json -Depth 5 | Set-Content -Path (Join-Path $OutDir "48-Laws-Of-Power_coverage.json") -Encoding UTF8

Write-Output "Assembled : $out"
Write-Output ("Size      : {0:N1} KB" -f ((Get-Item $out).Length / 1KB))
Write-Output "Coverage  : $coveragePct% of source, $totalOutWords words, bridge_ratio=$totalBridgeRatio, ~$totalMin min read"
