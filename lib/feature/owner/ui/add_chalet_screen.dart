import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rebtal/core/utils/widgets/premium_loading_overlay.dart';
import 'package:rebtal/core/app/cubit/app_cubit.dart';
import 'package:rebtal/core/utils/constant/color_manager.dart';
import 'package:rebtal/core/utils/helper/snack_bar_helper.dart';
import 'package:rebtal/core/utils/theme/dynamic_theme_manager.dart';
import 'package:rebtal/feature/owner/logic/cubit/owner_cubit.dart';
import 'package:rebtal/feature/owner/logic/cubit/owner_state.dart';
import 'package:rebtal/feature/owner/widget/modern_image_upload_section.dart';
import 'package:rebtal/feature/owner/widget/modern_amenities_section.dart';
import 'package:rebtal/core/utils/helper/helper_image.dart';

class AddChaletScreen extends StatefulWidget {
  const AddChaletScreen({super.key});

  @override
  State<AddChaletScreen> createState() => _AddChaletScreenState();
}

class _AddChaletScreenState extends State<AddChaletScreen> {
  @override
  void initState() {
    super.initState();
    // Reset form when entering the screen to ensure clean state
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AppCubit>().ownerCubit.resetForm();
    });
  }

  @override
  Widget build(BuildContext context) {
    final appCubit = context.read<AppCubit>();
    final ownerCubit = appCubit.ownerCubit;
    final isDark = DynamicThemeManager.isDarkMode(context);

    return MultiBlocListener(
      listeners: [
        BlocListener<OwnerCubit, OwnerState>(
          bloc: ownerCubit,
          listenWhen: (previous, current) =>
              previous.isFormSubmitting != current.isFormSubmitting,
          listener: (context, state) {
            if (state.isFormSubmitting) {
              PremiumLoadingOverlay.show(context);
            } else {
              PremiumLoadingOverlay.dismiss(context);
            }
          },
        ),
        BlocListener<OwnerCubit, OwnerState>(
          bloc: ownerCubit,
          listenWhen: (previous, current) =>
              previous.isFormSuccess != current.isFormSuccess ||
              previous.formError != current.formError,
          listener: (context, state) {
            if (state.isFormSuccess) {
              SnackBarHelper.showSuccess(context, "Chalet added successfully!");
              Navigator.pop(context);
            } else if (state.formError != null) {
              SnackBarHelper.showError(context, state.formError!);
            }
          },
        ),
      ],
      child: Scaffold(
        backgroundColor: isDark
            ? ColorManager.darkBackground0A0E27
            : ColorManager.lightBackgroundF8FAFF,
        appBar: _buildAppBar(context, isDark),
        body: const _AddChaletContent(),
        bottomNavigationBar: _SubmitButton(
          ownerCubit: ownerCubit,
          appCubit: appCubit,
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context, bool isDark) {
    return AppBar(
      elevation: 0,
      backgroundColor: isDark
          ? ColorManager.darkBackground0A0E27
          : ColorManager.lightBackgroundF8FAFF,
      leading: IconButton(
        icon: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: isDark ? ColorManager.white10 : ColorManager.grey200,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: isDark ? ColorManager.white : ColorManager.black,
            size: 18,
          ),
        ),
        onPressed: () => Navigator.pop(context),
      ),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Add New Chalet",
            style: TextStyle(
              color: isDark ? ColorManager.white : ColorManager.black,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            "Fill in the details below",
            style: TextStyle(
              color: isDark ? ColorManager.grey400 : ColorManager.grey600,
              fontSize: 12,
              fontWeight: FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}

class _AddChaletContent extends StatelessWidget {
  const _AddChaletContent();

  @override
  Widget build(BuildContext context) {
    final ownerCubit = context.read<AppCubit>().ownerCubit;
    final isDark = DynamicThemeManager.isDarkMode(context);

    return BlocBuilder<OwnerCubit, OwnerState>(
      bloc: ownerCubit,
      builder: (context, state) {
        final draft = state.draft;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Progress Indicator
              _buildProgressIndicator(isDark),
              const SizedBox(height: 24),

              // Image Section
              ModernImageUploadSection(
                images: draft.uploadedImages,
                onAdd: () => HelperImage().addSampleImages(context),
                onRemove: (index) => ownerCubit.removeChaletImage(index),
              ),
              const SizedBox(height: 24),

              // Basic Info Card
              _buildSectionCard(
                isDark: isDark,
                title: "Basic Information",
                icon: Icons.info_outline_rounded,
                iconColor: ColorManager.blue2563EB,
                child: Column(
                  children: [
                    _buildModernTextField(
                      isDark: isDark,
                      initialValue: draft.chaletName,
                      label: "Chalet Name",
                      hint: "Enter a catchy name for your chalet",
                      icon: Icons.villa_rounded,
                      onChanged: ownerCubit.updateChaletName,
                    ),
                    const SizedBox(height: 16),
                    _buildModernTextField(
                      isDark: isDark,
                      initialValue: draft.description,
                      label: "Description",
                      hint: "Describe what makes your chalet special...",
                      icon: Icons.description_rounded,
                      maxLines: 4,
                      onChanged: ownerCubit.updateDescription,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Pricing & Details Card
              _buildSectionCard(
                isDark: isDark,
                title: "Pricing & Details",
                icon: Icons.attach_money_rounded,
                iconColor: ColorManager.green3DDC84,
                child: Column(
                  children: [
                    _buildModernTextField(
                      isDark: isDark,
                      initialValue: draft.price,
                      label: "Price per Night (EGP)",
                      hint: "0.00",
                      icon: Icons.payments_rounded,
                      keyboardType: TextInputType.number,
                      onChanged: ownerCubit.updatePrice,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: _buildModernTextField(
                            isDark: isDark,
                            initialValue: draft.bedrooms?.toString() ?? '',
                            label: "Bedrooms",
                            hint: "0",
                            icon: Icons.bed_rounded,
                            keyboardType: TextInputType.number,
                            onChanged: (val) {
                              final num = int.tryParse(val);
                              if (num != null) ownerCubit.updateBedrooms(num);
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildModernTextField(
                            isDark: isDark,
                            initialValue: draft.bathrooms?.toString() ?? '',
                            label: "Bathrooms",
                            hint: "0",
                            icon: Icons.bathtub_rounded,
                            keyboardType: TextInputType.number,
                            onChanged: (val) {
                              final num = int.tryParse(val);
                              if (num != null) ownerCubit.updateBathrooms(num);
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Amenities Section
              ModernAmenitiesSection(
                selectedAmenities: {
                  'hasWifi': draft.hasWifi,
                  'hasPool': draft.hasPool,
                  'hasAirConditioning': draft.hasAirConditioning,
                  'hasParking': draft.hasParking,
                  'hasGarden': draft.hasGarden,
                  'hasBBQ': draft.hasBBQ,
                  'hasBeachView': draft.hasBeachView,
                  'hasHousekeeping': draft.hasHousekeeping,
                  'hasPetsAllowed': draft.hasPetsAllowed,
                  'hasGym': draft.hasGym,
                  'hasKitchen': draft.hasKitchen,
                  'hasTV': draft.hasTV,
                },
                onAmenityChanged: ownerCubit.updateAmenity,
              ),
              const SizedBox(height: 80), // Space for bottom button
            ],
          ),
        );
      },
    );
  }

  Widget _buildProgressIndicator(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [
                  ColorManager.blue2563EB.withOpacity(0.2),
                  ColorManager.purple764BA2.withOpacity(0.2),
                ]
              : [
                  ColorManager.blue2563EB.withOpacity(0.1),
                  ColorManager.purple764BA2.withOpacity(0.1),
                ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark
              ? ColorManager.blue2563EB.withOpacity(0.3)
              : ColorManager.blue2563EB.withOpacity(0.2),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: ColorManager.blue2563EB,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.edit_note_rounded,
              color: ColorManager.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Create Your Listing",
                  style: TextStyle(
                    color: isDark ? ColorManager.white : ColorManager.black,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "Add photos, details, and amenities",
                  style: TextStyle(
                    color: isDark ? ColorManager.grey400 : ColorManager.grey600,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionCard({
    required bool isDark,
    required String title,
    required IconData icon,
    required Color iconColor,
    required Widget child,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? ColorManager.darkBlue1A1A2E : ColorManager.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark
              ? ColorManager.grey800.withOpacity(0.3)
              : ColorManager.grey200,
        ),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? ColorManager.black.withOpacity(0.3)
                : ColorManager.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: iconColor, size: 22),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isDark ? ColorManager.white : ColorManager.black,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          child,
        ],
      ),
    );
  }

  Widget _buildModernTextField({
    required bool isDark,
    String? initialValue,
    required String label,
    required String hint,
    required IconData icon,
    int maxLines = 1,
    TextInputType? keyboardType,
    required Function(String) onChanged,
  }) {
    return TextFormField(
      initialValue: initialValue,
      maxLines: maxLines,
      keyboardType: keyboardType,
      onChanged: onChanged,
      style: TextStyle(
        color: isDark ? ColorManager.white : ColorManager.black,
        fontSize: 15,
      ),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        labelStyle: TextStyle(
          color: isDark ? ColorManager.grey400 : ColorManager.grey600,
          fontSize: 14,
        ),
        hintStyle: TextStyle(
          color: isDark ? ColorManager.grey600 : ColorManager.grey400,
          fontSize: 14,
        ),
        prefixIcon: Icon(
          icon,
          color: isDark ? ColorManager.grey400 : ColorManager.grey600,
          size: 22,
        ),
        filled: true,
        fillColor: isDark
            ? ColorManager.darkBlue2A2E4B.withOpacity(0.5)
            : ColorManager.grey50,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(
            color: isDark
                ? ColorManager.grey800.withOpacity(0.3)
                : ColorManager.grey300,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: ColorManager.blue2563EB, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
      ),
    );
  }
}

class _SubmitButton extends StatelessWidget {
  final OwnerCubit ownerCubit;
  final AppCubit appCubit;

  const _SubmitButton({required this.ownerCubit, required this.appCubit});

  @override
  Widget build(BuildContext context) {
    final isDark = DynamicThemeManager.isDarkMode(context);

    return BlocBuilder<OwnerCubit, OwnerState>(
      bloc: ownerCubit,
      builder: (context, state) {
        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: isDark ? ColorManager.darkBlue1A1A2E : ColorManager.white,
            boxShadow: [
              BoxShadow(
                color: ColorManager.black.withOpacity(0.1),
                blurRadius: 20,
                offset: const Offset(0, -4),
              ),
            ],
          ),
          child: SafeArea(
            child: Container(
              height: 56,
              decoration: BoxDecoration(
                gradient: state.isFormSubmitting
                    ? null
                    : const LinearGradient(
                        colors: [
                          ColorManager.blue2563EB,
                          ColorManager.purple764BA2,
                        ],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),
                color: state.isFormSubmitting
                    ? (isDark ? ColorManager.grey800 : ColorManager.grey300)
                    : null,
                borderRadius: BorderRadius.circular(16),
                boxShadow: state.isFormSubmitting
                    ? null
                    : [
                        BoxShadow(
                          color: ColorManager.blue2563EB.withOpacity(0.4),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: state.isFormSubmitting
                      ? null
                      : () {
                          final user = appCubit.authCubit.getCurrentUser();
                          if (user != null) {
                            ownerCubit.submitChalet(user.uid, user.name);
                          }
                        },
                  borderRadius: BorderRadius.circular(16),
                  child: Center(
                    child: state.isFormSubmitting
                        ? Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    isDark
                                        ? ColorManager.grey400
                                        : ColorManager.grey600,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Text(
                                "Submitting...",
                                style: TextStyle(
                                  color: isDark
                                      ? ColorManager.grey400
                                      : ColorManager.grey600,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.check_circle_outline_rounded,
                                color: ColorManager.white,
                                size: 22,
                              ),
                              const SizedBox(width: 10),
                              const Text(
                                "Submit Chalet",
                                style: TextStyle(
                                  color: ColorManager.white,
                                  fontSize: 17,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ],
                          ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
