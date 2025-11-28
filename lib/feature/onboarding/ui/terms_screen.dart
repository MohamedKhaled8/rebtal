import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rebtal/core/Router/routes.dart';
import 'package:rebtal/feature/onboarding/data/constants/terms_content.dart';
import 'package:rebtal/feature/onboarding/logic/cubit/terms_cubit.dart';
import 'package:rebtal/feature/onboarding/logic/cubit/terms_state.dart';
import 'package:screen_go/extensions/responsive_nums.dart';

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
        // Navigate to login screen when terms are completed
        if (state is TermsCompleted) {
          Navigator.pushNamedAndRemoveUntil(
            context,
            Routes.loginScreen,
            (route) => false,
          );
        }
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: SingleChildScrollView(
            controller: _scrollController,
            physics: const BouncingScrollPhysics(),
            child: Column(
              children: [
                // Header matching Figma design
                _buildHeader(),

                // Terms content
                _buildTermsContent(),

                // Agreement checkbox with circular design
                _buildAgreementCheckbox(),

                SizedBox(height: 1.5.h),

                // Action buttons matching Figma design
                _buildActionButtons(),

                SizedBox(height: 2.h),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Builds the header matching Figma design
  Widget _buildHeader() {
    return Padding(
      padding: EdgeInsets.fromLTRB(5.w, 2.h, 5.w, 2.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // AGREEMENT label (uppercase, light gray)
          Text(
            'AGREEMENT',
            style: TextStyle(
              fontSize: 11.sp,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF94A3B8),
              letterSpacing: 1.2,
            ),
          ),
          SizedBox(height: 1.h),
          // Terms of Service title
          Text(
            'Terms of Service',
            style: TextStyle(
              fontSize: 22.sp,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF1E293B),
            ),
          ),
          SizedBox(height: 0.5.h),
          // Last updated date
          Text(
            'Last updated on 4 October 2023',
            style: TextStyle(fontSize: 13.sp, color: const Color(0xFF94A3B8)),
          ),
        ],
      ),
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
    final text = TermsContent.termsAndConditions;
    final lines = text.split('\n');
    final List<Widget> widgets = [];

    for (int i = 0; i < lines.length; i++) {
      final line = lines[i].trim();

      if (line.isEmpty) {
        widgets.add(SizedBox(height: 1.h));
        continue;
      }

      // Check if line starts with bullet point (•)
      if (line.startsWith('•')) {
        widgets.add(
          Padding(
            padding: EdgeInsets.only(left: 4.w, top: 0.5.h, bottom: 0.5.h),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '• ',
                  style: TextStyle(
                    fontSize: 16.sp,
                    color: const Color(0xFF475569),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Expanded(
                  child: Text(
                    line.substring(1).trim(),
                    style: TextStyle(
                      fontSize: 16.sp,
                      height: 1.6,
                      color: const Color(0xFF475569),
                      letterSpacing: 0.2,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      } else if (line.startsWith(RegExp(r'^\d+\.'))) {
        // Section numbers (1., 2., etc.)
        widgets.add(
          Padding(
            padding: EdgeInsets.only(top: 1.5.h, bottom: 0.5.h),
            child: Text(
              line,
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF1E293B),
                height: 1.4,
              ),
            ),
          ),
        );
      } else if (line.startsWith(RegExp(r'^\d+\.\d+'))) {
        // Subsection numbers (1.1, 1.2, etc.)
        widgets.add(
          Padding(
            padding: EdgeInsets.only(top: 1.h, bottom: 0.5.h),
            child: Text(
              line,
              style: TextStyle(
                fontSize: 17.sp,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF1E293B),
                height: 1.4,
              ),
            ),
          ),
        );
      } else if (line.contains(
        '═══════════════════════════════════════════════════',
      )) {
        // Separator lines
        widgets.add(SizedBox(height: 1.5.h));
      } else {
        // Regular text
        widgets.add(
          Padding(
            padding: EdgeInsets.only(bottom: 0.8.h),
            child: Text(
              line,
              style: TextStyle(
                fontSize: 16.sp,
                height: 1.6,
                color: const Color(0xFF475569),
                letterSpacing: 0.2,
              ),
            ),
          ),
        );
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: widgets,
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
                    'I have read and agree to the Terms & Conditions',
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
                    'Accept & Continue',
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
                    'Scroll to Top',
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
