import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rebtal/core/utils/theme/cubit/theme_cubit.dart';

/// ThemeProvider - Provides ThemeCubit to the widget tree
///
/// This is the ONLY BlocProvider that should be at the app root level.
/// ThemeCubit is required by MaterialApp, so it must be available
/// before MaterialApp is built.
///
/// Why only ThemeCubit at root?
/// - MaterialApp needs theme state to build the app
/// - Other Cubits (Auth, Booking, Notifications) can be scoped to Routes/Screens
/// - This prevents unnecessary rebuilds and memory leaks
/// - Follows Flutter Bloc Best Practices for Route-based injection
class ThemeProvider extends StatelessWidget {
  final Widget child;

  const ThemeProvider({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ThemeCubit>(
      create: (_) => ThemeCubit(),
      lazy: false, // Initialize immediately for theme loading
      child: child,
    );
  }
}
