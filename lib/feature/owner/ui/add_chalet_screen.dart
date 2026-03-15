import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rebtal/core/utils/widgets/premium_loading_overlay.dart';
import 'package:rebtal/core/app/cubit/app_cubit.dart';
import 'package:rebtal/core/utils/constant/color_manager.dart';
import 'package:rebtal/core/utils/helper/snack_bar_helper.dart';
import 'package:rebtal/core/utils/theme/dynamic_theme_manager.dart';
import 'package:rebtal/feature/maps/ui/flutter_map_location_picker.dart';
import 'package:rebtal/feature/owner/logic/cubit/owner_cubit.dart';
import 'package:rebtal/feature/owner/logic/cubit/owner_state.dart';
import 'package:rebtal/feature/owner/widget/add_chalet_widgets.dart';
import 'package:rebtal/feature/owner/widget/modern_image_upload_section.dart';
import 'package:rebtal/feature/owner/widget/modern_amenities_section.dart';
import 'package:rebtal/core/utils/helper/helper_image.dart';
import 'package:responsive_screen_master/responsive_screen_master.dart';

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
            ? ColorsManager.darkBackground0A0E27
            : ColorsManager.lightBackgroundF8FAFF,
        appBar: _buildAppBar(context, isDark),
        body: _AddChaletContent(ownerCubit: ownerCubit),
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
          ? ColorsManager.darkBackground0A0E27
          : ColorsManager.lightBackgroundF8FAFF,
      leading: IconButton(
        icon: Container(
          padding: EdgeInsets.all(8.sp),
          decoration: BoxDecoration(
            color: isDark ? ColorsManager.white10 : ColorsManager.grey200,
            borderRadius: BorderRadius.circular(12.sp),
          ),
          child: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: isDark ? ColorsManager.white : ColorsManager.black,
            size: 20.spScaled,
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
              color: isDark ? ColorsManager.white : ColorsManager.black,
              fontSize: 20.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            "Fill in the details below",
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

class _AddChaletContent extends StatelessWidget {
  const _AddChaletContent({required this.ownerCubit});

  final OwnerCubit ownerCubit;

  void _scrollToSection(BuildContext context, String sectionKey) {
    // Find the scrollable widget and access its scroll controller
    final scrollable = context.findAncestorWidgetOfExactType<Scrollable>();
    if (scrollable != null) {
      // Delay to allow the UI to update first
      Future.delayed(const Duration(milliseconds: 300), () {
        // Use a different approach - find the ScrollController via the context
        final scrollController = PrimaryScrollController.of(context);
        if (scrollController.hasClients) {
          scrollController.animateTo(
            800.0, // Approximate position of bedrooms section
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeInOut,
          );
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = DynamicThemeManager.isDarkMode(context);

    return BlocBuilder<OwnerCubit, OwnerState>(
      bloc: ownerCubit,
      builder: (context, state) {
        final draft = state.draft;

        return SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            horizontal: stv(
              context: context,
              mobile: 20.sw,
              tablet: 32.sw,
              desktop: 48.sw,
            ),
            vertical: 20.sh,
          ),
          child: _buildSingleColumn(context, isDark, ownerCubit, draft),
        );
      },
    );
  }

  Widget _buildSingleColumn(
    BuildContext context,
    bool isDark,
    OwnerCubit ownerCubit,
    dynamic draft,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Progress Indicator
        _buildProgressIndicator(isDark),
        SizedBox(height: 24.sh),

        // Image Section
        ModernImageUploadSection(
          images: draft.uploadedImages,
          onAdd: () => HelperImage().addSampleImages(context),
          onRemove: (index) => ownerCubit.removeChaletImage(index),
        ),
        SizedBox(height: 24.sh),

        // Basic Info Card
        _buildSectionCard(
          isDark: isDark,
          title: "Basic Information",
          icon: Icons.info_outline_rounded,
          iconColor: ColorsManager.blue2563EB,
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
              SizedBox(height: 16.sh),
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
        SizedBox(height: 20.sh),

        // Location Section
        LocationSection(
          address: draft.selectedLocation,
          selectedPopularDestination: draft.popularDestination,
          onPopularDestinationChanged: ownerCubit.selectPopularDestination,
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
        SizedBox(height: 20.sh),

        // Pricing & Details Card
        _buildSectionCard(
          isDark: isDark,
          title: "Pricing & Details",
          icon: Icons.attach_money_rounded,
          iconColor: ColorsManager.green3DDC84,
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
              SizedBox(height: 16.sh),
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
                  SizedBox(width: 12.sw),
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
              SizedBox(height: 16.sh),
              _buildDayUseToggle(isDark, draft.dayUseEnabled, ownerCubit),
            ],
          ),
        ),
        SizedBox(height: 20.sh),

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
            if (picked != null) {
              ownerCubit.selectAvailableFromDate(picked);
              // Auto-scroll to bedrooms section after date selection
              _scrollToSection(context, 'bedrooms');
            }
          },
          onSelectTo: () async {
            final now = DateTime.now();
            final picked = await showDatePicker(
              context: context,
              initialDate: draft.availableTo ?? (draft.availableFrom ?? now),
              firstDate: draft.availableFrom ?? now,
              lastDate: DateTime(now.year + 2),
            );
            if (picked != null) {
              ownerCubit.selectAvailableToDate(picked);
              // Auto-scroll to bedrooms section after date selection
              _scrollToSection(context, 'bedrooms');
            }
          },
        ),
        SizedBox(height: 20.sh),

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
        SizedBox(height: 80.sh), // Space for bottom button
      ],
    );
  }

  Widget _buildLeftColumn(
    BuildContext context,
    bool isDark,
    OwnerCubit ownerCubit,
    dynamic draft,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Progress Indicator
        _buildProgressIndicator(isDark),
        SizedBox(height: 24.sh),

        // Image Section
        ModernImageUploadSection(
          images: draft.uploadedImages,
          onAdd: () => HelperImage().addSampleImages(context),
          onRemove: (index) => ownerCubit.removeChaletImage(index),
        ),
        SizedBox(height: 24.sh),

        // Basic Info Card
        _buildSectionCard(
          isDark: isDark,
          title: "Basic Information",
          icon: Icons.info_outline_rounded,
          iconColor: ColorsManager.blue2563EB,
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
              SizedBox(height: 16.sh),
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
        SizedBox(height: 20.sh),

        // Location Section
        LocationSection(
          address: draft.selectedLocation,
          selectedPopularDestination: draft.popularDestination,
          onPopularDestinationChanged: ownerCubit.selectPopularDestination,
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
        SizedBox(height: 20.sh),

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
            if (picked != null) {
              ownerCubit.selectAvailableFromDate(picked);
              // Auto-scroll to bedrooms section after date selection
              _scrollToSection(context, 'bedrooms');
            }
          },
          onSelectTo: () async {
            final now = DateTime.now();
            final picked = await showDatePicker(
              context: context,
              initialDate: draft.availableTo ?? (draft.availableFrom ?? now),
              firstDate: draft.availableFrom ?? now,
              lastDate: DateTime(now.year + 2),
            );
            if (picked != null) {
              ownerCubit.selectAvailableToDate(picked);
              // Auto-scroll to bedrooms section after date selection
              _scrollToSection(context, 'bedrooms');
            }
          },
        ),
      ],
    );
  }

  Widget _buildRightColumn(
    BuildContext context,
    bool isDark,
    OwnerCubit ownerCubit,
    dynamic draft,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Pricing & Details Card
        _buildSectionCard(
          isDark: isDark,
          title: "Pricing & Details",
          icon: Icons.attach_money_rounded,
          iconColor: ColorsManager.green3DDC84,
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
              SizedBox(height: 16.sh),
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
                  SizedBox(width: 12.sw),
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
              SizedBox(height: 16.sh),
              _buildDayUseToggle(isDark, draft.dayUseEnabled, ownerCubit),
            ],
          ),
        ),
        SizedBox(height: 20.sh),

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
        SizedBox(height: 80.sh), // Space for bottom button
      ],
    );
  }

  Widget _buildProgressIndicator(bool isDark) {
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
        borderRadius: BorderRadius.circular(16.sp),
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
                  "Create Your Listing",
                  style: TextStyle(
                    color: isDark ? ColorsManager.white : ColorsManager.black,
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 4.sh),
                Text(
                  "Add photos, details, and amenities",
                  style: TextStyle(
                    color: isDark
                        ? ColorsManager.grey400
                        : ColorsManager.grey600,
                    fontSize: 13.sp,
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
      padding: EdgeInsets.all(20.sp),
      decoration: BoxDecoration(
        color: isDark ? ColorsManager.darkBlue1A1A2E : ColorsManager.white,
        borderRadius: BorderRadius.circular(20.sp),
        border: Border.all(
          color: isDark
              ? ColorsManager.grey800.withOpacity(0.3)
              : ColorsManager.grey200,
        ),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? ColorsManager.black.withOpacity(0.3)
                : ColorsManager.black.withOpacity(0.05),
            blurRadius: 20.sp,
            offset: Offset(0, 4.sp),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(10.sp),
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12.sp),
                ),
                child: Icon(icon, color: iconColor, size: 22.sp),
              ),
              SizedBox(width: 12.sw),
              Text(
                title,
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                  color: isDark ? ColorsManager.white : ColorsManager.black,
                ),
              ),
            ],
          ),
          SizedBox(height: 20.sh),
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
        color: isDark ? ColorsManager.white : ColorsManager.black,
        fontSize: 15.sp,
      ),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        labelStyle: TextStyle(
          color: isDark ? ColorsManager.grey400 : ColorsManager.grey600,
          fontSize: 14.sp,
        ),
        hintStyle: TextStyle(
          color: isDark ? ColorsManager.grey600 : ColorsManager.grey400,
          fontSize: 14.sp,
        ),
        prefixIcon: Icon(
          icon,
          color: isDark ? ColorsManager.grey400 : ColorsManager.grey600,
          size: 22,
        ),
        filled: true,
        fillColor: isDark
            ? ColorsManager.darkBlue2A2E4B.withOpacity(0.5)
            : ColorsManager.grey50,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14.sp),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14.sp),
          borderSide: BorderSide(
            color: isDark
                ? ColorsManager.grey800.withOpacity(0.3)
                : ColorsManager.grey300,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14.sp),
          borderSide: BorderSide(color: ColorsManager.blue2563EB, width: 2),
        ),
        contentPadding: EdgeInsets.symmetric(
          horizontal: 16.sw,
          vertical: 16.sh,
        ),
      ),
    );
  }

  Widget _buildDayUseToggle(
    bool isDark,
    bool dayUseEnabled,
    OwnerCubit ownerCubit,
  ) {
    return Container(
      padding: EdgeInsets.all(16.sp),
      decoration: BoxDecoration(
        color: isDark
            ? ColorsManager.darkBlue2A2E4B.withOpacity(0.5)
            : ColorsManager.grey50,
        borderRadius: BorderRadius.circular(14.sp),
        border: Border.all(
          color: dayUseEnabled
              ? ColorsManager.blue2563EB
              : (isDark
                    ? ColorsManager.grey800.withOpacity(0.3)
                    : ColorsManager.grey300),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(8.sp),
            decoration: BoxDecoration(
              color: dayUseEnabled
                  ? ColorsManager.blue2563EB.withOpacity(0.15)
                  : ColorsManager.grey400.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10.sp),
            ),
            child: Icon(
              Icons.wb_sunny_rounded,
              color: dayUseEnabled
                  ? ColorsManager.blue2563EB
                  : ColorsManager.grey600,
              size: 20.sp,
            ),
          ),
          SizedBox(width: 12.sw),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Day Use (استخدام يومي)",
                  style: TextStyle(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  dayUseEnabled ? "مفعل" : "غير مفعل",
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: ColorsManager.grey600,
                  ),
                ),
              ],
            ),
          ),
          Switch.adaptive(
            value: dayUseEnabled,
            onChanged: ownerCubit.updateDayUseEnabled,
            activeColor: ColorsManager.blue2563EB,
          ),
        ],
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
          padding: EdgeInsets.all(20.sp),
          decoration: BoxDecoration(
            color: isDark ? ColorsManager.darkBlue1A1A2E : ColorsManager.white,
            boxShadow: [
              BoxShadow(
                color: ColorsManager.black.withOpacity(0.1),
                blurRadius: 20.sp,
                offset: Offset(0, 4.sp),
              ),
            ],
          ),
          child: SafeArea(
            child: Container(
              height: 56.sp,
              decoration: BoxDecoration(
                gradient: state.isFormSubmitting
                    ? null
                    : const LinearGradient(
                        colors: [
                          ColorsManager.blue2563EB,
                          ColorsManager.purple764BA2,
                        ],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),
                color: state.isFormSubmitting
                    ? (isDark ? ColorsManager.grey800 : ColorsManager.grey300)
                    : null,
                borderRadius: BorderRadius.circular(16.sp),
                boxShadow: state.isFormSubmitting
                    ? null
                    : [
                        BoxShadow(
                          color: ColorsManager.blue2563EB.withOpacity(0.4),
                          blurRadius: 20.sp,
                          offset: Offset(0, 8.sp),
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
                  borderRadius: BorderRadius.circular(16.sp),
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
                                        ? ColorsManager.grey400
                                        : ColorsManager.grey600,
                                  ),
                                ),
                              ),
                              SizedBox(width: 12.sw),
                              Text(
                                "Submitting...",
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
                                "Submit Chalet",
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
      },
    );
  }
}
