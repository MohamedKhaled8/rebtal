# Application Architecture Documentation

## Single BlocProvider Architecture with AppCubit

### Overview

This application uses a **single `BlocProvider`** in `main.dart` that provides `AppCubit` - an application-level state coordinator. This architecture eliminates the need for `MultiBlocProvider` while maintaining Clean Architecture principles.

---

## Why This Is NOT an Anti-Pattern

### 1. **AppCubit is a Coordinator, Not a God Object**

`AppCubit` does NOT contain all business logic. Instead, it:
- Manages **application-level state** (authentication session, theme, global notifications)
- **Coordinates** feature cubits without implementing their business logic
- Delegates domain-specific operations to feature cubits

**Analogy**: Think of `AppCubit` as an orchestra conductor. It coordinates when instruments (feature cubits) play, but doesn't play the instruments itself.

### 2. **Separation of Concerns**

```
┌─────────────────────────────────────────────────────────┐
│                      AppCubit                           │
│  Responsibility: Application State & Coordination      │
│  - Auth session management                              │
│  - Theme coordination                                   │
│  - Global notification count                            │
│  - Feature cubit lifecycle                              │
└─────────────────────────────────────────────────────────┘
                          │
        ┌─────────────────┼─────────────────┬──────────────┐
        ▼                 ▼                 ▼              ▼
   ┌─────────┐      ┌──────────┐     ┌────────┐    ┌──────────┐
   │AuthCubit│      │BookingCubit│   │ThemeCubit│  │NotificationCubit│
   │         │      │            │   │          │  │                 │
   │Business │      │Business    │   │Business  │  │Business         │
   │Logic    │      │Logic       │   │Logic     │  │Logic            │
   └─────────┘      └──────────┘     └────────┘    └──────────┘
```

Each cubit has a **single, well-defined responsibility**:
- **AuthCubit**: User authentication, session management
- **BookingCubit**: Booking CRUD operations, business rules
- **ThemeCubit**: Theme persistence and management
- **NotificationCubit**: Notification CRUD, read/unread state
- **AppCubit**: Coordinate the above + manage app-level state

### 3. **Clean Architecture Compliance**

```
┌──────────────────────────────────────────────────────┐
│              Presentation Layer                      │
│  ┌────────────┐  ┌──────────────────────────────┐   │
│  │   UI       │  │  State Management            │   │
│  │  Widgets   │◄─┤  - AppCubit (Coordinator)    │   │
│  │            │  │  - Feature Cubits            │   │
│  └────────────┘  └──────────────────────────────┘   │
└──────────────────────────────────────────────────────┘
                          │
┌──────────────────────────────────────────────────────┐
│              Domain Layer                            │
│  ┌──────────────┐  ┌──────────────────────────┐     │
│  │  Use Cases   │  │  Entities/Models         │     │
│  │  (Business   │  │  (UserModel, Booking)    │     │
│  │   Logic)     │  │                          │     │
│  └──────────────┘  └──────────────────────────┘     │
└──────────────────────────────────────────────────────┘
                          │
┌──────────────────────────────────────────────────────┐
│              Data Layer                              │
│  ┌──────────────┐  ┌──────────────────────────┐     │
│  │ Repositories │  │  Data Sources            │     │
│  │              │  │  (Firebase, Local)       │     │
│  └──────────────┘  └──────────────────────────┘     │
└──────────────────────────────────────────────────────┘
```

**AppCubit sits in the Presentation Layer** and does NOT violate layer boundaries.

### 4. **Follows Established Patterns**

This architecture implements the **Coordinator Pattern** (also called Mediator Pattern):
- Common in iOS development (Coordinator pattern)
- Used in Redux (single store)
- Similar to Riverpod's ProviderScope
- Aligns with BLoC's own recommendations for app-level state

---

## Architecture Components

### 1. AppCubit (`lib/core/app/cubit/app_cubit.dart`)

**Purpose**: Application state coordinator

**Responsibilities**:
- Initialize and manage feature cubits lifecycle
- Listen to feature cubit state changes
- Coordinate cross-cutting concerns (e.g., load user data after login)
- Provide unified app state (authenticated/unauthenticated)
- Expose convenience methods for common operations

**Key Methods**:
```dart
// Public API
UserModel? getCurrentUser()
String getCurrentRole()
void toggleTheme()
void changeTheme(ThemeMode mode)
void changePrimaryColor(Color color)
Future<void> logout()
Future<void> reloadUserData()

// Feature Cubit Access
authCubit
bookingCubit
themeCubit
notificationCubit
```

### 2. AppState (`lib/core/app/cubit/app_state.dart`)

**Purpose**: Represent application-level state

**States**:
- `AppInitial`: App is initializing
- `AppUnauthenticated`: No user logged in
- `AppAuthenticated`: User is logged in (includes user data, theme, notification count)
- `AppError`: Application-level error

### 3. Feature Cubits

Feature cubits remain **independent** and are accessed through `AppCubit`:

```dart
// Access via AppCubit
final appCubit = context.read<AppCubit>();
final authCubit = appCubit.authCubit;
final bookingCubit = appCubit.bookingCubit;
```

---

## Lifecycle Management

### Application Startup

```
1. main() initializes Firebase, GetIt, services
2. setupGetIt() registers AppCubit as singleton
3. RebtalApp provides AppCubit via BlocProvider
4. AppCubit constructor:
   a. Initializes all feature cubits
   b. Sets up cross-cubit listeners
   c. AuthCubit checks for existing session
5. AppCubit emits initial state based on auth status
```

### User Login Flow

```
1. User logs in via LoginCubit (feature-specific)
2. LoginCubit calls AuthRepository
3. AuthCubit detects successful login
4. AuthCubit emits AuthSuccess
5. AppCubit listener catches AuthSuccess
6. AppCubit:
   a. Loads user-specific data (bookings, notifications)
   b. Emits AppAuthenticated with user data
7. UI rebuilds based on AppAuthenticated state
```

### User Logout Flow

```
1. UI calls appCubit.logout()
2. AppCubit delegates to authCubit.logout()
3. AuthCubit clears session and emits AuthInitial
4. AppCubit listener catches AuthInitial
5. AppCubit emits AppUnauthenticated
6. UI navigates to login screen
```

### Theme Change Flow

```
1. UI calls appCubit.toggleTheme()
2. AppCubit delegates to themeCubit.toggleTheme()
3. ThemeCubit updates theme and emits new ThemeState
4. AppCubit listener catches ThemeState change
5. AppCubit updates current AppState with new theme
6. MaterialApp rebuilds with new theme
```

---

## How to Use in UI

### Access AppCubit

```dart
// In any widget
final appCubit = context.read<AppCubit>();
```

### Listen to App State

```dart
BlocBuilder<AppCubit, AppState>(
  builder: (context, appState) {
    if (appState is AppAuthenticated) {
      return Text('Welcome ${appState.user.name}');
    }
    return const Text('Please login');
  },
)
```

### Access Feature Cubits

```dart
// Get the cubit
final authCubit = context.read<AppCubit>().authCubit;

// Listen to its state
BlocBuilder(
  bloc: authCubit,
  builder: (context, authState) {
    // Handle auth state
  },
)
```

### Call App-Level Methods

```dart
// Toggle theme
context.read<AppCubit>().toggleTheme();

// Logout
context.read<AppCubit>().logout();

// Get current user
final user = context.read<AppCubit>().getCurrentUser();
```

---

## Migration from MultiBlocProvider

### Before (Old Code)

```dart
// In rebtal_app.dart
MultiBlocProvider(
  providers: [
    BlocProvider(create: (context) => AuthCubit(getIt())),
    BlocProvider(create: (context) => BookingCubit()),
    BlocProvider(create: (context) => ThemeCubit()),
    BlocProvider(create: (context) => NotificationCubit()),
  ],
  child: MaterialApp(...),
)

// In UI
final authCubit = context.read<AuthCubit>();
BlocBuilder<AuthCubit, AuthState>(...)
```

### After (New Code)

```dart
// In rebtal_app.dart
BlocProvider<AppCubit>(
  create: (context) => getIt<AppCubit>(),
  child: MaterialApp(...),
)

// In UI
final authCubit = context.read<AppCubit>().authCubit;
BlocBuilder(bloc: authCubit, ...)

// OR for app-level state
BlocBuilder<AppCubit, AppState>(...)
```

---

## Benefits of This Architecture

### ✅ Single Source of Truth
- One place to understand app-level state
- Easier debugging (single cubit to inspect)
- Centralized coordination logic

### ✅ Better Testability
- Mock AppCubit to test entire app state
- Test feature cubits independently
- Test coordination logic in isolation

### ✅ Improved Performance
- Fewer BlocProviders in widget tree
- More granular rebuilds (only what's needed)
- Better memory management (centralized lifecycle)

### ✅ Cleaner Code
- No MultiBlocProvider boilerplate
- Clear separation of app vs feature state
- Explicit dependencies

### ✅ Scalability
- Easy to add new feature cubits
- Coordination logic in one place
- No provider tree depth issues

---

## Trade-offs

### ⚠️ Slightly More Verbose Access
- **Before**: `context.read<AuthCubit>()`
- **After**: `context.read<AppCubit>().authCubit`

**Mitigation**: Create extension methods if needed:
```dart
extension AppCubitX on BuildContext {
  AuthCubit get authCubit => read<AppCubit>().authCubit;
}
```

### ⚠️ AppCubit Knows About All Features
- AppCubit imports all feature cubits
- Changes to feature cubits may require AppCubit updates

**Mitigation**: This is acceptable because:
- AppCubit is at the app level (highest layer)
- It's the **only** place that knows about all features
- Feature cubits remain independent of each other

---

## Best Practices

### 1. Keep Feature Cubits Independent
❌ **Don't**: Make feature cubits depend on each other
```dart
// BAD
class BookingCubit {
  final AuthCubit authCubit; // ❌ Direct dependency
}
```

✅ **Do**: Let AppCubit coordinate
```dart
// GOOD
class AppCubit {
  void _handleAuthStateChange(AuthState state) {
    if (state is AuthSuccess) {
      bookingCubit.loadUserBookings(state.user.uid);
    }
  }
}
```

### 2. Use AppState for Global UI Concerns
✅ **Do**: Put app-level data in AppState
```dart
class AppAuthenticated extends AppState {
  final UserModel user;
  final int unreadNotifications; // ✅ Global concern
  final ThemeMode themeMode;      // ✅ Global concern
}
```

❌ **Don't**: Put feature-specific data in AppState
```dart
class AppAuthenticated extends AppState {
  final List<Booking> bookings; // ❌ Feature-specific
}
```

### 3. Delegate Business Logic to Feature Cubits
✅ **Do**: Keep AppCubit as coordinator
```dart
class AppCubit {
  Future<void> logout() async {
    await authCubit.logout(); // ✅ Delegates
  }
}
```

❌ **Don't**: Implement business logic in AppCubit
```dart
class AppCubit {
  Future<void> logout() async {
    // ❌ Direct Firebase calls in AppCubit
    await FirebaseAuth.instance.signOut();
  }
}
```

---

## Conclusion

This architecture provides a **clean, scalable, production-ready solution** that:
- Uses **only one BlocProvider** in main.dart
- Maintains **Clean Architecture** principles
- Follows **established design patterns** (Coordinator/Mediator)
- Provides **clear separation of concerns**
- Is **NOT an anti-pattern**

The AppCubit serves as an application-level coordinator, managing global state and feature cubit lifecycle while keeping business logic properly separated in feature cubits.
