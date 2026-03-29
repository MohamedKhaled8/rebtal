import 'package:flutter/material.dart';
import 'package:rebtal/core/utils/constant/color_manager.dart';
import 'package:rebtal/core/utils/theme/dynamic_theme_manager.dart';
import 'package:rebtal/core/utils/localization/translation_extension.dart';
import 'package:rebtal/feature/home/widget/public_chalet/public_chalet_list.dart';

class DestinationChaletsScreen extends StatelessWidget {
  final String destinationName;
  final String destinationArabicName;

  const DestinationChaletsScreen({
    super.key,
    required this.destinationName,
    required this.destinationArabicName,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = DynamicThemeManager.isDarkMode(context);

    return Scaffold(
      backgroundColor:
          isDark ? ColorsManager.black : ColorsManager.chaletBackgroundLight,
      appBar: AppBar(
        title: Text(
          destinationName,
          style: TextStyle(
            color: isDark ? Colors.white : Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(
          color: isDark ? Colors.white : Colors.black,
        ),
      ),
      body: PublicChaletsList(
        selectedCategory: destinationArabicName,
        emptyIcon: Icons.search_off_rounded,
        emptyTitle: context.tr('home_no_results'),
        emptySubtitle: context.tr('home_try_other_search'),
      ),
    );
  }
}
