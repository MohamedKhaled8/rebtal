Future<void> _showRatingBottomSheet() async {
  double tempRating = 0;
  final controller = TextEditingController();

  await showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    isDismissible: true,
    enableDrag: true,
    backgroundColor: Colors.transparent,
    builder: (ctx) {
      return StatefulBuilder(
        builder: (context, setModalState) {
          final isDark = DynamicThemeManager.isDarkMode(context);
          final canSubmit = tempRating > 0 && controller.text.trim().isNotEmpty;

          return Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            child: Container(
              decoration: BoxDecoration(
                color: isDark ? ColorManager.darkSurface1E1E1E : Colors.white,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(24),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
              child: SafeArea(
                top: false,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Handle bar
                      Center(
                        child: Container(
                          width: 40,
                          height: 4,
                          margin: const EdgeInsets.only(bottom: 20),
                          decoration: BoxDecoration(
                            color: isDark
                                ? Colors.white.withOpacity(0.3)
                                : Colors.grey[300],
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),

                      // Icon
                      Center(
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [
                                ColorManager.chaletAccent,
                                ColorManager.teal00A896,
                              ],
                            ),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.rate_review_rounded,
                            color: Colors.white,
                            size: 32,
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Title
                      Text(
                        'قيّم تجربتك',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                      ),

                      const SizedBox(height: 8),

                      // Subtitle
                      Text(
                        'ساعدنا في تحسين الخدمة من خلال تقييمك',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          color: isDark
                              ? Colors.white.withOpacity(0.7)
                              : Colors.grey[600],
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Stars
                      Container(
                        padding: const EdgeInsets.symmetric(
                          vertical: 16,
                          horizontal: 12,
                        ),
                        decoration: BoxDecoration(
                          color: isDark
                              ? Colors.white.withOpacity(0.05)
                              : ColorManager.chaletAccent.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: tempRating > 0
                                ? ColorManager.chaletAccent.withOpacity(0.3)
                                : Colors.transparent,
                            width: 2,
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(5, (i) {
                            final filled = tempRating >= i + 1;
                            return GestureDetector(
                              onTap: () => setModalState(
                                () => tempRating = (i + 1).toDouble(),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 4,
                                ),
                                child: Icon(
                                  filled
                                      ? Icons.star_rounded
                                      : Icons.star_border_rounded,
                                  color: filled
                                      ? ColorManager.yellowEAB308
                                      : (isDark
                                            ? Colors.white.withOpacity(0.3)
                                            : Colors.grey[400]),
                                  size: 40,
                                ),
                              ),
                            );
                          }),
                        ),
                      ),

                      if (tempRating > 0) ...[
                        const SizedBox(height: 12),
                        Center(
                          child: Text(
                            _getRatingLabel(tempRating),
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: ColorManager.chaletAccent,
                            ),
                          ),
                        ),
                      ],

                      const SizedBox(height: 24),

                      // Comment field
                      Text(
                        'تعليقك (مطلوب)',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                      ),

                      const SizedBox(height: 12),

                      TextField(
                        controller: controller,
                        maxLines: 4,
                        style: TextStyle(
                          fontSize: 15,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                        decoration: InputDecoration(
                          hintText: 'شاركنا رأيك وتجربتك بالتفصيل...',
                          hintStyle: TextStyle(
                            color: isDark
                                ? Colors.white.withOpacity(0.4)
                                : Colors.grey[400],
                          ),
                          filled: true,
                          fillColor: isDark
                              ? Colors.white.withOpacity(0.05)
                              : Colors.grey[100],
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: isDark
                                  ? Colors.white.withOpacity(0.1)
                                  : Colors.grey[300]!,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: ColorManager.chaletAccent,
                              width: 2,
                            ),
                          ),
                          contentPadding: const EdgeInsets.all(16),
                        ),
                        onChanged: (val) => setModalState(() {}),
                      ),

                      const SizedBox(height: 24),

                      // Submit button
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        child: ElevatedButton(
                          onPressed: canSubmit
                              ? () async {
                                  try {
                                    // Fetch latest user details for the review
                                    String userImage = '';
                                    String displayName = widget.userName;
                                    try {
                                      final userDoc = await FirebaseFirestore
                                          .instance
                                          .collection('users')
                                          .doc(widget.userId)
                                          .get();
                                      if (userDoc.exists) {
                                        userImage =
                                            userDoc.data()?['profileImage'] ??
                                            '';
                                        displayName =
                                            userDoc.data()?['name'] ??
                                            widget.userName;
                                      }
                                    } catch (_) {}

                                    final ratingData = {
                                      'chaletId': widget.chaletId,
                                      'chaletName': widget.chaletName,
                                      'userId': widget.userId,
                                      'userName': displayName,
                                      'userImage': userImage,
                                      'rating': tempRating,
                                      'review': controller.text.trim(),
                                      'createdAt': FieldValue.serverTimestamp(),
                                    };

                                    await FirebaseFirestore.instance
                                        .collection('chalet_ratings')
                                        .add(ratingData);

                                    await _updateChaletRatingAggregate(
                                      chaletId: widget.chaletId,
                                      newRating: tempRating,
                                    );

                                    if (mounted) Navigator.pop(context);
                                    if (mounted) {
                                      SnackBarHelper.showSuccess(
                                        context,
                                        'شكراً لتقييمك! 🌟',
                                        icon: Icons.star,
                                      );
                                    }
                                  } catch (e) {
                                    if (mounted) {
                                      SnackBarHelper.showError(
                                        context,
                                        'تعذر حفظ التقييم: $e',
                                      );
                                    }
                                  }
                                }
                              : null,
                          style: ElevatedButton.styleFrom(
                            minimumSize: const Size.fromHeight(56),
                            backgroundColor: canSubmit
                                ? ColorManager.chaletAccent
                                : (isDark
                                      ? Colors.grey[800]
                                      : Colors.grey[300]),
                            foregroundColor: Colors.white,
                            disabledBackgroundColor: isDark
                                ? Colors.grey[800]
                                : Colors.grey[300],
                            disabledForegroundColor: isDark
                                ? Colors.white.withOpacity(0.3)
                                : Colors.grey[500],
                            elevation: canSubmit ? 2 : 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                canSubmit
                                    ? Icons.send_rounded
                                    : Icons.edit_outlined,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                canSubmit
                                    ? 'إرسال التقييم'
                                    : 'أكمل البيانات للإرسال',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      );
    },
  );
}

String _getRatingLabel(double rating) {
  if (rating == 5) return 'ممتاز! 🌟';
  if (rating == 4) return 'جيد جداً 👍';
  if (rating == 3) return 'جيد ✓';
  if (rating == 2) return 'مقبول';
  return 'ضعيف';
}
