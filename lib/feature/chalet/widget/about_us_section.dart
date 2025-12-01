import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rebtal/core/utils/constant/color_manager.dart';
import 'package:rebtal/feature/chalet/logic/cubit/chalet_detail_cubit.dart';

class AboutUsSection extends StatelessWidget {
  final String description;
  final bool isDark;

  const AboutUsSection({
    super.key,
    required this.description,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return BlocSelector<ChaletDetailCubit, ChaletDetailState, bool>(
      selector: (state) {
        if (state is ChaletDetailLoaded) {
          return state.isDescriptionExpanded;
        }
        return false;
      },
      builder: (context, isExpanded) {
        final displayText = description.isNotEmpty
            ? description
            : 'No description available.';
        final shouldShowExpand = displayText.length > 150;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'About Us',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: isDark
                    ? ColorManager.chaletTextPrimaryDark
                    : ColorManager.chaletTextPrimaryLight,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 12),
            AnimatedSize(
              duration: const Duration(milliseconds: 300),
              alignment: Alignment.topCenter,
              child: shouldShowExpand && !isExpanded
                  ? ShaderMask(
                      shaderCallback: (Rect bounds) {
                        return LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            ColorManager.black,
                            ColorManager.black,
                            ColorManager.transparent,
                          ],
                          stops: const [0.0, 0.5, 1.0],
                        ).createShader(bounds);
                      },
                      blendMode: BlendMode.dstIn,
                      child: SizedBox(
                        height: 100,
                        child: Text(
                          displayText,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w400,
                            color: isDark
                                ? ColorManager.chaletTextSecondaryDark
                                : ColorManager.chaletTextSecondaryLight,
                            height: 1.6,
                            letterSpacing: 0.3,
                          ),
                          textAlign: TextAlign.justify,
                        ),
                      ),
                    )
                  : Text(
                      displayText,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                        color: isDark
                            ? ColorManager.chaletTextSecondaryDark
                            : ColorManager.chaletTextSecondaryLight,
                        height: 1.6,
                        letterSpacing: 0.3,
                      ),
                      textAlign: TextAlign.justify,
                    ),
            ),
            if (shouldShowExpand) ...[
              const SizedBox(height: 8),
              GestureDetector(
                onTap: () =>
                    context.read<ChaletDetailCubit>().toggleDescription(),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      isExpanded ? 'Show Less' : 'Read More',
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: ColorManager.chaletAccent,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(
                      isExpanded
                          ? Icons.keyboard_arrow_up
                          : Icons.keyboard_arrow_down,
                      color: ColorManager.chaletAccent,
                      size: 20,
                    ),
                  ],
                ),
              ),
            ],
          ],
        );
      },
    );
  }
}
