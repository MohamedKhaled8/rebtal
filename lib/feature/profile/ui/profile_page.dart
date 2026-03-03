import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rebtal/core/app/cubit/app_cubit.dart';
import 'package:rebtal/core/Router/routes.dart';
import 'package:rebtal/core/utils/localization/translation_extension.dart';
import 'package:rebtal/feature/profile/widget/profile_content.dart';
import 'package:rebtal/feature/owner/ui/chalet_status_page.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AppCubit, AppState>(
      listener: (context, state) {
        if (state is AppUnauthenticated) {
          Navigator.pushNamedAndRemoveUntil(
            context,
            Routes.loginScreen,
            (route) => false,
          );
        } else if (state is AppError) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.message)));
        }
      },
      builder: (context, state) {
        if (state is AppAuthenticated) {
          return ProfileContent(
            user: state.user,
            onLogout: () => _showLogoutDialog(context),
            onNavigateToChalets: _navigateToChalets,
          );
        } else if (state is AppInitial) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        } else if (state is AppUnauthenticated) {
          // Should have navigated away, but show placeholder
          return Scaffold(
            body: Center(child: Text(context.tr('profile_please_login'))),
          );
        } else {
          // Fallback
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
      },
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            const Icon(Icons.logout, color: Color(0xFFEF4444)),
            const SizedBox(width: 12),
            Text(
              context.tr('profile_logout'),
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        content: Text(
          context.tr('profile_logout_confirm'),
          style: const TextStyle(fontSize: 16),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(
              context.tr('common_cancel'),
              style: const TextStyle(color: Colors.grey, fontSize: 16),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              context.read<AppCubit>().logout();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEF4444),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: Text(
              context.tr('profile_logout'),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _navigateToChalets(BuildContext context, String status) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ChaletStatusPage(status: status)),
    );
  }
}
