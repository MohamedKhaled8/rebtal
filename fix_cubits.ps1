# Automated Cubit Migration Script
# This script fixes all context.read<FeatureCubit>() calls to use AppCubit

Write-Host "Starting automated cubit migration..." -ForegroundColor Cyan
Write-Host "This will update all .dart files in the lib directory" -ForegroundColor Yellow
Write-Host ""

$libPath = Join-Path $PSScriptRoot "lib"
$files = Get-ChildItem -Path $libPath -Recurse -Filter "*.dart"
$totalFiles = $files.Count
$modifiedFiles = 0
$currentFile = 0

foreach ($file in $files) {
    $currentFile++
    Write-Progress -Activity "Processing files" -Status "$currentFile of $totalFiles" -PercentComplete (($currentFile / $totalFiles) * 100)
    
    $content = Get-Content $file.FullName -Raw
    $originalContent = $content
    $modified = $false
    
    # Skip if file already uses AppCubit correctly or is AppCubit itself
    if ($file.Name -eq "app_cubit.dart") {
        continue
    }
    
    # Check if file needs AppCubit import
    $needsImport = $false
    if ($content -match "context\.read<(AuthCubit|BookingCubit|ThemeCubit|NotificationCubit)>") {
        $needsImport = $true
    }
    
    # Add AppCubit import if needed and not present
    if ($needsImport -and $content -notmatch "import 'package:rebtal/core/app/cubit/app_cubit.dart'") {
        # Find the last import statement
        if ($content -match "(?s)(import '[^']+';)(?!.*import)") {
            $lastImport = $matches[1]
            $content = $content -replace [regex]::Escape($lastImport), "$lastImport`nimport 'package:rebtal/core/app/cubit/app_cubit.dart';"
            $modified = $true
        }
    }
    
    # Replace context.read<AuthCubit>() with context.read<AppCubit>().authCubit
    if ($content -match "context\.read<AuthCubit>\(\)") {
        $content = $content -replace "context\.read<AuthCubit>\(\)", "context.read<AppCubit>().authCubit"
        $modified = $true
    }
    
    # Replace context.read<BookingCubit>() with context.read<AppCubit>().bookingCubit
    if ($content -match "context\.read<BookingCubit>\(\)") {
        $content = $content -replace "context\.read<BookingCubit>\(\)", "context.read<AppCubit>().bookingCubit"
        $modified = $true
    }
    
    # Replace context.read<ThemeCubit>() with context.read<AppCubit>().themeCubit
    if ($content -match "context\.read<ThemeCubit>\(\)") {
        $content = $content -replace "context\.read<ThemeCubit>\(\)", "context.read<AppCubit>().themeCubit"
        $modified = $true
    }
    
    # Replace context.read<NotificationCubit>() with context.read<AppCubit>().notificationCubit
    if ($content -match "context\.read<NotificationCubit>\(\)") {
        $content = $content -replace "context\.read<NotificationCubit>\(\)", "context.read<AppCubit>().notificationCubit"
        $modified = $true
    }
    
    # Save if modified
    if ($modified) {
        Set-Content -Path $file.FullName -Value $content -NoNewline
        $modifiedFiles++
        $relativePath = $file.FullName.Replace($libPath, "lib")
        Write-Host "✓ Fixed: $relativePath" -ForegroundColor Green
    }
}

Write-Progress -Activity "Processing files" -Completed

Write-Host ""
Write-Host "Migration complete!" -ForegroundColor Green
Write-Host "Modified $modifiedFiles out of $totalFiles files" -ForegroundColor Cyan
Write-Host ""
Write-Host "IMPORTANT: You still need to manually fix:" -ForegroundColor Yellow
Write-Host "  - BlocBuilder<FeatureCubit, State> instances" -ForegroundColor Yellow
Write-Host "  - BlocListener<FeatureCubit, State> instances" -ForegroundColor Yellow
Write-Host "  - BlocConsumer<FeatureCubit, State> instances" -ForegroundColor Yellow
Write-Host ""
Write-Host "See UI_MIGRATION_GUIDE.md for patterns" -ForegroundColor Cyan
