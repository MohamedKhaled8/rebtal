import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:animate_do/animate_do.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rebtal/feature/booking/logic/wizard_cubit/booking_wizard_cubit.dart';
import 'package:rebtal/feature/booking/logic/wizard_cubit/booking_wizard_state.dart';
import 'package:rebtal/core/utils/helper/snack_bar_helper.dart';
import 'package:rebtal/core/utils/widgets/premium_loading_overlay.dart';
import 'package:rebtal/core/app/cubit/app_cubit.dart';
import 'package:rebtal/core/utils/localization/translation_extension.dart';
import 'package:rebtal/core/utils/helper/chalet_booked_calendar_helper.dart';
import 'package:rebtal/feature/booking/widgets/booking_table_range_picker_dialog.dart';
import 'package:responsive_screen_master/responsive_screen_master.dart';
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
      return Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              context.tr('booking_please_login'),
              textAlign: TextAlign.center,
            ),
          ),
        ),
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
    final text = isDark ? Colors.white : Colors.black;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDark
                ? const [
                    Color(0xFF0E1812),
                    Color(0xFF121212),
                    Color(0xFF0A0F0C),
                  ]
                : const [
                    Color(0xFFE6FBF0),
                    Color(0xFFFAFAFA),
                    Color(0xFFFFFFFF),
                  ],
            stops: const [0.0, 0.5, 1.0],
          ),
        ),
        child: BlocListener<BookingWizardCubit, BookingWizardState>(
        listener: (context, state) {
          if (!mounted) return;
          if (state.errorMessage != null) {
            SnackBarHelper.showError(context, state.errorMessage!);
          }
          if (state.status == BookingWizardStatus.submitting) {
            PremiumLoadingOverlay.show(
              context,
              message: context.tr('booking_wizard_processing'),
            );
          } else if (state.status == BookingWizardStatus.success) {
            PremiumLoadingOverlay.dismiss(context);
            // Play Celebration
            _confettiController.play();
            if (mounted) {
              SnackBarHelper.showSuccess(
                context,
                context.tr('booking_sent_to_owner'),
              );
              Navigator.of(context).pop();
            }
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
      ),
    );
  }

  Widget _buildHeader(BuildContext context, bool isDark, Color textColor) {
    final hPad = stv(
      context: context,
      mobile: 20.sw,
      tablet: 24.sw,
      desktop: 28.sw,
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(
            horizontal: hPad,
            vertical: otv(context: context, portrait: 8.sh, landscape: 4.sh),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: Icon(
                  Icons.close_rounded,
                  size: stv(
                    context: context,
                    mobile: 24.spScaled,
                    tablet: 28.spScaled,
                    desktop: 32.spScaled,
                  ),
                  color: isDark ? Colors.white70 : Colors.black54,
                ),
                style: IconButton.styleFrom(
                  backgroundColor: isDark ? Colors.white10 : Colors.grey[100],
                  padding: EdgeInsets.all(
                    stv(
                      context: context,
                      mobile: 6.sw,
                      tablet: 8.sw,
                      desktop: 10.sw,
                    ),
                  ),
                ),
              ),
              Text(
                context.tr('booking_confirm'),
                style: TextStyle(
                  fontSize: stv(
                    context: context,
                    mobile: 18.spScaled,
                    tablet: 20.spScaled,
                    desktop: 22.spScaled,
                  ),
                  fontWeight: FontWeight.bold,
                  color: textColor,
                  letterSpacing: -0.3,
                ),
              ),
              const SizedBox(width: 48),
            ],
          ),
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: hPad),
          child: Container(
            height: 3,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(3),
              gradient: LinearGradient(
                colors: [
                  kPrimaryColor,
                  kPrimaryColor.withValues(alpha: 0.35),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),
      ],
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
        final step = state.currentStep.clamp(0, 1);
        final isDark = Theme.of(context).brightness == Brightness.dark;
        final labels = [
          context.tr('booking_wizard_step_date'),
          context.tr('booking_wizard_step_review'),
        ];

        return Padding(
          padding: EdgeInsets.fromLTRB(
            stv(context: context, mobile: 20.sw, tablet: 28.sw, desktop: 32.sw),
            4,
            stv(context: context, mobile: 20.sw, tablet: 28.sw, desktop: 32.sw),
            otv(context: context, portrait: 12.sh, landscape: 8.sh),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _WizardStepTile(
                  index: 1,
                  label: labels[0],
                  isDone: step >= 1,
                  isCurrent: step == 0,
                  isDark: isDark,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 14, left: 6, right: 6),
                child: _WizardStepConnector(
                  filled: step >= 1,
                  isDark: isDark,
                ),
              ),
              Expanded(
                child: _WizardStepTile(
                  index: 2,
                  label: labels[1],
                  isDone: false,
                  isCurrent: step == 1,
                  isDark: isDark,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _WizardStepTile extends StatelessWidget {
  const _WizardStepTile({
    required this.index,
    required this.label,
    required this.isDone,
    required this.isCurrent,
    required this.isDark,
  });

  final int index;
  final String label;
  final bool isDone;
  final bool isCurrent;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final active = isCurrent || isDone;
    final ring = active
        ? kPrimaryColor
        : (isDark ? Colors.white24 : Colors.grey[400]!);
    final fill = isDone && !isCurrent
        ? kPrimaryColor.withValues(alpha: 0.2)
        : (isCurrent
              ? kPrimaryColor.withValues(alpha: 0.15)
              : (isDark ? Colors.white.withValues(alpha: 0.04) : Colors.grey[100]!));

    return Column(
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 320),
          curve: Curves.easeOutCubic,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: fill,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: ring.withValues(alpha: active ? 0.9 : 0.35),
              width: active ? 1.5 : 1,
            ),
            boxShadow: isCurrent
                ? [
                    BoxShadow(
                      color: kPrimaryColor.withValues(alpha: 0.25),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : null,
          ),
          child: Row(
            children: [
              Container(
                width: 28,
                height: 28,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: active ? kPrimaryColor : Colors.transparent,
                  border: Border.all(
                    color: active ? kPrimaryColor : ring,
                    width: 2,
                  ),
                ),
                child: isDone && !isCurrent
                    ? const Icon(Icons.check_rounded, size: 16, color: Colors.white)
                    : Text(
                        '$index',
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 13,
                          color: active && !isDone
                              ? Colors.white
                              : (isDark ? Colors.white70 : Colors.black54),
                        ),
                      ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                    color: active
                        ? (isDark ? Colors.white : Colors.black87)
                        : (isDark ? Colors.white38 : Colors.black45),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _WizardStepConnector extends StatelessWidget {
  const _WizardStepConnector({
    required this.filled,
    required this.isDark,
  });

  final bool filled;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 28,
      height: 4,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(4),
          gradient: LinearGradient(
            colors: filled
                ? [kPrimaryColor, kPrimaryColor.withValues(alpha: 0.6)]
                : [
                    isDark ? Colors.white12 : Colors.grey[300]!,
                    isDark ? Colors.white10 : Colors.grey[200]!,
                  ],
          ),
        ),
      ),
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
      padding: EdgeInsets.fromLTRB(
        stv(context: context, mobile: 24.sw, tablet: 28.sw, desktop: 32.sw),
        otv(context: context, portrait: 12.sh, landscape: 8.sh),
        stv(context: context, mobile: 24.sw, tablet: 28.sw, desktop: 32.sw),
        stv(context: context, mobile: 24.sw, tablet: 28.sw, desktop: 32.sw),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              final isLandscape = MediaQuery.of(context).orientation == Orientation.landscape;
              if (isLandscape) {
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        context.tr('booking_select_trip_date'),
                        style: TextStyle(
                          fontSize: stv(context: context, mobile: 24.spScaled, tablet: 26.spScaled, desktop: 28.spScaled),
                          fontWeight: FontWeight.w800,
                          color: textColor,
                          letterSpacing: -0.5,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        context.tr('booking_wizard_select_dates_desc'),
                        style: TextStyle(
                          fontSize: stv(context: context, mobile: 14.spScaled, tablet: 15.spScaled, desktop: 16.spScaled),
                          color: isDark ? Colors.white60 : Colors.grey[600],
                        ),
                      ),
                    ),
                  ],
                );
              }
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    context.tr('booking_select_trip_date'),
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      color: textColor,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    context.tr('booking_wizard_select_dates_desc'),
                    style: TextStyle(
                      fontSize: 16,
                      color: isDark ? Colors.white60 : Colors.grey[600],
                      height: 1.5,
                    ),
                  ),
                ],
              );
            },
          ),
          SizedBox(height: otv(context: context, portrait: 16.sh, landscape: 8.sh)),

          if (cubit.chaletName.trim().isNotEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              margin: EdgeInsets.only(
                bottom: otv(context: context, portrait: 14.sh, landscape: 10.sh),
              ),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
                color: isDark
                    ? kPrimaryColor.withValues(alpha: 0.12)
                    : kPrimaryColor.withValues(alpha: 0.08),
                border: Border.all(
                  color: kPrimaryColor.withValues(alpha: 0.4),
                ),
              ),
              child: Row(
                children: [
                  Icon(Icons.cottage_outlined, color: kPrimaryColor, size: 22),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      cubit.chaletName,
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                        color: textColor,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),

          BlocBuilder<BookingWizardCubit, BookingWizardState>(
            builder: (context, state) {
              return Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(26),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      kPrimaryColor.withValues(alpha: 0.7),
                      kPrimaryColor.withValues(alpha: 0.15),
                      const Color(0xFF6366F1).withValues(alpha: 0.35),
                    ],
                  ),
                ),
                padding: const EdgeInsets.all(2),
                child: Container(
                  padding: EdgeInsets.all(
                    stv(context: context, mobile: 20.sw, tablet: 24.sw, desktop: 28.sw),
                  ),
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(
                          alpha: isDark ? 0.35 : 0.06,
                        ),
                        blurRadius: 28,
                        offset: const Offset(0, 12),
                      ),
                    ],
                    border: Border.all(
                      color: isDark ? Colors.white10 : Colors.white,
                      width: 1,
                    ),
                  ),
                  child: otv(
                  context: context,
                  portrait: Column(
                    children: [
                      _buildDateInput(
                        context,
                        label: context.tr('booking_wizard_arrival'),
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
                        label: context.tr('booking_wizard_departure'),
                        date: state.endDate,
                        icon: Icons.logout_rounded,
                        color: const Color(0xFFFF5252),
                        onTap: () => _pickDateRange(context, cubit, state),
                      ),
                    ],
                  ),
                  landscape: Row(
                    children: [
                      Expanded(
                        child: _buildDateInput(
                          context,
                          label: context.tr('booking_wizard_arrival'),
                          date: state.startDate,
                          icon: Icons.login_rounded,
                          color: const Color(0xFF4CAF50),
                          onTap: () => _pickDateRange(context, cubit, state),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Icon(
                          Icons.arrow_forward_rounded,
                          size: 20,
                          color: isDark ? Colors.white24 : Colors.grey[300],
                        ),
                      ),
                      Expanded(
                        child: _buildDateInput(
                          context,
                          label: context.tr('booking_wizard_departure'),
                          date: state.endDate,
                          icon: Icons.logout_rounded,
                          color: const Color(0xFFFF5252),
                          onTap: () => _pickDateRange(context, cubit, state),
                        ),
                      ),
                    ],
                  ),
                ),
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
                        : context.tr('booking_wizard_pick_date'),
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
          SnackBar(
            content: Text(
              context.tr('booking_wizard_undef_period_30'),
            ),
          ),
        );
      }
    }

    // أيام تُغلق على التقويم بعد تأكيد الحجز — تقويم مخصص: الأيام المقفولة دائرة حمراء «محددة»
    final bookedDays = await loadChaletBookedDaySet(cubit.chaletId);

    if (!context.mounted) return;

    final picked = await showBookingTableRangePicker(
      context,
      firstDate: rangeFirst,
      lastDate: rangeLast,
      bookedDays: bookedDays,
      initialRange: state.startDate != null && state.endDate != null
          ? DateTimeRange(start: state.startDate!, end: state.endDate!)
          : null,
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
                          context.tr('booking_total_label').replaceAll(':', ''),
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
                          '${state.nights} ${context.tr('booking_wizard_nights')}',
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
                                    context.tr('booking_wizard_agree_terms'),
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
              context.tr('booking_wizard_children_title'),
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black,
              ),
            ),
            Text(
              context.tr('booking_wizard_children_subtitle'),
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
          padding: EdgeInsets.all(otv(context: context, portrait: 16.sh, landscape: 10.sh)),
          decoration: BoxDecoration(
            color: isDark ? kDarkCard : kLightCard,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.06),
                blurRadius: 24,
                offset: const Offset(0, -8),
              ),
            ],
            border: Border(
              top: BorderSide(
                color: isDark
                    ? kPrimaryColor.withValues(alpha: 0.25)
                    : kPrimaryColor.withValues(alpha: 0.35),
                width: 1,
              ),
            ),
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
                      padding: EdgeInsets.all(otv(context: context, portrait: 16.sh, landscape: 8.sh)),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: isDark ? Colors.white24 : Colors.grey[300]!,
                        ),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Icon(
                        Icons.arrow_back,
                        color: isDark ? Colors.white70 : Colors.black54,
                        size: stv(context: context, mobile: 20.spScaled, tablet: 22.spScaled, desktop: 24.spScaled),
                      ),
                    ),
                  ),
                ),
              Expanded(
                child: SizedBox(
                  height: otv(
                    context: context,
                    portrait: 52.sh,
                    landscape: 44.sh,
                  ),
                  child: Material(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(18),
                    clipBehavior: Clip.antiAlias,
                    child: InkWell(
                      onTap: isValid
                          ? () {
                              if (isLast) {
                                cubit.submitBooking();
                              } else {
                                cubit.nextStep();
                              }
                            }
                          : null,
                      borderRadius: BorderRadius.circular(18),
                      child: Ink(
                        decoration: BoxDecoration(
                          gradient: isValid
                              ? const LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    Color(0xFF3CE89F),
                                    kPrimaryColor,
                                    Color(0xFF00A656),
                                  ],
                                )
                              : null,
                          color: !isValid
                              ? (isDark
                                    ? Colors.white.withValues(alpha: 0.08)
                                    : Colors.grey[300])
                              : null,
                        ),
                        child: Center(
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                isLast
                                    ? context.tr('booking_wizard_confirm_continue')
                                    : context.tr('booking_wizard_next'),
                                style: TextStyle(
                                  fontSize: stv(
                                    context: context,
                                    mobile: 16.spScaled,
                                    tablet: 17.spScaled,
                                    desktop: 18.spScaled,
                                  ),
                                  fontWeight: FontWeight.bold,
                                  color: isValid
                                      ? Colors.white
                                      : (isDark
                                            ? Colors.white38
                                            : Colors.black45),
                                ),
                              ),
                              if (!isLast) ...[
                                const SizedBox(width: 8),
                                Icon(
                                  Icons.arrow_forward_rounded,
                                  size: stv(
                                    context: context,
                                    mobile: 18.spScaled,
                                    tablet: 20.spScaled,
                                    desktop: 22.spScaled,
                                  ),
                                  color: isValid
                                      ? Colors.white
                                      : (isDark
                                            ? Colors.white38
                                            : Colors.black45),
                                ),
                              ],
                            ],
                          ),
                        ),
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
      padding: EdgeInsets.fromLTRB(
        stv(context: context, mobile: 24.sw, tablet: 32.sw, desktop: 40.sw),
        12,
        stv(context: context, mobile: 24.sw, tablet: 32.sw, desktop: 40.sw),
        keyboardPadding + 24,
      ),
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
              SizedBox(height: otv(context: context, portrait: 24.sh, landscape: 12.sh)),
              Text(
                context.tr('booking_rating_how_experience'),
                style: TextStyle(
                  fontSize: stv(context: context, mobile: 22.spScaled, tablet: 24.spScaled, desktop: 26.spScaled),
                  fontWeight: FontWeight.bold,
                  color: text,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                context.tr('booking_rating_helps'),
                style: TextStyle(
                  fontSize: stv(context: context, mobile: 14.spScaled, tablet: 15.spScaled, desktop: 16.spScaled),
                  color: isDark ? Colors.white54 : Colors.grey,
                ),
              ),
              SizedBox(height: otv(context: context, portrait: 32.sh, landscape: 16.sh)),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (i) {
                  final active = tempRating >= i + 1;
                  return GestureDetector(
                    onTap: () =>
                        setState(() => tempRating = (i + 1).toDouble()),
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: stv(context: context, mobile: 4.sw, tablet: 6.sw, desktop: 8.sw)),
                      child: Icon(
                        active
                            ? Icons.star_rounded
                            : Icons.star_outline_rounded,
                        color: active
                            ? const Color(0xFFFFC107)
                            : (isDark ? Colors.white24 : Colors.grey[300]),
                        size: stv(context: context, mobile: 48.spScaled, tablet: 56.spScaled, desktop: 64.spScaled),
                      ),
                    ),
                  );
                }),
              ),

              SizedBox(height: otv(context: context, portrait: 32.sh, landscape: 16.sh)),

              TextField(
                controller: controller,
                maxLines: otv(context: context, portrait: 4, landscape: 2),
                onChanged: (v) =>
                    setState(() {}), // Update canSubmit in real-time
                style: TextStyle(color: text),
                decoration: InputDecoration(
                  hintText: context.tr('booking_rating_write_notes'),
                  hintStyle: TextStyle(
                    color: isDark ? Colors.white30 : Colors.grey[400],
                    fontSize: stv(context: context, mobile: 14.spScaled, tablet: 15.spScaled, desktop: 16.spScaled),
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

              SizedBox(height: otv(context: context, portrait: 32.sh, landscape: 16.sh)),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: (canSubmit && !isSubmitting) ? _submit : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kPrimaryColor,
                    disabledBackgroundColor: isDark
                        ? Colors.white10
                        : Colors.grey[200],
                    padding: EdgeInsets.symmetric(vertical: otv(context: context, portrait: 18.sh, landscape: 12.sh)),
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
                      : Text(
                          context.tr('booking_wizard_submit_rating'),
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: stv(context: context, mobile: 16.spScaled, tablet: 17.spScaled, desktop: 18.spScaled),
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
        SnackBarHelper.showSuccess(context, context.tr('booking_rating_thanks'));
        widget.onComplete();
      }
    } catch (e) {
      if (mounted) {
        SnackBarHelper.showError(
          context,
          '${context.tr('common_error')}: $e',
        );
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
