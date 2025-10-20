# Fix all malformed debugdebugPrint statements to debugPrint
Write-Host "Fixing malformed debugDebugPrint statements..." -ForegroundColor Green

$files = Get-ChildItem -Path "lib" -Include "*.dart" -Recurse
$fixedCount = 0

foreach ($file in $files) {
    $content = Get-Content $file.FullName -Raw -Encoding UTF8
    $originalContent = $content

    # Replace debugdebugPrint with debugPrint
    $content = $content -replace 'debugdebugPrint', 'debugPrint'

    if ($content -ne $originalContent) {
        Set-Content $file.FullName $content -Encoding UTF8
        Write-Host "Fixed debug statements in: $($file.Name)" -ForegroundColor Yellow
        $fixedCount++
    }
}

Write-Host "Fixed $fixedCount files with malformed debugPrint statements." -ForegroundColor Green
