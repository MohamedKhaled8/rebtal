# AppCubit Aggregation Migration Guide

This guide outlines the steps to migrate the Application to the new `AppCubit` Aggregation Architecture.

## Core Concept
We are moving from "Multiple Feature Providers" (MultiBlocProvider) to a "Single Centralized Provider" (AppCubit).
All global state is now managed by `AppCubit`'s `AppState`.

## Migration Steps

### 1. Update UI Consumption
Replace all direct access to feature Cubits (`BookingCubit`, `OwnerCubit`, etc.) with `AppCubit`.

**Pattern:**
```dart
// OLD
BlocBuilder<BookingCubit, BookingState>(
  builder: (context, state) { ... }
)
context.read<BookingCubit>().someMethod();

// NEW
BlocBuilder<AppCubit, AppState>(
  buildWhen: (prev, curr) => curr.bookings != prev.bookings, // Specific selector
  builder: (context, state) {
    if (state is! AppAuthenticated) return Loading();
    // Use state.bookings
  }
)
context.read<AppCubit>().bookingCubit.someMethod(); // Accessor or Facade
```

### 2. Refactor Feature Screens
Systematically go through each feature folder and update the main screens.

#### Auth & Onboarding
- Ensure `AuthCubit` is only accessed via `AppCubit` interaction.
- Login/Register screens should dispatch events that `AppCubit` listens to (already wired).

#### Booking
- **UserBookingsPage**: Update to use `BlocBuilder<AppCubit, AppState>` and `state.bookings`.
- **BookingDetails**: Access booking data passed from list or select from `AppCubit`.

#### Owner
- **OwnerChaletsPage**: Use `state.ownerChalets`.
- **AddChaletScreen**: Use `state.ownerFormData`.

### 3. Clean Up
Once all UI components are migrated:
1. Remove `MultiBlocProvider` usage in `main.dart` (Already done).
2. Make `AppCubit` getters private (remove the temporary public getters added in `app_cubit.dart`).
3. Ensure all feature Cubits are strictly private and only exposed via `AppCubit` facade methods or State.

## Troubleshooting

- **"Could not find the correct Provider<X>..."**: This means a widget is trying to find `X` (e.g., `OwnerCubit`) in the widget tree. replace `context.read<X>()` with `context.read<AppCubit>().x`.
- **State not updating**: Ensure `AppCubit` is correctly listening to the feature cubit stream in `_setupListeners()`.

## Status
- [x] AppCubit Refactored
- [x] AppState Expanded
- [x] Main.dart / RebtalApp Configured
- [x] OwnerChaletsPage Refactored
- [x] AddChaletScreen Refactored
- [x] UserBookingsPage Refactored
