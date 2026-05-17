import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rebtal/core/utils/theme/dynamic_theme_manager.dart';
import 'package:rebtal/feature/home/logic/cubit/home_cubit.dart';
import 'package:rebtal/feature/home/logic/cubit/home_state.dart';
import 'package:rebtal/feature/home/widget/public_chalet/public_chalets_error_view.dart';
import 'package:rebtal/feature/home/widget/public_chalet/public_chalets_filtered_list.dart';
import 'package:rebtal/feature/home/widget/public_chalet/public_chalets_loading_list.dart';

/// Public chalets list driven by [HomeCubit].
class PublicChaletsList extends StatelessWidget {
  const PublicChaletsList({
    super.key,
    this.emptyIcon,
    this.emptyTitle,
    this.emptySubtitle,
    this.selectedCategory,
    this.shrinkWrap = false,
  });

  final IconData? emptyIcon;
  final String? emptyTitle;
  final String? emptySubtitle;
  final String? selectedCategory;
  final bool shrinkWrap;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeCubit, HomeState>(
      builder: (context, state) {
        final isDark = DynamicThemeManager.isDarkMode(context);

        if (state.showInitialPublicLoading) {
          return PublicChaletsLoadingList(shrinkWrap: shrinkWrap);
        }

        if (state.publicError != null) {
          return PublicChaletsErrorView(shrinkWrap: shrinkWrap, isDark: isDark);
        }

        return PublicChaletsFilteredList(
          chalets: state.publicChalets,
          isDark: isDark,
          shrinkWrap: shrinkWrap,
          selectedCategory: selectedCategory,
          displayLimit: state.displayLimit,
          emptyIcon: emptyIcon,
          emptyTitle: emptyTitle,
          emptySubtitle: emptySubtitle,
        );
      },
    );
  }
}
