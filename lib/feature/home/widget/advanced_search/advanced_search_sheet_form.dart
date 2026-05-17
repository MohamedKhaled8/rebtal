import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rebtal/core/utils/localization/translation_extension.dart';
import 'package:rebtal/core/utils/theme/dynamic_theme_manager.dart';
import 'package:rebtal/feature/home/logic/cubit/home_cubit.dart';
import 'package:rebtal/feature/home/logic/cubit/home_state.dart';
import 'package:rebtal/feature/home/widget/advanced_search/advanced_search_header.dart';
import 'package:rebtal/feature/home/widget/advanced_search/advanced_search_palette.dart';
import 'package:rebtal/feature/home/widget/advanced_search/advanced_search_section_header.dart';
import 'package:rebtal/feature/home/widget/advanced_search/advanced_search_sections.dart';

/// Holds [TextEditingController]s — required for text fields.
class AdvancedSearchSheetForm extends StatefulWidget {
  const AdvancedSearchSheetForm({super.key});

  @override
  State<AdvancedSearchSheetForm> createState() =>
      AdvancedSearchSheetFormState();
}

class AdvancedSearchSheetFormState extends State<AdvancedSearchSheetForm> {
  late final TextEditingController _queryController;
  bool _syncingControllers = false;

  @override
  void initState() {
    super.initState();
    final form = context.read<HomeCubit>().state.advancedSearch;
    _queryController = TextEditingController(text: form.query);
  }

  @override
  void dispose() {
    _queryController.dispose();
    super.dispose();
  }

  void _syncControllersFromState(HomeState state) {
    _syncingControllers = true;
    _queryController.text = state.advancedSearch.query;
    _syncingControllers = false;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = DynamicThemeManager.isDarkMode(context);
    final themeColor = isDark ? Colors.white : Colors.black;
    final bgColor = AdvancedSearchPalette.background(isDark);
    final cardColor = AdvancedSearchPalette.card(isDark);

    return BlocListener<HomeCubit, HomeState>(
      listenWhen: (previous, current) =>
          previous.advancedSearch != current.advancedSearch,
      listener: (context, state) {
        if (!_syncingControllers &&
            _queryController.text != state.advancedSearch.query) {
          _syncControllersFromState(state);
        }
      },
      child: Container(
        height: MediaQuery.of(context).size.height * 0.92,
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            AdvancedSearchHeader(themeColor: themeColor, isDark: isDark),
            Expanded(
              child: ListView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 16,
                ),
                children: [
                  AdvancedSearchSectionHeader(
                    title: context.tr('home_search'),
                    icon: Icons.search_rounded,
                    themeColor: themeColor,
                  ),
                  const SizedBox(height: 12),
                  AdvancedSearchQueryField(
                    controller: _queryController,
                    isDark: isDark,
                    themeColor: themeColor,
                    cardColor: cardColor,
                  ),
                  const SizedBox(height: 28),
                  AdvancedSearchSectionHeader(
                    title: context.tr('owner_availability_period'),
                    icon: Icons.explore_rounded,
                    themeColor: themeColor,
                  ),
                  const SizedBox(height: 12),
                  AdvancedSearchBookingOptions(
                    isDark: isDark,
                    themeColor: themeColor,
                    cardColor: cardColor,
                  ),
                  const SizedBox(height: 28),
                  AdvancedSearchSectionHeader(
                    title: context.tr('home_price_range_per_night'),
                    icon: Icons.payments_rounded,
                    themeColor: themeColor,
                  ),
                  const SizedBox(height: 12),
                  AdvancedSearchPriceRangeSection(
                    cardColor: cardColor,
                    themeColor: themeColor,
                    isDark: isDark,
                  ),
                  const SizedBox(height: 28),
                  AdvancedSearchSectionHeader(
                    title: context.tr('home_chalet_area_m2'),
                    icon: Icons.square_foot_rounded,
                    themeColor: themeColor,
                  ),
                  const SizedBox(height: 12),
                  AdvancedSearchAreaSection(
                    cardColor: cardColor,
                    isDark: isDark,
                  ),
                  const SizedBox(height: 28),
                  AdvancedSearchSectionHeader(
                    title: context.tr('home_rooms_facilities'),
                    icon: Icons.meeting_room_rounded,
                    themeColor: themeColor,
                  ),
                  const SizedBox(height: 12),
                  AdvancedSearchCapacitySection(
                    cardColor: cardColor,
                    themeColor: themeColor,
                    isDark: isDark,
                  ),
                  const SizedBox(height: 28),
                  AdvancedSearchSectionHeader(
                    title: context.tr('home_facilities_services'),
                    icon: Icons.spa_rounded,
                    themeColor: themeColor,
                  ),
                  const SizedBox(height: 12),
                  AdvancedSearchFacilitiesSection(
                    isDark: isDark,
                    themeColor: themeColor,
                    cardColor: cardColor,
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
            AdvancedSearchBottomBar(bgColor: bgColor),
          ],
        ),
      ),
    );
  }
}
