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
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Text('${context.tr('common_error')}: ${snapshot.error}'),
            );
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  AppImageHelper(
                    path: ImageAssetsManger.couponDiscount,
                    height: otv(
                      context: context,
                      portrait: 200.sh,
                      landscape: 150.sh,
                    ),
                    width: otv(
                      context: context,
                      portrait: 200.sw,
                      landscape: 150.sw,
                    ),
                    fit: BoxFit.contain,
                  ),
                  SizedBox(
                    height: otv(
                      context: context,
                      portrait: 16.sh,
                      landscape: 8.sh,
                    ),
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

          final bookings = snapshot.data!.docs;

          return Builder(
            builder: (context) {
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
                final int rowCount = (bookings.length / 2).ceil();
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
                            bookingDoc: bookings[firstIndex],
                            isLeft: true,
                          ),
                        ),
                        if (secondIndex < bookings.length)
                          Expanded(
                            child: _ReOfferItem(
                              bookingDoc: bookings[secondIndex],
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
                itemCount: bookings.length,
                itemBuilder: (context, index) {
                  return _ReOfferItem(bookingDoc: bookings[index]);
                },
              );
            },
          );
        },
      ),
    );
  }
}

class _ReOfferItem extends StatelessWidget {
  final DocumentSnapshot bookingDoc;
  final bool? isLeft;

  const _ReOfferItem({required this.bookingDoc, this.isLeft});

  @override
  Widget build(BuildContext context) {
    final bookingData = bookingDoc.data() as Map<String, dynamic>;
    final chaletId = bookingData['chaletId'];

    if (chaletId == null) return const SizedBox.shrink();

    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance
          .collection('chalets')
          .doc(chaletId)
          .get(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Center(
            child: Padding(
              padding: EdgeInsets.all(20.sw),
              child: const CircularProgressIndicator(),
            ),
          );
        }

        if (!snapshot.data!.exists) {
          return const SizedBox.shrink();
        }

        final chaletData = snapshot.data!.data() as Map<String, dynamic>;

        return PublicChaletCard(
          chaletData: chaletData,
          docId: chaletId,
          margin: EdgeInsets.only(
            bottom: otv(context: context, portrait: 24.sh, landscape: 12.sh),
            left:
                isLeft == null
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
            right:
                isLeft == null
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
                  bookingId: bookingDoc.id,
                  isReOffer: true,
                ),
              ),
            );
          },
        );
      },
    );
  }
}
