import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:rebtal/core/utils/localization/translation_extension.dart';
import 'package:rebtal/core/utils/constant/color_manager.dart';
import 'package:rebtal/core/utils/constant/image_assets_manger.dart';
import 'package:rebtal/core/utils/helper/app_image_helper.dart';
import 'package:rebtal/core/utils/theme/dynamic_theme_manager.dart';
import 'package:rebtal/feature/home/widget/public_chalet/public_chalet_card.dart';
import 'package:rebtal/feature/chalet/ui/chalet_detail_page.dart';
import 'package:responsive_screen_master/responsive_screen_master.dart';

class OffersPage extends StatelessWidget {
  const OffersPage({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = DynamicThemeManager.isDarkMode(context);
    return Scaffold(
      backgroundColor: isDark
          ? ColorsManager.chaletBackgroundDark
          : ColorsManager.chaletBackgroundLight,
      appBar: AppBar(
        title: Text(
          context.tr('chalet_resale_offers'),
          style: TextStyle(
            color: isDark ? ColorsManager.white : ColorsManager.black,
            fontWeight: FontWeight.bold,
            fontSize: stv(
              context: context,
              mobile: 22.spScaled,
              tablet: 26.spScaled,
              desktop: 30.spScaled,
            ),
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(
          color: isDark ? ColorsManager.white : ColorsManager.black,
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('bookings')
            .where('status', isEqualTo: 'reOffered')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.blue),
            );
          }
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  '${context.tr('common_error')}: ${snapshot.error}',
                  style: const TextStyle(color: Colors.red, fontSize: 18),
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return _buildEmptyState(context);
          }

          final bookings = snapshot.data!.docs;

          // Asynchronously fetch and filter valid chalets to avoid displaying a blank screen
          return FutureBuilder<List<Map<String, dynamic>?>>(
            future: Future.wait(
              bookings.map((doc) async {
                try {
                  final bookingData = doc.data() as Map<String, dynamic>;
                  final chaletId = bookingData['chaletId'];
                  if (chaletId == null) return null;

                  final chaletDoc = await FirebaseFirestore.instance
                      .collection('chalets')
                      .doc(chaletId)
                      .get();

                  if (!chaletDoc.exists) return null;

                  final chaletData = chaletDoc.data() as Map<String, dynamic>;
                  // Inject critical IDs needed for display and navigation
                  chaletData['_id'] = chaletId;
                  chaletData['_bookingId'] = doc.id;
                  return chaletData;
                } catch (e) {
                  return null;
                }
              }).toList(),
            ),
            builder: (context, futureSnapshot) {
              if (futureSnapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(color: Colors.blue),
                );
              }

              final validChalets = (futureSnapshot.data ?? [])
                  .whereType<Map<String, dynamic>>()
                  .toList();

              if (validChalets.isEmpty) {
                return _buildEmptyState(context);
              }

              final bool showTwoColumns = otv(
                context: context,
                portrait: stv(
                  context: context,
                  mobile: false,
                  tablet: true,
                  desktop: true,
                ),
                landscape: true,
              );

              if (showTwoColumns) {
                final int rowCount = (validChalets.length / 2).ceil();
                return ListView.builder(
                  padding: EdgeInsets.symmetric(vertical: 16.sh),
                  itemCount: rowCount,
                  itemBuilder: (context, index) {
                    final firstIndex = index * 2;
                    final secondIndex = firstIndex + 1;

                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: _ReOfferItem(
                            chaletData: validChalets[firstIndex],
                            isLeft: true,
                          ),
                        ),
                        if (secondIndex < validChalets.length)
                          Expanded(
                            child: _ReOfferItem(
                              chaletData: validChalets[secondIndex],
                              isLeft: false,
                            ),
                          )
                        else
                          const Expanded(child: SizedBox.shrink()),
                      ],
                    );
                  },
                );
              }

              return ListView.builder(
                padding: EdgeInsets.symmetric(vertical: 16.sh),
                itemCount: validChalets.length,
                itemBuilder: (context, index) {
                  return _ReOfferItem(chaletData: validChalets[index]);
                },
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AppImageHelper(
            path: ImageAssetsManger.couponDiscount,
            height: otv(context: context, portrait: 200.sp, landscape: 150.sp),
            width: otv(context: context, portrait: 200.sp, landscape: 150.sp),
            fit: BoxFit.contain,
          ),
          SizedBox(
            height: otv(context: context, portrait: 16.sp, landscape: 8.sp),
          ),
          Text(
            context.tr('chalet_no_offers'),
            style: TextStyle(
              color: DynamicThemeManager.isDarkMode(context)
                  ? ColorsManager.white70
                  : ColorsManager.chaletGrey500,
              fontSize: stv(
                context: context,
                mobile: 18.spScaled,
                tablet: 22.spScaled,
                desktop: 26.spScaled,
              ),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _ReOfferItem extends StatelessWidget {
  final Map<String, dynamic> chaletData;
  final bool? isLeft;

  const _ReOfferItem({required this.chaletData, this.isLeft});

  @override
  Widget build(BuildContext context) {
    final chaletId = chaletData['_id'];
    final bookingId = chaletData['_bookingId'];

    return PublicChaletCard(
      chaletData: chaletData,
      docId: chaletId,
      margin: EdgeInsets.only(
        bottom: otv(context: context, portrait: 24.sh, landscape: 12.sh),
        left: isLeft == null
            ? stv(
                context: context,
                mobile: 16.sw,
                tablet: 24.sw,
                desktop: 32.sw,
              )
            : (isLeft == true
                  ? stv(
                      context: context,
                      mobile: 16.sw,
                      tablet: 24.sw,
                      desktop: 32.sw,
                    )
                  : stv(
                      context: context,
                      mobile: 12.sw,
                      tablet: 16.sw,
                      desktop: 20.sw,
                    )),
        right: isLeft == null
            ? stv(
                context: context,
                mobile: 16.sw,
                tablet: 24.sw,
                desktop: 32.sw,
              )
            : (isLeft == true
                  ? stv(
                      context: context,
                      mobile: 12.sw,
                      tablet: 16.sw,
                      desktop: 20.sw,
                    )
                  : stv(
                      context: context,
                      mobile: 16.sw,
                      tablet: 24.sw,
                      desktop: 32.sw,
                    )),
      ),
      badge: Container(
        padding: EdgeInsets.symmetric(
          horizontal: stv(
            context: context,
            mobile: 10.sw,
            tablet: 14.sw,
            desktop: 18.sw,
          ),
          vertical: otv(context: context, portrait: 6.sh, landscape: 3.sh),
        ),
        decoration: BoxDecoration(
          color: ColorsManager.chaletActionBlue,
          borderRadius: BorderRadius.circular(8.sw),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 4),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.swap_horiz,
              color: Colors.white,
              size: stv(
                context: context,
                mobile: 14.spScaled,
                tablet: 16.spScaled,
                desktop: 18.spScaled,
              ),
            ),
            SizedBox(
              width: stv(
                context: context,
                mobile: 4.sw,
                tablet: 6.sw,
                desktop: 8.sw,
              ),
            ),
            Text(
              context.tr('booking_status_under_discussion'),
              style: TextStyle(
                color: Colors.white,
                fontSize: stv(
                  context: context,
                  mobile: 12.spScaled,
                  tablet: 14.spScaled,
                  desktop: 16.spScaled,
                ),
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
      onDetailsPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ChaletDetailPage(
              requestData: chaletData,
              docId: chaletId,
              status: 'approved',
              bookingId: bookingId,
              isReOffer: true,
            ),
          ),
        );
      },
    );
  }
}
