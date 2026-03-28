import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rebtal/core/Router/routes.dart';
import 'package:rebtal/core/utils/localization/translation_extension.dart';
import 'package:rebtal/feature/onboarding/data/constants/terms_content.dart';
import 'package:rebtal/feature/onboarding/logic/cubit/terms_cubit.dart';
import 'package:rebtal/feature/onboarding/logic/cubit/terms_state.dart';
import 'package:responsive_screen_master/responsive_screen_master.dart';

/// Terms & Conditions screen with scroll detection and smart checkbox
/// Checkbox is disabled until user scrolls to the very bottom
class TermsScreen extends StatefulWidget {
  const TermsScreen({super.key});

  @override
  State<TermsScreen> createState() => _TermsScreenState();
}

class _TermsScreenState extends State<TermsScreen> {
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();

    // Listen to scroll events
    _scrollController.addListener(() {
      context.read<TermsCubit>().onScroll(_scrollController);
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<TermsCubit, TermsState>(
      listener: (context, state) {
        // Navigate to auth entry when terms are completed
        if (state is TermsCompleted) {
          Navigator.pushNamedAndRemoveUntil(
            context,
            Routes.authEntryScreen,
            (route) => false,
          );
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        appBar: AppBar(
          title: Text(context.tr('terms_title')),
          backgroundColor: const Color(0xFF2563EB),
          foregroundColor: Colors.white,
          elevation: 0,
          centerTitle: false,
          actions: [
            IconButton(
              onPressed: () => Navigator.of(context).maybePop(),
              icon: const Icon(Icons.close_rounded),
            ),
          ],
        ),
        body: Stack(
          children: [
            SingleChildScrollView(
              controller: _scrollController,
              physics: const BouncingScrollPhysics(),
              child: Column(
                children: [
                  Padding(
                    padding: EdgeInsets.fromLTRB(5.w, 1.6.h, 5.w, 0.5.h),
                    child: Align(
                      alignment: AlignmentDirectional.centerStart,
                      child: Text(
                        context.tr('terms_last_updated'),
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF64748B),
                        ),
                      ),
                    ),
                  ),
                  _buildTermsContent(),
                  _buildAgreementCheckbox(),
                  SizedBox(height: 1.5.h),
                  _buildActionButtons(),
                  SizedBox(height: 8.h),
                ],
              ),
            ),
            Positioned(
              right: 16,
              bottom: 16,
              child: BlocBuilder<TermsCubit, TermsState>(
                builder: (context, state) {
                  final cubit = context.read<TermsCubit>();
                  if (cubit.hasScrolledToBottom) return const SizedBox.shrink();
                  return _ScrollToBottomFab(onTap: _scrollToBottom);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _scrollToBottom() {
    if (!_scrollController.hasClients) return;
    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent,
      duration: const Duration(milliseconds: 650),
      curve: Curves.easeInOutCubic,
    );
  }

  /// Builds the terms content with bullet points formatting
  Widget _buildTermsContent() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 5.w),
      padding: EdgeInsets.symmetric(vertical: 2.h),
      child: _buildFormattedTermsText(),
    );
  }

  /// Builds formatted terms text with bullet points
  Widget _buildFormattedTermsText() {
    final isAr = Directionality.of(context) == TextDirection.rtl;
    final text = isAr
        ? TermsContent.termsAndConditionsAr
        : TermsContent.termsAndConditions;
    final blocks = text
        .split(RegExp(r'\n\s*---\s*\n'))
        .map((b) => b.trim())
        .where((b) => b.isNotEmpty)
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final block in blocks) ...[
          _TermsBlockCard(block: block),
          SizedBox(height: 1.2.h),
        ],
      ],
    );
  }

  /// Builds the agreement checkbox with circular design
  /// Only enabled after scrolling to the very bottom
  Widget _buildAgreementCheckbox() {
    return BlocBuilder<TermsCubit, TermsState>(
      builder: (context, state) {
        final cubit = context.read<TermsCubit>();
        final hasScrolledToBottom = cubit.hasScrolledToBottom;
        final isAgreed = cubit.isAgreed;

        return Padding(
          padding: EdgeInsets.symmetric(horizontal: 5.w),
          child: Row(
            children: [
              // Circular checkbox
              GestureDetector(
                onTap: hasScrolledToBottom
                    ? () {
                        cubit.toggleAgreement(!isAgreed);
                      }
                    : null,
                child: Opacity(
                  opacity: hasScrolledToBottom ? 1.0 : 0.5,
                  child: Container(
                    width: 24.sp,
                    height: 24.sp,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: hasScrolledToBottom
                            ? (isAgreed
                                  ? const Color(0xFF2563EB)
                                  : const Color(0xFF94A3B8))
                            : const Color(0xFFE2E8F0),
                        width: 2,
                      ),
                      color: isAgreed && hasScrolledToBottom
                          ? const Color(0xFF2563EB)
                          : Colors.transparent,
                    ),
                    child: isAgreed && hasScrolledToBottom
                        ? Icon(Icons.check, size: 16.sp, color: Colors.white)
                        : null,
                  ),
                ),
              ),
              SizedBox(width: 3.w),
              // Agreement text
              Expanded(
                child: GestureDetector(
                  onTap: hasScrolledToBottom
                      ? () {
                          cubit.toggleAgreement(!isAgreed);
                        }
                      : null,
                  child: Text(
                    '${context.tr('onboarding_terms_agree')}${context.tr('auth_and_privacy')}',
                    style: TextStyle(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w500,
                      color: hasScrolledToBottom
                          ? const Color(0xFF1E293B)
                          : const Color(0xFF94A3B8),
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

  /// Builds the action buttons matching Figma design
  /// "Accept & Continue" (blue) and "Scroll to Top" (white with border)
  Widget _buildActionButtons() {
    return BlocBuilder<TermsCubit, TermsState>(
      builder: (context, state) {
        final cubit = context.read<TermsCubit>();
        final hasScrolledToBottom = cubit.hasScrolledToBottom;
        final isAgreed = cubit.isAgreed;

        return Padding(
          padding: EdgeInsets.symmetric(horizontal: 5.w),
          child: Column(
            children: [
              // Accept & Continue button (blue, enabled only when scrolled to bottom and agreed)
              SizedBox(
                width: double.infinity,
                height: 6.5.h,
                child: ElevatedButton(
                  onPressed: (hasScrolledToBottom && isAgreed)
                      ? () {
                          cubit.completeTerms();
                        }
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: (hasScrolledToBottom && isAgreed)
                        ? const Color(0xFF2563EB) // Blue when enabled
                        : const Color(0xFFE2E8F0), // Gray when disabled
                    foregroundColor: (hasScrolledToBottom && isAgreed)
                        ? Colors.white
                        : const Color(0xFF94A3B8),
                    elevation: (hasScrolledToBottom && isAgreed) ? 2 : 0,
                    shadowColor: (hasScrolledToBottom && isAgreed)
                        ? const Color(0xFF2563EB).withOpacity(0.4)
                        : Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    context.tr('onboarding_accept'),
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 1.5.h),
              // Scroll to Top button (white with black border)
              SizedBox(
                width: double.infinity,
                height: 6.5.h,
                child: OutlinedButton(
                  onPressed: () {
                    _scrollController.animateTo(
                      0,
                      duration: const Duration(milliseconds: 500),
                      curve: Curves.easeInOut,
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(
                      color: Color(0xFF1E293B),
                      width: 1.5,
                    ),
                    backgroundColor: Colors.white,
                    foregroundColor: const Color(0xFF1E293B),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    context.tr('onboarding_scroll_top'),
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
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

class _TermsBlockCard extends StatelessWidget {
  const _TermsBlockCard({required this.block});

  final String block;

  @override
  Widget build(BuildContext context) {
    final lines = block.split('\n').map((l) => l.trim()).toList();
    final nonEmpty = lines.where((l) => l.isNotEmpty).toList();
    if (nonEmpty.isEmpty) return const SizedBox.shrink();

    final title = nonEmpty.first;
    final bodyLines = nonEmpty.skip(1).toList();

    final hasTitle = title.endsWith('?') ||
        title.endsWith('؟') ||
        title.startsWith('المادة') ||
        title.startsWith('أولاً') ||
        title.startsWith('ثانياً') ||
        title.startsWith('ثالثاً') ||
        title.startsWith('رابعاً') ||
        title.startsWith('سياسة') ||
        title.startsWith('ملاحظة') ||
        title.startsWith('التعديلات') ||
        title.startsWith('سياسة الاحتفاظ');

    final effectiveTitle = hasTitle ? title : '';
    final effectiveBody = hasTitle ? bodyLines : nonEmpty;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 14,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (effectiveTitle.isNotEmpty) ...[
            Text(
              effectiveTitle,
              style: const TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 16,
                color: Color(0xFF0F172A),
                height: 1.25,
              ),
            ),
            const SizedBox(height: 10),
          ],
          for (final l in effectiveBody) ...[
            if (l.startsWith('- ')) ...[
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '• ',
                    style: TextStyle(
                      color: Color(0xFF334155),
                      fontWeight: FontWeight.w900,
                      height: 1.7,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      l.substring(2).trim(),
                      style: const TextStyle(
                        color: Color(0xFF334155),
                        fontWeight: FontWeight.w500,
                        height: 1.7,
                        fontSize: 14.5,
                      ),
                    ),
                  ),
                ],
              ),
            ] else ...[
              Text(
                l,
                style: const TextStyle(
                  color: Color(0xFF334155),
                  fontWeight: FontWeight.w500,
                  height: 1.7,
                  fontSize: 14.5,
                ),
              ),
            ],
            const SizedBox(height: 6),
          ],
        ],
      ),
    );
  }
}

class _ScrollToBottomFab extends StatelessWidget {
  const _ScrollToBottomFab({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: const Color(0xFF2563EB),
          borderRadius: BorderRadius.circular(999),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.18),
              blurRadius: 18,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: const Icon(
          Icons.keyboard_double_arrow_down_rounded,
          color: Colors.white,
          size: 22,
        ),
      ),
    );
  }
}
