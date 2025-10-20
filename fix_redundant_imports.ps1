# Remove redundant foundation.dart imports when material.dart is already imported
Write-Host "Removing redundant foundation imports..." -ForegroundColor Green

$files = Get-ChildItem -Path "lib" -Include "*.dart" -Recurse

foreach ($file in $files) {
    $content = Get-Content $file.FullName -Raw -Encoding UTF8

    # Check if the file imports material.dart
    $hasMaterialImport = $content -match "import 'package:flutter/material.dart'"
    $hasFoundationImport = $content -match "import 'package:flutter/foundation.dart'"
    $usesDebugPrint = $content -match 'debugPrint\('

    # Remove foundation import if material is imported and debugPrint isn't used
    if ($hasMaterialImport -and $hasFoundationImport -and -not $usesDebugPrint) {
        # Remove the foundation import line
        $content = $content -replace "(?m)^import 'package:flutter/foundation.dart';\s*$", ""
        Set-Content $file.FullName $content -Encoding UTF8
        Write-Host "Removed redundant foundation import from: $($file.Name)" -ForegroundColor Yellow
    }
}

Write-Host "Redundant import cleanup completed!" -ForegroundColor Green
