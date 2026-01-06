import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rebtal/core/app/cubit/app_cubit.dart';
import 'package:rebtal/core/utils/constant/color_manager.dart';
import 'package:rebtal/core/utils/helper/helper_image.dart';
import 'package:rebtal/core/utils/helper/snack_bar_helper.dart';
import 'package:rebtal/core/utils/theme/dynamic_theme_manager.dart';
import 'package:rebtal/core/utils/widgets/premium_loading_overlay.dart';
import 'package:rebtal/feature/maps/ui/flutter_map_location_picker.dart';
import 'package:rebtal/feature/owner/logic/cubit/owner_cubit.dart';
import 'package:rebtal/feature/owner/logic/cubit/owner_state.dart';
import 'package:rebtal/feature/owner/widget/add_chalet_widgets.dart';
import 'package:rebtal/feature/owner/widget/amenities_selection_section.dart';
import 'package:rebtal/feature/owner/widget/image_upload_section.dart';

class OwnerChaletAddScreen extends StatelessWidget {
  const OwnerChaletAddScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appCubit = context.read<AppCubit>();
    final ownerCubit = appCubit.ownerCubit;
    final currentUser = appCubit.authCubit.getCurrentUser();
    final isDark = DynamicThemeManager.isDarkMode(context);

    // Initialize form with user data if not already done
    if (currentUser != null && ownerCubit.state.draft.merchantName == null) {
      ownerCubit.initializeFormWithUserData(
        ownerName: currentUser.name,
        email: currentUser.email,
        phone: currentUser.phone,
      );
    }

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
              SnackBarHelper.showSuccess(context, 'تم إضافة الشاليه بنجاح!');
              Navigator.pop(context);
            } else if (state.formError != null) {
              SnackBarHelper.showError(context, state.formError!);
            }
          },
        ),
      ],
      child: BlocBuilder<OwnerCubit, OwnerState>(
        bloc: ownerCubit,
        builder: (context, state) {
          return Scaffold(
            backgroundColor: isDark
                ? ColorManager.darkBackground0A0E27
                : ColorManager.lightBackgroundF8FAFF,
            appBar: _buildModernAppBar(context, isDark),
            body: const _ChaletFormContent(),
            bottomNavigationBar: _SubmitButton(
              isSubmitting: state.isFormSubmitting,
              isDark: isDark,
              onSubmit: () {
                final user = appCubit.authCubit.getCurrentUser();
                if (user != null) {
                  ownerCubit.submitChalet(user.uid, user.name);
                } else {
                  SnackBarHelper.showError(context, "المستخدم غير مسجل");
                }
              },
            ),
          );
        },
      ),
    );
  }

  PreferredSizeWidget _buildModernAppBar(BuildContext context, bool isDark) {
    return AppBar(
      elevation: 0,
      backgroundColor: isDark
          ? ColorManager.darkBackground0A0E27
          : ColorManager.lightBackgroundF8FAFF,
      leading: IconButton(
        icon: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: isDark
                ? ColorManager.white.withOpacity(0.1)
                : ColorManager.grey200,
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
            "إضافة شاليه جديد",
            style: TextStyle(
              color: isDark ? ColorManager.white : ColorManager.black,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            "املأ البيانات أدناه",
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

class _ChaletFormContent extends StatelessWidget {
  const _ChaletFormContent();

  @override
  Widget build(BuildContext context) {
    final ownerCubit = context.read<AppCubit>().ownerCubit;
    final isDark = DynamicThemeManager.isDarkMode(context);

    return BlocBuilder<OwnerCubit, OwnerState>(
      bloc: ownerCubit,
      builder: (context, state) {
        final draft = state.draft;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              // Progress Indicator
              _buildProgressCard(isDark),
              const SizedBox(height: 24),

              // Owner Info Section
              OwnerInfoSection(
                name: draft.merchantName ?? '',
                email: draft.email ?? '',
                phone: draft.phoneNumber ?? '',
              ),
              const SizedBox(height: 20),

              // Images Section
              ImageUploadSection(
                images: draft.uploadedImages,
                onAdd: () => HelperImage().addSampleImages(context),
                onRemove: (index) => ownerCubit.removeChaletImage(index),
              ),
              const SizedBox(height: 20),

              // Chalet Details Section
              ChaletDetailsSection(
                initialName: draft.chaletName,
                initialDescription: draft.description,
                onNameChanged: ownerCubit.updateChaletName,
                onDescriptionChanged: ownerCubit.updateDescription,
              ),
              const SizedBox(height: 20),

              // Location Section
              LocationSection(
                address: draft.selectedLocation,
                onPickLocation: () async {
                  final selected = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => FlutterGoogleMapLocationPicker(
                        initialAddress: draft.selectedLocation,
                      ),
                    ),
                  );
                  if (selected is Map) {
                    final addr = selected['address'] as String?;
                    final lat = selected['lat'] as double?;
                    final lon = selected['lon'] as double?;
                    if (addr != null) {
                      ownerCubit.updateGeo(
                        lat: lat ?? 0,
                        lon: lon ?? 0,
                        address: addr,
                      );
                    }
                  }
                },
              ),
              const SizedBox(height: 20),

              // Property Details Section
              PropertyDetailsSection(
                initialPrice: draft.price,
                initialArea: draft.chaletArea,
                initialBedrooms: draft.bedrooms?.toString(),
                initialBathrooms: draft.bathrooms?.toString(),
                initialChildrenCount: draft.childrenCount?.toString(),
                onPriceChanged: ownerCubit.updatePrice,
                onAreaChanged: ownerCubit.updateChaletArea,
                onBedroomsChanged: (v) =>
                    ownerCubit.updateBedrooms(int.tryParse(v) ?? 0),
                onBathroomsChanged: (v) =>
                    ownerCubit.updateBathrooms(int.tryParse(v) ?? 0),
                onChildrenCountChanged: (v) =>
                    ownerCubit.updateChildrenCount(int.tryParse(v)),
              ),
              const SizedBox(height: 20),

              // Discount Section
              DiscountSection(
                discountEnabled: draft.discountEnabled,
                discountType: draft.discountType,
                discountValue: draft.discountValue,
                originalPrice: double.tryParse(draft.price) ?? 0,
                onDiscountEnabledChanged: ownerCubit.updateDiscountEnabled,
                onDiscountTypeChanged: ownerCubit.updateDiscountType,
                onDiscountValueChanged: ownerCubit.updateDiscountValue,
              ),
              const SizedBox(height: 20),

              // Features Section
              FeaturesSection(
                selectedFeatures: draft.features,
                onToggleFeature: ownerCubit.toggleFeature,
              ),
              const SizedBox(height: 20),

              // Availability Section
              AvailabilitySection(
                availableFrom: draft.availableFrom,
                availableTo: draft.availableTo,
                onSelectFrom: () async {
                  final now = DateTime.now();
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: draft.availableFrom ?? now,
                    firstDate: now,
                    lastDate: DateTime(now.year + 2),
                  );
                  if (picked != null)
                    ownerCubit.selectAvailableFromDate(picked);
                },
                onSelectTo: () async {
                  final now = DateTime.now();
                  final picked = await showDatePicker(
                    context: context,
                    initialDate:
                        draft.availableTo ?? (draft.availableFrom ?? now),
                    firstDate: draft.availableFrom ?? now,
                    lastDate: DateTime(now.year + 2),
                  );
                  if (picked != null) ownerCubit.selectAvailableToDate(picked);
                },
              ),
              const SizedBox(height: 20),

              // Amenities Section
              AmenitiesSelectionSection(
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

              const SizedBox(height: 100), // Space for bottom button
            ],
          ),
        );
      },
    );
  }

  Widget _buildProgressCard(bool isDark) {
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
                  "إنشاء إعلانك",
                  style: TextStyle(
                    color: isDark ? ColorManager.white : ColorManager.black,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "أضف الصور والتفاصيل والمرافق",
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
}

class _SubmitButton extends StatelessWidget {
  final bool isSubmitting;
  final bool isDark;
  final VoidCallback onSubmit;

  const _SubmitButton({
    required this.isSubmitting,
    required this.isDark,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
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
            gradient: isSubmitting
                ? null
                : const LinearGradient(
                    colors: [
                      ColorManager.blue2563EB,
                      ColorManager.purple764BA2,
                    ],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
            color: isSubmitting
                ? (isDark ? ColorManager.grey800 : ColorManager.grey300)
                : null,
            borderRadius: BorderRadius.circular(16),
            boxShadow: isSubmitting
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
              onTap: isSubmitting ? null : onSubmit,
              borderRadius: BorderRadius.circular(16),
              child: Center(
                child: isSubmitting
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
                            "جاري الإرسال...",
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
                            "إرسال الشاليه",
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
  }
}
