# PowerShell script to clean markdown formatting from the report
$content = Get-Content "final_project_report.md" -Raw

# Remove markdown headers (# ## ###)
$content = $content -replace '^#{1,6}\s*', ''

# Remove markdown bold/italic (* ** _ __)
$content = $content -replace '\*\*([^*]+)\*\*', '$1'
$content = $content -replace '\*([^*]+)\*', '$1'
$content = $content -replace '__([^_]+)__', '$1'
$content = $content -replace '_([^_]+)_', '$1'

# Remove markdown links [text](url)
$content = $content -replace '\[([^\]]+)\]\([^\)]+\)', '$1'

# Remove markdown code blocks (```code```)
$content = $content -replace '```[\s\S]*?```', ''

# Remove inline code (`code`)
$content = $content -replace '`([^`]+)`', '$1'

# Remove markdown lists (- * +)
$content = $content -replace '^[ \t]*[-*+]\s*', ''

# Clean up extra whitespace
$content = $content -replace '(\r?\n){3,}', "`n`n"

# Write to clean file
$content | Out-File "final_project_report_clean_complete.txt" -Encoding UTF8

Write-Host "Markdown cleaning completed. Clean file saved as final_project_report_clean_complete.txt"
