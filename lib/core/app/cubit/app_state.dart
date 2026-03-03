part of 'app_cubit.dart';

/// Base class for all app states
abstract class AppState {
  final ThemeMode themeMode;
  final Color primaryColor;
  final Locale locale;

  const AppState({
    required this.themeMode,
    required this.primaryColor,
    required this.locale,
  });
}

/// Initial app state (loading)
class AppInitial extends AppState {
  AppInitial()
    : super(
        themeMode: ThemeMode.system,
        primaryColor: const Color(0xFF6200EE),
        locale: const Locale('ar'),
      );
}

/// Unauthenticated state
class AppUnauthenticated extends AppState {
  const AppUnauthenticated({
    required super.themeMode,
    required super.primaryColor,
    required super.locale,
  });

  AppUnauthenticated copyWith({
    ThemeMode? themeMode,
    Color? primaryColor,
    Locale? locale,
  }) {
    return AppUnauthenticated(
      themeMode: themeMode ?? this.themeMode,
      primaryColor: primaryColor ?? this.primaryColor,
      locale: locale ?? this.locale,
    );
  }
}

/// Authenticated state with user data
class AppAuthenticated extends AppState {
  final UserModel user;
  final int unreadNotifications;
  final List<dynamic> ownerChalets;
  final bool isOwnerChaletsLoading;
  final List<Booking> bookings;
  final bool isBookingsLoading;
  final ChaletDraft? ownerFormData;

  const AppAuthenticated({
    required this.user,
    required super.themeMode,
    required super.primaryColor,
    required super.locale,
    this.unreadNotifications = 0,
    this.ownerChalets = const [],
    this.isOwnerChaletsLoading = false,
    this.bookings = const [],
    this.isBookingsLoading = false,
    this.ownerFormData,
  });

  AppAuthenticated copyWith({
    UserModel? user,
    ThemeMode? themeMode,
    Color? primaryColor,
    Locale? locale,
    int? unreadNotifications,
    List<dynamic>? ownerChalets,
    bool? isOwnerChaletsLoading,
    List<Booking>? bookings,
    bool? isBookingsLoading,
    ChaletDraft? ownerFormData,
  }) {
    return AppAuthenticated(
      user: user ?? this.user,
      themeMode: themeMode ?? this.themeMode,
      primaryColor: primaryColor ?? this.primaryColor,
      locale: locale ?? this.locale,
      unreadNotifications: unreadNotifications ?? this.unreadNotifications,
      ownerChalets: ownerChalets ?? this.ownerChalets,
      isOwnerChaletsLoading:
          isOwnerChaletsLoading ?? this.isOwnerChaletsLoading,
      bookings: bookings ?? this.bookings,
      isBookingsLoading: isBookingsLoading ?? this.isBookingsLoading,
      ownerFormData: ownerFormData ?? this.ownerFormData,
    );
  }
}

/// Error state
class AppError extends AppState {
  final String message;

  const AppError({
    required this.message,
    required super.themeMode,
    required super.primaryColor,
    required super.locale,
  });
}
