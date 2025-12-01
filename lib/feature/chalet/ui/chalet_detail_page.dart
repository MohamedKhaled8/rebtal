import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rebtal/core/utils/constant/color_manager.dart';
import 'package:rebtal/core/utils/theme/dynamic_theme_manager.dart';
import 'package:rebtal/feature/auth/cubit/auth_cubit.dart';
import 'package:rebtal/feature/chalet/logic/cubit/chalet_detail_cubit.dart';
import 'package:rebtal/feature/chalet/widget/about_us_section.dart';
import 'package:rebtal/feature/chalet/widget/fixed_bottom_bar.dart';
import 'package:rebtal/feature/chalet/widget/image_header_section.dart';
import 'package:rebtal/feature/chalet/widget/services_section.dart';
import 'package:rebtal/feature/chalet/widget/action_buttons.dart';
import 'package:rebtal/feature/chalet/widget/availability_card.dart';
import 'package:rebtal/feature/chalet/widget/image_gallery_card.dart';
import 'package:rebtal/feature/chalet/widget/owner_information_card.dart';
import 'package:rebtal/feature/chalet/widget/property_features_card.dart';
import 'package:rebtal/feature/chalet/widget/request_details_card.dart';

class ChaletDetailPage extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ChaletDetailCubit()..initialize(requestData),
      child: BlocSelector<ChaletDetailCubit, ChaletDetailState, List<String>>(
        selector: (state) {
          if (state is ChaletDetailLoaded) {
            return state.images;
          }
          return <String>[];
        },
        builder: (context, images) {
          return BlocBuilder<AuthCubit, AuthState>(
            builder: (context, authState) {
              String role = 'guest';
              if (authState is AuthSuccess) {
                role = authState.user.role.toLowerCase().trim();
              }

              final isDark = DynamicThemeManager.isDarkMode(context);
              final hotelName = requestData['chaletName'] ?? 'Chalet Name';
              final location = requestData['location'] ?? 'Unknown Location';
              final price = requestData['price'];
              final description = requestData['description']?.toString() ?? '';

              return SafeArea(
                child: Scaffold(
                  backgroundColor: isDark
                      ? ColorManager.chaletBackgroundDark
                      : ColorManager.chaletBackgroundLight,
                  body: Stack(
                    children: [
                      // Main Scrollable Content
                      CustomScrollView(
                        physics: const BouncingScrollPhysics(),
                        slivers: [
                          // Image Header Section
                          SliverToBoxAdapter(
                            child: ImageHeaderSection(
                              hotelName: hotelName,
                              location: location,
                            ),
                          ),

                          // Content Section
                          SliverToBoxAdapter(
                            child: Container(
                              decoration: BoxDecoration(
                                color: isDark
                                    ? ColorManager.chaletBackgroundDark
                                    : ColorManager.chaletBackgroundLight,
                                borderRadius: const BorderRadius.vertical(
                                  top: Radius.circular(21.994),
                                ),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.fromLTRB(
                                  16,
                                  16,
                                  16,
                                  100,
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // About Us Section
                                    AboutUsSection(
                                      description: description,
                                      isDark: isDark,
                                    ),
                                    const SizedBox(height: 24),

                                    // Services & Facilities Section
                                    ServicesSection(
                                      requestData: requestData,
                                      isDark: isDark,
                                    ),
                                    const SizedBox(height: 24),

                                    // Additional Details
                                    PropertyFeaturesCard(
                                      requestData: requestData,
                                    ),
                                    const SizedBox(height: 24),

                                    // Gallery (if more images)
                                    if (images.length > 1) ...[
                                      ImageGalleryCard(
                                        requestData: requestData,
                                        images: images,
                                      ),
                                      const SizedBox(height: 24),
                                    ],

                                    // Role-based Sections
                                    if (role == 'user' || role == 'owner') ...[
                                      OwnerInformationCard(
                                        requestData: requestData,
                                      ),
                                      const SizedBox(height: 24),

                                      AvailabilityCard(
                                        requestData: requestData,
                                      ),
                                      const SizedBox(height: 24),
                                    ],

                                    if (role == 'admin') ...[
                                      OwnerInformationCard(
                                        requestData: requestData,
                                      ),
                                      const SizedBox(height: 24),

                                      AvailabilityCard(
                                        requestData: requestData,
                                      ),
                                      const SizedBox(height: 24),

                                      _buildSectionTitle(
                                        'تفاصيل الطلب',
                                        isDark,
                                      ),
                                      const SizedBox(height: 12),
                                      RequestDetailsCard(
                                        docId: docId,
                                        requestData: requestData,
                                      ),
                                      const SizedBox(height: 24),
                                    ],

                                    // Action Buttons (for admin/owner)
                                    if (role == 'admin' || role == 'owner') ...[
                                      ActionButtons(
                                        status: status,
                                        docId: docId,
                                        requestData: requestData,
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
                        FixedBottomBar(
                          price: price,
                          requestData: requestData,
                          isDark: isDark,
                          docId: docId,
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

  Widget _buildSectionTitle(String title, bool isDark) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w800,
        color: isDark
            ? ColorManager.chaletTextPrimaryDark
            : ColorManager.chaletTextPrimaryLight,
        letterSpacing: 0.5,
      ),
    );
  }
}
