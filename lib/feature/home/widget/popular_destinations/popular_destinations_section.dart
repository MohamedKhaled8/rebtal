import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:rebtal/core/utils/constant/popular_destinations.dart';
import 'package:rebtal/core/utils/dependency/get_it.dart';
import 'package:rebtal/core/utils/helper/app_image_helper.dart';
import 'package:rebtal/core/utils/localization/translation_extension.dart';
import 'package:rebtal/core/utils/theme/dynamic_theme_manager.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:rebtal/feature/auth/widget/handwritten_animated_text.dart';
import 'package:rebtal/feature/home/domain/usecases/watch_public_chalets_usecase.dart';
import 'package:responsive_screen_master/responsive_screen_master.dart';

class PopularDestinationsSection extends StatelessWidget {
  final String? selectedDestination;
  final ValueChanged<String>? onDestinationSelected;

  const PopularDestinationsSection({
    super.key,
    this.selectedDestination,
    this.onDestinationSelected,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = DynamicThemeManager.isDarkMode(context);
    final watchPublicChalets = getIt<WatchPublicChaletsUseCase>();

    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: watchPublicChalets(),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          // مفيش شاليهات عامة، نخفي السيكشن خالص
          return const SizedBox.shrink();
        }

        final docs = snapshot.data!.docs;
        final popularNames = PopularDestinations.namesAr.toSet();
        final Set<String> usedDestinations = {};

        for (final doc in docs) {
          final data = doc.data();
          final features = data['features'] as List<dynamic>?;
          if (features == null) continue;
          for (final f in features) {
            final name = f.toString();
            if (popularNames.contains(name)) {
              usedDestinations.add(name);
            }
          }
        }

        if (usedDestinations.isEmpty) {
          // ولا وجهة مشهورة مستخدمة حتى الآن
          return const SizedBox.shrink();
        }

        final usedDestinationModels = PopularDestinations.all
            .where((d) => usedDestinations.contains(d.nameAr))
            .toList();

        final titlePadding = EdgeInsets.symmetric(
          horizontal: 5.w,
          vertical: 10.sh,
        );

        final cardHeight = otv(
          context: context,
          portrait: 22.h,
          landscape: 55.h,
        );

        final cardWidth = stv(
          context: context,
          mobile: 50.w,
          tablet: 55.w,
          desktop: 60.w,
        );

        final titleStyle = TextStyle(
          fontSize: stv(
            context: context,
            mobile: 22.spScaled,
            tablet: 20.spScaled,
            desktop: 22.spScaled,
          ),
          fontWeight: FontWeight.w800,
          color: isDark ? Colors.white : Colors.black87,
          fontFamily: GoogleFonts.cairo().fontFamily,
        );

        return Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Padding(
              padding: titlePadding,
              child: Align(
                alignment: Alignment.centerRight,
                child: Text(
                  context.tr('home_popular_destinations'),
                  style: titleStyle,
                ),
              ),
            ),
            SizedBox(
              height: cardHeight + 2.sh,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: EdgeInsets.symmetric(horizontal: 4.w),
                itemCount: usedDestinationModels.length,
                itemBuilder: (context, index) {
                  final destination = usedDestinationModels[index];
                  final isSelected = selectedDestination == destination.nameAr;

                  return Padding(
                    padding: EdgeInsets.only(left: 3.w),
                    child: SizedBox(
                      width: cardWidth,
                      height: cardHeight,
                      child: GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () {
                          if (onDestinationSelected == null) return;
                          onDestinationSelected!.call(destination.nameAr);
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(18),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(18),
                            child: Stack(
                              fit: StackFit.expand,
                              children: [
                                AppImageHelper(
                                  path: destination.imageUrl,
                                  fit: BoxFit.cover,
                                ),
                                Container(
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                      colors: [
                                        Colors.black.withOpacity(0.05),
                                        Colors.black.withOpacity(0.7),
                                      ],
                                      stops: const [0.6, 1.0],
                                    ),
                                  ),
                                ),
                                if (isSelected)
                                  Positioned(
                                    top: 8,
                                    right: 8,
                                    child: Container(
                                      padding: const EdgeInsets.all(4),
                                      decoration: const BoxDecoration(
                                        color: Color(0xFF2563EB),
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        Icons.check,
                                        color: Colors.white,
                                        size: 12,
                                      ),
                                    ),
                                  ),
                                Padding(
                                  padding: const EdgeInsets.all(10),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      SizedBox(
                                        height: stv(
                                          context: context,
                                          mobile:
                                              55.spScaled, // Increased height
                                          tablet:
                                              60.spScaled, // Increased height
                                          desktop:
                                              65.spScaled, // Increased height
                                        ),
                                        child: Center(
                                          child: HandwrittenAnimatedText(
                                            text: destination.getLocalizedName(context),
                                            fontSize: stv(
                                              context: context,
                                              mobile: 28.spScaled,
                                              tablet: 32.spScaled,
                                              desktop: 38.spScaled,
                                            ),
                                            color: Colors.white,
                                            fontFamily: GoogleFonts.reemKufi()
                                                .fontFamily,
                                            animationDuration: const Duration(
                                              milliseconds: 2500,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            SizedBox(height: 1.sh),
          ],
        );
      },
    );
  }
}
