import 'dart:async';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rebtal/core/utils/format/currency.dart';
import 'package:rebtal/core/utils/helper/app_image_helper.dart';
import 'package:rebtal/feature/admin/logic/cubit/admin_cubit.dart';
import 'package:rebtal/feature/admin/widget/chalet/action_buttons.dart';
import 'package:rebtal/feature/admin/widget/chalet/availability_card.dart';
import 'package:rebtal/feature/admin/widget/chalet/image_gallery_card.dart';
import 'package:rebtal/feature/admin/widget/chalet/owner_information_card.dart';
import 'package:rebtal/feature/admin/widget/chalet/property_features_card.dart';
import 'package:rebtal/feature/admin/widget/chalet/request_details_card.dart';
import 'package:rebtal/feature/auth/cubit/auth_cubit.dart';
import 'package:rebtal/feature/booking/ui/booking_bridge_widget.dart';

class ChaletDetailPage extends StatefulWidget {
  final Map<String, dynamic> requestData;
  final String docId;
  final String status;

  const ChaletDetailPage({
    super.key,
    required this.requestData,
    required this.docId,
    required this.status,
  });

  @override
  State<ChaletDetailPage> createState() => _ChaletDetailPageState();
}

class _ChaletDetailPageState extends State<ChaletDetailPage> {
  final PageController _pageController = PageController();
  bool _isDescriptionExpanded = false;
  int _currentImageIndex = 0;
  Timer? _autoPlayTimer;

  @override
  void initState() {
    super.initState();
    _startAutoPlay();
  }

  void _startAutoPlay() {
    _autoPlayTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (_pageController.hasClients) {
        final images = context.read<AdminCubit>().extractImages(
          widget.requestData,
        );
        if (images.length > 1) {
          int nextIndex = _currentImageIndex + 1;
          if (nextIndex >= images.length) {
            nextIndex = 0;
          }
          _pageController.animateToPage(
            nextIndex,
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeInOut,
          );
        }
      }
    });
  }

  @override
  void dispose() {
    _autoPlayTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => AdminCubit()),
        BlocProvider(create: (context) => AuthCubit()),
      ],
      child: BlocBuilder<AdminCubit, AdminState>(
        builder: (context, state) {
          final cubit = context.read<AdminCubit>();
          final images = cubit.extractImages(widget.requestData);
          final hotelName = widget.requestData['chaletName'] ?? 'Chalet Name';
          final location = widget.requestData['location'] ?? 'Unknown Location';
          final price = widget.requestData['price'];
          final description =
              widget.requestData['description']?.toString() ?? '';

          return BlocBuilder<AuthCubit, AuthState>(
            builder: (context, authState) {
              String role = 'guest';
              if (authState is AuthSuccess) {
                role = authState.user.role.toLowerCase().trim();
              }

              return SafeArea(
                child: Scaffold(
                  backgroundColor: const Color(0xFFF5F8FF),
                  body: Stack(
                    children: [
                      // Main Scrollable Content
                      CustomScrollView(
                        physics: const BouncingScrollPhysics(),
                        slivers: [
                          // Image Header Section
                          SliverToBoxAdapter(
                            child: _buildImageHeader(
                              context,
                              images,
                              hotelName,
                              location,
                            ),
                          ),

                          // Content Section
                          SliverToBoxAdapter(
                            child: Container(
                              decoration: const BoxDecoration(
                                color: Color(0xFFF5F8FF),
                                borderRadius: BorderRadius.vertical(
                                  top: Radius.circular(21.994),
                                ),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.fromLTRB(
                                  11.52,
                                  8.798,
                                  11.52,
                                  100,
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // About Us Section
                                    _buildAboutUsSection(description),
                                    const SizedBox(height: 8.798),

                                    // Services & Facilities Section
                                    _buildServicesSection(widget.requestData),
                                    const SizedBox(height: 24),

                                    // Additional Details
                                    PropertyFeaturesCard(
                                      requestData: widget.requestData,
                                    ),
                                    const SizedBox(height: 24),

                                    // Gallery (if more images)
                                    if (images.length > 1) ...[
                                      ImageGalleryCard(
                                        requestData: widget.requestData,
                                        images: images,
                                      ),
                                      const SizedBox(height: 24),
                                    ],

                                    // Role-based Sections
                                    if (role == 'user' || role == 'owner') ...[
                                      OwnerInformationCard(
                                        requestData: widget.requestData,
                                      ),
                                      const SizedBox(height: 24),

                                      AvailabilityCard(
                                        requestData: widget.requestData,
                                      ),
                                      const SizedBox(height: 24),
                                    ],

                                    if (role == 'admin') ...[
                                      OwnerInformationCard(
                                        requestData: widget.requestData,
                                      ),
                                      const SizedBox(height: 24),

                                      AvailabilityCard(
                                        requestData: widget.requestData,
                                      ),
                                      const SizedBox(height: 24),

                                      _buildSectionTitle('تفاصيل الطلب'),
                                      const SizedBox(height: 12),
                                      RequestDetailsCard(
                                        docId: widget.docId,
                                        requestData: widget.requestData,
                                      ),
                                      const SizedBox(height: 24),
                                    ],

                                    // Action Buttons (for admin/owner)
                                    if (role == 'admin' || role == 'owner') ...[
                                      ActionButtons(
                                        status: widget.status,
                                        docId: widget.docId,
                                        requestData: widget.requestData,
                                      ),
                                      const SizedBox(height: 24),
                                    ],
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),

                      // Fixed Bottom Bar
                      if (role == 'user' || role == 'guest')
                        _buildFixedBottomBar(
                          context,
                          price,
                          widget.requestData,
                        ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  // Image Header - Updated
  Widget _buildImageHeader(
    BuildContext context,
    List<String> images,
    String hotelName,
    String location,
  ) {
    if (images.isEmpty) {
      return Container(
        height: 400,
        margin: const EdgeInsets.only(bottom: 16.31),
        decoration: BoxDecoration(
          color: Colors.grey[200], // Placeholder color
        ),
      );
    }

    return Container(
      height: 400,
      margin: const EdgeInsets.only(bottom: 16.31),
      decoration: const BoxDecoration(
        color: Colors.black, // Ensure no empty space behind
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Main Image with PageView
          GestureDetector(
            onTap: () {
              final cubit = context.read<AdminCubit>();
              cubit.openFullScreen(
                context,
                images: images,
                start: _currentImageIndex,
              );
            },
            child: PageView.builder(
              controller: _pageController,
              itemCount: images.length,
              onPageChanged: (index) {
                setState(() {
                  _currentImageIndex = index;
                });
              },
              itemBuilder: (context, index) {
                return Hero(
                  tag: 'chalet_image_$index',
                  child: AppImageHelper(path: images[index], fit: BoxFit.cover),
                );
              },
            ),
          ),

          // Gradient Overlay
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.2),
                    Colors.transparent,
                    Colors.black.withOpacity(0.8),
                  ],
                  stops: const [0.0, 0.5, 1.0],
                ),
              ),
            ),
          ),

          // Back Button (Top Left)
          Positioned(
            top: 50,
            left: 20,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.white.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: BackdropFilter(
                  filter: ui.ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: IconButton(
                    icon: const Icon(
                      Icons.arrow_back_ios_new,
                      color: Colors.white,
                      size: 20,
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
              ),
            ),
          ),

          // Thumbnails (Bottom Right)
          if (images.length > 1)
            Positioned(
              right: 20,
              bottom: 100, // Adjusted position
              child: SizedBox(
                height: 60,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  shrinkWrap: true,
                  itemCount: images.length > 4 ? 4 : images.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (context, index) {
                    final isSelected = _currentImageIndex == index;
                    return GestureDetector(
                      onTap: () {
                        _pageController.animateToPage(
                          index,
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      },
                      child: Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: isSelected
                              ? Border.all(color: Colors.white, width: 2)
                              : null,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.3),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: AppImageHelper(
                            path: images[index],
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),

          // Title and Location (Bottom Left)
          Positioned(
            bottom: 20,
            left: 20,
            right: 20,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  hotelName,
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    letterSpacing: 0.5,
                    shadows: [
                      Shadow(
                        color: Colors.black45,
                        blurRadius: 8,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(
                      Icons.location_on,
                      color: Colors.white,
                      size: 16,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        location,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFFE0E0E0),
                          height: 1.3,
                          shadows: [
                            Shadow(
                              color: Colors.black45,
                              blurRadius: 4,
                              offset: Offset(0, 1),
                            ),
                          ],
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
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

  // About Us Section
  Widget _buildAboutUsSection(String description) {
    final displayText = description.isNotEmpty
        ? description
        : 'No description available.';
    final shouldShowExpand = displayText.length > 150;
    final displayDescription = _isDescriptionExpanded || !shouldShowExpand
        ? displayText
        : '${displayText.substring(0, 150)}...';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'About Us',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: Color(0xFF1A1A2E),
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 12),
        AnimatedSize(
          duration: const Duration(milliseconds: 300),
          alignment: Alignment.topCenter,
          child: Text(
            displayDescription,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w400,
              color: Color(0xFF555555),
              height: 1.6,
              letterSpacing: 0.3,
            ),
            textAlign: TextAlign.justify,
          ),
        ),
        if (shouldShowExpand) ...[
          const SizedBox(height: 8),
          GestureDetector(
            onTap: () {
              setState(() {
                _isDescriptionExpanded = !_isDescriptionExpanded;
              });
            },
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _isDescriptionExpanded ? 'تقليص الوصف' : 'عرض المزيد',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF2C67FF),
                  ),
                ),
                const SizedBox(width: 4),
                Icon(
                  _isDescriptionExpanded
                      ? Icons.keyboard_arrow_up
                      : Icons.keyboard_arrow_down,
                  color: const Color(0xFF2C67FF),
                  size: 20,
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  // Services & Facilities Section
  Widget _buildServicesSection(Map<String, dynamic> requestData) {
    final amenitiesList = [
      {'label': 'Swimming pool', 'key': 'hasPool'},
      {'label': 'Parking area', 'key': 'hasParking'},
      {'label': 'Fitness center', 'key': 'hasGym'},
      {'label': 'Wifi', 'key': 'hasWifi'},
      {'label': '${requestData['bedrooms'] ?? 'N/A'} Rooms', 'key': 'bedrooms'},
      {'label': 'Bars', 'key': 'hasBars'},
      {'label': 'Play ground', 'key': 'hasPlayground'},
      {'label': 'AC', 'key': 'hasAirConditioning'},
      {'label': 'Garden', 'key': 'hasGarden'},
      {'label': 'BBQ', 'key': 'hasBBQ'},
      {'label': 'Beach View', 'key': 'hasBeachView'},
      {'label': 'Housekeeping', 'key': 'hasHousekeeping'},
      {'label': 'Pets Allowed', 'key': 'hasPetsAllowed'},
      {'label': 'Kitchen', 'key': 'hasKitchen'},
      {'label': 'TV', 'key': 'hasTV'},
      {'label': 'Breakfast', 'key': 'hasBreakfast'},
    ];

    // Filter enabled amenities
    final enabledAmenities = amenitiesList.where((item) {
      final key = item['key'] as String;
      if (key == 'bedrooms') return true; // Always show rooms
      if (requestData['amenities'] is List) {
        return (requestData['amenities'] as List).contains(key);
      }
      return requestData[key] == true;
    }).toList();

    // Split into two columns
    final leftColumn = enabledAmenities
        .take((enabledAmenities.length / 2).ceil())
        .toList();
    final rightColumn = enabledAmenities
        .skip((enabledAmenities.length / 2).ceil())
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Services & Facilities',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: Color(0xFF323232),
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 8.798),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Left Column
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: leftColumn.map((item) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 5.865),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.check_circle,
                          size: 18,
                          color: Color(0xFF2C67FF),
                        ),
                        const SizedBox(width: 2.933),
                        Expanded(
                          child: Text(
                            item['label'] as String,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF555555),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(width: 16),
            // Right Column
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: rightColumn.map((item) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 5.865),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.check_circle,
                          size: 18,
                          color: Color(0xFF2C67FF),
                        ),
                        const SizedBox(width: 2.933),
                        Expanded(
                          child: Text(
                            item['label'] as String,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF555555),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // Fixed Bottom Bar - Updated Price Order
  Widget _buildFixedBottomBar(
    BuildContext context,
    dynamic price,
    Map<String, dynamic> requestData,
  ) {
    final formattedPrice = CurrencyFormatter.egp(
      (price is num) ? price : double.tryParse((price ?? '').toString()) ?? 0,
      withSuffixPerNight: true,
    );

    // Calculate discount logic
    final discountEnabled = requestData['discountEnabled'] == true;
    final discountValue =
        double.tryParse(requestData['discountValue']?.toString() ?? '0') ?? 0;

    String displayPrice;
    String? originalPriceStr;

    if (discountEnabled && discountValue > 0) {
      // Calculate discounted price
      final basePrice = (price is num)
          ? price.toDouble()
          : double.tryParse(
                  (price ?? '').toString().replaceAll(RegExp(r'[^0-9.]'), ''),
                ) ??
                0.0;

      final discountType = requestData['discountType'];
      double finalPrice = basePrice;

      if (discountType == 'percentage') {
        finalPrice = basePrice * (1 - discountValue / 100);
      } else if (discountType == 'fixed') {
        finalPrice = basePrice - discountValue;
      }
      if (finalPrice < 0) finalPrice = 0;

      displayPrice = CurrencyFormatter.egp(
        finalPrice,
        withSuffixPerNight: true,
      );
      originalPriceStr = CurrencyFormatter.egp(
        basePrice,
        withSuffixPerNight: false,
      );
    } else {
      displayPrice = formattedPrice;
      originalPriceStr = null;
    }

    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SafeArea(
          top: false,
          child: Row(
            children: [
              // Price Section
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (originalPriceStr != null) ...[
                      Text(
                        '$originalPriceStr / night',
                        style: const TextStyle(
                          fontSize: 14,
                          decoration: TextDecoration.lineThrough,
                          decorationColor: Color(0xFF9CA3AF),
                          decorationThickness: 2,
                          color: Color(0xFF9CA3AF),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 4),
                    ],
                    RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: displayPrice.split(' /')[0],
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF2C67FF),
                            ),
                          ),
                          const TextSpan(
                            text: ' / night',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF6B7280),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              // Reserve Now Button
              ElevatedButton(
                onPressed: () {
                  final authCubit = context.read<AuthCubit>();
                  final currentUser = authCubit.getCurrentUser();
                  if (currentUser == null) return;

                  final bookingAvailability =
                      requestData['bookingAvailability'] ?? 'available';
                  final isBookingAvailable = bookingAvailability == 'available';

                  if (isBookingAvailable) {
                    var ownerId =
                        requestData['ownerId'] ?? requestData['userId'] ?? '';
                    if (ownerId.isEmpty) {
                      ownerId = '';
                    }

                    final chaletId = widget.docId;
                    final chaletName =
                        requestData['chaletName'] ??
                        requestData['name'] ??
                        'شاليه';
                    final ownerName =
                        requestData['merchantName'] ??
                        requestData['ownerName'] ??
                        'صاحب الشاليه';

                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      backgroundColor: Colors.transparent,
                      builder: (context) => BookingBridgeWidget(
                        chaletId: chaletId,
                        chaletName: chaletName,
                        ownerId: ownerId,
                        ownerName: ownerName,
                        userId: currentUser.uid,
                        userName: currentUser.name,
                        requestData: widget.requestData,
                        parentContext: context,
                      ),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'This chalet is currently not available for booking',
                        ),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2C67FF),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 16,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 4,
                  shadowColor: const Color(0xFF2C67FF).withOpacity(0.4),
                ),
                child: const Text(
                  'Reserve Now',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        color: Color(0xFF1A1A2E),
        letterSpacing: 0.5,
      ),
    );
  }
}
