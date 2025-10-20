# PowerShell script to replace print() calls with proper logging or debugPrint()
# Run this in your Flutter project root directory

Write-Host "Starting print statement fixes..." -ForegroundColor Green

Get-ChildItem -Path "lib" -Include "*.dart" -Recurse | ForEach-Object {
    $content = Get-Content $_.FullName -Raw

    # Replace print() with debugPrint() in most cases
    $updated = $content -replace 'print\(', 'debugPrint('

    if ($content -ne $updated) {
        Set-Content $_.FullName $updated -Encoding UTF8
        Write-Host "Updated print statements in: $($_.Name)" -ForegroundColor Yellow
    }
}

Write-Host "Print statement fix completed!" -ForegroundColor Green
Write-Host "Note: Review changed files to ensure debugPrint imports are available" -ForegroundColor Cyan
