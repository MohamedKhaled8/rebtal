# Visual Architecture Diagram

## Before: MultiBlocProvider Architecture

```
┌──────────────────────────────────────────────────────────────┐
│                        main.dart                             │
│                                                              │
│  runApp(RebtalApp())                                         │
└──────────────────────────────────────────────────────────────┘
                            │
                            ▼
┌──────────────────────────────────────────────────────────────┐
│                     rebtal_app.dart                          │
│                                                              │
│  MultiBlocProvider(                                          │
│    providers: [                                              │
│      BlocProvider(create: (_) => AuthCubit()),       ◄────┐  │
│      BlocProvider(create: (_) => BookingCubit()),    ◄────┤  │
│      BlocProvider(create: (_) => ThemeCubit()),      ◄────┤  │
│      BlocProvider(create: (_) => NotificationCubit()),◄────┤  │
│    ],                                                       │  │
│  )                                                          │  │
└──────────────────────────────────────────────────────────────┘
                            │                                 │
                            ▼                                 │
┌──────────────────────────────────────────────────────────────┐
│                      UI Widgets                              │
│                                                              │
│  context.read<AuthCubit>()          ─────────────────────────┘
│  context.read<BookingCubit>()       ─────────────────────────┐
│  context.read<ThemeCubit>()         ─────────────────────────┤
│  context.read<NotificationCubit>()  ─────────────────────────┘
│                                                              │
│  Problem: 4 separate providers, no coordination             │
└──────────────────────────────────────────────────────────────┘
```

---

## After: Single AppCubit Architecture

```
┌──────────────────────────────────────────────────────────────┐
│                        main.dart                             │
│                                                              │
│  setupGetIt() ──► Registers AppCubit as Singleton            │
│  runApp(RebtalApp())                                         │
└──────────────────────────────────────────────────────────────┘
                            │
                            ▼
┌──────────────────────────────────────────────────────────────┐
│                     rebtal_app.dart                          │
│                                                              │
│  BlocProvider<AppCubit>(                                     │
│    create: (_) => getIt<AppCubit>(),  ◄── SINGLE PROVIDER    │
│  )                                                           │
└──────────────────────────────────────────────────────────────┘
                            │
                            ▼
┌──────────────────────────────────────────────────────────────┐
│                       AppCubit                               │
│                  (Application Coordinator)                   │
│                                                              │
│  ┌────────────────────────────────────────────────────┐     │
│  │  Manages:                                          │     │
│  │  • authCubit         ──► Authentication           │     │
│  │  • bookingCubit      ──► Bookings                 │     │
│  │  • themeCubit        ──► Theme                    │     │
│  │  • notificationCubit ──► Notifications            │     │
│  └────────────────────────────────────────────────────┘     │
│                                                              │
│  ┌────────────────────────────────────────────────────┐     │
│  │  Coordinates:                                      │     │
│  │  • Login → Load bookings & notifications          │     │
│  │  • Logout → Clear all data                        │     │
│  │  • Theme changes → Update app state               │     │
│  └────────────────────────────────────────────────────┘     │
│                                                              │
│  ┌────────────────────────────────────────────────────┐     │
│  │  Provides:                                         │     │
│  │  • AppState (Authenticated/Unauthenticated)       │     │
│  │  • Unified access to all cubits                   │     │
│  │  • Convenience methods (logout, toggleTheme)      │     │
│  └────────────────────────────────────────────────────┘     │
└──────────────────────────────────────────────────────────────┘
                            │
                            ▼
┌──────────────────────────────────────────────────────────────┐
│                      UI Widgets                              │
│                                                              │
│  // Access AppCubit                                          │
│  final appCubit = context.read<AppCubit>();                  │
│                                                              │
│  // Access feature cubits                                    │
│  final authCubit = appCubit.authCubit;                       │
│  final bookingCubit = appCubit.bookingCubit;                 │
│                                                              │
│  // Or use extensions                                        │
│  final authCubit = context.authCubit;                        │
│                                                              │
│  Benefits: Single provider, coordinated state               │
└──────────────────────────────────────────────────────────────┘
```

---

## State Flow Diagram

### Login Flow

```
┌─────────────┐
│   User      │
│   Logs In   │
└──────┬──────┘
       │
       ▼
┌─────────────────────────────────────────────────────────┐
│  LoginCubit.login()                                     │
│  (Feature-specific business logic)                      │
└──────┬──────────────────────────────────────────────────┘
       │
       ▼
┌─────────────────────────────────────────────────────────┐
│  AuthRepository.login()                                 │
│  (Data layer - Firebase Auth)                           │
└──────┬──────────────────────────────────────────────────┘
       │
       ▼
┌─────────────────────────────────────────────────────────┐
│  AuthCubit emits AuthSuccess(user)                      │
└──────┬──────────────────────────────────────────────────┘
       │
       ▼
┌─────────────────────────────────────────────────────────┐
│  AppCubit listener catches AuthSuccess                  │
│                                                         │
│  AppCubit._handleAuthStateChange() {                    │
│    1. Load user bookings                               │
│    2. Load user notifications                          │
│    3. Emit AppAuthenticated(user, theme, notifications)│
│  }                                                      │
└──────┬──────────────────────────────────────────────────┘
       │
       ▼
┌─────────────────────────────────────────────────────────┐
│  UI rebuilds with AppAuthenticated state                │
│  • Shows user name                                      │
│  • Shows notification badge                             │
│  • Applies user's theme                                 │
│  • Displays bookings                                    │
└─────────────────────────────────────────────────────────┘
```

### Theme Change Flow

```
┌─────────────┐
│   User      │
│   Toggles   │
│   Theme     │
└──────┬──────┘
       │
       ▼
┌─────────────────────────────────────────────────────────┐
│  appCubit.toggleTheme()                                 │
└──────┬──────────────────────────────────────────────────┘
       │
       ▼
┌─────────────────────────────────────────────────────────┐
│  themeCubit.toggleTheme()                               │
│  (Updates theme in SharedPreferences)                   │
└──────┬──────────────────────────────────────────────────┘
       │
       ▼
┌─────────────────────────────────────────────────────────┐
│  ThemeCubit emits ThemeState(newMode)                   │
└──────┬──────────────────────────────────────────────────┘
       │
       ▼
┌─────────────────────────────────────────────────────────┐
│  AppCubit listener catches ThemeState                   │
│                                                         │
│  AppCubit._handleThemeStateChange() {                   │
│    Update current AppState with new theme              │
│  }                                                      │
└──────┬──────────────────────────────────────────────────┘
       │
       ▼
┌─────────────────────────────────────────────────────────┐
│  MaterialApp rebuilds with new theme                    │
│  • Dark/Light mode applied                              │
│  • All widgets update automatically                     │
└─────────────────────────────────────────────────────────┘
```

---

## Responsibility Boundaries

```
┌───────────────────────────────────────────────────────────────┐
│                    AppCubit Responsibilities                  │
│  ✅ Application lifecycle management                          │
│  ✅ Cross-cubit coordination                                  │
│  ✅ Global app state (authenticated/unauthenticated)          │
│  ✅ Feature cubit initialization                              │
│  ✅ Convenience methods for common operations                 │
│                                                               │
│  ❌ Business logic (belongs in feature cubits)                │
│  ❌ Data fetching (belongs in repositories)                   │
│  ❌ UI rendering (belongs in widgets)                         │
└───────────────────────────────────────────────────────────────┘

┌───────────────────────────────────────────────────────────────┐
│                 Feature Cubit Responsibilities                │
│  ✅ Feature-specific business logic                           │
│  ✅ Feature state management                                  │
│  ✅ Calling repositories/use cases                            │
│  ✅ Emitting feature-specific states                          │
│                                                               │
│  ❌ Knowing about other feature cubits                        │
│  ❌ Application-level coordination                            │
│  ❌ Direct UI manipulation                                    │
└───────────────────────────────────────────────────────────────┘

┌───────────────────────────────────────────────────────────────┐
│                      UI Responsibilities                      │
│  ✅ Rendering widgets                                         │
│  ✅ Listening to state changes                                │
│  ✅ Calling cubit methods                                     │
│  ✅ User interaction handling                                 │
│                                                               │
│  ❌ Business logic                                            │
│  ❌ Data fetching                                             │
│  ❌ State management                                          │
└───────────────────────────────────────────────────────────────┘
```

---

## Comparison Table

| Aspect | MultiBlocProvider | Single AppCubit |
|--------|-------------------|-----------------|
| **Providers in main.dart** | 4 separate | 1 single |
| **Coordination** | Manual, scattered | Centralized in AppCubit |
| **Access pattern** | `context.read<FeatureCubit>()` | `context.read<AppCubit>().featureCubit` |
| **Cross-cubit communication** | Complex, requires listeners in UI | Simple, handled in AppCubit |
| **Testing** | Mock each provider separately | Mock single AppCubit |
| **Scalability** | Provider tree grows with features | Single provider, always |
| **Performance** | More providers = deeper tree | Shallow tree, better performance |
| **Complexity** | Low for simple apps | Low for all apps |
| **Maintenance** | Scattered state logic | Centralized coordination |

---

## File Structure

```
lib/
├── core/
│   ├── app/
│   │   ├── cubit/
│   │   │   ├── app_cubit.dart          ◄── Main coordinator
│   │   │   ├── app_state.dart          ◄── App-level states
│   │   │   └── app_cubit_usage_examples.dart
│   │   └── extensions/
│   │       └── context_extensions.dart  ◄── Convenience methods
│   └── utils/
│       └── dependency/
│           └── get_it.dart              ◄── DI registration
├── feature/
│   ├── auth/
│   │   └── cubit/
│   │       └── auth_cubit.dart          ◄── Feature cubit
│   ├── booking/
│   │   └── logic/
│   │       └── booking_cubit.dart       ◄── Feature cubit
│   └── notifications/
│       └── logic/
│           └── notification_cubit.dart  ◄── Feature cubit
├── rebtal_app.dart                      ◄── Single BlocProvider
└── main.dart

Documentation/
├── ARCHITECTURE.md                      ◄── Architecture explanation
├── MIGRATION_GUIDE.md                   ◄── Migration instructions
└── IMPLEMENTATION_SUMMARY.md            ◄── This summary
```

---

## Key Takeaways

1. **AppCubit is a Coordinator**, not a God Object
2. **Feature Cubits remain independent** with single responsibilities
3. **Clean Architecture is maintained** - no layer violations
4. **Follows established patterns** - Coordinator/Mediator pattern
5. **Production-ready** - used in real-world applications
6. **Scalable** - easy to add new features
7. **Testable** - improved test isolation
8. **Performant** - fewer providers, better rebuilds

This architecture provides the **best of both worlds**:
- Simplicity of a single provider
- Separation of concerns of multiple cubits
- Coordination without tight coupling
- Clean Architecture compliance
