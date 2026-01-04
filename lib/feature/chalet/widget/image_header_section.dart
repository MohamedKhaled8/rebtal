import 'dart:ui' as ui;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rebtal/core/app/cubit/app_cubit.dart';
import 'package:rebtal/core/utils/constant/color_manager.dart';
import 'package:rebtal/core/utils/helper/app_image_helper.dart';
import 'package:rebtal/core/utils/widgets/rating_display_widget.dart';
import 'package:rebtal/feature/chalet/logic/cubit/chalet_detail_cubit.dart';
import 'package:share_plus/share_plus.dart';

class ImageHeaderSection extends StatefulWidget {
  final String hotelName;
  final String location;
  final Map<String, dynamic> requestData;
  final String docId; // Added docId explicitly

  const ImageHeaderSection({
    super.key,
    required this.hotelName,
    required this.location,
    required this.requestData,
    required this.docId, // Required now
  });

  @override
  State<ImageHeaderSection> createState() => _ImageHeaderSectionState();
}

class _ImageHeaderSectionState extends State<ImageHeaderSection> {
  bool _isFavorite = false;
  String? _userId;

  @override
  void initState() {
    super.initState();
    try {
      final user = context.read<AppCubit>().authCubit.getCurrentUser();
      _userId = user?.uid;
    } catch (_) {}
    _checkFavoriteInitial();
  }

  Future<void> _checkFavoriteInitial() async {
    // Retry fetching user if null initially
    if (_userId == null) {
      try {
        final user = context.read<AppCubit>().authCubit.getCurrentUser();
        _userId = user?.uid;
      } catch (_) {}
    }

    if (_userId == null) return;
    if (widget.docId.isEmpty) return; // Validate docId

    try {
      final favDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(_userId)
          .collection('favorites')
          .doc(widget.docId) // Use explicit docId
          .get();
      if (mounted) {
        setState(() {
          _isFavorite = favDoc.exists;
        });
      }
    } catch (e) {
      debugPrint('Error checking favorite: $e');
    }
  }

  Future<void> _toggleFavorite() async {
    // Re-check user ID
    if (_userId == null) {
      try {
        final user = context.read<AppCubit>().authCubit.getCurrentUser();
        _userId = user?.uid;
      } catch (_) {}
    }

    if (_userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('يرجى تسجيل الدخول لإضافة للمفضلة')),
      );
      return;
    }

    if (widget.docId.isEmpty) {
      // Validate explicit docId
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('خطأ: معرف الشاليه غير موجود')),
      );
      return;
    }

    // Optimistic Update
    setState(() {
      _isFavorite = !_isFavorite;
    });

    try {
      final favRef = FirebaseFirestore.instance
          .collection('users')
          .doc(_userId)
          .collection('favorites')
          .doc(widget.docId); // Use explicit docId

      if (!_isFavorite) {
        // Logic: if current state is false (after toggle), it means we removed it
        await favRef.delete();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('تم الحذف من المفضلة'),
              duration: Duration(milliseconds: 500),
            ),
          );
        }
      } else {
        // Logic: if current state is true (after toggle), we added it
        await favRef.set({
          'chaletId': widget.docId, // Use explicit docId
          'name': widget.hotelName,
          'location': widget.location,
          'image':
              (widget.requestData['images'] is List &&
                  widget.requestData['images'].isNotEmpty)
              ? widget.requestData['images'][0]
              : (widget.requestData['profileImage'] ?? ''),
          'price': widget.requestData['price'],
          'createdAt': FieldValue.serverTimestamp(),
          'chaletData': widget.requestData,
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('تم الإضافة للمفضلة'),
              duration: Duration(milliseconds: 500),
            ),
          );
        }
      }
    } catch (e) {
      debugPrint('Error toggling favorite: $e');
      // Revert if failed
      if (mounted) {
        setState(() {
          _isFavorite = !_isFavorite;
        });
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('حدث خطأ: $e')));
      }
    }
  }

  void _shareChalet() async {
    final text =
        'Check out ${widget.hotelName} in ${widget.location} on Rebtal!\nPrice: ${widget.requestData['price']} EGP/night';
    try {
      await Share.share(text);
    } catch (e) {
      debugPrint('Share Error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('لا يمكن المشاركة الآن. تأكد من تثبيت التطبيق.'),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocSelector<
      ChaletDetailCubit,
      ChaletDetailState,
      ({List<String> images, int currentIndex})
    >(
      selector: (state) {
        if (state is ChaletDetailLoaded) {
          return (images: state.images, currentIndex: state.currentImageIndex);
        }
        return (images: <String>[], currentIndex: 0);
      },
      builder: (context, data) {
        final images = data.images;

        if (images.isEmpty) {
          return Container(
            height: 400,
            margin: const EdgeInsets.only(bottom: 16.31),
            decoration: BoxDecoration(color: ColorManager.chaletGrey200),
          );
        }

        final cubit = context.read<ChaletDetailCubit>();

        return Container(
          height: 400,
          margin: const EdgeInsets.only(bottom: 16.31),
          decoration: const BoxDecoration(color: ColorManager.black),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // 1. Main Image Slider
              GestureDetector(
                onTap: () {
                  final currentIndex = data.currentIndex;
                  cubit.openFullScreen(
                    context,
                    images: images,
                    start: currentIndex,
                  );
                },
                child: PageView.builder(
                  controller: cubit.pageController,
                  itemCount: images.length,
                  onPageChanged: cubit.onPageChanged,
                  itemBuilder: (context, index) {
                    return Hero(
                      tag: 'chalet_image_header_$index',
                      child: AppImageHelper(
                        path: images[index],
                        fit: BoxFit.cover,
                      ),
                    );
                  },
                ),
              ),

              // 2. Gradient Overlay
              Positioned.fill(
                child: IgnorePointer(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          ColorManager.black.withOpacity(0.3),
                          ColorManager.transparent,
                          ColorManager.black.withOpacity(0.8),
                        ],
                        stops: const [0.0, 0.4, 1.0],
                      ),
                    ),
                  ),
                ),
              ),

              // 3. Top Left: Back Button
              Positioned(
                top: 50,
                left: 20,
                child: _buildGlassyButton(
                  onTap: () => Navigator.pop(context),
                  icon: Icons.arrow_back_ios_new,
                ),
              ),

              // 4. Top Right: Share & Favorite
              Positioned(
                top: 50,
                right: 20,
                child: Row(
                  children: [
                    _buildGlassyButton(
                      onTap: _shareChalet,
                      icon: Icons.share_rounded,
                    ),
                    const SizedBox(width: 12),
                    _buildGlassyButton(
                      onTap: _toggleFavorite,
                      icon: _isFavorite
                          ? Icons.favorite_rounded
                          : Icons.favorite_border_rounded,
                      color: _isFavorite
                          ? ColorManager.chaletUnavailableRed
                          : ColorManager.white,
                    ),
                  ],
                ),
              ),

              // 5. Rating Badge (Top Right - Below Buttons)
              if (widget.docId.isNotEmpty)
                Positioned(
                  top: 100,
                  right: 20,
                  child: RatingDisplayWidget(
                    chaletId: widget.docId,
                    isDark: false,
                    isBadge: true,
                  ),
                ),

              // 6. Bottom: Title and Location
              Positioned(
                bottom: 20,
                left: 20,
                right: 20,
                child: IgnorePointer(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.hotelName,
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w800,
                          color: ColorManager.white,
                          letterSpacing: 0.5,
                          shadows: [
                            Shadow(
                              color: ColorManager.black.withOpacity(0.45),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(
                            Icons.location_on,
                            color: ColorManager.white,
                            size: 16,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              widget.location,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: ColorManager.chaletGrey200,
                                height: 1.3,
                                shadows: [
                                  Shadow(
                                    color: ColorManager.black.withOpacity(0.45),
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
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildGlassyButton({
    required VoidCallback onTap,
    required IconData icon,
    Color color = ColorManager.white,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 40,
        width: 40,
        decoration: BoxDecoration(
          color: ColorManager.white.withOpacity(0.2), // Glassy bg
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: ColorManager.white.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: BackdropFilter(
            filter: ui.ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Center(child: Icon(icon, color: color, size: 20)),
          ),
        ),
      ),
    );
  }
}
