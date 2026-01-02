# Quick Reference: Constructor Injection Pattern

## Before vs After

### ❌ Before (using `late`)

```dart
class AppCubit extends Cubit<AppState> {
  late final AuthCubit authCubit;
  late final BookingCubit bookingCubit;
  late final ThemeCubit themeCubit;
  late final NotificationCubit notificationCubit;

  AppCubit() : super(AppInitial()) {
    _initializeFeatureCubits();
    _setupListeners();
  }

  void _initializeFeatureCubits() {
    authCubit = AuthCubit(getIt());
    bookingCubit = BookingCubit();
    themeCubit = ThemeCubit();
    notificationCubit = NotificationCubit();
  }
}
```

**Problems**:
- ❌ No compile-time safety
- ❌ Hidden dependencies
- ❌ Can forget initialization
- ❌ Hard to test
- ❌ Violates Dependency Inversion

---

### ✅ After (Constructor Injection)

```dart
class AppCubit extends Cubit<AppState> {
  final AuthCubit authCubit;
  final BookingCubit bookingCubit;
  final ThemeCubit themeCubit;
  final NotificationCubit notificationCubit;

  AppCubit({
    required this.authCubit,
    required this.bookingCubit,
    required this.themeCubit,
    required this.notificationCubit,
  }) : super(AppInitial()) {
    _setupListeners();
  }
}
```

**Benefits**:
- ✅ Compile-time safety
- ✅ Explicit dependencies
- ✅ Immutable
- ✅ Easy to test
- ✅ Follows Clean Architecture

---

## GetIt Configuration

### ❌ Before

```dart
Future<void> setupGetIt() async {
  // ... other registrations ...
  
  getIt.registerLazySingleton<AppCubit>(() => AppCubit());
}
```

---

### ✅ After

```dart
Future<void> setupGetIt() async {
  // ... other registrations ...
  
  // Register feature cubits
  getIt.registerLazySingleton<AuthCubit>(
    () => AuthCubit(getIt<BaseAuthRepository>()),
  );
  getIt.registerLazySingleton<BookingCubit>(() => BookingCubit());
  getIt.registerLazySingleton<ThemeCubit>(() => ThemeCubit());
  getIt.registerLazySingleton<NotificationCubit>(() => NotificationCubit());
  
  // Register AppCubit with injected dependencies
  getIt.registerLazySingleton<AppCubit>(
    () => AppCubit(
      authCubit: getIt<AuthCubit>(),
      bookingCubit: getIt<BookingCubit>(),
      themeCubit: getIt<ThemeCubit>(),
      notificationCubit: getIt<NotificationCubit>(),
    ),
  );
}
```

---

## Testing

### ❌ Before (Hard to Test)

```dart
test('AppCubit test', () {
  // Problem: AppCubit creates its own dependencies
  final appCubit = AppCubit();
  
  // Can't inject mocks!
  // authCubit is created internally
});
```

---

### ✅ After (Easy to Test)

```dart
test('AppCubit test', () {
  // Create mocks
  final mockAuthCubit = MockAuthCubit();
  final mockBookingCubit = MockBookingCubit();
  final mockThemeCubit = MockThemeCubit();
  final mockNotificationCubit = MockNotificationCubit();
  
  // Inject mocks
  final appCubit = AppCubit(
    authCubit: mockAuthCubit,
    bookingCubit: mockBookingCubit,
    themeCubit: mockThemeCubit,
    notificationCubit: mockNotificationCubit,
  );
  
  // ✅ All dependencies are mocks!
  verify(() => mockAuthCubit.someMethod()).called(1);
});
```

---

## Key Principles

### 1. Dependencies are Explicit

```dart
// ✅ Clear what AppCubit needs
AppCubit({
  required this.authCubit,     // ← Visible
  required this.bookingCubit,  // ← Visible
})
```

### 2. Dependencies are Immutable

```dart
// ✅ Cannot be changed after construction
final AuthCubit authCubit;  // final, not late final
```

### 3. Fail Fast

```dart
// ✅ Error at construction, not at first use
final appCubit = AppCubit(
  authCubit: null,  // ❌ Compiler error immediately!
);
```

### 4. Composition Root

```dart
// ✅ Only one place creates and wires dependencies
setupGetIt() {
  // Create all dependencies here
  // Wire them together here
  // Nowhere else!
}
```

---

## Common Mistakes to Avoid

### ❌ Mistake 1: Using `late`

```dart
// ❌ DON'T
late final AuthCubit authCubit;
```

### ❌ Mistake 2: Service Locator in Cubit

```dart
// ❌ DON'T
class AppCubit {
  AppCubit() {
    final authCubit = getIt<AuthCubit>();  // ❌ Tight coupling
  }
}
```

### ❌ Mistake 3: Creating Dependencies Inside Cubit

```dart
// ❌ DON'T
class AppCubit {
  AppCubit() {
    final authCubit = AuthCubit(getIt());  // ❌ AppCubit shouldn't create
  }
}
```

### ✅ Correct: Constructor Injection

```dart
// ✅ DO
class AppCubit {
  final AuthCubit authCubit;
  
  AppCubit({required this.authCubit});  // ✅ Injected
}
```

---

## Checklist

- [ ] All dependencies are `final` (not `late final`)
- [ ] All dependencies are injected via constructor
- [ ] Constructor parameters are `required`
- [ ] No `getIt` calls inside AppCubit
- [ ] No dependency creation inside AppCubit
- [ ] All dependencies registered in `setupGetIt()`
- [ ] AppCubit registered with injected dependencies
- [ ] Tests inject mocks via constructor

---

## Summary

**Golden Rule**: Dependencies should be **explicit, immutable, and injected at construction time**.

**Why?**
- ✅ Compile-time safety
- ✅ Easy testing
- ✅ Clear ownership
- ✅ Follows Clean Architecture
- ✅ Fail Fast principle

**Remember**: The Composition Root (`setupGetIt()`) is the ONLY place that creates and wires dependencies. Everywhere else receives them via constructor injection.
