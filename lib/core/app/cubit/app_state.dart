part of 'app_cubit.dart';

/// Base class for all app states
abstract class AppState {
  final ThemeMode themeMode;
  final Color primaryColor;

  const AppState({required this.themeMode, required this.primaryColor});
}

/// Initial app state (loading)
class AppInitial extends AppState {
  AppInitial()
    : super(themeMode: ThemeMode.system, primaryColor: const Color(0xFF6200EE));
}

/// Unauthenticated state
class AppUnauthenticated extends AppState {
  const AppUnauthenticated({
    required super.themeMode,
    required super.primaryColor,
  });

  AppUnauthenticated copyWith({ThemeMode? themeMode, Color? primaryColor}) {
    return AppUnauthenticated(
      themeMode: themeMode ?? this.themeMode,
      primaryColor: primaryColor ?? this.primaryColor,
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
  final OwnerData? ownerFormData;

  const AppAuthenticated({
    required this.user,
    required super.themeMode,
    required super.primaryColor,
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
    int? unreadNotifications,
    List<dynamic>? ownerChalets,
    bool? isOwnerChaletsLoading,
    List<Booking>? bookings,
    bool? isBookingsLoading,
    OwnerData? ownerFormData,
  }) {
    return AppAuthenticated(
      user: user ?? this.user,
      themeMode: themeMode ?? this.themeMode,
      primaryColor: primaryColor ?? this.primaryColor,
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
  });
}
