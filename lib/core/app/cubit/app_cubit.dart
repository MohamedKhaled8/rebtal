import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:rebtal/core/utils/model/user_model.dart';
import 'package:rebtal/feature/auth/cubit/auth_cubit.dart';
import 'package:rebtal/feature/booking/logic/booking_cubit.dart';
import 'package:rebtal/feature/booking/models/booking.dart';
import 'package:rebtal/core/utils/theme/cubit/theme_cubit.dart';
import 'package:rebtal/feature/notifications/logic/notification_cubit.dart';
import 'package:rebtal/feature/notifications/logic/notification_state.dart';
import 'package:rebtal/feature/owner/logic/cubit/owner_cubit.dart';
import 'package:rebtal/feature/owner/logic/cubit/owner_state.dart';
import 'package:rebtal/core/utils/network/network_cubit.dart';

part 'app_state.dart';

// ============================================================
// FACADE INTERFACES (SOLID - Interface Segregation Principle)
// ============================================================

abstract interface class AppThemeFacade {
  void toggleTheme({Brightness? platformBrightness});
  void changeTheme(ThemeMode mode);
  void changePrimaryColor(Color color);
}

abstract interface class AppLocaleFacade {
  Future<void> changeLocale(Locale locale);
}

abstract interface class AppAuthFacade {
  UserModel? getCurrentUser();
  String getCurrentRole();
  void toggleViewMode();
  Future<void> logout();
  Future<void> reloadUserData();
  Future<void> updateProfile({
    required String name,
    required String phone,
    String? profileImageUrl,
  });
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  });
  Future<void> updateIdCard(String idCardUrl);
}

abstract interface class AppOwnerFacade {
  Future<void> fetchOwnerChalets();
}

abstract interface class AppBookingFacade {
  void cancelBooking(String bookingId);
}

// ============================================================
// ABSTRACT CUBIT (SOLID - Dependency Inversion Principle)
// ============================================================

abstract class AppCubit extends Cubit<AppState>
    implements AppThemeFacade, AppLocaleFacade, AppAuthFacade, AppOwnerFacade, AppBookingFacade {
  AppCubit(super.initialState);

  /// Accessors for underlying feature cubits (Migration & Backward-Compatibility Layer)
  AuthCubit get authCubit;
  BookingCubit get bookingCubit;
  ThemeCubit get themeCubit;
  NotificationCubit get notificationCubit;
  OwnerCubit get ownerCubit;
  NetworkCubit get networkCubit;
}

// ============================================================
// CONCRETE CUBIT IMPLEMENTATION
// ============================================================

class AppCubitImpl extends AppCubit {
  static const String _localeKey = 'app_locale';

  /// Feature Cubits - internal implementation details (Private)
  final AuthCubit _authCubit;
  final BookingCubit _bookingCubit;
  final ThemeCubit _themeCubit;
  final NotificationCubit _notificationCubit;
  final OwnerCubit _ownerCubit;
  final NetworkCubit _networkCubit;

  @override
  AuthCubit get authCubit => _authCubit;
  @override
  BookingCubit get bookingCubit => _bookingCubit;
  @override
  ThemeCubit get themeCubit => _themeCubit;
  @override
  NotificationCubit get notificationCubit => _notificationCubit;
  @override
  OwnerCubit get ownerCubit => _ownerCubit;
  @override
  NetworkCubit get networkCubit => _networkCubit;

  /// Constructor Injection
  AppCubitImpl({
    required AuthCubit authCubit,
    required BookingCubit bookingCubit,
    required ThemeCubit themeCubit,
    required NotificationCubit notificationCubit,
    required OwnerCubit ownerCubit,
    required NetworkCubit networkCubit,
  }) : _authCubit = authCubit,
       _bookingCubit = bookingCubit,
       _themeCubit = themeCubit,
       _notificationCubit = notificationCubit,
       _ownerCubit = ownerCubit,
       _networkCubit = networkCubit,
       super(
         AppUnauthenticated(
           themeMode: ThemeMode.system,
           primaryColor: const Color(0xFF6200EE),
           locale: const Locale('ar'), // Start with Arabic as default
         ),
       ) {
    _setupListeners();
    _loadLocale();
  }

  Locale _savedLocale = const Locale('ar');
  String? _lastUserDataLoadKey;
  String? _notificationsListenerUid;

  Future<void> _loadLocale() async {
    final prefs = await SharedPreferences.getInstance();
    final savedCode = prefs.getString(_localeKey);
    final locale = savedCode != null ? Locale(savedCode) : const Locale('ar');
    _savedLocale = locale;

    // Only emit if different from current locale
    if (state.locale != locale) {
      _emitWithLocale(locale);
    }
  }

  void _emitWithLocale(Locale locale) {
    emit(state.copyWithLocale(locale));
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
    switch (authState) {
      case AuthSuccess(:final user):
        final currentAppState = state is AppAuthenticated
            ? (state as AppAuthenticated)
            : null;

        // Always preserve existing owner chalets & bookings to avoid flicker.
        final preservedChalets = currentAppState?.ownerChalets ?? [];
        final preservedChaletsLoading =
            currentAppState?.isOwnerChaletsLoading ?? false;

        // Update app state with authenticated user
        emit(
          AppAuthenticated(
            user: user,
            themeMode: _themeCubit.state.themeMode,
            primaryColor: _themeCubit.state.primaryColor,
            locale: _savedLocale,
            unreadNotifications: _getUnreadNotificationCount(),
            // Preserve existing data — never reset to empty mid-session.
            bookings: currentAppState?.bookings ?? [],
            isBookingsLoading: currentAppState?.isBookingsLoading ?? false,
            ownerChalets: preservedChalets,
            isOwnerChaletsLoading: preservedChaletsLoading,
            ownerFormData: currentAppState?.ownerFormData,
          ),
        );

        final viewRole = _authCubit.getCurrentRole();
        final dataKey = '${user.uid}:$viewRole';
        if (_lastUserDataLoadKey != dataKey) {
          _lastUserDataLoadKey = dataKey;
          _loadUserData(user, viewRole);
        }
        if (_notificationsListenerUid != user.uid) {
          _notificationsListenerUid = user.uid;
          _notificationCubit.listenToNotifications(user.uid);
        }

      case AuthGuest():
        _lastUserDataLoadKey = null;
        _notificationsListenerUid = null;
        _ownerCubit.reset();
        _bookingCubit.reset();
        emit(
          AppGuestBrowsing(
            themeMode: _themeCubit.state.themeMode,
            primaryColor: _themeCubit.state.primaryColor,
            locale: _savedLocale,
          ),
        );

      case AuthUnauthenticated() || AuthInitial():
        _lastUserDataLoadKey = null;
        _notificationsListenerUid = null;
        _ownerCubit.reset();
        _bookingCubit.reset();
        emit(
          AppUnauthenticated(
            themeMode: _themeCubit.state.themeMode,
            primaryColor: _themeCubit.state.primaryColor,
            locale: _savedLocale,
          ),
        );

      case AuthFailure(:final error):
        _lastUserDataLoadKey = null;
        _notificationsListenerUid = null;
        _ownerCubit.reset();
        _bookingCubit.reset();
        emit(
          AppError(
            message: error,
            themeMode: _themeCubit.state.themeMode,
            primaryColor: _themeCubit.state.primaryColor,
            locale: _savedLocale,
          ),
        );

      // Other AuthState variants that do not trigger AppState changes:
      case AuthLoading() ||
           AuthRegistrationSuccess() ||
           AuthValidationError() ||
           AuthNavigate() ||
           RoleChanged() ||
           AuthOfflineWarning():
        // These states are transient or handled locally within auth/routing,
        // and do not change the global AppCubit state.
        break;
    }
  }

  /// Handle theme state changes
  void _handleThemeStateChange(ThemeState themeState) {
    emit(
      state.copyWithTheme(
        themeMode: themeState.themeMode,
        primaryColor: themeState.primaryColor,
      ),
    );
  }

  /// Handle notification state changes
  void _handleNotificationStateChange(NotificationState notificationState) {
    if (state case AppAuthenticated authenticated && NotificationLoaded(:final unreadCount)) {
      emit(
        authenticated.copyWith(
          unreadNotifications: unreadCount,
        ),
      );
    }
  }

  /// Handle owner/chalet state changes
  void _handleOwnerStateChange(OwnerState ownerState) {
    if (state case AppAuthenticated authenticated) {
      // Avoid replacing a populated list with an empty one during
      // transient loading states (e.g. subscription re-establishment).
      final bool isLoading = ownerState.status == OwnerStatus.loading;
      final List<dynamic> chaletsToUse =
          (isLoading && ownerState.chalets.isEmpty && authenticated.ownerChalets.isNotEmpty)
              ? authenticated.ownerChalets
              : ownerState.chalets;

      // Only show loading shimmer when there is genuinely no cached data.
      final bool showLoading = isLoading && chaletsToUse.isEmpty;

      emit(
        authenticated.copyWith(
          ownerChalets: chaletsToUse,
          isOwnerChaletsLoading: showLoading,
          ownerFormData: ownerState.draft,
        ),
      );
    }
  }

  /// Handle booking state changes
  void _handleBookingStateChange(BookingState bookingState) {
    if (state case AppAuthenticated authenticated) {
      emit(
        authenticated.copyWith(
          bookings: bookingState.bookings,
          isBookingsLoading: bookingState.isLoading,
        ),
      );
    }
  }

  /// Get current unread notification count
  int _getUnreadNotificationCount() {
    if (_notificationCubit.state case NotificationLoaded(:final unreadCount)) {
      return unreadCount;
    }
    return 0;
  }

  /// Load streams for the active view role (user / owner / admin).
  void _loadUserData(UserModel user, String viewRole) {
    if (viewRole == 'owner') {
      _bookingCubit.loadOwnerBookings(user.uid);
      _ownerCubit.fetchChalets(user.uid);
    } else if (viewRole == 'user') {
      _bookingCubit.loadUserBookings(user.uid);
    } else if (viewRole == 'admin') {
      _bookingCubit.loadBookings();
    }
  }

  // ==================== PUBLIC ACTIONS (FACADE IMPLEMENTATIONS) ====================

  // --- Auth ---
  @override
  UserModel? getCurrentUser() => _authCubit.getCurrentUser();
  @override
  String getCurrentRole() => _authCubit.getCurrentRole();
  @override
  void toggleViewMode() => _authCubit.toggleViewMode();
  @override
  Future<void> logout() => _authCubit.logout();
  @override
  Future<void> reloadUserData() => _authCubit.reloadUserData();
  @override
  Future<void> updateProfile({
    required String name,
    required String phone,
    String? profileImageUrl,
  }) => _authCubit.updateProfile(
    name: name,
    phone: phone,
    profileImageUrl: profileImageUrl,
  );
  @override
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) => _authCubit.changePassword(
    currentPassword: currentPassword,
    newPassword: newPassword,
  );
  @override
  Future<void> updateIdCard(String idCardUrl) =>
      _authCubit.updateIdCard(idCardUrl);

  // --- Theme ---
  @override
  void toggleTheme({Brightness? platformBrightness}) =>
      _themeCubit.toggleTheme(platformBrightness: platformBrightness);
  @override
  void changeTheme(ThemeMode mode) => _themeCubit.changeTheme(mode);
  @override
  void changePrimaryColor(Color color) => _themeCubit.changeColor(color);

  // --- Locale ---
  @override
  Future<void> changeLocale(Locale locale) async {
    _savedLocale = locale;
    _emitWithLocale(locale);
    SharedPreferences.getInstance().then((prefs) {
      prefs.setString(_localeKey, locale.languageCode);
    });
  }

  // --- Owner (Chalets) ---
  @override
  Future<void> fetchOwnerChalets() {
    final user = getCurrentUser();
    if (user != null) {
      return _ownerCubit.fetchChalets(user.uid);
    }
    return Future.value();
  }

  // --- Booking ---
  @override
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
    _networkCubit.close();
    return super.close();
  }
}
