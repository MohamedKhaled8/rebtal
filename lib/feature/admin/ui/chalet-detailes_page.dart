import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rebtal/core/utils/helper/app_image_helper.dart';
import 'package:rebtal/feature/admin/logic/cubit/admin_cubit.dart';
import 'package:rebtal/feature/admin/widget/chalet/action_buttons.dart';
import 'package:rebtal/feature/admin/widget/chalet/amenities_section.dart';
import 'package:rebtal/feature/admin/widget/chalet/availability_card.dart';
import 'package:rebtal/feature/admin/widget/chalet/description_card.dart';
import 'package:rebtal/feature/admin/widget/chalet/header_card.dart';
import 'package:rebtal/feature/admin/widget/chalet/image_gallery_card.dart';
import 'package:rebtal/feature/admin/widget/chalet/owner_information_card.dart';
import 'package:rebtal/feature/admin/widget/chalet/property_features_card.dart';
import 'package:rebtal/feature/admin/widget/chalet/request_details_card.dart';
import 'package:rebtal/feature/auth/cubit/auth_cubit.dart';

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
  int _currentImageIndex = 0;

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

          return BlocBuilder<AuthCubit, AuthState>(
            builder: (context, authState) {
              String role = 'guest';
              if (authState is AuthSuccess) {
                role = authState.user.role.toLowerCase().trim();
              }

              return Scaffold(
                backgroundColor: const Color(0xFFF8FAFC),
                body: CustomScrollView(
                  physics: const BouncingScrollPhysics(),
                  slivers: [
                    // 1. Immersive Header
                    SliverAppBar(
                      expandedHeight: 320,
                      pinned: true,
                      backgroundColor: Colors.transparent,
                      elevation: 0,
                      leading: Container(
                        margin: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.3),
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          icon: const Icon(
                            Icons.arrow_back_ios_new,
                            color: Colors.white,
                            size: 20,
                          ),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ),
                      flexibleSpace: FlexibleSpaceBar(
                        background: Stack(
                          fit: StackFit.expand,
                          children: [
                            // Image Slider
                            PageView.builder(
                              itemCount: images.length,
                              onPageChanged: (index) {
                                setState(() => _currentImageIndex = index);
                              },
                              itemBuilder: (context, index) {
                                return AppImageHelper(
                                  path: images[index],
                                  fit: BoxFit.cover,
                                );
                              },
                            ),

                            // Gradient Shadow Overlay (The "Shadow" Request)
                            Positioned.fill(
                              child: Container(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: [
                                      Colors.transparent,
                                      Colors.black.withOpacity(0.1),
                                      Colors.black.withOpacity(0.4),
                                      Colors.black.withOpacity(0.8),
                                    ],
                                    stops: const [0.4, 0.6, 0.8, 1.0],
                                  ),
                                ),
                              ),
                            ),

                            // Image Indicators
                            if (images.length > 1)
                              Positioned(
                                bottom: 40, // Above the rounded sheet
                                left: 0,
                                right: 0,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: List.generate(
                                    images.length,
                                    (index) => AnimatedContainer(
                                      duration: const Duration(
                                        milliseconds: 300,
                                      ),
                                      margin: const EdgeInsets.symmetric(
                                        horizontal: 4,
                                      ),
                                      width: _currentImageIndex == index
                                          ? 24
                                          : 8,
                                      height: 4,
                                      decoration: BoxDecoration(
                                        color: _currentImageIndex == index
                                            ? Colors.white
                                            : Colors.white.withOpacity(0.5),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),

                    // 2. Content Body (Sheet Effect)
                    SliverToBoxAdapter(
                      child: Transform.translate(
                        offset: const Offset(0, -24), // Overlap effect
                        child: Container(
                          decoration: const BoxDecoration(
                            color: Color(0xFFF8FAFC),
                            borderRadius: BorderRadius.vertical(
                              top: Radius.circular(32),
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(20, 32, 20, 20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Header Info (Title, Location, Price)
                                HeaderCard(requestData: widget.requestData),
                                const SizedBox(height: 24),

                                // Divider
                                Divider(color: Colors.grey[200], height: 1),
                                const SizedBox(height: 24),

                                // Features (Beds, Baths, etc.)
                                PropertyFeaturesCard(
                                  requestData: widget.requestData,
                                ),
                                const SizedBox(height: 24),

                                // Description
                                DescriptionCard(
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

                                // Amenities
                                AmenitiesSection(
                                  requestData: widget.requestData,
                                ),
                                const SizedBox(height: 24),

                                // Role-based Sections
                                if (role == 'user' || role == 'owner') ...[
                                  _buildSectionTitle('معلومات المالك'),
                                  const SizedBox(height: 12),
                                  OwnerInformationCard(
                                    requestData: widget.requestData,
                                  ),
                                  const SizedBox(height: 24),

                                  _buildSectionTitle('التوفر'),
                                  const SizedBox(height: 12),
                                  AvailabilityCard(
                                    requestData: widget.requestData,
                                  ),
                                  const SizedBox(height: 24),
                                ],

                                if (role == 'admin') ...[
                                  _buildSectionTitle('معلومات المالك'),
                                  const SizedBox(height: 12),
                                  OwnerInformationCard(
                                    requestData: widget.requestData,
                                  ),
                                  const SizedBox(height: 24),

                                  _buildSectionTitle('التوفر'),
                                  const SizedBox(height: 12),
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

                                // Action Buttons (Fixed at bottom or inline)
                                const SizedBox(height: 12),
                                ActionButtons(
                                  status: widget.status,
                                  docId: widget.docId,
                                  requestData: widget.requestData,
                                ),
                                const SizedBox(height: 40),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Color(0xFF1A1A2E),
      ),
    );
  }
}
