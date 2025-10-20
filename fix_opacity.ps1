# PowerShell script to replace deprecated .withOpacity() calls with .withValues(alpha:)
# Run this in your Flutter project root directory

Write-Host "Starting bulk withOpacity fix..." -ForegroundColor Green

Get-ChildItem -Path "lib" -Include "*.dart" -Recurse | ForEach-Object {
    $content = Get-Content $_.FullName -Raw
    $updated = $content -replace '\.withOpacity\((0\.\d+|1\.0)\)', '.withValues(alpha: $1)'
    if ($content -ne $updated) {
        Set-Content $_.FullName $updated -Encoding UTF8
        Write-Host "Updated: $($_.Name)" -ForegroundColor Yellow
    }
}

Write-Host "Bulk withOpacity fix completed!" -ForegroundColor Green
Write-Host "Run 'flutter analyze' to verify the fixes" -ForegroundColor Cyan
