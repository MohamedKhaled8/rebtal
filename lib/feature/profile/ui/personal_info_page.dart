import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rebtal/core/app/cubit/app_cubit.dart';
import 'package:rebtal/core/utils/dependency/get_it.dart';
import 'package:rebtal/core/utils/theme/dynamic_theme_manager.dart';
import 'package:rebtal/core/utils/model/user_model.dart';
import 'package:rebtal/core/utils/helper/snack_bar_helper.dart';
import 'package:rebtal/core/utils/helper/image_clean/helper_image_contract.dart';
import 'package:rebtal/core/utils/localization/translation_extension.dart';
import 'package:cached_network_image/cached_network_image.dart';

class PersonalInfoPage extends StatefulWidget {
  final UserModel user;
  const PersonalInfoPage({super.key, required this.user});

  @override
  State<PersonalInfoPage> createState() => _PersonalInfoPageState();
}

class _PersonalInfoPageState extends State<PersonalInfoPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();

  bool _isEditingProfile = false;
  bool _isChangingPassword = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController.text = widget.user.name;
    _phoneController.text = widget.user.phone;

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _nameController.dispose();
    _phoneController.dispose();
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    super.dispose();
  }

  Future<void> _updateProfile() async {
    setState(() => _isLoading = true);
    try {
      await context.read<AppCubit>().updateProfile(
        name: _nameController.text,
        phone: _phoneController.text,
      );
      if (mounted) {
        setState(() {
          _isEditingProfile = false;
          _isLoading = false;
        });
        SnackBarHelper.showSuccess(
          context,
          context.tr('profile_updated_success'),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        SnackBarHelper.showError(
          context,
          '${context.tr('profile_update_failed')} $e',
        );
      }
    }
  }

  Future<void> _changePassword() async {
    if (_newPasswordController.text.length < 6) {
      SnackBarHelper.showError(
        context,
        context.tr('profile_password_min_length'),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      await context.read<AppCubit>().changePassword(
        currentPassword: _currentPasswordController.text,
        newPassword: _newPasswordController.text,
      );
      if (mounted) {
        setState(() {
          _isChangingPassword = false;
          _isLoading = false;
          _currentPasswordController.clear();
          _newPasswordController.clear();
        });
        SnackBarHelper.showSuccess(
          context,
          context.tr('profile_password_changed'),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        SnackBarHelper.showError(
          context,
          '${context.tr('profile_password_change_failed')} $e',
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = DynamicThemeManager.isDarkMode(context);
    final Color backgroundColor = isDark
        ? const Color(0xFF121212)
        : Colors.white;
    final Color primaryText = isDark ? Colors.white : const Color(0xFF222222);
    final Color secondaryText = isDark
        ? Colors.white70
        : const Color(0xFF717171);
    final Color dividerColor = isDark
        ? Colors.white10
        : const Color(0xFFDDDDDD);

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_rounded, color: primaryText),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          context.tr('profile_personal_info'),
          style: TextStyle(
            color: primaryText,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: BlocBuilder<AppCubit, AppState>(
          builder: (context, state) {
            final user = (state is AppAuthenticated) ? state.user : widget.user;

            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Profile Picture Section
                  _buildAnimatedItem(
                    0,
                    Center(
                      child: GestureDetector(
                        onTap: () => getIt<HelperImageContract>()
                            .addProfilePicture(context),
                        child: Stack(
                          children: [
                            Container(
                              width: 100,
                              height: 100,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: isDark
                                    ? const Color(0xFF333333)
                                    : const Color(0xFFF5F5F5),
                                image:
                                    user.profileImageUrl != null &&
                                        user.profileImageUrl!.isNotEmpty
                                    ? DecorationImage(
                                        image: CachedNetworkImageProvider(
                                          user.profileImageUrl!,
                                        ),
                                        fit: BoxFit.cover,
                                      )
                                    : null,
                                border: Border.all(
                                  color: isDark
                                      ? Colors.white10
                                      : Colors.black12,
                                  width: 1,
                                ),
                              ),
                              child:
                                  user.profileImageUrl == null ||
                                      user.profileImageUrl!.isEmpty
                                  ? Center(
                                      child: Text(
                                        user.name.isNotEmpty
                                            ? user.name[0].toUpperCase()
                                            : 'U',
                                        style: TextStyle(
                                          fontSize: 36,
                                          fontWeight: FontWeight.w700,
                                          color: primaryText,
                                        ),
                                      ),
                                    )
                                  : null,
                            ),
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: isDark ? Colors.white : Colors.black,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: backgroundColor,
                                    width: 3,
                                  ),
                                ),
                                child: Icon(
                                  Icons.camera_alt,
                                  size: 14,
                                  color: isDark ? Colors.black : Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 40),

                  // Basic Information Header
                  _buildAnimatedItem(
                    1,
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            context.tr('profile_basic_info'),
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: primaryText,
                            ),
                          ),
                          if (!_isEditingProfile)
                            TextButton(
                              onPressed: () =>
                                  setState(() => _isEditingProfile = true),
                              style: TextButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 8,
                                ),
                                backgroundColor: isDark
                                    ? Colors.white10
                                    : Colors.black.withOpacity(0.05),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                              ),
                              child: Text(
                                context.tr('common_edit'),
                                style: TextStyle(
                                  color: primaryText,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),

                  if (_isEditingProfile)
                    _buildAnimatedItem(
                      2,
                      Column(
                        children: [
                          _buildTextField(
                            isDark,
                            context.tr('auth_full_name'),
                            _nameController,
                          ),
                          const SizedBox(height: 16),
                          _buildTextField(
                            isDark,
                            context.tr('auth_phone'),
                            _phoneController,
                            keyboardType: TextInputType.phone,
                          ),
                          const SizedBox(height: 24),
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton(
                                  onPressed: () =>
                                      setState(() => _isEditingProfile = false),
                                  style: OutlinedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 14,
                                    ),
                                    side: BorderSide(color: dividerColor),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  child: Text(
                                    context.tr('common_cancel'),
                                    style: TextStyle(color: secondaryText),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: _isLoading ? null : _updateProfile,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: isDark
                                        ? Colors.white
                                        : Colors.black,
                                    foregroundColor: isDark
                                        ? Colors.black
                                        : Colors.white,
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 14,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    elevation: 0,
                                  ),
                                  child: _isLoading
                                      ? SizedBox(
                                          height: 20,
                                          width: 20,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            color: isDark
                                                ? Colors.black
                                                : Colors.white,
                                          ),
                                        )
                                      : Text(
                                          context.tr('common_save'),
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    )
                  else
                    _buildAnimatedItem(
                      2,
                      Column(
                        children: [
                          _buildInfoRow(
                            isDark,
                            context.tr('common_name'),
                            user.name,
                            Icons.person_outline_rounded,
                          ),
                          _buildInfoRow(
                            isDark,
                            context.tr('common_email'),
                            user.email,
                            Icons.email_outlined,
                          ),
                          _buildInfoRow(
                            isDark,
                            context.tr('auth_phone'),
                            user.phone,
                            Icons.phone_iphone_rounded,
                            isLast: true,
                          ),
                        ],
                      ),
                    ),

                  const SizedBox(height: 32),

                  const SizedBox(height: 32),
                  _buildAnimatedItem(
                    3,
                    Divider(height: 1, color: dividerColor),
                  ),
                  const SizedBox(height: 32),

                  // Security Section
                  _buildAnimatedItem(
                    4,
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: Text(
                        context.tr('profile_security_privacy'),
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: primaryText,
                        ),
                      ),
                    ),
                  ),

                  if (_isChangingPassword)
                    _buildAnimatedItem(
                      5,
                      Column(
                        children: [
                          _buildTextField(
                            isDark,
                            context.tr('profile_current_password'),
                            _currentPasswordController,
                            isPassword: true,
                          ),
                          const SizedBox(height: 16),
                          _buildTextField(
                            isDark,
                            context.tr('profile_new_password'),
                            _newPasswordController,
                            isPassword: true,
                          ),
                          const SizedBox(height: 24),
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton(
                                  onPressed: () => setState(
                                    () => _isChangingPassword = false,
                                  ),
                                  style: OutlinedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 14,
                                    ),
                                    side: BorderSide(color: dividerColor),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  child: Text(
                                    context.tr('common_cancel'),
                                    style: TextStyle(color: secondaryText),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: _isLoading
                                      ? null
                                      : _changePassword,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: isDark
                                        ? Colors.white
                                        : Colors.black,
                                    foregroundColor: isDark
                                        ? Colors.black
                                        : Colors.white,
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 14,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    elevation: 0,
                                  ),
                                  child: _isLoading
                                      ? SizedBox(
                                          height: 20,
                                          width: 20,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            color: isDark
                                                ? Colors.black
                                                : Colors.white,
                                          ),
                                        )
                                      : Text(
                                          context.tr('common_update'),
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    )
                  else
                    _buildAnimatedItem(
                      5,
                      _buildInfoRow(
                        isDark,
                        context.tr('auth_password'),
                        '••••••••',
                        Icons.lock_outline_rounded,
                        isLast: true,
                      ),
                    ),

                  const SizedBox(height: 40),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildTextField(
    bool isDark,
    String label,
    TextEditingController controller, {
    bool isPassword = false,
    TextInputType? keyboardType,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: isDark ? Colors.white70 : const Color(0xFF717171),
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          obscureText: isPassword,
          keyboardType: keyboardType,
          style: TextStyle(color: isDark ? Colors.white : Colors.black),
          decoration: InputDecoration(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(
                color: isDark ? Colors.white10 : const Color(0xFFDDDDDD),
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(
                color: isDark ? Colors.white : Colors.black,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow(
    bool isDark,
    String label,
    String value,
    IconData icon, {
    bool isLast = false,
  }) {
    final primaryText = isDark ? Colors.white : const Color(0xFF222222);
    final secondaryText = isDark ? Colors.white70 : const Color(0xFF717171);

    return InkWell(
      onTap: label == context.tr('auth_password')
          ? () => setState(() => _isChangingPassword = true)
          : null,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: isLast
                  ? Colors.transparent
                  : (isDark ? Colors.white10 : const Color(0xFFEEEEEE)),
            ),
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 26,
              color: isDark ? Colors.white : const Color(0xFF222222),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(fontSize: 13, color: secondaryText),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: primaryText,
                    ),
                  ),
                ],
              ),
            ),
            if (label == context.tr('auth_password'))
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 16,
                color: isDark ? Colors.white60 : const Color(0xFF222222),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnimatedItem(int index, Widget child) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final double delay = index * 0.1;
        final double start = delay;
        final double end = start + 0.5;
        final fade = CurvedAnimation(
          parent: _controller,
          curve: Interval(
            start.clamp(0.0, 1.0),
            end.clamp(0.0, 1.0),
            curve: Curves.easeOut,
          ),
        );
        final slide =
            Tween<Offset>(
              begin: const Offset(0, 0.1),
              end: Offset.zero,
            ).animate(
              CurvedAnimation(
                parent: _controller,
                curve: Interval(
                  start.clamp(0.0, 1.0),
                  end.clamp(0.0, 1.0),
                  curve: Curves.easeOutCubic,
                ),
              ),
            );
        return FadeTransition(
          opacity: fade,
          child: SlideTransition(position: slide, child: child!),
        );
      },
      child: child,
    );
  }
}
