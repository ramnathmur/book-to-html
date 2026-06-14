#requires -Version 7
# Assembler (deterministic substrate). Merges template + units + design_plan into final HTML.
param(
  [string]$Base = "C:\Claude Cowork\CLAUDE OUTPUTS\book-to-html\_build\20260527-001-boat-go-faster",
  [string]$Template = "C:\Claude Cowork\skills\book-to-html\references\reading-ux-template.html",
  [string]$OutDir = "C:\Claude Cowork\CLAUDE OUTPUTS\book-to-html",
  [string]$OutName = "Will-It-Make-The-Boat-Go-Faster_Reader_v1.html"
)
$ErrorActionPreference = 'Stop'

$design = Get-Content (Join-Path $Base "design_plan.json") -Raw | ConvertFrom-Json
$tpl    = Get-Content $Template -Raw

# Load all chapter units in order
$chapters = @{}
$totalOutWords = 0
$totalBridgeWords = 0
$totalSourceWords = 64352
$allDropped = [System.Collections.Generic.List[object]]::new()
for ($n=1; $n -le 12; $n++) {
  $obj = Get-Content (Join-Path $Base "units\ch$n`_units.json") -Raw | ConvertFrom-Json
  $chapters[$n] = $obj
  $totalOutWords += $obj.coverage_intent.chapter_output_words
  $totalBridgeWords += [int]($obj.coverage_intent.chapter_output_words * $obj.coverage_intent.bridge_ratio)
  if ($obj.coverage_intent.dropped_sections) { foreach ($d in $obj.coverage_intent.dropped_sections) { $allDropped.Add($d) | Out-Null } }
}
$totalBridgeRatio = [math]::Round($totalBridgeWords / $totalOutWords, 3)
$coveragePct = [math]::Round($totalOutWords / $totalSourceWords * 100, 1)
$totalMin = [math]::Round($totalOutWords / 220)

# Build TOC
$tocEntries = ($design.toc | ForEach-Object {
  '        <li><a href="#{0}">{1}</a> <span style="color:var(--muted);font-size:0.75rem">{2} min</span></li>' -f $_.anchor_id, $_.title, $_.reading_time_min
}) -join "`n"

# Build article body — one <section> per chapter
$sb = [System.Text.StringBuilder]::new()
foreach ($n in 1..12) {
  $ch = $chapters[$n]
  $tocItem = $design.toc | Where-Object { $_.ch -eq $n } | Select-Object -First 1
  $illu = $design.illustration_plan | Where-Object { $_.ch -eq $n } | Select-Object -First 1

  [void]$sb.AppendLine('')
  [void]$sb.AppendLine("      <section class=""chapter"" id=""$($tocItem.anchor_id)-section"">")
  [void]$sb.AppendLine("        <h2 id=""$($tocItem.anchor_id)"">$($tocItem.title)<span class=""reading-time"">$($tocItem.reading_time_min) min read</span></h2>")

  # Channel B opener image
  if ($illu.channel_b_opener) {
    $promptEncoded = [System.Web.HttpUtility]::UrlEncode($illu.channel_b_opener.prompt)
    if (-not $promptEncoded) {
      Add-Type -AssemblyName System.Web
      $promptEncoded = [System.Web.HttpUtility]::UrlEncode($illu.channel_b_opener.prompt)
    }
    $url = "https://image.pollinations.ai/prompt/$promptEncoded`?model=flux`&seed=$($illu.channel_b_opener.seed)`&width=1280`&height=720`&nologo=true"
    $altEsc = $illu.channel_b_opener.alt -replace '"','&quot;'
    [void]$sb.AppendLine("        <figure class=""opener"">")
    [void]$sb.AppendLine("          <img src=""$url"" alt=""$altEsc"" loading=""lazy"" referrerpolicy=""no-referrer"" onerror=""this.closest('figure').classList.add('opener-fallback');this.style.display='none';"">")
    [void]$sb.AppendLine("          <figcaption>$altEsc</figcaption>")
    [void]$sb.AppendLine("        </figure>")
  }

  # Channel A diagram (placed up-front for dual-coding priming)
  if ($illu.channel_a_diagram) {
    $diag = $illu.channel_a_diagram
    if ($diag.kind -eq 'mermaid') {
      $captEsc = $diag.caption -replace '"','&quot;'
      [void]$sb.AppendLine("        <figure class=""diagram"">")
      [void]$sb.AppendLine("          <pre class=""mermaid"">")
      [void]$sb.AppendLine($diag.content)
      [void]$sb.AppendLine("          </pre>")
      [void]$sb.AppendLine("          <figcaption>$captEsc</figcaption>")
      [void]$sb.AppendLine("        </figure>")
    }
  }

  # Render units in order. Pull-quote injection after first ~30% of units if signature_quotes_for_pullquote available
  $pullQuoteSrcIds = @()
  if ($ch.editor_design_hints -and $ch.editor_design_hints.signature_quotes_for_pullquote) {
    $pullQuoteSrcIds = $ch.editor_design_hints.signature_quotes_for_pullquote
  }
  $unitCount = $ch.units.Count
  $pullQuoteInjectedAfter = [System.Collections.Generic.HashSet[string]]::new()

  for ($i=0; $i -lt $ch.units.Count; $i++) {
    $u = $ch.units[$i]
    $html = $u.html
    # Some units may have outer <blockquote> or <p>; pass through
    [void]$sb.AppendLine("        " + $html)
    # Pull-quote injection check
    $srcIds = if ($u.PSObject.Properties['source_ids']) { $u.source_ids } else { @() }
    foreach ($pqId in $pullQuoteSrcIds) {
      if (($srcIds -contains $pqId) -and (-not $pullQuoteInjectedAfter.Contains($pqId)) -and ($i -lt [math]::Floor($unitCount * 0.7))) {
        # Extract quote text from the unit's html (strip tags)
        $qt = [regex]::Replace($html, '<[^>]+>', '')
        $qt = [System.Net.WebUtility]::HtmlDecode($qt).Trim()
        if ($qt.Length -gt 220) { $qt = $qt.Substring(0, 200).Trim() + "…" }
        if ($qt.Length -ge 30) {
          [void]$sb.AppendLine("        <aside class=""pullquote"">" + ($qt -replace '<', '&lt;') + "</aside>")
          [void]$pullQuoteInjectedAfter.Add($pqId)
        }
      }
    }
  }

  [void]$sb.AppendLine("      </section>")
}

$articleBody = $sb.ToString()

# Substitute placeholders
$buildId = "20260527-001-boat-go-faster"
$buildDate = (Get-Date).ToString("yyyy-MM-dd")
$bookTitle = "Will It Make The Boat Go Faster?"
$bookAuthor = "Ben Hunt-Davis & Harriet Beveridge"
$designNote = $design.design_note -replace '<', '&lt;'

$html = $tpl
$html = $html.Replace('{{ BOOK_TITLE }}', $bookTitle)
$html = $html.Replace('{{ BOOK_AUTHOR }}', $bookAuthor)
$html = $html.Replace('{{ BUILD_DATE }}', $buildDate)
$html = $html.Replace('{{ TOTAL_MIN }}', "$totalMin")
$html = $html.Replace('{{ TOTAL_WORDS }}', "$totalOutWords")
$html = $html.Replace('{{ DESIGNER_DESIGN_NOTE }}', $designNote)
$html = $html.Replace('{{ COVERAGE_PCT }}', "$coveragePct")
$html = $html.Replace('{{ BRIDGE_RATIO }}', "$totalBridgeRatio")
$html = $html.Replace('{{ BUILD_ID }}', $buildId)

# Insert TOC entries — find the comment placeholder and replace via index/substring (avoids regex $ backreference traps)
function ReplaceFirst([string]$haystack, [string]$pattern, [string]$replacement) {
  $rx = [regex]::new($pattern, [System.Text.RegularExpressions.RegexOptions]::Singleline)
  $m = $rx.Match($haystack)
  if (-not $m.Success) { return $haystack }
  return $haystack.Substring(0, $m.Index) + $replacement + $haystack.Substring($m.Index + $m.Length)
}
$html = ReplaceFirst $html '<!--\s*\{\{\s*TOC_ENTRIES\s*\}\}[\s\S]*?-->' $tocEntries
$html = ReplaceFirst $html '<!--\s*\{\{\s*ARTICLE_BODY\s*\}\}[\s\S]*?-->' $articleBody

# Enable Mermaid script (uncomment the CDN block)
$html = $html.Replace('<!-- <script src="https://cdn.jsdelivr.net/npm/mermaid/dist/mermaid.min.js"></script>
       <script>mermaid.initialize({startOnLoad:true, theme:''neutral''});</script> -->',
  '<script src="https://cdn.jsdelivr.net/npm/mermaid/dist/mermaid.min.js"></script>
       <script>mermaid.initialize({startOnLoad:true, theme:''neutral''});</script>')

# Inject opener-fallback CSS into the existing <style>
$fallbackCss = "
    figure.opener img { width: 100%; height: auto; border-radius: 2px; }
    figure.opener-fallback { background: rgba(127,127,127,0.05); padding: 1rem; text-align: center; font-style: italic; color: var(--muted); }
    figure.opener-fallback::before { content: ""(illustration unavailable — see passage below)""; display: block; margin-bottom: 0.5rem; }
    figure.diagram pre.mermaid { background: transparent; border: 0; padding: 0; margin: 0; }
    section.chapter { margin-bottom: 2rem; }
"
$html = $html.Replace('    /* Footer */', $fallbackCss + "    /* Footer */")

# Save
New-Item -ItemType Directory -Path $OutDir -Force | Out-Null
$out = Join-Path $OutDir $OutName
$html | Set-Content -Path $out -Encoding UTF8

# Save sidecars
$cov = [pscustomobject]@{
  build_id = $buildId
  book_title = $bookTitle
  book_author = $bookAuthor
  source_words = $totalSourceWords
  output_words = $totalOutWords
  retention_pct = $coveragePct
  bridge_ratio = $totalBridgeRatio
  total_units = ($chapters.Values | ForEach-Object { $_.units.Count } | Measure-Object -Sum).Sum
  per_chapter = (1..12 | ForEach-Object {
    $c = $chapters[$_]
    [pscustomobject]@{
      ch = $_; title = $c.chapter_title
      source_words = $c.coverage_intent.chapter_source_words
      output_words = $c.coverage_intent.chapter_output_words
      bridge_ratio = $c.coverage_intent.bridge_ratio
      units = $c.units.Count
    }
  })
  dropped_sections = $allDropped
}
$cov | ConvertTo-Json -Depth 5 | Set-Content -Path (Join-Path $OutDir "Will-It-Make-The-Boat-Go-Faster_coverage.json") -Encoding UTF8

Write-Output "Assembled: $out"
Write-Output ("Size: {0:N1} KB" -f ((Get-Item $out).Length / 1KB))
Write-Output "Coverage: $coveragePct% of source, $totalOutWords words, bridge_ratio=$totalBridgeRatio, ~$totalMin min read"
