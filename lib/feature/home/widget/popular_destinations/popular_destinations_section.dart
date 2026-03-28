import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:rebtal/core/utils/constant/popular_destinations.dart';
import 'package:rebtal/core/utils/dependency/get_it.dart';
import 'package:rebtal/core/utils/helper/app_image_helper.dart';
import 'package:rebtal/core/utils/localization/translation_extension.dart';
import 'package:rebtal/core/utils/theme/dynamic_theme_manager.dart';
import 'package:rebtal/feature/home/domain/usecases/watch_public_chalets_usecase.dart';
import 'package:rebtal/feature/home/ui/destination_chalets_screen.dart';
import 'package:responsive_screen_master/responsive_screen_master.dart';

class PopularDestinationsSection extends StatelessWidget {
  const PopularDestinationsSection({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = DynamicThemeManager.isDarkMode(context);
    final watchPublicChalets = getIt<WatchPublicChaletsUseCase>();

    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: watchPublicChalets(),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
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
          return const SizedBox.shrink();
        }

        final usedDestinationModels = PopularDestinations.all
            .where((d) => usedDestinations.contains(d.nameAr))
            .toList();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.only(
                left: 5.w,
                right: 5.w,
                top: 16,
                bottom: 12,
              ),
              child: Text(
                context.tr('home_popular_destinations'),
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
            ),
            SizedBox(
              height: 90,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: EdgeInsets.symmetric(horizontal: 5.w),
                itemCount: usedDestinationModels.length,
                itemBuilder: (context, index) {
                  final destination = usedDestinationModels[index];

                  return Padding(
                    padding: const EdgeInsets.only(right: 16),
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => DestinationChaletsScreen(
                              destinationName: destination.getLocalizedName(
                                context,
                              ),
                              destinationArabicName: destination.nameAr,
                            ),
                          ),
                        );
                      },
                      child: Column(
                        children: [
                          Container(
                            width: 64,
                            height: 64,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: isDark
                                    ? Colors.white24
                                    : Colors.black.withOpacity(0.08),
                                width: 1,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(
                                    isDark ? 0.3 : 0.1,
                                  ),
                                  blurRadius: 8,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: ClipOval(
                              child: AppImageHelper(
                                path: destination.imageUrl,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          const SizedBox(height: 6),
                          SizedBox(
                            width: 70,
                            child: Text(
                              destination.getLocalizedName(context),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: isDark ? Colors.white70 : Colors.black54,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}
