import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rebtal/core/utils/localization/translation_extension.dart';
import 'package:rebtal/core/app/cubit/app_cubit.dart';
import 'package:rebtal/core/utils/constant/color_manager.dart';
import 'package:rebtal/core/utils/dependency/get_it.dart';
import 'package:rebtal/core/utils/helper/image_clean/helper_image_contract.dart';
import 'package:rebtal/core/utils/helper/snack_bar_helper.dart';
import 'package:rebtal/core/utils/theme/dynamic_theme_manager.dart';
import 'package:rebtal/core/utils/widgets/premium_loading_overlay.dart';
import 'package:rebtal/feature/maps/ui/flutter_map_location_picker.dart';
import 'package:rebtal/feature/owner/logic/cubit/owner_cubit.dart';
import 'package:rebtal/feature/owner/logic/cubit/owner_state.dart';
import 'package:rebtal/feature/owner/widget/add_chalet_widgets.dart';
import 'package:rebtal/feature/owner/widget/owner_chalet_form_host.dart';
import 'package:rebtal/feature/owner/widget/pricing_periods_section.dart';
import 'package:rebtal/feature/owner/widget/amenities_selection_section.dart';
import 'package:rebtal/feature/owner/utils/owner_helper.dart';
import 'package:rebtal/feature/owner/widget/image_upload_section.dart';
import 'package:responsive_screen_master/responsive_screen_master.dart';

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
              SnackBarHelper.showSuccess(
                context,
                context.tr('owner_chalet_added'),
              );
              Navigator.pop(context);
            } else if (state.formError != null) {
              SnackBarHelper.showError(context, state.formError!);
            }
          },
        ),
      ],
      child: BlocBuilder<OwnerCubit, OwnerState>(
        bloc: ownerCubit,
        buildWhen: (previous, current) =>
            previous.isFormSubmitting != current.isFormSubmitting,
        builder: (context, state) {
          return Scaffold(
            resizeToAvoidBottomInset: false,
            backgroundColor: isDark
                ? ColorsManager.darkBackground0A0E27
                : ColorsManager.lightBackgroundF8FAFF,
            appBar: _buildModernAppBar(context, isDark),
            body: _ChaletFormContent(ownerCubit: ownerCubit),
            bottomNavigationBar: _SubmitButton(
              isSubmitting: state.isFormSubmitting,
              isDark: isDark,
              onSubmit: () {
                final user = appCubit.authCubit.getCurrentUser();
                if (user != null) {
                  ownerCubit.submitChalet(user.uid, user.name);
                } else {
                  SnackBarHelper.showError(
                    context,
                    context.tr('owner_user_not_registered'),
                  );
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
          ? ColorsManager.darkBackground0A0E27
          : ColorsManager.lightBackgroundF8FAFF,
      leading: IconButton(
        icon: Container(
          padding: EdgeInsets.all(8.sp),
          decoration: BoxDecoration(
            color: isDark
                ? ColorsManager.white.withOpacity(0.1)
                : ColorsManager.grey200,
            borderRadius: BorderRadius.circular(12.sp),
          ),
          child: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: isDark ? ColorsManager.white : ColorsManager.black,
            size: 18,
          ),
        ),
        onPressed: () => Navigator.pop(context),
      ),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.tr('owner_add_new_chalet'),
            style: TextStyle(
              color: isDark ? ColorsManager.white : ColorsManager.black,
              fontSize: 20.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            context.tr('owner_fill_data'),
            style: TextStyle(
              color: isDark ? ColorsManager.grey400 : ColorsManager.grey600,
              fontSize: 12.sp,
              fontWeight: FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}

class _ChaletFormContent extends StatelessWidget {
  const _ChaletFormContent({required this.ownerCubit});

  final OwnerCubit ownerCubit;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.manual,
      padding: EdgeInsets.symmetric(
        horizontal: stv(
          context: context,
          mobile: 20.sw,
          tablet: 32.sw,
          desktop: 48.sw,
        ),
        vertical: 20.sh,
      ),
      child: OwnerChaletFormHost(
        cubit: ownerCubit,
        builder: _buildFormColumn,
      ),
    );
  }

  Widget _buildFormColumn(
    BuildContext context,
    bool isDark,
    OwnerCubit ownerCubit,
    ChaletDraft draft,
  ) {
    return Column(
      children: [
          // Progress Indicator
          _buildProgressCard(context, isDark),
          SizedBox(height: 24.sh),

          // Owner Info Section
          OwnerInfoSection(
            name: draft.merchantName ?? '',
            email: draft.email ?? '',
            phone: draft.phoneNumber ?? '',
          ),
          SizedBox(height: 20.sh),

          // Images Section
          ImageUploadSection(
            images: draft.uploadedImages,
            onAdd: () =>
                getIt<HelperImageContract>().addSampleImages(context),
            onRemove: (index) => ownerCubit.removeChaletImage(index),
          ),
          SizedBox(height: 20.sh),

          // Chalet Details Section
          ChaletDetailsSection(
            initialName: draft.chaletName,
            initialDescription: draft.description,
            onNameChanged: ownerCubit.updateChaletName,
            onDescriptionChanged: ownerCubit.updateDescription,
          ),
          SizedBox(height: 20.sh),

          // Location Section
          LocationSection(
            address: draft.selectedLocation,
            selectedPopularDestination: draft.popularDestination,
            onPopularDestinationChanged:
                ownerCubit.selectPopularDestination,
            onPickLocation: () async {
              FocusManager.instance.primaryFocus?.unfocus();
              final selected = await Navigator.push<Object?>(
                context,
                MaterialPageRoute(
                  builder: (_) => FlutterGoogleMapLocationPicker(
                    initialAddress: draft.selectedLocation,
                  ),
                ),
              );
              FocusManager.instance.primaryFocus?.unfocus();
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
          SizedBox(height: 20.sh),

          // Property Details Section
          PropertyDetailsSection(
            hideNightlyPrice: draft.dayUseOnly,
            initialPrice: draft.price,
            initialArea: draft.chaletArea,
            initialBedrooms: draft.bedrooms?.toString(),
            initialBathrooms: draft.bathrooms?.toString(),
            onPriceChanged: ownerCubit.updatePrice,
            onAreaChanged: ownerCubit.updateChaletArea,
            onBedroomsChanged: (v) =>
                ownerCubit.updateBedrooms(int.tryParse(v) ?? 0),
            onBathroomsChanged: (v) =>
                ownerCubit.updateBathrooms(int.tryParse(v) ?? 0),
          ),
          SizedBox(height: 20.sh),

          DayUseSection(
            dayUseEnabled: draft.dayUseEnabled,
            dayUseOnly: draft.dayUseOnly,
            dayUsePrice: draft.dayUsePrice,
            onDayUseChanged: ownerCubit.updateDayUseEnabled,
            onDayUseOnlyChanged: ownerCubit.updateDayUseOnly,
            onDayUsePriceChanged: ownerCubit.updateDayUsePrice,
          ),
          SizedBox(height: 20.sh),

          PricingPeriodsSection(
            periods: draft.pricingPeriods,
            onAdd: (from, to, price) => ownerCubit.addPricingPeriod(
              from: from,
              to: to,
              price: price,
            ),
            onRemove: ownerCubit.removePricingPeriod,
          ),
          SizedBox(height: 20.sh),

          // المرافق والخدمات (يشمل المميزات الإضافية — بدون قسم منفصل)
          AmenitiesSelectionSection(
            selectedAmenities: OwnerHelper.amenitiesDisplayMap(draft),
            onAmenityChanged: ownerCubit.updateAmenity,
          ),

          SizedBox(height: 80.sh), // Space for bottom button
        ],
      );
  }

  Widget _buildProgressCard(BuildContext context, bool isDark) {
    return Container(
      padding: EdgeInsets.all(16.sp),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [
                  ColorsManager.blue2563EB.withOpacity(0.2),
                  ColorsManager.purple764BA2.withOpacity(0.2),
                ]
              : [
                  ColorsManager.blue2563EB.withOpacity(0.1),
                  ColorsManager.purple764BA2.withOpacity(0.1),
                ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark
              ? ColorsManager.blue2563EB.withOpacity(0.3)
              : ColorsManager.blue2563EB.withOpacity(0.2),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(12.sp),
            decoration: BoxDecoration(
              color: ColorsManager.blue2563EB,
              borderRadius: BorderRadius.circular(12.sp),
            ),
            child: Icon(
              Icons.edit_note_rounded,
              color: ColorsManager.white,
              size: 24.sp,
            ),
          ),
          SizedBox(width: 16.sw),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.tr("owner_create_ad"),
                  style: TextStyle(
                    color: isDark ? ColorsManager.white : ColorsManager.black,
                    fontSize: 16.spScaled,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 4.sh),
                Text(
                  context.tr("owner_add_details_hint"),
                  style: TextStyle(
                    color: isDark
                        ? ColorsManager.grey400
                        : ColorsManager.grey600,
                    fontSize: 13.spScaled,
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
      padding: EdgeInsets.all(20.sp),
      decoration: BoxDecoration(
        color: isDark ? ColorsManager.darkBlue1A1A2E : ColorsManager.white,
        boxShadow: [
          BoxShadow(
            color: ColorsManager.black.withOpacity(0.1),
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
                      ColorsManager.blue2563EB,
                      ColorsManager.purple764BA2,
                    ],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
            color: isSubmitting
                ? (isDark ? ColorsManager.grey800 : ColorsManager.grey300)
                : null,
            borderRadius: BorderRadius.circular(16.sp),
            boxShadow: isSubmitting
                ? null
                : [
                    BoxShadow(
                      color: ColorsManager.blue2563EB.withOpacity(0.4),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: isSubmitting ? null : onSubmit,
              borderRadius: BorderRadius.circular(16.sp),
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
                                    ? ColorsManager.grey400
                                    : ColorsManager.grey600,
                              ),
                            ),
                          ),
                          SizedBox(width: 12.sw),
                          Text(
                            context.tr("common_sending"),
                            style: TextStyle(
                              color: isDark
                                  ? ColorsManager.grey400
                                  : ColorsManager.grey600,
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.check_circle_outline_rounded,
                            color: ColorsManager.white,
                            size: 22.sp,
                          ),
                          SizedBox(width: 10.sw),
                          Text(
                            context.tr("owner_submit_chalet"),
                            style: TextStyle(
                              color: ColorsManager.white,
                              fontSize: 17.sp,
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
