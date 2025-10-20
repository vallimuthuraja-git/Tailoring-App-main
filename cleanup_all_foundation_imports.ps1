# Comprehensive cleanup of all unused foundation.dart imports
Write-Host "Starting comprehensive foundation import cleanup..." -ForegroundColor Green

$files = Get-ChildItem -Path "lib" -Include "*.dart" -Recurse
$removedCount = 0

foreach ($file in $files) {
    $content = Get-Content $file.FullName -Raw -Encoding UTF8
    $originalContent = $content

    # Check if file has foundation import but doesn't use debugPrint
    $hasFoundationImport = $content -match "import 'package:flutter/foundation.dart'"
    $usesDebugPrint = $content -match 'debugPrint\('

    # Remove foundation import if debugPrint is not used
    if ($hasFoundationImport -and -not $usesDebugPrint) {
        $content = $content -replace "(?m)^import 'package:flutter/foundation.dart';\s*$", ""
        if ($content -ne $originalContent) {
            Set-Content $file.FullName $content.TrimEnd() -Encoding UTF8
            Write-Host "Removed foundation import from: $($file.Name)" -ForegroundColor Yellow
            $removedCount++
        }
    }
}

Write-Host "Cleanup completed! Removed $removedCount unused foundation imports." -ForegroundColor Green
