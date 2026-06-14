#requires -Version 7
# Proofreader substrate — deterministic anchor verification.
# For each kind=anchor unit, check that verbatim_quote (or html stripped) is substantially contained in the concatenated source paragraphs at source_ids.
param(
  [string]$Base = "C:\Claude Cowork\CLAUDE OUTPUTS\book-to-html\_build\20260527-001-boat-go-faster"
)
$ErrorActionPreference = 'Stop'

$corpus = Get-Content (Join-Path $Base "corpus.json") -Raw | ConvertFrom-Json
$sidIndex = @{}
foreach ($p in $corpus.corpus) { $sidIndex[$p.source_id] = $p.text }

function Normalize([string]$s) {
  if (-not $s) { return "" }
  $s = [regex]::Replace($s, '<[^>]+>', ' ')
  $s = [System.Net.WebUtility]::HtmlDecode($s)
  $s = [regex]::Replace($s, '[‘’‚‛′]', "'")  # curly singles → straight
  $s = [regex]::Replace($s, '[“”„″]', '"')          # curly doubles → straight
  $s = [regex]::Replace($s, '[–—−]', '-')                # dashes → hyphen
  $s = [regex]::Replace($s, '\s+', ' ').Trim().ToLower()
  return $s
}

# Token-set overlap: |intersection| / |smaller_set|. Returns 0..1.
function TokenSetRatio([string]$a, [string]$b) {
  $ta = ($a -split ' ' | Where-Object { $_.Length -gt 0 }) | Sort-Object -Unique
  $tb = ($b -split ' ' | Where-Object { $_.Length -gt 0 }) | Sort-Object -Unique
  if ($ta.Count -eq 0) { return 0 }
  $setA = [System.Collections.Generic.HashSet[string]]::new()
  $ta | ForEach-Object { [void]$setA.Add($_) }
  $setB = [System.Collections.Generic.HashSet[string]]::new()
  $tb | ForEach-Object { [void]$setB.Add($_) }
  $inter = 0
  foreach ($t in $setA) { if ($setB.Contains($t)) { $inter++ } }
  $smaller = [math]::Min($setA.Count, $setB.Count)
  return [math]::Round($inter / $smaller, 3)
}

$results = [System.Collections.Generic.List[object]]::new()
$violations = [System.Collections.Generic.List[object]]::new()

for ($n=1; $n -le 12; $n++) {
  $unitFile = Join-Path $Base "units\ch$n`_units.json"
  $obj = Get-Content $unitFile -Raw | ConvertFrom-Json
  foreach ($u in $obj.units) {
    if ($u.kind -ne 'anchor') { continue }
    if (-not $u.source_ids -or $u.source_ids.Count -eq 0) {
      $violations.Add([pscustomobject]@{unit_id=$u.unit_id; kind="anchor_no_source_ids"; evidence="anchor unit has no source_ids"}) | Out-Null
      continue
    }
    $srcText = ($u.source_ids | ForEach-Object { $sidIndex[$_] }) -join ' '
    $quote = if ($u.verbatim_quote) { $u.verbatim_quote } else { $u.html }
    $nq = Normalize $quote
    $ns = Normalize $srcText
    $ratio = TokenSetRatio $nq $ns
    $substr = $ns.Contains($nq) -or ($nq.Length -gt 50 -and $ns.Contains($nq.Substring(0, [math]::Min(80, $nq.Length))))
    # Ellipsis-truncation convention: strip trailing/leading "..." and test prefix-containment
    $nqStrip = $nq.TrimEnd('.', ' ').TrimEnd('.', ' ').TrimEnd('.', ' ').TrimStart('.', ' ').TrimStart('.', ' ').TrimStart('.', ' ').Trim()
    $ellipsisOk = ($nqStrip.Length -ge 20) -and $ns.Contains($nqStrip.Substring(0, [math]::Min(60, $nqStrip.Length)))
    $status = if ($substr -or $ellipsisOk -or $ratio -ge 0.92) { "pass" } else { "fail" }
    $results.Add([pscustomobject]@{unit_id=$u.unit_id; chapter=$n; ratio=$ratio; substring=$substr; status=$status}) | Out-Null
    if ($status -eq "fail") {
      $violations.Add([pscustomobject]@{
        unit_id=$u.unit_id; chapter=$n
        kind="anchor_not_verbatim"
        ratio=$ratio
        quote_excerpt = $nq.Substring(0, [math]::Min(120, $nq.Length))
        source_excerpt = $ns.Substring(0, [math]::Min(120, $ns.Length))
      }) | Out-Null
    }
  }
}

$total = $results.Count
$pass = ($results | Where-Object { $_.status -eq "pass" }).Count
$fail = ($results | Where-Object { $_.status -eq "fail" }).Count
Write-Output ("Anchor verification: {0} total, {1} pass, {2} fail (pass_pct={3:N3})" -f $total, $pass, $fail, ($pass/$total))

if ($fail -gt 0) {
  Write-Output "`nFAILED UNITS (showing up to 8):"
  $violations | Select-Object -First 8 | Format-List
}

# Save full report
$report = [pscustomobject]@{
  generated_at = (Get-Date).ToString("yyyy-MM-ddTHH:mm:ssZ")
  total_anchors = $total
  passed = $pass
  failed = $fail
  pass_pct = [math]::Round($pass/$total, 4)
  violations = $violations
}
$report | ConvertTo-Json -Depth 5 | Set-Content -Path (Join-Path $Base "anchor_verification.json") -Encoding UTF8
Write-Output "Wrote anchor_verification.json"
