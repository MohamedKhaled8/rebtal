import 'package:flutter/material.dart';
import 'package:rebtal/core/utils/widgets/shimmers.dart';
import 'package:responsive_screen_master/responsive_screen_master.dart';

class PublicChaletsLoadingList extends StatelessWidget {
  const PublicChaletsLoadingList({super.key, required this.shrinkWrap});

  final bool shrinkWrap;

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
    if (_showTwoColumns(context)) {
      return ListView.builder(
        shrinkWrap: shrinkWrap,
        physics: _listPhysics,
        padding: EdgeInsets.symmetric(vertical: 16.sh),
        itemCount: 2,
        itemBuilder: (context, i) => Row(
          children: [
            Expanded(
              child: PublicChaletCardShimmer(
                margin: EdgeInsets.only(
                  bottom: 16.sh,
                  left: 16.sw,
                  right: 8.sw,
                ),
              ),
            ),
            Expanded(
              child: PublicChaletCardShimmer(
                margin: EdgeInsets.only(
                  bottom: 16.sh,
                  left: 8.sw,
                  right: 16.sw,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: shrinkWrap,
      physics: _listPhysics,
      padding: EdgeInsets.symmetric(vertical: 16.sh),
      itemCount: 3,
      itemBuilder: (context, i) => const PublicChaletCardShimmer(),
    );
  }
}
