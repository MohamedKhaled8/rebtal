import 'package:flutter/material.dart';
import 'package:rebtal/feature/home/domain/entities/home_chalet_entity.dart';
import 'package:rebtal/feature/home/widget/public_chalet/public_chalet_card.dart';
import 'package:rebtal/feature/home/widget/public_chalet/public_chalets_load_more_button.dart';
import 'package:responsive_screen_master/responsive_screen_master.dart';

class PublicChaletsTwoColumnList extends StatelessWidget {
  const PublicChaletsTwoColumnList({
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
    final rowCount = (countToShow / 2).ceil();
    final extra = (hasMore ? 1 : 0) + 1;
    final itemCount = rowCount + extra;

    return ListView.builder(
      shrinkWrap: shrinkWrap,
      physics: listPhysics,
      padding: EdgeInsets.only(bottom: 20.sh),
      itemCount: itemCount,
      itemBuilder: (context, index) {
        if (index < rowCount) {
          final firstIndex = index * 2;
          final secondIndex = firstIndex + 1;
          return RepaintBoundary(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: PublicChaletCard(
                    key: ValueKey(filtered[firstIndex].id),
                    chaletData: filtered[firstIndex].data,
                    docId: filtered[firstIndex].id,
                    margin: EdgeInsets.only(
                      bottom: otv(
                        context: context,
                        portrait: 24.sh,
                        landscape: 12.sh,
                      ),
                      left: stv(
                        context: context,
                        mobile: 16.sw,
                        tablet: 24.sw,
                        desktop: 32.sw,
                      ),
                      right: stv(
                        context: context,
                        mobile: 16.sw,
                        tablet: 20.sw,
                        desktop: 24.sw,
                      ),
                    ),
                  ),
                ),
                if (secondIndex < countToShow)
                  Expanded(
                    child: PublicChaletCard(
                      key: ValueKey(filtered[secondIndex].id),
                      chaletData: filtered[secondIndex].data,
                      docId: filtered[secondIndex].id,
                      margin: EdgeInsets.only(
                        bottom: otv(
                          context: context,
                          portrait: 24.sh,
                          landscape: 12.sh,
                        ),
                        left: stv(
                          context: context,
                          mobile: 16.sw,
                          tablet: 20.sw,
                          desktop: 24.sw,
                        ),
                        right: stv(
                          context: context,
                          mobile: 16.sw,
                          tablet: 24.sw,
                          desktop: 32.sw,
                        ),
                      ),
                    ),
                  )
                else
                  const Expanded(child: SizedBox()),
              ],
            ),
          );
        }
        if (hasMore && index == rowCount) {
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
