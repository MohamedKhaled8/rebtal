import 'package:flutter/material.dart';
import 'package:rebtal/core/utils/helper/app_image_helper.dart';
import 'package:responsive_screen_master/responsive_screen_master.dart';

/// Stateful wrapper required for [PageController] lifecycle.
class ChaletImageCarousel extends StatefulWidget {
  const ChaletImageCarousel({
    super.key,
    required this.docId,
    required this.images,
  });

  final String docId;
  final List<String> images;

  @override
  State<ChaletImageCarousel> createState() => ChaletImageCarouselState();
}

class ChaletImageCarouselState extends State<ChaletImageCarousel> {
  PageController? _pageController;

  @override
  void initState() {
    super.initState();
    if (widget.images.length > 1) {
      _pageController = PageController();
    }
  }

  @override
  void dispose() {
    _pageController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: otv(
        context: context,
        portrait: stv(
          context: context,
          mobile: 230.sh,
          tablet: 235.sh,
          desktop: 245.sh,
        ),
        landscape: stv(
          context: context,
          mobile: 330.sh,
          tablet: 350.sh,
          desktop: 400.sh,
        ),
      ),
      width: double.infinity,
      child: PageView.builder(
        key: ValueKey<String>('pub_chalet_pv_${widget.docId}'),
        controller: _pageController,
        itemCount: widget.images.length,
        itemBuilder: (context, index) {
          return AppImageHelper(
            key: ValueKey(
              'pub_chalet_img_${widget.docId}_${widget.images[index]}_$index',
            ),
            path: widget.images[index],
            fit: BoxFit.cover,
            cacheScope: widget.docId,
            memCacheWidth: 600,
          );
        },
      ),
    );
  }
}
