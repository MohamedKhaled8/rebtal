import 'dart:ui' as ui;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rebtal/core/utils/localization/translation_extension.dart';
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
        SnackBar(content: Text(context.tr('chalet_login_to_favorite'))),
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
            SnackBar(
              content: Text(context.tr('chalet_removed_from_favorites')),
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
            SnackBar(
              content: Text(context.tr('chalet_added_to_favorites')),
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
          SnackBar(content: Text(context.tr('chalet_share_error'))),
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
            height: 300, // Roughly 40% height visually
            width: double.infinity,
            color: ColorsManager.chaletGrey200,
          );
        }

        final cubit = context.read<ChaletDetailCubit>();

        return SizedBox(
          height: 320, // Airbnb style height
          width: double.infinity,
          child: Stack(
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
                  physics: const BouncingScrollPhysics(),
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

              // 2. Top Bar Buttons
              Positioned(
                top: 50,
                left: 20,
                right: 20,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Back Button
                    _buildCircleButton(
                      onTap: () => Navigator.pop(context),
                      icon: Icons.arrow_back,
                      isBack: true,
                    ),

                    // Right Actions
                    Row(
                      children: [
                        _buildCircleButton(
                          onTap: _shareChalet,
                          icon: Icons.ios_share,
                        ),
                        const SizedBox(width: 12),
                        _buildCircleButton(
                          onTap: _toggleFavorite,
                          icon: _isFavorite
                              ? Icons.favorite
                              : Icons.favorite_border,
                          color: _isFavorite
                              ? const Color(0xFFFF385C)
                              : Colors.black,
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // 3. Page Indicator (Bottom Right)
              Positioned(
                bottom: 20,
                right: 20,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.7),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    '${data.currentIndex + 1} / ${images.length}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCircleButton({
    required VoidCallback onTap,
    required IconData icon,
    Color color = Colors.black,
    bool isBack = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 32, // Smaller Airbnb style
        width: 32,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.12),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Icon(icon, size: 18, color: color),
      ),
    );
  }
}
