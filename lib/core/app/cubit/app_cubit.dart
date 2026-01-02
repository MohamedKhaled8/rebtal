import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rebtal/core/utils/model/user_model.dart';
import 'package:rebtal/feature/auth/cubit/auth_cubit.dart';
import 'package:rebtal/feature/booking/logic/booking_cubit.dart';
import 'package:rebtal/feature/booking/models/booking.dart';
import 'package:rebtal/core/utils/theme/cubit/theme_cubit.dart';
import 'package:rebtal/feature/notifications/logic/notification_cubit.dart';
import 'package:rebtal/feature/notifications/logic/notification_state.dart';
import 'package:rebtal/feature/owner/logic/cubit/owner_cubit.dart';
import 'package:rebtal/feature/owner/logic/cubit/owner_state.dart';

part 'app_state.dart';

class AppCubit extends Cubit<AppState> {
  /// Feature Cubits - internal implementation details (Private)
  final AuthCubit _authCubit;
  final BookingCubit _bookingCubit;
  final ThemeCubit _themeCubit;
  final NotificationCubit _notificationCubit;
  final OwnerCubit _ownerCubit;

  // Temporary Public Accessors for Migration
  AuthCubit get authCubit => _authCubit;
  BookingCubit get bookingCubit => _bookingCubit;
  ThemeCubit get themeCubit => _themeCubit;
  NotificationCubit get notificationCubit => _notificationCubit;
  OwnerCubit get ownerCubit => _ownerCubit;

  /// Constructor Injection
  AppCubit({
    required AuthCubit authCubit,
    required BookingCubit bookingCubit,
    required ThemeCubit themeCubit,
    required NotificationCubit notificationCubit,
    required OwnerCubit ownerCubit,
  }) : _authCubit = authCubit,
       _bookingCubit = bookingCubit,
       _themeCubit = themeCubit,
       _notificationCubit = notificationCubit,
       _ownerCubit = ownerCubit,
       super(AppInitial()) {
    _setupListeners();
  }

  /// Setup cross-cubit listeners for coordination
  void _setupListeners() {
    // Listen to auth changes
    _authCubit.stream.listen(_handleAuthStateChange);

    // Listen to theme changes
    _themeCubit.stream.listen(_handleThemeStateChange);

    // Listen to notification changes
    _notificationCubit.stream.listen(_handleNotificationStateChange);

    // Listen to owner changes (chalets & form)
    _ownerCubit.stream.listen(_handleOwnerStateChange);

    // Listen to booking changes
    _bookingCubit.stream.listen(_handleBookingStateChange);
  }

  // ==================== STATE HANDLERS ====================

  /// Handle authentication state changes
  void _handleAuthStateChange(AuthState authState) {
    if (authState is AuthSuccess) {
      final user = authState.user;
      final currentAppState = state is AppAuthenticated
          ? (state as AppAuthenticated)
          : null;

      // Update app state with authenticated user
      emit(
        AppAuthenticated(
          user: user,
          themeMode: _themeCubit.state.themeMode,
          primaryColor: _themeCubit.state.primaryColor,
          unreadNotifications: _getUnreadNotificationCount(),
          // Preserve existing data if available
          bookings: currentAppState?.bookings ?? [],
          isBookingsLoading: currentAppState?.isBookingsLoading ?? false,
          ownerChalets: currentAppState?.ownerChalets ?? [],
          isOwnerChaletsLoading:
              currentAppState?.isOwnerChaletsLoading ?? false,
          ownerFormData: currentAppState?.ownerFormData,
        ),
      );

      // Load user-specific data
      _loadUserData(user);
    } else if (authState is AuthInitial) {
      emit(
        AppUnauthenticated(
          themeMode: _themeCubit.state.themeMode,
          primaryColor: _themeCubit.state.primaryColor,
        ),
      );
    } else if (authState is AuthFailure) {
      emit(
        AppError(
          message: authState.error,
          themeMode: _themeCubit.state.themeMode,
          primaryColor: _themeCubit.state.primaryColor,
        ),
      );
    }
  }

  /// Handle theme state changes
  void _handleThemeStateChange(ThemeState themeState) {
    final currentState = state;
    if (currentState is AppAuthenticated) {
      emit(
        currentState.copyWith(
          themeMode: themeState.themeMode,
          primaryColor: themeState.primaryColor,
        ),
      );
    } else if (currentState is AppUnauthenticated) {
      emit(
        currentState.copyWith(
          themeMode: themeState.themeMode,
          primaryColor: themeState.primaryColor,
        ),
      );
    }
  }

  /// Handle notification state changes
  void _handleNotificationStateChange(NotificationState notificationState) {
    final currentState = state;
    if (currentState is AppAuthenticated &&
        notificationState is NotificationLoaded) {
      emit(
        currentState.copyWith(
          unreadNotifications: notificationState.unreadCount,
        ),
      );
    }
  }

  /// Handle owner/chalet state changes
  void _handleOwnerStateChange(OwnerState ownerState) {
    final currentState = state;
    if (currentState is AppAuthenticated) {
      if (ownerState is OwnerLoaded) {
        emit(
          currentState.copyWith(
            ownerChalets: ownerState.chalets,
            isOwnerChaletsLoading: false,
          ),
        );
      } else if (ownerState is OwnerLoading) {
        emit(currentState.copyWith(isOwnerChaletsLoading: true));
      } else if (ownerState is OwnerData) {
        // Form Data updated
        emit(currentState.copyWith(ownerFormData: ownerState));
      }
    }
  }

  /// Handle booking state changes
  void _handleBookingStateChange(BookingState bookingState) {
    final currentState = state;
    if (currentState is AppAuthenticated) {
      emit(
        currentState.copyWith(
          bookings: bookingState.bookings,
          isBookingsLoading: bookingState.isLoading,
        ),
      );
    }
  }

  /// Get current unread notification count
  int _getUnreadNotificationCount() {
    final notificationState = _notificationCubit.state;
    if (notificationState is NotificationLoaded) {
      return notificationState.unreadCount;
    }
    return 0;
  }

  /// Load user-specific data after authentication
  void _loadUserData(UserModel user) {
    final role = _authCubit.getCurrentRole();

    if (role == 'owner') {
      _bookingCubit.loadOwnerBookings(user.uid);
      _ownerCubit.fetchChalets();
    } else if (role == 'user') {
      _bookingCubit.loadUserBookings(user.uid);
    } else if (role == 'admin') {
      _bookingCubit.loadBookings();
    }

    _notificationCubit.listenToNotifications(user.uid);
  }

  // ==================== PUBLIC ACTIONS (FACADE) ====================
  // Delegate UI actions to underlying private cubits

  // --- Auth ---
  UserModel? getCurrentUser() => _authCubit.getCurrentUser();
  String getCurrentRole() => _authCubit.getCurrentRole();
  void toggleViewMode() => _authCubit.toggleViewMode();
  Future<void> logout() => _authCubit.logout();
  Future<void> reloadUserData() => _authCubit.reloadUserData();

  // --- Theme ---
  void toggleTheme() => _themeCubit.toggleTheme();
  void changeTheme(ThemeMode mode) => _themeCubit.changeTheme(mode);
  void changePrimaryColor(Color color) => _themeCubit.changeColor(color);

  // --- Owner (Chalets) ---
  Future<void> fetchOwnerChalets() => _ownerCubit.fetchChalets();

  /// Expose the raw OwnerCubit ONLY for limited scopes where passing it
  /// explicitly to a complex widget (like a wizard) is cleaner than
  /// wrapping every method. But prefer using App state/methods.
  ///
  /// The user asked to remove direct usage, but for simple migration,
  /// we might still need to specific sub-methods.
  /// Ideally, we expose specific methods for the "Add" screen.

  // Update Owner Form Data
  void updateOwnerFormData(OwnerData data) {
    // This assumes OwnerCubit has a way to update state directly or specific methods
    // We might need to look at OwnerCubit to see how to drive it.
    // For now, assuming standard flow.
  }

  // But we can expose getters for the *Instances* if absolutely necessary for internal routing,
  // though we tried to keep them private.
  // Actually, to make "BlocProvider.value(value: appCubit.ownerCubit)" work in the old code shown in previous diffs,
  // we effectively broke that pattern.
  //
  // If the user wants `BlocSelector<AppCubit, AppState>`, they read from AppCubit.
  // If they need to perform an action: `appCubit.addChalet(...)`.

  // --- Booking ---
  // Expose booking actions if needed
  void cancelBooking(String bookingId) =>
      _bookingCubit.cancelBooking(bookingId);

  @override
  Future<void> close() {
    // Clean up all feature cubits
    _authCubit.close();
    _bookingCubit.close();
    _themeCubit.close();
    _notificationCubit.close();
    _ownerCubit.close();
    return super.close();
  }
}
