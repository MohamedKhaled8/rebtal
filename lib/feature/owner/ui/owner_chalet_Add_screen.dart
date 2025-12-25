import 'package:rebtal/core/Router/export_routes.dart';
import 'package:rebtal/core/utils/helper/helper_image.dart';
import 'package:rebtal/core/utils/constant/color_manager.dart';
import 'package:rebtal/feature/owner/logic/cubit/owner_cubit.dart';
import 'package:rebtal/feature/owner/logic/cubit/owner_state.dart';
import 'package:rebtal/feature/owner/widget/image_upload_section.dart';
import 'package:rebtal/feature/owner/widget/profile_picture_section.dart';
import 'package:rebtal/feature/owner/widget/amenities_selection_section.dart';
import 'package:rebtal/feature/owner/ui/flutter_map_location_picker.dart';
import 'package:rebtal/feature/auth/cubit/auth_cubit.dart';

class OwnerChaletAddScreen extends StatefulWidget {
  const OwnerChaletAddScreen({super.key});

  @override
  State<OwnerChaletAddScreen> createState() => _OwnerChaletAddScreenState();
}

class _OwnerChaletAddScreenState extends State<OwnerChaletAddScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _chaletNameController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _chaletAreaController = TextEditingController();
  final TextEditingController _bedroomsController = TextEditingController();
  final TextEditingController _bathroomsController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _childrenCountController =
      TextEditingController();
  final TextEditingController _discountValueController =
      TextEditingController();

  bool _isInitialized = false;

  void _autoFillUserData(BuildContext context) {
    if (!_isInitialized && mounted) {
      try {
        final authCubit = context.read<AuthCubit>();
        final currentUser = authCubit.getCurrentUser();

        if (currentUser != null) {
          // We need to access the cubit safely here
          final cubit = _localCubit ?? context.read<OwnerCubit>();

          // Auto-fill name and email
          if (_nameController.text.isEmpty) {
            _nameController.text = currentUser.name;
            cubit.updateMerchantName(currentUser.name);
          }

          if (_emailController.text.isEmpty) {
            _emailController.text = currentUser.email;
            cubit.updateEmail(currentUser.email);
          }

          _isInitialized = true;
        }
      } catch (e) {
        debugPrint('Auto-fill error: $e');
      }
    }
  }

  // Manage Cubit lifecycle
  OwnerCubit? _localCubit;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Check if Cubit is provided from above
    try {
      context.read<OwnerCubit>();
    } catch (e) {
      // If not provided, create a local one if not already created
      _localCubit ??= OwnerCubit();
    }
  }

  @override
  void dispose() {
    _localCubit?.close();
    // ... dispose controllers ...
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // If we have a local cubit, provide it. Otherwise, assume it's provided from above.
    if (_localCubit != null) {
      return BlocProvider.value(
        value: _localCubit!,
        child: _OwnerScreenContent(
          formKey: _formKey,
          chaletNameController: _chaletNameController,
          nameController: _nameController,
          descriptionController: _descriptionController,
          phoneController: _phoneController,
          locationController: _locationController,
          priceController: _priceController,
          chaletAreaController: _chaletAreaController,
          bedroomsController: _bedroomsController,
          bathroomsController: _bathroomsController,
          emailController: _emailController,
          childrenCountController: _childrenCountController,
          discountValueController: _discountValueController,
          autoFillCallback: _autoFillUserData,
        ),
      );
    } else {
      return _OwnerScreenContent(
        formKey: _formKey,
        chaletNameController: _chaletNameController,
        nameController: _nameController,
        descriptionController: _descriptionController,
        phoneController: _phoneController,
        locationController: _locationController,
        priceController: _priceController,
        chaletAreaController: _chaletAreaController,
        bedroomsController: _bedroomsController,
        bathroomsController: _bathroomsController,
        emailController: _emailController,
        childrenCountController: _childrenCountController,
        discountValueController: _discountValueController,
        autoFillCallback: _autoFillUserData,
      );
    }
  }
}

class _OwnerScreenContent extends StatefulWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController chaletNameController;
  final TextEditingController nameController;
  final TextEditingController descriptionController;
  final TextEditingController phoneController;
  final TextEditingController locationController;
  final TextEditingController priceController;
  final TextEditingController chaletAreaController;
  final TextEditingController bedroomsController;
  final TextEditingController bathroomsController;
  final TextEditingController emailController;
  final TextEditingController childrenCountController;
  final TextEditingController discountValueController;
  final Function(BuildContext) autoFillCallback;

  const _OwnerScreenContent({
    required this.formKey,
    required this.chaletNameController,
    required this.nameController,
    required this.descriptionController,
    required this.phoneController,
    required this.locationController,
    required this.priceController,
    required this.chaletAreaController,
    required this.bedroomsController,
    required this.bathroomsController,
    required this.emailController,
    required this.childrenCountController,
    required this.discountValueController,
    required this.autoFillCallback,
  });

  @override
  State<_OwnerScreenContent> createState() => _OwnerScreenContentState();
}

class _OwnerScreenContentState extends State<_OwnerScreenContent> {
  bool _isInitialized = false;

  void _autoFillUserData(BuildContext context) {
    if (!_isInitialized && mounted) {
      try {
        final authCubit = context.read<AuthCubit>();
        final currentUser = authCubit.getCurrentUser();

        if (currentUser != null) {
          final ownerCubit = context.read<OwnerCubit>();

          if (widget.nameController.text.isEmpty) {
            widget.nameController.text = currentUser.name;
            ownerCubit.updateMerchantName(currentUser.name);
          }

          if (widget.emailController.text.isEmpty) {
            widget.emailController.text = currentUser.email;
            ownerCubit.updateEmail(currentUser.email);
          }

          _isInitialized = true;
        }
      } catch (e) {
        debugPrint('Auto-fill error: $e');
      }
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _autoFillUserData(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: _buildModernAppBar(),
      body: BlocBuilder<OwnerCubit, OwnerState>(
        builder: (context, state) {
          final data = context.read<OwnerCubit>().currentData;

          // Sync controllers with state
          _syncControllers(data);

          // Auto-fill user data
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _autoFillUserData(context);
          });

          return SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Form(
              key: widget.formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeaderSection(),
                  const SizedBox(height: 24),

                  // Profile Picture
                  _buildSectionCard(
                    child: ProfilePictureSection(
                      profileImage: data.profileImage,
                      onTap: () => HelperImage().addProfilePicture(context),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Image Upload
                  _buildSectionCard(
                    child: ImageUploadSection(
                      images: data.uploadedImages,
                      onAdd: () => HelperImage().addSampleImages(context),
                      onRemove: (index) =>
                          context.read<OwnerCubit>().removeChaletImage(index),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Owner Information
                  _buildOwnerInfoSection(context, data),
                  const SizedBox(height: 20),

                  // Chalet Details
                  _buildChaletDetailsSection(context, data),
                  const SizedBox(height: 20),

                  // Location
                  _buildLocationSection(context, data),
                  const SizedBox(height: 20),

                  // Property Details (Base Price)
                  _buildPropertyDetailsSection(context, data),
                  const SizedBox(height: 20),

                  // Discount Section
                  if (data.discountEnabled)
                    _buildDiscountSection(context, data),
                  if (data.discountEnabled) const SizedBox(height: 20),

                  // Children Count
                  _buildChildrenCountSection(context, data),
                  const SizedBox(height: 20),

                  // Features Section
                  _buildFeaturesSection(context, data),
                  const SizedBox(height: 20),

                  // Availability
                  _buildAvailabilitySection(context, state),
                  const SizedBox(height: 20),

                  // Amenities
                  AmenitiesSelectionSection(
                    selectedAmenities: context
                        .read<OwnerCubit>()
                        .getAmenitiesMap(),
                    onAmenityChanged: (key, value) {
                      context.read<OwnerCubit>().updateAmenity(key, value);
                    },
                  ),
                  const SizedBox(height: 32),

                  // Submit Button
                  _buildSubmitButton(context),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _syncControllers(OwnerData data) {
    if (data.chaletName != null &&
        widget.chaletNameController.text != data.chaletName) {
      widget.chaletNameController.text = data.chaletName ?? '';
    }
    if (data.description != null &&
        widget.descriptionController.text != data.description) {
      widget.descriptionController.text = data.description ?? '';
    }
    if (data.phoneNumber != null &&
        widget.phoneController.text != data.phoneNumber) {
      widget.phoneController.text = data.phoneNumber ?? '';
    }
    if (data.price.isNotEmpty && widget.priceController.text != data.price) {
      widget.priceController.text = data.price;
    }
    if (data.chaletArea != null &&
        widget.chaletAreaController.text != data.chaletArea) {
      widget.chaletAreaController.text = data.chaletArea ?? '';
    }
    if (data.selectedLocation.isNotEmpty &&
        widget.locationController.text != data.selectedLocation) {
      widget.locationController.text = data.selectedLocation;
    }
    if (data.bedrooms != null &&
        widget.bedroomsController.text != data.bedrooms.toString()) {
      widget.bedroomsController.text = data.bedrooms?.toString() ?? '';
    }
    if (data.bathrooms != null &&
        widget.bathroomsController.text != data.bathrooms.toString()) {
      widget.bathroomsController.text = data.bathrooms?.toString() ?? '';
    }
    if (data.childrenCount != null &&
        widget.childrenCountController.text != data.childrenCount.toString()) {
      widget.childrenCountController.text =
          data.childrenCount?.toString() ?? '';
    }
    if (data.discountValue != null &&
        widget.discountValueController.text != data.discountValue) {
      widget.discountValueController.text = data.discountValue ?? '';
    }
  }

  PreferredSizeWidget _buildModernAppBar() {
    return AppBar(
      elevation: 0,
      backgroundColor: Colors.white,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new, size: 20),
        color: Colors.grey.shade800,
        onPressed: () => Navigator.of(context).pop(),
      ),
      title: Text(
        'Add New Chalet',
        style: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.bold,
          color: Colors.grey.shade800,
        ),
      ),
      centerTitle: true,
    );
  }

  Widget _buildHeaderSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Create Your Listing',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Colors.grey.shade800,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Share your beautiful chalet with travelers',
          style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
        ),
      ],
    );
  }

  Widget _buildSectionCard({required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _buildOwnerInfoSection(BuildContext context, OwnerData data) {
    return _buildSectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader(
            icon: Icons.person_outline_rounded,
            title: 'Owner Information',
            color: Colors.blue,
          ),
          const SizedBox(height: 24),
          _buildReadOnlyField(
            controller: widget.nameController,
            label: 'Owner Name',
            icon: Icons.person_rounded,
            hint: 'Enter owner name',
          ),
          const SizedBox(height: 16),
          _buildReadOnlyField(
            controller: widget.emailController,
            label: 'Email Address',
            icon: Icons.email_rounded,
            hint: 'Enter email address',
          ),
          const SizedBox(height: 16),
          _buildModernTextField(
            controller: widget.phoneController,
            label: 'Phone Number',
            icon: Icons.phone_rounded,
            hint: 'Enter phone number',
            keyboardType: TextInputType.phone,
            validator: (v) =>
                (v == null || v.isEmpty) ? 'Please enter phone number' : null,
            onChanged: (v) => context.read<OwnerCubit>().updatePhoneNumber(v),
          ),
        ],
      ),
    );
  }

  Widget _buildChaletDetailsSection(BuildContext context, OwnerData data) {
    return _buildSectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader(
            icon: Icons.home_rounded,
            title: 'Chalet Details',
            color: Colors.purple,
          ),
          const SizedBox(height: 24),
          _buildModernTextField(
            controller: widget.chaletNameController,
            label: 'Chalet Name',
            icon: Icons.villa_rounded,
            hint: 'Enter chalet name',
            validator: (v) =>
                (v == null || v.isEmpty) ? 'Please enter chalet name' : null,
            onChanged: (v) => context.read<OwnerCubit>().updateChaletName(v),
          ),
          const SizedBox(height: 16),
          _buildModernTextField(
            controller: widget.descriptionController,
            label: 'Description',
            icon: Icons.description_rounded,
            hint: 'Describe your chalet...',
            keyboardType: TextInputType.multiline,
            maxLines: 5,
            validator: (v) =>
                (v == null || v.isEmpty) ? 'Please enter description' : null,
            onChanged: (v) => context.read<OwnerCubit>().updateDescription(v),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationSection(BuildContext context, OwnerData data) {
    return _buildSectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader(
            icon: Icons.location_on_rounded,
            title: 'Location',
            color: Colors.orange,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () async {
              final selected = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => FlutterMapLocationPicker(
                    initialAddress: widget.locationController.text,
                    initialLat: null, // Will use default Cairo location
                    initialLon: null,
                  ),
                ),
              );
              if (selected is Map) {
                final addr = selected['address'] as String?;
                final lat = selected['lat'] as double?;
                final lon = selected['lon'] as double?;
                if (addr != null && addr.isNotEmpty) {
                  widget.locationController.text = addr;
                  if (mounted) {
                    context.read<OwnerCubit>().updateGeo(
                      lat: lat ?? 0,
                      lon: lon ?? 0,
                      address: addr,
                    );
                  }
                }
              } else if (selected is String && selected.isNotEmpty) {
                widget.locationController.text = selected;
                if (mounted) {
                  context.read<OwnerCubit>().updateLocation(selected);
                }
              }
            },
            icon: const Icon(Icons.map_outlined, size: 20),
            label: const Text('Select Location on Map'),
            style: ElevatedButton.styleFrom(
              backgroundColor: ColorManager.kPrimaryGradient.colors.first,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
          ),
          const SizedBox(height: 16),
          _buildReadOnlyField(
            controller: widget.locationController,
            label: 'Selected Address',
            icon: Icons.place_rounded,
            hint: 'Selected address will appear here',
          ),
        ],
      ),
    );
  }

  Widget _buildPropertyDetailsSection(BuildContext context, OwnerData data) {
    return _buildSectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader(
            icon: Icons.info_outline_rounded,
            title: 'Property Details',
            color: Colors.teal,
          ),
          const SizedBox(height: 24),
          // Price Field
          _buildModernTextField(
            controller: widget.priceController,
            label: 'Base Price per Night (EGP)',
            icon: Icons.attach_money_rounded,
            hint: 'Enter price per night',
            keyboardType: TextInputType.number,
            validator: (v) =>
                (v == null || v.isEmpty) ? 'Please enter price' : null,
            onChanged: (v) => context.read<OwnerCubit>().updatePrice(v),
          ),
          const SizedBox(height: 16),
          // Chalet Area Field
          _buildModernTextField(
            controller: widget.chaletAreaController,
            label: 'Chalet Area (m²)',
            icon: Icons.square_foot_rounded,
            hint: 'Enter area in square meters',
            keyboardType: TextInputType.number,
            validator: (v) =>
                (v == null || v.isEmpty) ? 'Please enter area' : null,
            onChanged: (v) => context.read<OwnerCubit>().updateChaletArea(v),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: _buildModernTextField(
                  controller: widget.bedroomsController,
                  label: 'Bedrooms',
                  icon: Icons.bed_rounded,
                  hint: '0',
                  keyboardType: TextInputType.number,
                  validator: (v) =>
                      (v == null || v.isEmpty) ? 'Required' : null,
                  onChanged: (v) {
                    final value = int.tryParse(v) ?? 0;
                    context.read<OwnerCubit>().updateBedrooms(value);
                  },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildModernTextField(
                  controller: widget.bathroomsController,
                  label: 'Bathrooms',
                  icon: Icons.bathtub_rounded,
                  hint: '0',
                  keyboardType: TextInputType.number,
                  validator: (v) =>
                      (v == null || v.isEmpty) ? 'Required' : null,
                  onChanged: (v) {
                    final value = int.tryParse(v) ?? 0;
                    context.read<OwnerCubit>().updateBathrooms(value);
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          // Discount Toggle
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.local_offer_rounded,
                    color: Colors.grey.shade700,
                    size: 22,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Enable Discount',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade800,
                    ),
                  ),
                ],
              ),
              Switch(
                value: data.discountEnabled,
                onChanged: (value) {
                  context.read<OwnerCubit>().updateDiscountEnabled(value);
                },
                activeColor: ColorManager.kPrimaryGradient.colors.first,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAvailabilitySection(BuildContext context, OwnerState state) {
    return _buildSectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader(
            icon: Icons.calendar_today_rounded,
            title: 'Availability Period',
            color: Colors.pink,
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: _buildDateSelector(
                  context: context,
                  label: 'From Date',
                  icon: Icons.play_arrow_rounded,
                  selectedDate: state is OwnerData ? state.availableFrom : null,
                  onTap: () async {
                    final now = DateTime.now();
                    DateTime? picked = await showDatePicker(
                      context: context,
                      initialDate: now,
                      firstDate: now,
                      lastDate: DateTime(now.year + 2),
                      builder: (context, child) {
                        return Theme(
                          data: Theme.of(context).copyWith(
                            colorScheme: ColorScheme.light(
                              primary:
                                  ColorManager.kPrimaryGradient.colors.first,
                              onPrimary: Colors.white,
                              surface: Colors.white,
                              onSurface: Colors.black,
                            ),
                          ),
                          child: child!,
                        );
                      },
                    );
                    if (picked != null) {
                      context.read<OwnerCubit>().updateAvailableFrom(picked);
                    }
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildDateSelector(
                  context: context,
                  label: 'To Date',
                  icon: Icons.stop_rounded,
                  selectedDate: state is OwnerData ? state.availableTo : null,
                  onTap: () async {
                    final now = DateTime.now();
                    final fromDate = state is OwnerData
                        ? state.availableFrom
                        : now;
                    DateTime? picked = await showDatePicker(
                      context: context,
                      initialDate: fromDate ?? now,
                      firstDate: fromDate ?? now,
                      lastDate: DateTime(now.year + 2),
                      builder: (context, child) {
                        return Theme(
                          data: Theme.of(context).copyWith(
                            colorScheme: ColorScheme.light(
                              primary:
                                  ColorManager.kPrimaryGradient.colors.first,
                              onPrimary: Colors.white,
                              surface: Colors.white,
                              onSurface: Colors.black,
                            ),
                          ),
                          child: child!,
                        );
                      },
                    );
                    if (picked != null) {
                      context.read<OwnerCubit>().updateAvailableTo(picked);
                    }
                  },
                ),
              ),
            ],
          ),
          if (state is OwnerData &&
              state.availableFrom != null &&
              state.availableTo != null)
            Container(
              margin: const EdgeInsets.only(top: 16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.check_circle_outline,
                    color: Colors.grey.shade600,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Duration: ${_calculateDays(state.availableFrom!, state.availableTo!)} days',
                      style: TextStyle(
                        color: Colors.grey.shade700,
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildDiscountSection(BuildContext context, OwnerData data) {
    final basePrice = double.tryParse(data.price) ?? 0.0;
    final discountValue = double.tryParse(data.discountValue ?? '0') ?? 0.0;
    double finalPrice = basePrice;

    if (data.discountType == 'percentage' && discountValue > 0) {
      finalPrice = basePrice * (1 - discountValue / 100);
    } else if (data.discountType == 'fixed' && discountValue > 0) {
      finalPrice = basePrice - discountValue;
      if (finalPrice < 0) finalPrice = 0;
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.orange.withOpacity(0.1),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader(
            icon: Icons.local_offer_rounded,
            title: 'Discount',
            color: Colors.orange,
          ),
          const SizedBox(height: 24),
          // Discount Type Selection
          Text(
            'Discount Type',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade700,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildDiscountTypeChip(
                  context: context,
                  label: 'Percentage (%)',
                  value: 'percentage',
                  selected: data.discountType == 'percentage',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildDiscountTypeChip(
                  context: context,
                  label: 'Fixed Amount',
                  value: 'fixed',
                  selected: data.discountType == 'fixed',
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          // Discount Value Input
          _buildModernTextField(
            controller: widget.discountValueController,
            label: data.discountType == 'percentage'
                ? 'Discount Percentage (%)'
                : 'Discount Amount (EGP)',
            icon: Icons.percent_rounded,
            hint: data.discountType == 'percentage'
                ? 'Enter percentage'
                : 'Enter amount',
            keyboardType: TextInputType.number,
            validator: (v) {
              if (v == null || v.isEmpty) {
                return 'Please enter discount value';
              }
              final value = double.tryParse(v);
              if (value == null || value <= 0) {
                return 'Invalid value';
              }
              if (data.discountType == 'percentage' && value > 100) {
                return 'Percentage cannot exceed 100%';
              }
              if (data.discountType == 'fixed' && value >= basePrice) {
                return 'Discount cannot exceed base price';
              }
              return null;
            },
            onChanged: (v) {
              context.read<OwnerCubit>().updateDiscountValue(v);
            },
          ),
          const SizedBox(height: 24),
          // Price Preview
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Original Price',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${basePrice.toStringAsFixed(2)} EGP',
                      style: TextStyle(
                        fontSize: 16,
                        decoration: TextDecoration.lineThrough,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
                Icon(
                  Icons.arrow_forward_rounded,
                  color: Colors.grey.shade400,
                  size: 20,
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'Final Price',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${finalPrice.toStringAsFixed(2)} EGP',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: ColorManager.kPrimaryGradient.colors.first,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDiscountTypeChip({
    required BuildContext context,
    required String label,
    required String value,
    required bool selected,
  }) {
    return GestureDetector(
      onTap: () {
        context.read<OwnerCubit>().updateDiscountType(value);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: selected
              ? ColorManager.kPrimaryGradient.colors.first.withOpacity(0.1)
              : Colors.grey.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected
                ? ColorManager.kPrimaryGradient.colors.first
                : Colors.grey.shade300,
            width: selected ? 2 : 1,
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
              color: selected
                  ? ColorManager.kPrimaryGradient.colors.first
                  : Colors.grey.shade700,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildChildrenCountSection(BuildContext context, OwnerData data) {
    return _buildSectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader(
            icon: Icons.child_care_rounded,
            title: 'Children Count',
            color: Colors.pink,
          ),
          const SizedBox(height: 24),
          _buildModernTextField(
            controller: widget.childrenCountController,
            label: 'Number of Children',
            icon: Icons.people_rounded,
            hint: 'Enter number of children',
            keyboardType: TextInputType.number,
            validator: (v) {
              if (v == null || v.isEmpty) {
                return 'Please enter children count';
              }
              final value = int.tryParse(v);
              if (value == null || value < 0) {
                return 'Please enter a valid number';
              }
              return null;
            },
            onChanged: (v) {
              final value = int.tryParse(v);
              context.read<OwnerCubit>().updateChildrenCount(value);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildFeaturesSection(BuildContext context, OwnerData data) {
    final availableFeatures = [
      'Pool',
      'Sea',
      'Family Gathering',
      'Luxury',
      'Mountain',
    ];

    return _buildSectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader(
            icon: Icons.star_rounded,
            title: 'Features',
            color: Colors.amber,
          ),
          const SizedBox(height: 24),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: availableFeatures.map((feature) {
              final isSelected = data.features.contains(feature);
              return GestureDetector(
                onTap: () {
                  context.read<OwnerCubit>().toggleFeature(feature);
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? ColorManager.kPrimaryGradient.colors.first
                        : Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(25),
                    border: Border.all(
                      color: isSelected
                          ? ColorManager.kPrimaryGradient.colors.first
                          : Colors.grey.shade300,
                      width: isSelected ? 2 : 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isSelected ? Icons.check_circle : Icons.circle_outlined,
                        size: 20,
                        color: isSelected ? Colors.white : Colors.grey.shade600,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        feature,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: isSelected
                              ? FontWeight.w600
                              : FontWeight.normal,
                          color: isSelected
                              ? Colors.white
                              : Colors.grey.shade700,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildSubmitButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {
          if (widget.formKey.currentState!.validate()) {
            HelperImage().submitForm(context, widget.formKey);
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: ColorManager.kPrimaryGradient.colors.first,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 2,
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.check_circle_outline, size: 22),
            SizedBox(width: 12),
            Text(
              'Submit Listing',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader({
    required IconData icon,
    required String title,
    required Color color,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: Colors.grey.shade700, size: 22),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.grey.shade800,
          ),
        ),
      ],
    );
  }

  Widget _buildModernTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required String hint,
    TextInputType? keyboardType,
    int maxLines = 1,
    String? Function(String?)? validator,
    void Function(String)? onChanged,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      validator: validator,
      onChanged: onChanged,
      style: TextStyle(color: Colors.grey.shade800, fontSize: 15),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, color: Colors.grey.shade600, size: 22),
        filled: true,
        fillColor: Colors.grey.shade50,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: ColorManager.kPrimaryGradient.colors.first,
            width: 2,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
      ),
    );
  }

  Widget _buildReadOnlyField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required String hint,
  }) {
    return TextFormField(
      controller: controller,
      readOnly: true,
      style: TextStyle(color: Colors.grey.shade700, fontSize: 15),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, color: Colors.grey.shade600, size: 22),
        suffixIcon: Icon(
          Icons.lock_outline,
          size: 18,
          color: Colors.grey.shade400,
        ),
        filled: true,
        fillColor: Colors.grey.shade100,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
      ),
    );
  }

  Widget _buildDateSelector({
    required BuildContext context,
    required String label,
    required IconData icon,
    required DateTime? selectedDate,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selectedDate != null
                ? ColorManager.kPrimaryGradient.colors.first
                : Colors.grey.shade300,
            width: selectedDate != null ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: selectedDate != null
                  ? ColorManager.kPrimaryGradient.colors.first
                  : Colors.grey.shade600,
              size: 22,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    selectedDate != null
                        ? "${selectedDate.day}/${selectedDate.month}/${selectedDate.year}"
                        : "Select date",
                    style: TextStyle(
                      fontSize: 15,
                      color: selectedDate != null
                          ? Colors.grey.shade800
                          : Colors.grey.shade500,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.calendar_today_outlined,
              color: Colors.grey.shade400,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  int _calculateDays(DateTime from, DateTime to) {
    return to.difference(from).inDays + 1;
  }
}
