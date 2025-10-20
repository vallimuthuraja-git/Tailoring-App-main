# PowerShell script to add missing imports and fix unused imports
# Run this to ensure all files have correct debugPrint imports

Write-Host "Checking and fixing imports..." -ForegroundColor Green

$files = Get-ChildItem -Path "lib" -Include "*.dart" -Recurse

foreach ($file in $files) {
    $content = Get-Content $file.FullName -Raw -Encoding UTF8

    # Check if file uses debugPrint but doesn't import foundation
    if ($content -match 'debugPrint\(' -and $content -notmatch "import 'package:flutter/foundation.dart'") {
        # Add foundation import if debugPrint is used
        $content = "import 'package:flutter/foundation.dart';" + "`n" + $content
        Set-Content $file.FullName $content -Encoding UTF8
        Write-Host "Added foundation import to: $($file.Name)" -ForegroundColor Yellow
    }
}

Write-Host "Import fixes completed!" -ForegroundColor Green
