#requires -Version 7
# Ingestor (deterministic) — build source_id corpus from extracted epub.
param(
  [string]$XhtmlDir = "C:\Claude Cowork\CLAUDE OUTPUTS\book-to-html\_build\20260527-001-boat-go-faster\epub_unpacked\OEBPS",
  [string]$OutPath  = "C:\Claude Cowork\CLAUDE OUTPUTS\book-to-html\_build\20260527-001-boat-go-faster\corpus.json"
)
$ErrorActionPreference = 'Stop'

# Walk spine-ordered files (filenames are NN_*.html, so sort lexicographically works)
$files = Get-ChildItem -Path $XhtmlDir -Filter "*.html" -Recurse | Sort-Object Name

# Skip pure front-matter / cover / copyright pages
$skip = @('Cover_Page','Series_Page','Title_Page','Copyright_Page','Dedication','About_the_Author','Acknowledgements','Index')

$paragraphs = [System.Collections.Generic.List[object]]::new()
$chapters   = [System.Collections.Generic.List[object]]::new()
$currentChapter = 0
$currentSection = 0
$currentChapterTitle = "Front Matter"
$chapterStartCount = 0
$totalWords = 0

foreach ($f in $files) {
  $skipFile = $false
  foreach ($s in $skip) { if ($f.Name -match $s) { $skipFile = $true; break } }
  if ($skipFile) { continue }

  $raw = Get-Content $f.FullName -Raw

  # Detect "CHAPTER N" marker — file pattern "NN_CHAPTER_N__TITLE.html"
  if ($f.Name -match '^\d+_CHAPTER_(\d+)__(.+)\.html$') {
    if ($currentChapter -gt 0) {
      $chapters.Add([pscustomobject]@{ no = $currentChapter; title = $currentChapterTitle; words = ($paragraphs.Count - $chapterStartCount) * 60 }) | Out-Null
    }
    $currentChapter = [int]$Matches[1]
    $currentChapterTitle = ($Matches[2] -replace '_',' ').Trim()
    $currentSection = 0
    $chapterStartCount = $paragraphs.Count
    continue   # chapter-title-only file, no body paragraphs
  }

  # Increment section within current chapter
  $currentSection += 1

  # Strip HTML tags, decode entities, split on paragraph boundaries
  # First grab <p>...</p> blocks if present
  $paraMatches = [regex]::Matches($raw, '<p[^>]*>(.*?)</p>', 'Singleline')
  if ($paraMatches.Count -eq 0) {
    # Fall back: split on double newlines after tag stripping
    $stripped = [regex]::Replace($raw, '<[^>]+>', ' ')
    $stripped = [System.Net.WebUtility]::HtmlDecode($stripped)
    $stripped = [regex]::Replace($stripped, '\s+', ' ').Trim()
    if ($stripped.Length -gt 50) {
      $paraNo = 1
      $sid = "ch${currentChapter}`u{00a7}${currentSection}`u{00b6}${paraNo}"
      $wc = ($stripped -split '\s+').Count
      $totalWords += $wc
      $paragraphs.Add([pscustomobject]@{
        source_id = $sid; text = $stripped; chapter_no = $currentChapter
        section_no = $currentSection; para_no = $paraNo; word_count = $wc
        source_file = $f.Name
      }) | Out-Null
    }
    continue
  }

  $paraNo = 0
  foreach ($pm in $paraMatches) {
    $inner = $pm.Groups[1].Value
    $text = [regex]::Replace($inner, '<[^>]+>', ' ')
    $text = [System.Net.WebUtility]::HtmlDecode($text)
    $text = [regex]::Replace($text, '\s+', ' ').Trim()
    if ($text.Length -lt 30) { continue }   # skip page numbers, fragments
    $paraNo += 1
    $sid = "ch${currentChapter}`u{00a7}${currentSection}`u{00b6}${paraNo}"
    $wc = ($text -split '\s+').Count
    $totalWords += $wc
    $paragraphs.Add([pscustomobject]@{
      source_id = $sid; text = $text; chapter_no = $currentChapter
      section_no = $currentSection; para_no = $paraNo; word_count = $wc
      source_file = $f.Name
    }) | Out-Null
  }
}

# Close out final chapter
if ($currentChapter -gt 0) {
  $chapters.Add([pscustomobject]@{ no = $currentChapter; title = $currentChapterTitle; words = ($paragraphs.Count - $chapterStartCount) * 60 }) | Out-Null
}

# Recompute chapter word counts from actual paragraphs
$chWords = @{}
foreach ($p in $paragraphs) {
  if (-not $chWords.ContainsKey($p.chapter_no)) { $chWords[$p.chapter_no] = 0 }
  $chWords[$p.chapter_no] += $p.word_count
}
$chaptersFinal = $chapters | ForEach-Object {
  [pscustomobject]@{ no = $_.no; title = $_.title; words = ($chWords[$_.no] ?? 0) }
}

$corpus = [pscustomobject]@{
  book_metadata = [pscustomobject]@{
    title = "Will It Make The Boat Go Faster?"
    author = "Ben Hunt-Davis & Harriet Beveridge"
    total_words = $totalWords
    chapters = $chaptersFinal
    paragraph_count = $paragraphs.Count
    build_id = "20260527-001-boat-go-faster"
  }
  corpus = $paragraphs
}

$corpus | ConvertTo-Json -Depth 6 | Set-Content -Path $OutPath -Encoding UTF8
Write-Output "Wrote $($paragraphs.Count) paragraphs, $totalWords words, $($chaptersFinal.Count) chapters -> $OutPath"
$chaptersFinal | Format-Table -AutoSize
