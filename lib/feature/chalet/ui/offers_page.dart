import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:rebtal/core/utils/constant/color_manager.dart';
import 'package:rebtal/core/utils/constant/image_assets_manger.dart';
import 'package:rebtal/core/utils/helper/app_image_helper.dart';
import 'package:rebtal/core/utils/theme/dynamic_theme_manager.dart';
import 'package:rebtal/feature/home/widget/public_chalets_list.dart';
import 'package:rebtal/feature/chalet/ui/chalet_detail_page.dart';

class OffersPage extends StatelessWidget {
  const OffersPage({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = DynamicThemeManager.isDarkMode(context);
    return Scaffold(
      backgroundColor: isDark
          ? ColorManager.chaletBackgroundDark
          : ColorManager.chaletBackgroundLight,
      appBar: AppBar(
        title: Text(
          'عروض إعادة البيع',
          style: TextStyle(
            color: isDark ? ColorManager.white : ColorManager.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(
          color: isDark ? ColorManager.white : ColorManager.black,
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
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  AppImageHelper(path: ImageAssetsManger.couponDiscount),

                  const SizedBox(height: 16),
                  Text(
                    'لا توجد عروض',
                    style: TextStyle(
                      color: DynamicThemeManager.isDarkMode(context)
                          ? ColorManager.white70
                          : ColorManager.chaletGrey500,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            );
          }

          final bookings = snapshot.data!.docs;

          return ListView.builder(
            itemCount: bookings.length,
            padding: const EdgeInsets.only(bottom: 80),
            itemBuilder: (context, index) {
              final bookingDoc = bookings[index];
              return _ReOfferItem(bookingDoc: bookingDoc);
            },
          );
        },
      ),
    );
  }
}

class _ReOfferItem extends StatelessWidget {
  final DocumentSnapshot bookingDoc;

  const _ReOfferItem({required this.bookingDoc});

  @override
  Widget build(BuildContext context) {
    // bookingData has chaletId
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
          return const Padding(
            padding: EdgeInsets.all(20.0),
            child: SizedBox(
              height: 300,
              child: Center(child: CircularProgressIndicator()),
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
          badge: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: ColorManager.chaletActionBlue,
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 4),
              ],
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.swap_horiz, color: Colors.white, size: 14),
                SizedBox(width: 4),
                Text(
                  'متاح للنقاش',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
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
                  bookingId: bookingDoc.id, // Will add this param
                  isReOffer: true, // Will add this param
                ),
              ),
            );
          },
        );
      },
    );
  }
}
