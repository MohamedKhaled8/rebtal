# Automated Migration Script

## PowerShell Script to Fix All Files

Save this as `fix_cubits.ps1` and run it:

```powershell
# Get all Dart files
$files = Get-ChildItem -Path "lib" -Recurse -Filter "*.dart"

foreach ($file in $files) {
    $content = Get-Content $file.FullName -Raw
    $modified = $false
    
    # Check if file needs AppCubit import
    if ($content -match "context\.read<(AuthCubit|BookingCubit|ThemeCubit|NotificationCubit)>") {
        # Add AppCubit import if not present
        if ($content -notmatch "import 'package:rebtal/core/app/cubit/app_cubit.dart'") {
            $content = $content -replace "(import 'package:flutter_bloc/flutter_bloc.dart';)", "`$1`nimport 'package:rebtal/core/app/cubit/app_cubit.dart';"
            $modified = $true
        }
    }
    
    # Replace context.read<AuthCubit>()
    if ($content -match "context\.read<AuthCubit>\(\)") {
        $content = $content -replace "context\.read<AuthCubit>\(\)", "context.read<AppCubit>().authCubit"
        $modified = $true
    }
    
    # Replace context.read<BookingCubit>()
    if ($content -match "context\.read<BookingCubit>\(\)") {
        $content = $content -replace "context\.read<BookingCubit>\(\)", "context.read<AppCubit>().bookingCubit"
        $modified = $true
    }
    
    # Replace context.read<ThemeCubit>()
    if ($content -match "context\.read<ThemeCubit>\(\)") {
        $content = $content -replace "context\.read<ThemeCubit>\(\)", "context.read<AppCubit>().themeCubit"
        $modified = $true
    }
    
    # Replace context.read<NotificationCubit>()
    if ($content -match "context\.read<NotificationCubit>\(\)") {
        $content = $content -replace "context\.read<NotificationCubit>\(\)", "context.read<AppCubit>().notificationCubit"
        $modified = $true
    }
    
    # Save if modified
    if ($modified) {
        Set-Content -Path $file.FullName -Value $content -NoNewline
        Write-Host "Fixed: $($file.FullName)" -ForegroundColor Green
    }
}

Write-Host "`nDone! Remember to manually fix BlocBuilder/BlocListener instances." -ForegroundColor Yellow
```

## Manual Fixes Still Needed

After running the script, you'll still need to manually fix:

### BlocBuilder instances
```dart
// Find: BlocBuilder<AuthCubit, AuthState>
// Replace with:
final authCubit = context.read<AppCubit>().authCubit;
BlocBuilder(bloc: authCubit, ...)
```

### BlocListener instances
```dart
// Find: BlocListener<AuthCubit, AuthState>
// Replace with:
final authCubit = context.read<AppCubit>().authCubit;
BlocListener(bloc: authCubit, ...)
```

### BlocConsumer instances
```dart
// Find: BlocConsumer<BookingCubit, BookingState>
// Replace with:
final bookingCubit = context.read<AppCubit>().bookingCubit;
BlocConsumer(bloc: bookingCubit, ...)
```

## Or Use Context Extensions

For cleaner code, use the extensions we created:

```dart
// Add this import
import 'package:rebtal/core/app/extensions/context_extensions.dart';

// Then use:
final authCubit = context.authCubit;  // Instead of context.read<AppCubit>().authCubit
final bookingCubit = context.bookingCubit;
```

## Quick Fix for Common Patterns

### Pattern 1: Simple read
```powershell
# Find all: context.read<AuthCubit>()
# Replace: context.read<AppCubit>().authCubit
```

### Pattern 2: BlocProvider.value
```dart
// Old:
BlocProvider.value(
  value: context.read<BookingCubit>(),
  child: ...
)

// New:
BlocProvider.value(
  value: context.read<AppCubit>().bookingCubit,
  child: ...
)
```

