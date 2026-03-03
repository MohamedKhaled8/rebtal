import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:rebtal/core/utils/localization/translation_extension.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rebtal/core/utils/theme/dynamic_theme_manager.dart';
import 'package:rebtal/feature/booking/models/booking.dart';
import 'package:rebtal/core/utils/helper/snack_bar_helper.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rebtal/core/app/cubit/app_cubit.dart';
import 'package:rebtal/core/utils/widgets/premium_loading_overlay.dart';

class RatingPage extends StatefulWidget {
  final Booking booking;
  final bool isOwnerRating;

  const RatingPage({
    super.key,
    required this.booking,
    this.isOwnerRating = false,
  });

  @override
  State<RatingPage> createState() => _RatingPageState();
}

class _RatingPageState extends State<RatingPage> {
  double _rating = 0;
  final TextEditingController _reviewController = TextEditingController();
  bool _isSubmitting = false;

  final Map<String, double> _aspectRatings = {};

  final List<String> _aspectKeys = [];

  @override
  void initState() {
    super.initState();
    _aspectKeys.addAll(widget.isOwnerRating
        ? ['booking_schedule_rating', 'booking_cleanliness', 'booking_handling', 'booking_rules']
        : ['booking_cleanliness', 'booking_location', 'booking_facilities', 'booking_value', 'booking_communication']);
    for (var key in _aspectKeys) {
      _aspectRatings[key] = 0;
    }
    _reviewController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _reviewController.dispose();
    super.dispose();
  }

  Future<void> _submitRating() async {
    if (_rating == 0 || _reviewController.text.trim().isEmpty) {
      SnackBarHelper.showWarning(context, context.tr('booking_please_comment_rating'));
      return;
    }

    setState(() => _isSubmitting = true);

    // Show loading immediately
    PremiumLoadingOverlay.show(context, message: context.tr('common_loading'));

    try {
      final appCubit = context.read<AppCubit>();
      final currentUser = appCubit.getCurrentUser();

      String? profileImageUrl;
      String latestName = widget.booking.userName;

      // 1. Try to get image from current user if it matches the booking userId
      if (currentUser != null && currentUser.uid == widget.booking.userId) {
        profileImageUrl = currentUser.profileImageUrl;
        latestName = currentUser.name;
      } else {
        // 2. Fallback to robust Firestore lookup (checking all common collection formats)
        DocumentSnapshot? userDoc;
        final collections = [
          'Users',
          'Owners',
          'Admin',
          'Admins',
          'users',
          'owners',
          'admins',
        ];

        for (final col in collections) {
          try {
            final doc = await FirebaseFirestore.instance
                .collection(col)
                .doc(widget.booking.userId)
                .get();
            if (doc.exists) {
              userDoc = doc;
              break;
            }
          } catch (_) {
            // Ignore collection doesn't exist errors
          }
        }

        if (userDoc != null && userDoc.exists) {
          final userData = userDoc.data() as Map<String, dynamic>? ?? {};
          latestName =
              userData['name'] ??
              userData['userName'] ??
              widget.booking.userName;
          profileImageUrl =
              userData['profileImageUrl'] ??
              userData['profileImage'] ??
              userData['userImage'];
        }
      }

      final ratingData = {
        'bookingId': widget.booking.id,
        'userId': widget.booking.userId, // Important for dynamic fetching later
        'rating': _rating,
        'review': _reviewController.text.trim(),
        'aspectRatings': _aspectRatings,
        'createdAt': FieldValue.serverTimestamp(),
        'userImage': profileImageUrl ?? '', // For backward compatibility
        'profileImageUrl': profileImageUrl ?? '', // For consistency
        'userName': latestName,
      };

      if (widget.isOwnerRating) {
        ratingData['ownerId'] = widget.booking.ownerId;
        await FirebaseFirestore.instance
            .collection('user_ratings')
            .add(ratingData);
      } else {
        ratingData['chaletId'] = widget.booking.chaletId;
        ratingData['userId'] = widget.booking.userId;
        await FirebaseFirestore.instance
            .collection('chalet_ratings')
            .add(ratingData);
      }

      if (mounted) {
        PremiumLoadingOverlay.dismiss(context);
        SnackBarHelper.showSuccess(context, context.tr('booking_rating_sent'));
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        PremiumLoadingOverlay.dismiss(context);
        setState(() => _isSubmitting = false);
        SnackBarHelper.showError(context, '${context.tr('booking_error_msg')} $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = DynamicThemeManager.isDarkMode(context);
    // Label colors adapt to theme
    final Color labelColor = isDark ? Colors.black : Colors.black;
    // TextField colors FORCED to Black text on White background for visibility
    const Color inputTextColor = Colors.black;
    const Color inputFillColor = Colors.white;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0A0E27) : Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Text(
          widget.isOwnerRating ? context.tr('booking_rating_tenant') : context.tr('booking_rating_chalet'),
          style: TextStyle(color: labelColor, fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: labelColor),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              // Header
              FadeInDown(
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF1ED760), Color(0xFF00A896)],
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    children: [
                      const Icon(
                        Icons.star_rounded,
                        color: Colors.white,
                        size: 60,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        widget.isOwnerRating
                            ? widget.booking.userName
                            : widget.booking.chaletName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 30),

              // Stars
              Text(
                context.tr('booking_total_rating'),
                style: TextStyle(
                  color: labelColor,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 15),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (index) {
                  return GestureDetector(
                    onTap: () =>
                        setState(() => _rating = (index + 1).toDouble()),
                    child: ZoomIn(
                      delay: Duration(milliseconds: index * 100),
                      child: Icon(
                        index < _rating
                            ? Icons.star_rounded
                            : Icons.star_outline_rounded,
                        size: 55,
                        color: const Color(0xFFEAB308),
                      ),
                    ),
                  );
                }),
              ),

              const SizedBox(height: 30),

              if (_rating > 0) ...[
                // Comment Field
                FadeInUp(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${context.tr('booking_write_comment')}:',
                        style: TextStyle(
                          color: labelColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: _reviewController,
                        maxLines: 4,
                        style: const TextStyle(
                          color: inputTextColor, // FORCED BLACK
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                        decoration: InputDecoration(
                          hintText: context.tr('booking_how_was_experience'),
                          hintStyle: TextStyle(color: Colors.grey[500]),
                          filled: true,
                          fillColor: inputFillColor, // FORCED WHITE
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                            borderSide: const BorderSide(color: Colors.grey),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                            borderSide: BorderSide(color: Colors.grey.shade300),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                            borderSide: const BorderSide(
                              color: Color(0xFF1ED760),
                              width: 2,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 30),

                // Aspects
                ..._aspectRatings.keys.map(
                  (aspect) => _buildAspect(context, aspect, isDark, labelColor),
                ),

                const SizedBox(height: 30),

                // Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isSubmitting ? null : _submitRating,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1ED760),
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      elevation: 4,
                    ),
                    child: Text(
                      context.tr('booking_send_rating'),
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAspect(BuildContext ctx, String aspectKey, bool isDark, Color textColor) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF252540) : Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: isDark ? Colors.white10 : Colors.grey.shade200,
        ),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            ctx.tr(aspectKey),
            style: TextStyle(color: textColor, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(5, (index) {
              return GestureDetector(
                onTap: () => setState(
                  () => _aspectRatings[aspectKey] = (index + 1).toDouble(),
                ),
                child: Icon(
                  index < (_aspectRatings[aspectKey] ?? 0)
                      ? Icons.star_rounded
                      : Icons.star_outline_rounded,
                  size: 32,
                  color: const Color(0xFFEAB308),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}
