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
import 'package:rebtal/feature/booking/widgets/booking_table_range_picker_dialog.dart';
import 'package:rebtal/feature/booking/widgets/booking_date_step_view.dart';
import 'package:rebtal/feature/booking/widgets/booking_pricing_step_view.dart';
import 'package:rebtal/core/utils/services/chalet_pricing_service.dart';
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
      backgroundColor: isDark ? const Color(0xFF000000) : const Color(0xFFF5F5F5),
      body: BlocListener<BookingWizardCubit, BookingWizardState>(
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
                      child:
                          BlocBuilder<BookingWizardCubit, BookingWizardState>(
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
                                  child: switch (state.currentStep) {
                                    0 => const _DateSelectionStep(),
                                    1 => _BookingPricingStep(
                                      isDark: Theme.of(context).brightness ==
                                          Brightness.dark,
                                    ),
                                    _ => const _BookingReviewStep(),
                                  },
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
        final step = state.currentStep.clamp(0, BookingWizardCubit.lastStepIndex);
        final isDark = Theme.of(context).brightness == Brightness.dark;
        final labels = [
          context.tr('booking_wizard_step_date'),
          context.tr('booking_wizard_step_pricing'),
          context.tr('booking_wizard_step_review'),
        ];
        final inactive = isDark ? const Color(0xFF3A3A3C) : const Color(0xFFD1D5DB);

        Widget connector(int index) {
          return Expanded(
            child: Container(
              height: 2,
              margin: const EdgeInsets.only(bottom: 18, left: 4, right: 4),
              color: step > index ? kPrimaryColor : inactive,
            ),
          );
        }

        return Padding(
          padding: EdgeInsets.fromLTRB(
            stv(context: context, mobile: 16.sw, tablet: 24.sw, desktop: 28.sw),
            8,
            stv(context: context, mobile: 16.sw, tablet: 24.sw, desktop: 28.sw),
            otv(context: context, portrait: 8.sh, landscape: 6.sh),
          ),
          child: Row(
            children: [
              _WizardStepDot(
                index: 1,
                label: labels[0],
                isActive: step == 0,
                isDone: step > 0,
                isDark: isDark,
                compact: true,
              ),
              connector(0),
              _WizardStepDot(
                index: 2,
                label: labels[1],
                isActive: step == 1,
                isDone: step > 1,
                isDark: isDark,
                compact: true,
              ),
              connector(1),
              _WizardStepDot(
                index: 3,
                label: labels[2],
                isActive: step == 2,
                isDone: false,
                isDark: isDark,
                compact: true,
              ),
            ],
          ),
        );
      },
    );
  }
}

class _WizardStepDot extends StatelessWidget {
  const _WizardStepDot({
    required this.index,
    required this.label,
    required this.isActive,
    required this.isDone,
    required this.isDark,
    this.compact = false,
  });

  final int index;
  final String label;
  final bool isActive;
  final bool isDone;
  final bool isDark;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final muted = isDark ? const Color(0xFF8E8E93) : const Color(0xFF6B7280);
    final active = isActive || isDone;

    return Column(
      children: [
        Container(
          width: 28,
          height: 28,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isDone && !isActive
                ? kPrimaryColor
                : (isActive ? kPrimaryColor.withValues(alpha: 0.15) : Colors.transparent),
            border: Border.all(
              color: active ? kPrimaryColor : (isDark ? const Color(0xFF3A3A3C) : const Color(0xFFD1D5DB)),
              width: 1.5,
            ),
          ),
          child: isDone && !isActive
              ? const Icon(Icons.check_rounded, size: 16, color: Colors.white)
              : Text(
                  '$index',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                    color: isActive ? kPrimaryColor : muted,
                  ),
                ),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: compact ? 10 : 12,
            fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
            color: active ? (isDark ? Colors.white : Colors.black87) : muted,
          ),
        ),
      ],
    );
  }
}

class _DateSelectionStep extends StatelessWidget {
  const _DateSelectionStep();

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<BookingWizardCubit>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return BlocBuilder<BookingWizardCubit, BookingWizardState>(
      buildWhen: (prev, curr) =>
          prev.isDatesSelected != curr.isDatesSelected ||
          prev.startDate != curr.startDate ||
          prev.endDate != curr.endDate ||
          prev.dataRevision != curr.dataRevision,
      builder: (context, state) {
        return BookingDateStepView(
          key: ValueKey(state.dataRevision),
          chaletName: cubit.chaletName,
          requestData: cubit.activeRequestData,
          state: state,
          isDark: isDark,
          onOpenCalendar: () => _pickDateRange(context, cubit, state),
        );
      },
    );
  }

  Future<void> _pickDateRange(
    BuildContext context,
    BookingWizardCubit cubit,
    BookingWizardState state,
  ) async {
    final requestData = cubit.activeRequestData;

    DateTime? parseDate(dynamic val) {
      if (val == null) return null;
      if (val is Timestamp) return val.toDate();
      if (val is String) return DateTime.tryParse(val);
      if (val is DateTime) return val;
      return null;
    }

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    final serverFrom = ChaletPricingService.envelopeFrom(requestData) ??
        parseDate(requestData['availableFrom']);
    final serverTo = ChaletPricingService.envelopeTo(requestData) ??
        parseDate(requestData['availableTo']);

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
          SnackBar(content: Text(context.tr('booking_wizard_undef_period_30'))),
        );
      }
    }

    final cached = cubit.cachedOccupancy;
    final occupancyFuture =
        cubit.isOccupancyReady ? null : cubit.ensureOccupancy();

    final pricingData = Map<String, dynamic>.from(requestData);
    if (cubit.basePriceInput != null && pricingData['price'] == null) {
      pricingData['price'] = cubit.basePriceInput;
    }

    final picked = await showBookingTableRangePicker(
      context,
      firstDate: rangeFirst,
      lastDate: rangeLast,
      bookedDays: cached?.confirmedBooked ?? const {},
      pendingDays: cached?.pendingReview ?? const {},
      occupancyFuture: occupancyFuture,
      initialRange: state.startDate != null && state.endDate != null
          ? DateTimeRange(start: state.startDate!, end: state.endDate!)
          : null,
      dayPriceFor: (day) {
        final price = ChaletPricingService.priceForNight(pricingData, day);
        return price > 0 ? price : null;
      },
    );

    if (!context.mounted || picked == null) return;
    cubit.selectDates(picked.start, picked.end);
  }
}

class _BookingPricingStep extends StatelessWidget {
  const _BookingPricingStep({required this.isDark});

  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BookingWizardCubit, BookingWizardState>(
      builder: (context, state) {
        return BookingPricingStepView(state: state, isDark: isDark);
      },
    );
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
              return Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: isDark
                        ? const Color(0xFF2C2C2E)
                        : const Color(0xFFE5E7EB),
                  ),
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
        final isLast = state.currentStep == BookingWizardCubit.lastStepIndex;
        final isValid = switch (state.currentStep) {
          0 => state.isDatesSelected,
          1 => state.nightlyBreakdown.isNotEmpty,
          _ => state.termsAccepted,
        };
        final actionLabel = switch (state.currentStep) {
          0 => context.tr('booking_wizard_next'),
          1 => context.tr('booking_wizard_continue_pricing'),
          _ => context.tr('booking_wizard_confirm_continue'),
        };

        return Container(
          padding: EdgeInsets.fromLTRB(
            20,
            otv(context: context, portrait: 12.sh, landscape: 8.sh),
            20,
            otv(context: context, portrait: 16.sh, landscape: 12.sh),
          ),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1C1C1E) : Colors.white,
            border: Border(
              top: BorderSide(
                color: isDark ? const Color(0xFF2C2C2E) : const Color(0xFFE5E7EB),
              ),
            ),
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
                      padding: EdgeInsets.all(
                        otv(context: context, portrait: 16.sh, landscape: 8.sh),
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: isDark ? Colors.white24 : Colors.grey[300]!,
                        ),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Icon(
                        Icons.arrow_back,
                        color: isDark ? Colors.white70 : Colors.black54,
                        size: stv(
                          context: context,
                          mobile: 20.spScaled,
                          tablet: 22.spScaled,
                          desktop: 24.spScaled,
                        ),
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
                          color: isValid
                              ? kPrimaryColor
                              : (isDark
                                    ? Colors.white.withValues(alpha: 0.08)
                                    : Colors.grey[300]),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Center(
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                actionLabel,
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
              SizedBox(
                height: otv(
                  context: context,
                  portrait: 24.sh,
                  landscape: 12.sh,
                ),
              ),
              Text(
                context.tr('booking_rating_how_experience'),
                style: TextStyle(
                  fontSize: stv(
                    context: context,
                    mobile: 22.spScaled,
                    tablet: 24.spScaled,
                    desktop: 26.spScaled,
                  ),
                  fontWeight: FontWeight.bold,
                  color: text,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                context.tr('booking_rating_helps'),
                style: TextStyle(
                  fontSize: stv(
                    context: context,
                    mobile: 14.spScaled,
                    tablet: 15.spScaled,
                    desktop: 16.spScaled,
                  ),
                  color: isDark ? Colors.white54 : Colors.grey,
                ),
              ),
              SizedBox(
                height: otv(
                  context: context,
                  portrait: 32.sh,
                  landscape: 16.sh,
                ),
              ),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (i) {
                  final active = tempRating >= i + 1;
                  return GestureDetector(
                    onTap: () =>
                        setState(() => tempRating = (i + 1).toDouble()),
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: stv(
                          context: context,
                          mobile: 4.sw,
                          tablet: 6.sw,
                          desktop: 8.sw,
                        ),
                      ),
                      child: Icon(
                        active
                            ? Icons.star_rounded
                            : Icons.star_outline_rounded,
                        color: active
                            ? const Color(0xFFFFC107)
                            : (isDark ? Colors.white24 : Colors.grey[300]),
                        size: stv(
                          context: context,
                          mobile: 48.spScaled,
                          tablet: 56.spScaled,
                          desktop: 64.spScaled,
                        ),
                      ),
                    ),
                  );
                }),
              ),

              SizedBox(
                height: otv(
                  context: context,
                  portrait: 32.sh,
                  landscape: 16.sh,
                ),
              ),

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
                    fontSize: stv(
                      context: context,
                      mobile: 14.spScaled,
                      tablet: 15.spScaled,
                      desktop: 16.spScaled,
                    ),
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

              SizedBox(
                height: otv(
                  context: context,
                  portrait: 32.sh,
                  landscape: 16.sh,
                ),
              ),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: (canSubmit && !isSubmitting) ? _submit : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kPrimaryColor,
                    disabledBackgroundColor: isDark
                        ? Colors.white10
                        : Colors.grey[200],
                    padding: EdgeInsets.symmetric(
                      vertical: otv(
                        context: context,
                        portrait: 18.sh,
                        landscape: 12.sh,
                      ),
                    ),
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
                            fontSize: stv(
                              context: context,
                              mobile: 16.spScaled,
                              tablet: 17.spScaled,
                              desktop: 18.spScaled,
                            ),
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
        SnackBarHelper.showSuccess(
          context,
          context.tr('booking_rating_thanks'),
        );
        widget.onComplete();
      }
    } catch (e) {
      if (mounted) {
        SnackBarHelper.showError(context, '${context.tr('common_error')}: $e');
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
