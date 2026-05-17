import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rebtal/core/utils/home_search_notifier.dart';
import 'package:rebtal/feature/home/domain/entities/home_chalet_entity.dart';
import 'package:rebtal/feature/home/logic/cubit/home_cubit.dart';
import 'package:rebtal/feature/home/logic/helpers/home_chalet_list_helper.dart';
import 'package:rebtal/feature/home/widget/public_chalet/public_chalets_empty_view.dart';
import 'package:rebtal/feature/home/widget/public_chalet/public_chalets_single_column_list.dart';
import 'package:rebtal/feature/home/widget/public_chalet/public_chalets_two_column_list.dart';
import 'package:responsive_screen_master/responsive_screen_master.dart';

class PublicChaletsFilteredList extends StatelessWidget {
  const PublicChaletsFilteredList({
    super.key,
    required this.chalets,
    required this.isDark,
    required this.shrinkWrap,
    required this.selectedCategory,
    required this.displayLimit,
    this.emptyIcon,
    this.emptyTitle,
    this.emptySubtitle,
  });

  final List<HomeChaletEntity> chalets;
  final bool isDark;
  final bool shrinkWrap;
  final String? selectedCategory;
  final int displayLimit;
  final IconData? emptyIcon;
  final String? emptyTitle;
  final String? emptySubtitle;

  ScrollPhysics get _listPhysics => shrinkWrap
      ? const NeverScrollableScrollPhysics()
      : const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics());

  bool _showTwoColumns(BuildContext context) {
    return otv(
      context: context,
      portrait: stv(
        context: context,
        mobile: false,
        tablet: true,
        desktop: true,
      ),
      landscape: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<SearchFilters>(
      valueListenable: HomeSearch.filters,
      builder: (context, filters, _) {
        final filtered = HomeChaletListHelper.filterAndSort(
          chalets,
          filters,
          selectedCategory,
        );

        if (filtered.isEmpty) {
          return PublicChaletsEmptyView(
            shrinkWrap: shrinkWrap,
            listPhysics: _listPhysics,
            isDark: isDark,
            emptyIcon: emptyIcon,
            emptyTitle: emptyTitle,
            emptySubtitle: emptySubtitle,
          );
        }

        final isFiltering = !filters.isEmpty;
        final countToShow = HomeChaletListHelper.visibleCount(
          filtered,
          displayLimit,
          isFiltering,
        );
        final hasMore = HomeChaletListHelper.hasMore(
          filtered,
          displayLimit,
          isFiltering,
        );
        final showTwoColumns = _showTwoColumns(context);
        final cubit = context.read<HomeCubit>();

        if (showTwoColumns) {
          return PublicChaletsTwoColumnList(
            filtered: filtered,
            countToShow: countToShow,
            hasMore: hasMore,
            shrinkWrap: shrinkWrap,
            listPhysics: _listPhysics,
            onLoadMore: cubit.loadMorePublicChalets,
          );
        }

        return PublicChaletsSingleColumnList(
          filtered: filtered,
          countToShow: countToShow,
          hasMore: hasMore,
          shrinkWrap: shrinkWrap,
          listPhysics: _listPhysics,
          onLoadMore: cubit.loadMorePublicChalets,
        );
      },
    );
  }
}
