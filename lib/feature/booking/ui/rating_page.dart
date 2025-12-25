import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rebtal/core/utils/constant/color_manager.dart';
import 'package:rebtal/feature/booking/models/booking.dart';

class RatingPage extends StatefulWidget {
  final Booking booking;
  final bool
  isOwnerRating; // true = owner rating user, false = user rating chalet

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

  final List<String> _chaletAspects = [
    'النظافة',
    'الموقع',
    'المرافق',
    'القيمة مقابل السعر',
    'التواصل',
  ];

  final List<String> _userAspects = [
    'الالتزام بالمواعيد',
    'النظافة',
    'التعامل',
    'الالتزام بالقواعد',
  ];

  final Map<String, double> _aspectRatings = {};

  @override
  void initState() {
    super.initState();
    final aspects = widget.isOwnerRating ? _userAspects : _chaletAspects;
    for (var aspect in aspects) {
      _aspectRatings[aspect] = 0;
    }
  }

  @override
  void dispose() {
    _reviewController.dispose();
    super.dispose();
  }

  Future<void> _submitRating() async {
    if (_rating == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('يرجى اختيار تقييم'),
          backgroundColor: Colors.orange.shade600,
        ),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      final ratingData = {
        'bookingId': widget.booking.id,
        'rating': _rating,
        'review': _reviewController.text.trim(),
        'aspectRatings': _aspectRatings,
        'createdAt': FieldValue.serverTimestamp(),
      };

      if (widget.isOwnerRating) {
        // Owner rating user
        ratingData['userId'] = widget.booking.userId;
        ratingData['userName'] = widget.booking.userName;
        ratingData['ownerId'] = widget.booking.ownerId;
        ratingData['ownerName'] = widget.booking.ownerName;

        await FirebaseFirestore.instance
            .collection('user_ratings')
            .add(ratingData);

        // Update user average rating
        await _updateUserRating(widget.booking.userId);
      } else {
        // User rating chalet
        ratingData['chaletId'] = widget.booking.chaletId;
        ratingData['chaletName'] = widget.booking.chaletName;
        ratingData['userId'] = widget.booking.userId;
        ratingData['userName'] = widget.booking.userName;

        await FirebaseFirestore.instance
            .collection('chalet_ratings')
            .add(ratingData);

        // Update chalet average rating
        await _updateChaletRating(widget.booking.chaletId);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 12),
                Text('شكراً لتقييمك!'),
              ],
            ),
            backgroundColor: Colors.green.shade600,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );

        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('خطأ: $e'),
            backgroundColor: Colors.red.shade600,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  Future<void> _updateChaletRating(String chaletId) async {
    final ratingsSnapshot = await FirebaseFirestore.instance
        .collection('chalet_ratings')
        .where('chaletId', isEqualTo: chaletId)
        .get();

    if (ratingsSnapshot.docs.isNotEmpty) {
      double totalRating = 0;
      for (var doc in ratingsSnapshot.docs) {
        totalRating += (doc.data()['rating'] as num).toDouble();
      }
      final averageRating = totalRating / ratingsSnapshot.docs.length;

      await FirebaseFirestore.instance
          .collection('chalets')
          .doc(chaletId)
          .update({
            'averageRating': averageRating,
            'totalRatings': ratingsSnapshot.docs.length,
          });
    }
  }

  Future<void> _updateUserRating(String userId) async {
    final ratingsSnapshot = await FirebaseFirestore.instance
        .collection('user_ratings')
        .where('userId', isEqualTo: userId)
        .get();

    if (ratingsSnapshot.docs.isNotEmpty) {
      double totalRating = 0;
      for (var doc in ratingsSnapshot.docs) {
        totalRating += (doc.data()['rating'] as num).toDouble();
      }
      final averageRating = totalRating / ratingsSnapshot.docs.length;

      await FirebaseFirestore.instance.collection('users').doc(userId).update({
        'averageRating': averageRating,
        'totalRatings': ratingsSnapshot.docs.length,
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final aspects = widget.isOwnerRating ? _userAspects : _chaletAspects;

    return Scaffold(
      backgroundColor: isDark
          ? const Color(0xFF0A0E27)
          : const Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          widget.isOwnerRating ? 'تقييم المستأجر' : 'تقييم الشاليه',
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Card
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [ColorManager.chaletAccent, Color(0xFF00A896)],
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    Icon(
                      widget.isOwnerRating ? Icons.person : Icons.villa,
                      color: Colors.white,
                      size: 48,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      widget.isOwnerRating
                          ? widget.booking.userName
                          : widget.booking.chaletName,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      widget.isOwnerRating
                          ? 'كيف كانت تجربتك مع المستأجر؟'
                          : 'كيف كانت تجربتك في الشاليه؟',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.white70,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // Overall Rating
              Text(
                'التقييم الإجمالي',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),

              const SizedBox(height: 16),

              Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(5, (index) {
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _rating = (index + 1).toDouble();
                        });
                      },
                      child: Icon(
                        index < _rating ? Icons.star : Icons.star_border,
                        size: 48,
                        color: Colors.amber.shade600,
                      ),
                    );
                  }),
                ),
              ),

              if (_rating > 0) ...[
                const SizedBox(height: 8),
                Center(
                  child: Text(
                    _getRatingText(_rating),
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: ColorManager.chaletAccent,
                    ),
                  ),
                ),
              ],

              const SizedBox(height: 32),

              // Aspect Ratings
              Text(
                'تقييم تفصيلي',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),

              const SizedBox(height: 16),

              ...aspects.map((aspect) => _buildAspectRating(aspect, isDark)),

              const SizedBox(height: 24),

              // Review Text
              Text(
                'تعليقك (اختياري)',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),

              const SizedBox(height: 12),

              TextField(
                controller: _reviewController,
                maxLines: 5,
                decoration: InputDecoration(
                  hintText: 'شاركنا تجربتك...',
                  filled: true,
                  fillColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: isDark ? Colors.white12 : Colors.grey.shade300,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: isDark ? Colors.white12 : Colors.grey.shade300,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: ColorManager.chaletAccent,
                      width: 2,
                    ),
                  ),
                ),
                style: TextStyle(color: isDark ? Colors.white : Colors.black87),
              ),

              const SizedBox(height: 32),

              // Submit Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _isSubmitting ? null : _submitRating,
                  icon: _isSubmitting
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation(Colors.white),
                          ),
                        )
                      : const Icon(Icons.send, size: 20),
                  label: Text(
                    _isSubmitting ? 'جاري الإرسال...' : 'إرسال التقييم',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ColorManager.chaletAccent,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                    disabledBackgroundColor: Colors.grey.shade400,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAspectRating(String aspect, bool isDark) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? Colors.white12 : Colors.grey.shade300,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            aspect,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(5, (index) {
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _aspectRatings[aspect] = (index + 1).toDouble();
                  });
                },
                child: Icon(
                  index < (_aspectRatings[aspect] ?? 0)
                      ? Icons.star
                      : Icons.star_border,
                  size: 32,
                  color: Colors.amber.shade600,
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  String _getRatingText(double rating) {
    if (rating == 5) return 'ممتاز! 🌟';
    if (rating == 4) return 'جيد جداً 👍';
    if (rating == 3) return 'جيد ✓';
    if (rating == 2) return 'مقبول';
    return 'ضعيف';
  }
}
