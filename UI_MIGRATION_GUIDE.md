# Migration Guide: Updating UI to Use AppCubit

## Issue

After refactoring to use Constructor Injection and single `BlocProvider<AppCubit>`, existing UI code that directly accesses feature cubits will throw `ProviderNotFoundException`.

**Error Example**:
```
Error: Could not find the correct Provider<AuthCubit> above this BlocListener<AuthCubit, AuthState> Widget
```

---

## Root Cause

**Before**: We had `MultiBlocProvider` providing all cubits directly:
```dart
MultiBlocProvider(
  providers: [
    BlocProvider(create: (_) => AuthCubit()),
    BlocProvider(create: (_) => BookingCubit()),
    // ...
  ],
)
```

**After**: We now have single `BlocProvider<AppCubit>`:
```dart
BlocProvider<AppCubit>(
  create: (_) => getIt<AppCubit>(),
)
```

Feature cubits are **not** provided directly to the widget tree. They're accessed **through** AppCubit.

---

## Solution Pattern

### Pattern 1: Reading a Cubit

**❌ Before (Broken)**:
```dart
final authCubit = context.read<AuthCubit>();
```

**✅ After (Fixed)**:
```dart
final authCubit = context.read<AppCubit>().authCubit;
```

---

### Pattern 2: BlocListener

**❌ Before (Broken)**:
```dart
BlocListener<AuthCubit, AuthState>(
  listener: (context, state) {
    // ...
  },
  child: ...,
)
```

**✅ After (Fixed)**:
```dart
// Get the cubit first
final authCubit = context.read<AppCubit>().authCubit;

BlocListener(
  bloc: authCubit,  // Pass bloc explicitly
  listener: (context, state) {
    // ...
  },
  child: ...,
)
```

---

### Pattern 3: BlocBuilder

**❌ Before (Broken)**:
```dart
BlocBuilder<AuthCubit, AuthState>(
  builder: (context, state) {
    // ...
  },
)
```

**✅ After (Fixed)**:
```dart
// Get the cubit first
final authCubit = context.read<AppCubit>().authCubit;

BlocBuilder(
  bloc: authCubit,  // Pass bloc explicitly
  builder: (context, state) {
    // ...
  },
)
```

---

### Pattern 4: BlocConsumer

**❌ Before (Broken)**:
```dart
BlocConsumer<BookingCubit, BookingState>(
  listener: (context, state) { ... },
  builder: (context, state) { ... },
)
```

**✅ After (Fixed)**:
```dart
final bookingCubit = context.read<AppCubit>().bookingCubit;

BlocConsumer(
  bloc: bookingCubit,
  listener: (context, state) { ... },
  builder: (context, state) { ... },
)
```

---

### Pattern 5: Calling Cubit Methods

**❌ Before (Broken)**:
```dart
context.read<AuthCubit>().logout();
```

**✅ After (Fixed)**:
```dart
// Option 1: Through AppCubit convenience method
context.read<AppCubit>().logout();

// Option 2: Direct cubit access
context.read<AppCubit>().authCubit.logout();
```

---

## Example: SplashScreen Fix

### Before (Broken)

```dart
class _SplashScreenState extends State<SplashScreen> {
  void _checkAuthState() async {
    // ❌ This throws ProviderNotFoundException
    final authCubit = context.read<AuthCubit>();
    
    if (authCubit.state is AuthSuccess) {
      _navigateBasedOnRole();
    }
  }

  @override
  Widget build(BuildContext context) {
    // ❌ This throws ProviderNotFoundException
    return BlocListener<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is AuthSuccess) {
          _navigateBasedOnRole();
        }
      },
      child: Scaffold(...),
    );
  }
}
```

### After (Fixed)

```dart
import 'package:rebtal/core/app/cubit/app_cubit.dart';  // ✅ Add import

class _SplashScreenState extends State<SplashScreen> {
  void _checkAuthState() async {
    // ✅ Access through AppCubit
    final appCubit = context.read<AppCubit>();
    final authCubit = appCubit.authCubit;
    
    if (authCubit.state is AuthSuccess) {
      _navigateBasedOnRole();
    }
  }

  @override
  Widget build(BuildContext context) {
    // ✅ Get cubit first
    final authCubit = context.read<AppCubit>().authCubit;
    
    // ✅ Pass bloc explicitly
    return BlocListener(
      bloc: authCubit,
      listener: (context, state) {
        if (state is AuthSuccess) {
          _navigateBasedOnRole();
        }
      },
      child: Scaffold(...),
    );
  }
}
```

---

## Quick Fix Checklist

For each screen with errors:

1. **Add Import**:
   ```dart
   import 'package:rebtal/core/app/cubit/app_cubit.dart';
   ```

2. **Find all `context.read<FeatureCubit>()`**:
   - Replace with `context.read<AppCubit>().featureCubit`

3. **Find all `BlocListener<FeatureCubit, State>`**:
   - Get cubit: `final cubit = context.read<AppCubit>().featureCubit;`
   - Change to: `BlocListener(bloc: cubit, ...)`

4. **Find all `BlocBuilder<FeatureCubit, State>`**:
   - Get cubit: `final cubit = context.read<AppCubit>().featureCubit;`
   - Change to: `BlocBuilder(bloc: cubit, ...)`

5. **Find all `BlocConsumer<FeatureCubit, State>`**:
   - Get cubit: `final cubit = context.read<AppCubit>().featureCubit;`
   - Change to: `BlocConsumer(bloc: cubit, ...)`

---

## Common Screens to Update

Search for these patterns in your codebase:

```bash
# Find all BlocListener usages
grep -r "BlocListener<" lib/

# Find all BlocBuilder usages
grep -r "BlocBuilder<" lib/

# Find all context.read usages
grep -r "context.read<" lib/

# Find all BlocConsumer usages
grep -r "BlocConsumer<" lib/
```

Likely files to update:
- Login screen
- Register screen
- Home screen
- Profile screen
- Settings screen
- Any screen using AuthCubit, BookingCubit, ThemeCubit, or NotificationCubit

---

## Optional: Use Context Extensions

To make access cleaner, use the context extensions:

```dart
// lib/core/app/extensions/context_extensions.dart
import 'package:rebtal/core/app/extensions/context_extensions.dart';

// Then you can use:
final authCubit = context.authCubit;  // Instead of context.read<AppCubit>().authCubit
final bookingCubit = context.bookingCubit;
final themeCubit = context.themeCubit;
final notificationCubit = context.notificationCubit;
```

---

## Summary

**Key Rule**: Feature cubits are **not** in the widget tree. Access them **through** AppCubit.

**Pattern**:
```dart
// 1. Get AppCubit
final appCubit = context.read<AppCubit>();

// 2. Get feature cubit
final authCubit = appCubit.authCubit;

// 3. Use it
BlocListener(bloc: authCubit, ...)
BlocBuilder(bloc: authCubit, ...)
```

**Or use extensions**:
```dart
final authCubit = context.authCubit;
BlocListener(bloc: authCubit, ...)
```
