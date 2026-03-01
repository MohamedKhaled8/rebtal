import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:animate_do/animate_do.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rebtal/feature/booking/logic/wizard_cubit/booking_wizard_cubit.dart';
import 'package:rebtal/feature/booking/logic/wizard_cubit/booking_wizard_state.dart';
import 'package:rebtal/core/utils/helper/snack_bar_helper.dart';
import 'package:rebtal/core/utils/widgets/premium_loading_overlay.dart';
import 'package:rebtal/core/app/cubit/app_cubit.dart';
import 'package:confetti/confetti.dart';

// Premium Colors
const kPrimaryColor = Color(0xFF00D27F);
const kDarkBg = Color(0xFF121212);
const kLightBg = Color(0xFFFAFAFA);
const kDarkCard = Color(0xFF1E1E1E);
const kLightCard = Color(0xFFFFFFFF);

class BookingWizardPage extends StatelessWidget {
  final Map<String, dynamic> requestData;
  final dynamic basePrice;
  final String chaletName;
  final String chaletId;
  final String ownerId;

  const BookingWizardPage({
    super.key,
    required this.requestData,
    required this.basePrice,
    required this.chaletName,
    required this.chaletId,
    required this.ownerId,
  });

  @override
  Widget build(BuildContext context) {
    final appCubit = context.read<AppCubit>();
    final user = appCubit.authCubit.getCurrentUser();

    if (user == null) {
      return const Scaffold(
        body: Center(child: Text("Please login to continue")),
      );
    }

    return BlocProvider(
      create: (context) => BookingWizardCubit(
        requestData: requestData,
        basePriceInput: basePrice,
        userId: user.uid,
        userName: user.name,
        chaletId: chaletId,
        chaletName: chaletName,
        ownerIdInput: ownerId,
        ownerNameInput:
            requestData['merchantName'] ?? requestData['ownerName'] ?? 'Owner',
      ),
      child: const BookingWizardView(),
    );
  }
}

class BookingWizardView extends StatefulWidget {
  const BookingWizardView({super.key});

  @override
  State<BookingWizardView> createState() => _BookingWizardViewState();
}

class _BookingWizardViewState extends State<BookingWizardView> {
  late ConfettiController _confettiController;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(
      duration: const Duration(seconds: 3),
    );
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? kDarkBg : kLightBg;
    final text = isDark ? Colors.white : Colors.black;

    return Scaffold(
      backgroundColor: bg,
      body: BlocListener<BookingWizardCubit, BookingWizardState>(
        listener: (context, state) {
          if (!mounted) return;
          if (state.errorMessage != null) {
            SnackBarHelper.showError(context, state.errorMessage!);
          }
          if (state.status == BookingWizardStatus.submitting) {
            PremiumLoadingOverlay.show(context, message: 'Processing...');
          } else if (state.status == BookingWizardStatus.success) {
            PremiumLoadingOverlay.dismiss(context);
            // Play Celebration
            _confettiController.play();

            // Show Rating Sheet directly
            if (mounted) _showRatingSheet(context);
          } else if (state.status == BookingWizardStatus.failure) {
            PremiumLoadingOverlay.dismiss(context);
          }
        },
        child: Stack(
          alignment: Alignment.topCenter,
          children: [
            SafeArea(
              child: Column(
                children: [
                  // 1. Premium Header
                  FadeInDown(
                    duration: const Duration(milliseconds: 600),
                    child: _buildHeader(context, isDark, text),
                  ),

                  const SizedBox(height: 10),

                  // 2. Progress Indicator
                  FadeInDown(
                    delay: const Duration(milliseconds: 200),
                    duration: const Duration(milliseconds: 600),
                    child: const _WizardProgressBar(),
                  ),

                  // 3. Main Content
                  Expanded(
                    child: BlocBuilder<BookingWizardCubit, BookingWizardState>(
                      builder: (context, state) {
                        return AnimatedSwitcher(
                          duration: const Duration(milliseconds: 400),
                          transitionBuilder: (child, animation) {
                            return FadeTransition(
                              opacity: animation,
                              child: SlideTransition(
                                position: Tween<Offset>(
                                  begin: const Offset(0.05, 0),
                                  end: Offset.zero,
                                ).animate(animation),
                                child: child,
                              ),
                            );
                          },
                          child: KeyedSubtree(
                            key: ValueKey(state.currentStep),
                            child: state.currentStep == 0
                                ? const _DateSelectionStep()
                                : const _BookingReviewStep(),
                          ),
                        );
                      },
                    ),
                  ),

                  // 4. Bottom Action Bar
                  const _WizardBottomBar(),
                ],
              ),
            ),

            // Confetti Overlay
            IgnorePointer(
              child: ConfettiWidget(
                confettiController: _confettiController,
                blastDirectionality: BlastDirectionality.explosive,
                shouldLoop: false,
                colors: const [
                  kPrimaryColor,
                  Colors.blue,
                  Colors.pink,
                  Colors.orange,
                  Colors.purple,
                ],
                createParticlePath: (size) => Path()
                  ..addOval(
                    Rect.fromCircle(
                      center: Offset(size.width / 2, size.height / 2),
                      radius: size.width / 2,
                    ),
                  ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, bool isDark, Color textColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: Icon(
              Icons.close_rounded,
              size: 28,
              color: isDark ? Colors.white70 : Colors.black54,
            ),
            style: IconButton.styleFrom(
              backgroundColor: isDark ? Colors.white10 : Colors.grey[100],
              padding: const EdgeInsets.all(8),
            ),
          ),
          Text(
            'تأكيد الحجز',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
          const SizedBox(width: 48), // Balance for back button
        ],
      ),
    );
  }

  void _showRatingSheet(BuildContext context) {
    final cubit = context.read<BookingWizardCubit>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      enableDrag: false,
      isDismissible: false,
      builder: (ctx) => BlocProvider.value(
        value: cubit,
        child: RatingBottomSheet(
          onComplete: () {
            Navigator.of(ctx).pop(); // Close sheet
            Navigator.of(context).pop(); // Close wizard
          },
        ),
      ),
    );
  }
}

class _WizardProgressBar extends StatelessWidget {
  const _WizardProgressBar();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BookingWizardCubit, BookingWizardState>(
      builder: (context, state) {
        final step = state.currentStep;
        final isDark = Theme.of(context).brightness == Brightness.dark;

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Row(
            children: [
              _buildDot(0, step, "التاريخ", isDark),
              Expanded(child: _buildLine(0, step, isDark)),
              _buildDot(1, step, "المراجعة", isDark),
              Expanded(child: _buildLine(1, step, isDark)),
              _buildDot(2, step, "الدفع", isDark),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDot(int index, int currentStep, String label, bool isDark) {
    final isActive = index <= currentStep;
    final color = isActive
        ? kPrimaryColor
        : (isDark ? Colors.white24 : Colors.grey[300]!);

    return Column(
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            boxShadow: isActive
                ? [
                    BoxShadow(
                      color: color.withOpacity(0.4),
                      blurRadius: 8,
                      spreadRadius: 2,
                    ),
                  ]
                : [],
          ),
        ),
      ],
    );
  }

  Widget _buildLine(int index, int currentStep, bool isDark) {
    final isActive = index < currentStep;
    final color = isActive
        ? kPrimaryColor
        : (isDark ? Colors.white12 : Colors.grey[200]!);
    return Container(
      height: 2,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      color: color,
    );
  }
}

class _DateSelectionStep extends StatelessWidget {
  const _DateSelectionStep();

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<BookingWizardCubit>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? kDarkCard : kLightCard;
    final textColor = isDark ? Colors.white : Colors.black;

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "اختر موعد رحلتك",
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: textColor,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "حدد تواريخ الإقامة المناسبة لك.",
            style: TextStyle(
              fontSize: 16,
              color: isDark ? Colors.white60 : Colors.grey[600],
              height: 1.5,
            ),
          ),
          const SizedBox(height: 24),

          BlocBuilder<BookingWizardCubit, BookingWizardState>(
            builder: (context, state) {
              return Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(isDark ? 0.3 : 0.05),
                      blurRadius: 24,
                      offset: const Offset(0, 8),
                    ),
                  ],
                  border: Border.all(
                    color: isDark ? Colors.white10 : Colors.grey[100]!,
                  ),
                ),
                child: Column(
                  children: [
                    _buildDateInput(
                      context,
                      label: "الوصول",
                      date: state.startDate,
                      icon: Icons.login_rounded,
                      color: const Color(0xFF4CAF50),
                      onTap: () => _pickDateRange(context, cubit, state),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      child: Row(
                        children: [
                          Expanded(
                            child: Divider(
                              color: isDark ? Colors.white10 : Colors.grey[200],
                            ),
                          ),
                          Icon(
                            Icons.arrow_downward_rounded,
                            size: 16,
                            color: isDark ? Colors.white24 : Colors.grey[300],
                          ),
                          Expanded(
                            child: Divider(
                              color: isDark ? Colors.white10 : Colors.grey[200],
                            ),
                          ),
                        ],
                      ),
                    ),
                    _buildDateInput(
                      context,
                      label: "المغادرة",
                      date: state.endDate,
                      icon: Icons.logout_rounded,
                      color: const Color(0xFFFF5252),
                      onTap: () => _pickDateRange(context, cubit, state),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDateInput(
    BuildContext context, {
    required String label,
    required DateTime? date,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final hasDate = date != null;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: hasDate
              ? color.withOpacity(0.05)
              : (isDark ? Colors.white.withOpacity(0.02) : Colors.grey[50]),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: hasDate ? color.withOpacity(0.3) : Colors.transparent,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 20, color: color),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark ? Colors.white54 : Colors.grey[600],
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    hasDate
                        ? "${date.day}/${date.month}/${date.year}"
                        : "اختر التاريخ",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
            if (!hasDate)
              Icon(
                Icons.edit_calendar_rounded,
                color: isDark ? Colors.white24 : Colors.grey[400],
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickDateRange(
    BuildContext context,
    BookingWizardCubit cubit,
    BookingWizardState state,
  ) async {
    final requestData = cubit.requestData;

    DateTime? parseDate(dynamic val) {
      if (val == null) return null;
      if (val is Timestamp) return val.toDate();
      if (val is String) return DateTime.tryParse(val);
      if (val is DateTime) return val;
      return null;
    }

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    final serverFrom = parseDate(requestData['availableFrom']);
    final serverTo = parseDate(requestData['availableTo']);

    DateTime rangeFirst;
    DateTime rangeLast;
    if (serverFrom != null && serverTo != null) {
      final from = DateTime(serverFrom.year, serverFrom.month, serverFrom.day);
      final to = DateTime(serverTo.year, serverTo.month, serverTo.day);
      rangeFirst = from.isBefore(today) ? today : from;
      rangeLast = to.isBefore(rangeFirst) ? rangeFirst : to;
    } else {
      rangeFirst = today;
      rangeLast = today.add(const Duration(days: 30));
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'فترة الحجز غير محددة. يمكنك اختيار من اليوم ولمدة 30 يوماً.',
            ),
          ),
        );
      }
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Theme Data
    final themeData = Theme.of(context).copyWith(
      colorScheme: isDark
          ? const ColorScheme.dark(
              primary: kPrimaryColor,
              onPrimary: Colors.black,
              surface: Color(0xFF1E1E1E),
              onSurface: Colors.white,
              secondary: kPrimaryColor,
              onSecondary: Colors.black,
            )
          : const ColorScheme.light(
              primary: kPrimaryColor,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
      dialogBackgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: isDark ? Colors.white : kPrimaryColor,
        ),
      ),
    );

    // Range Picker (مقيد بفترة الحجز فقط)
    final picked = await showDateRangePicker(
      context: context,
      initialDateRange: state.startDate != null && state.endDate != null
          ? DateTimeRange(start: state.startDate!, end: state.endDate!)
          : null,
      firstDate: rangeFirst,
      lastDate: rangeLast,
      builder: (context, child) => Theme(data: themeData, child: child!),
    );
    if (picked != null) {
      cubit.selectDates(picked.start, picked.end);
    }
  }
}

class _BookingReviewStep extends StatelessWidget {
  const _BookingReviewStep();

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<BookingWizardCubit>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? kDarkCard : kLightCard;
    final textColor = isDark ? Colors.white : Colors.black;

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          BlocBuilder<BookingWizardCubit, BookingWizardState>(
            builder: (context, state) {
              return Stack(
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: cardColor,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(isDark ? 0.3 : 0.05),
                          blurRadius: 24,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Text(
                          'الإجمالي',
                          style: TextStyle(
                            color: isDark ? Colors.white54 : Colors.grey[600],
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${state.totalAmount.toStringAsFixed(0)} EGP',
                          style: const TextStyle(
                            fontSize: 36,
                            fontWeight: FontWeight.w900,
                            color: kPrimaryColor,
                            letterSpacing: -1,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${state.nights} ليالي',
                          style: TextStyle(
                            color: isDark ? Colors.white38 : Colors.grey[400],
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        const SizedBox(height: 32),
                        Divider(
                          height: 1,
                          color: isDark ? Colors.white10 : Colors.grey[100],
                        ),
                        const SizedBox(height: 32),

                        _buildGuestCounter(context, cubit, state),

                        const SizedBox(height: 32),
                        Divider(
                          height: 1,
                          color: isDark ? Colors.white10 : Colors.grey[100],
                        ),
                        const SizedBox(height: 32),

                        InkWell(
                          onTap: () => cubit.toggleTerms(!state.termsAccepted),
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: state.termsAccepted
                                  ? kPrimaryColor.withOpacity(0.1)
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: state.termsAccepted
                                    ? kPrimaryColor
                                    : (isDark
                                          ? Colors.white24
                                          : Colors.grey[300]!),
                              ),
                            ),
                            child: Row(
                              children: [
                                Checkbox(
                                  value: state.termsAccepted,
                                  activeColor: kPrimaryColor,
                                  onChanged: (v) =>
                                      cubit.toggleTerms(v ?? false),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(5),
                                  ),
                                ),
                                Expanded(
                                  child: Text(
                                    'أوافق على الشروط وسياسات الإلغاء',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: textColor,
                                      fontSize: 13,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  Positioned(
                    top: 12,
                    right: 24,
                    left: 24,
                    child: Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: isDark ? Colors.white10 : Colors.grey[200],
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildGuestCounter(
    BuildContext context,
    BookingWizardCubit cubit,
    BookingWizardState state,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "الأطفال",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black,
              ),
            ),
            Text(
              "أضف عدد الأطفال",
              style: TextStyle(
                fontSize: 12,
                color: isDark ? Colors.white54 : Colors.grey,
              ),
            ),
          ],
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
          decoration: BoxDecoration(
            color: isDark ? Colors.black26 : Colors.grey[100],
            borderRadius: BorderRadius.circular(30),
          ),
          child: Row(
            children: [
              _buildRoundBtn(
                Icons.remove,
                () => cubit.updateGuestCount(state.guestCount - 1),
                isDark,
              ),
              SizedBox(
                width: 24,
                child: Center(
                  child: Text(
                    "${state.guestCount}",
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
              _buildRoundBtn(
                Icons.add,
                () => cubit.updateGuestCount(state.guestCount + 1),
                isDark,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRoundBtn(IconData icon, VoidCallback onTap, bool isDark) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: isDark ? Colors.white10 : Colors.white,
          shape: BoxShape.circle,
          boxShadow: [
            if (!isDark)
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
          ],
        ),
        child: Icon(
          icon,
          size: 16,
          color: isDark ? Colors.white : Colors.black,
        ),
      ),
    );
  }
}

class _WizardBottomBar extends StatelessWidget {
  const _WizardBottomBar();

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<BookingWizardCubit>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return BlocBuilder<BookingWizardCubit, BookingWizardState>(
      builder: (context, state) {
        final isLast = state.currentStep == 1;
        final isValid = isLast ? state.termsAccepted : state.isDatesSelected;

        return Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: isDark ? kDarkCard : kLightCard,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(isDark ? 0.3 : 0.05),
                blurRadius: 20,
                offset: const Offset(0, -5),
              ),
            ],
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Row(
            children: [
              if (state.currentStep > 0)
                Padding(
                  padding: const EdgeInsets.only(left: 16),
                  child: InkWell(
                    onTap: cubit.previousStep,
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: isDark ? Colors.white24 : Colors.grey[300]!,
                        ),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Icon(
                        Icons.arrow_back,
                        color: isDark ? Colors.white70 : Colors.black54,
                      ),
                    ),
                  ),
                ),
              Expanded(
                child: ElevatedButton(
                  onPressed: isValid
                      ? () => isLast ? cubit.submitBooking() : cubit.nextStep()
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kPrimaryColor,
                    disabledBackgroundColor: isDark
                        ? Colors.white10
                        : Colors.grey[300],
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        isLast ? "تأكيد واستمرار" : "التالي",
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (!isLast) ...[
                        const SizedBox(width: 8),
                        const Icon(Icons.arrow_forward_rounded, size: 18),
                      ],
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
}

class RatingBottomSheet extends StatefulWidget {
  final VoidCallback onComplete;
  const RatingBottomSheet({super.key, required this.onComplete});

  @override
  State<RatingBottomSheet> createState() => _RatingBottomSheetState();
}

class _RatingBottomSheetState extends State<RatingBottomSheet> {
  double tempRating = 0;
  final controller = TextEditingController();
  bool isSubmitting = false;

  @override
  Widget build(BuildContext context) {
    final canSubmit = tempRating > 0 && controller.text.trim().isNotEmpty;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? kDarkCard : Colors.white;
    final text = isDark ? Colors.white : Colors.black;
    final keyboardPadding = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      decoration: BoxDecoration(
        color: bg,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
      ),
      padding: EdgeInsets.fromLTRB(24, 24, 24, keyboardPadding + 24),
      child: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'كيف كانت تجربتك؟',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: text,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'تقييمك يساعدنا على تحسين الخدمة',
                style: TextStyle(
                  fontSize: 14,
                  color: isDark ? Colors.white54 : Colors.grey,
                ),
              ),
              const SizedBox(height: 32),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (i) {
                  final active = tempRating >= i + 1;
                  return GestureDetector(
                    onTap: () =>
                        setState(() => tempRating = (i + 1).toDouble()),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: Icon(
                        active
                            ? Icons.star_rounded
                            : Icons.star_outline_rounded,
                        color: active
                            ? const Color(0xFFFFC107)
                            : (isDark ? Colors.white24 : Colors.grey[300]),
                        size: 48,
                      ),
                    ),
                  );
                }),
              ),

              const SizedBox(height: 32),

              TextField(
                controller: controller,
                maxLines: 4,
                onChanged: (v) =>
                    setState(() {}), // Update canSubmit in real-time
                style: TextStyle(color: text),
                decoration: InputDecoration(
                  hintText: 'اكتبي ملاحظاتك هنا...',
                  hintStyle: TextStyle(
                    color: isDark ? Colors.white30 : Colors.grey[400],
                  ),
                  filled: true,
                  fillColor: isDark ? Colors.black12 : Colors.grey[50],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.all(16),
                ),
              ),

              const SizedBox(height: 32),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: (canSubmit && !isSubmitting) ? _submit : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kPrimaryColor,
                    disabledBackgroundColor: isDark
                        ? Colors.white10
                        : Colors.grey[200],
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: isSubmitting
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text(
                          "إرسال التقييم",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _submit() async {
    setState(() => isSubmitting = true);
    // Removed FocusScope.of(context).unfocus() to allow sending without hiding keyboard

    try {
      final cubit = context.read<BookingWizardCubit>();

      final ratingData = {
        'chaletId': cubit.chaletId,
        'chaletName': cubit.chaletName,
        'userId': cubit.userId,
        'userName': cubit.userName,
        'rating': tempRating,
        'review': controller.text.trim(),
        'createdAt': FieldValue.serverTimestamp(),
      };

      await FirebaseFirestore.instance
          .collection('chalet_ratings')
          .add(ratingData);

      await _updateChaletRatingAggregate(
        chaletId: cubit.chaletId,
        newRating: tempRating,
      );

      if (mounted) {
        SnackBarHelper.showSuccess(context, 'شكراً لتقييمك! ⭐');
        widget.onComplete();
      }
    } catch (e) {
      if (mounted) {
        SnackBarHelper.showError(context, 'حدث خطأ: $e');
        setState(() => isSubmitting = false);
      }
    }
  }

  Future<void> _updateChaletRatingAggregate({
    required String chaletId,
    required double newRating,
  }) async {
    final chaletRef = FirebaseFirestore.instance
        .collection('chalets')
        .doc(chaletId);
    await FirebaseFirestore.instance.runTransaction((txn) async {
      final snap = await txn.get(chaletRef);
      if (!snap.exists) return;

      final data = snap.data() ?? {};
      final num count = (data['ratingCount'] ?? 0);
      final num sum = (data['ratingSum'] ?? 0);

      final double newCount = (count.toDouble() + 1);
      final double newSum = (sum.toDouble() + newRating);
      final double avg = newCount == 0 ? newRating : newSum / newCount;

      txn.update(chaletRef, {
        'ratingCount': newCount,
        'ratingSum': newSum,
        'rating': double.parse(avg.toStringAsFixed(2)),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    });
  }
}
