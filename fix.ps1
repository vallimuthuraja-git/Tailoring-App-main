$content = Get-Content 'd:/Tailoring-App-main/lib/widgets/catalog/optimized_product_image.dart'
$content = $content[0..73] + $content[115..($content.Length-1)]
$content | Set-Content 'd:/Tailoring-App-main/lib/widgets/catalog/optimized_product_image.dart'