# Final cleanup of remaining foundation import issues
Write-Host "Cleaning up final foundation import issues..." -ForegroundColor Green

$files = @(
    "lib\main.dart",
    "lib\providers\cart_provider.dart",
    "lib\screens\avatar\avatar_customization_screen.dart",
    "lib\screens\comprehensive_products_screen.dart",
    "lib\screens\customer\customer_management_screen.dart",
    "lib\screens\demo_setup_screen.dart",
    "lib\screens\employee\employee_list_simple.dart",
    "lib\screens\employee\employee_management_home.dart",
    "lib\screens\employee\simple_employee_list_screen.dart",
    "lib\screens\home\controllers\home_controller.dart",
    "lib\screens\home\controllers\navigation_controller.dart",
    "lib\screens\product_screen.dart",
    "lib\screens\services\service_catalog_screen.dart",
    "lib\screens\services\service_create_screen.dart",
    "lib\screens\services\service_edit_screen.dart",
    "lib\services\notification_service.dart",
    "lib\widgets\catalog\catalog_components.dart",
    "lib\widgets\catalog\unified_product_card.dart",
    "lib\widgets\user_avatar.dart",
    "lib\services\work_assignment_service.dart"
)

$fixedCount = 0

foreach ($file in $files) {
    if (Test-Path $file) {
        $content = Get-Content $file -Raw -Encoding UTF8
        $originalContent = $content

        # Check if material.dart is imported
        if ($content -match "import 'package:flutter/material.dart'") {
            # Remove foundation import if present
            $content = $content -replace "(?m)^import 'package:flutter/foundation.dart';\s*$", ""

            if ($content -ne $originalContent) {
                Set-Content $file $content.TrimEnd() -Encoding UTF8
                Write-Host "Removed foundation import from: $($file.Split('\')[-1])" -ForegroundColor Yellow
                $fixedCount++
            }
        }
    }
}

Write-Host "Final cleanup completed! Removed $fixedCount redundant foundation imports." -ForegroundColor Green
