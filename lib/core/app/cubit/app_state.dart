part of 'app_cubit.dart';

/// Base class for all app states
sealed class AppState {
  final ThemeMode themeMode;
  final Color primaryColor;
  final Locale locale;

  const AppState({
    required this.themeMode,
    required this.primaryColor,
    required this.locale,
  });

  /// Polymorphic abstraction for theme updates
  AppState copyWithTheme({ThemeMode? themeMode, Color? primaryColor});

  /// Polymorphic abstraction for locale updates
  AppState copyWithLocale(Locale locale);
}

/// Initial app state (loading)
class AppInitial extends AppState {
  AppInitial()
    : super(
        themeMode: ThemeMode.system,
        primaryColor: const Color(0xFF6200EE),
        locale: const Locale('ar'),
      );

  @override
  AppInitial copyWithTheme({ThemeMode? themeMode, Color? primaryColor}) => this;

  @override
  AppInitial copyWithLocale(Locale locale) => this;
}

/// Guest browsing state (no account)
class AppGuestBrowsing extends AppState {
  const AppGuestBrowsing({
    required super.themeMode,
    required super.primaryColor,
    required super.locale,
  });

  AppGuestBrowsing copyWith({
    ThemeMode? themeMode,
    Color? primaryColor,
    Locale? locale,
  }) {
    return AppGuestBrowsing(
      themeMode: themeMode ?? this.themeMode,
      primaryColor: primaryColor ?? this.primaryColor,
      locale: locale ?? this.locale,
    );
  }

  @override
  AppGuestBrowsing copyWithTheme({ThemeMode? themeMode, Color? primaryColor}) {
    return copyWith(themeMode: themeMode, primaryColor: primaryColor);
  }

  @override
  AppGuestBrowsing copyWithLocale(Locale locale) {
    return copyWith(locale: locale);
  }
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

  @override
  AppUnauthenticated copyWithTheme({ThemeMode? themeMode, Color? primaryColor}) {
    return copyWith(themeMode: themeMode, primaryColor: primaryColor);
  }

  @override
  AppUnauthenticated copyWithLocale(Locale locale) {
    return copyWith(locale: locale);
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

  @override
  AppAuthenticated copyWithTheme({ThemeMode? themeMode, Color? primaryColor}) {
    return copyWith(themeMode: themeMode, primaryColor: primaryColor);
  }

  @override
  AppAuthenticated copyWithLocale(Locale locale) {
    return copyWith(locale: locale);
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

  @override
  AppError copyWithTheme({ThemeMode? themeMode, Color? primaryColor}) {
    return AppError(
      message: message,
      themeMode: themeMode ?? this.themeMode,
      primaryColor: primaryColor ?? this.primaryColor,
      locale: locale,
    );
  }

  @override
  AppError copyWithLocale(Locale locale) {
    return AppError(
      message: message,
      themeMode: themeMode,
      primaryColor: primaryColor,
      locale: locale,
    );
  }
}
