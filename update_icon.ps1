# Replace old clipboard icon with a graduation cap (education-themed) icon
# across all AIIMS HTML files

$files = Get-ChildItem 'd:\AIMS\*.html'

# Old clipboard icon path (what we want to replace)
$oldPath = 'M19 3h-4.18C14.4 1.84 13.3 1 12 1c-1.3 0-2.4.84-2.82 2H5c-1.1 0-2 .9-2 2v14c0 1.1.9 2 2 2h14c1.1 0 2-.9 2-2V5c0-1.1-.9-2-2-2zm-7 0c.55 0 1 .45 1 1s-.45 1-1 1-1-.45-1-1 .45-1 1-1zm2 14H7v-2h7v2zm3-4H7v-2h10v2zm0-4H7V7h10v2z'

# New graduation cap icon path (education themed)
$newPath = 'M5 13.18v4L12 21l7-3.82v-4L12 17l-7-3.82zM12 3L1 9l11 6 9-4.91V17h2V9L12 3z'

foreach ($f in $files) {
    $content = Get-Content $f.FullName -Raw -Encoding UTF8
    if ($content -match [regex]::Escape($oldPath)) {
        $updated = $content -replace [regex]::Escape($oldPath), $newPath
        Set-Content $f.FullName $updated -NoNewline -Encoding UTF8
        Write-Host "Updated: $($f.Name)"
    } else {
        Write-Host "Skipped (no match): $($f.Name)"
    }
}

Write-Host "`nDone! All icons updated to graduation cap."
