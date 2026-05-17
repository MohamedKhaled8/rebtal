import 'package:flutter/material.dart';
import 'package:rebtal/feature/home/domain/entities/home_chalet_entity.dart';
import 'package:rebtal/feature/home/widget/public_chalet/public_chalet_card.dart';
import 'package:rebtal/feature/home/widget/public_chalet/public_chalets_load_more_button.dart';
import 'package:responsive_screen_master/responsive_screen_master.dart';

class PublicChaletsSingleColumnList extends StatelessWidget {
  const PublicChaletsSingleColumnList({
    super.key,
    required this.filtered,
    required this.countToShow,
    required this.hasMore,
    required this.shrinkWrap,
    required this.listPhysics,
    required this.onLoadMore,
  });

  final List<HomeChaletEntity> filtered;
  final int countToShow;
  final bool hasMore;
  final bool shrinkWrap;
  final ScrollPhysics listPhysics;
  final VoidCallback onLoadMore;

  @override
  Widget build(BuildContext context) {
    final itemCount = countToShow + (hasMore ? 1 : 0) + 1;

    return ListView.builder(
      shrinkWrap: shrinkWrap,
      physics: listPhysics,
      padding: EdgeInsets.only(bottom: 20.sh),
      itemCount: itemCount,
      itemBuilder: (context, index) {
        if (index < countToShow) {
          final entity = filtered[index];
          return RepaintBoundary(
            child: PublicChaletCard(
              key: ValueKey(entity.id),
              chaletData: entity.data,
              docId: entity.id,
            ),
          );
        }
        if (hasMore && index == countToShow) {
          return PublicChaletsLoadMoreButton(
            remainingCount: filtered.length - countToShow,
            onPressed: onLoadMore,
          );
        }
        return SizedBox(height: 60.sh);
      },
    );
  }
}
