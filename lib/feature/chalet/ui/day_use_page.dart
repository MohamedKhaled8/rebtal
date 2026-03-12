import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:rebtal/core/utils/localization/translation_extension.dart';
import 'package:rebtal/core/utils/constant/color_manager.dart';
import 'package:rebtal/core/utils/theme/dynamic_theme_manager.dart';
import 'package:rebtal/feature/home/widget/public_chalet/public_chalet_card.dart';
import 'package:responsive_screen_master/responsive_screen_master.dart';

class DayUsePage extends StatelessWidget {
  const DayUsePage({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = DynamicThemeManager.isDarkMode(context);
    return Scaffold(
      backgroundColor: isDark
          ? ColorsManager.chaletBackgroundDark
          : ColorsManager.chaletBackgroundLight,
      appBar: AppBar(
        title: Text(
          context.tr('chalet_day_use'),
          style: TextStyle(
            color: isDark ? ColorsManager.white : ColorsManager.black,
            fontWeight: FontWeight.bold,
            fontSize: stv(
              context: context,
              mobile: 18.spScaled,
              tablet: 22.spScaled,
              desktop: 26.spScaled,
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
            .collection('chalets')
            .where('dayUseEnabled', isEqualTo: true)
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
                  Icon(
                    Icons.wb_sunny_rounded,
                    size: stv(
                      context: context,
                      mobile: 80.spScaled,
                      tablet: 100.spScaled,
                      desktop: 120.spScaled,
                    ),
                    color: isDark ? Colors.white24 : Colors.grey.shade300,
                  ),
                  SizedBox(
                    height: otv(
                      context: context,
                      portrait: 16.sh,
                      landscape: 8.sh,
                    ),
                  ),
                  Text(
                    context.tr('chalet_no_day_use'),
                    style: TextStyle(
                      color:
                          isDark ? ColorsManager.white70 : ColorsManager.grey700,
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

          final chalets = snapshot.data!.docs;

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
                final int rowCount = (chalets.length / 2).ceil();
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
                          child: _buildDayUseCard(
                            context,
                            chalets[firstIndex],
                            isLeft: true,
                          ),
                        ),
                        if (secondIndex < chalets.length)
                          Expanded(
                            child: _buildDayUseCard(
                              context,
                              chalets[secondIndex],
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
                itemCount: chalets.length,
                itemBuilder: (context, i) {
                  return _buildDayUseCard(context, chalets[i]);
                },
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildDayUseCard(
    BuildContext context,
    DocumentSnapshot chaletDoc, {
    bool? isLeft,
  }) {
    final chaletData = chaletDoc.data() as Map<String, dynamic>;
    return PublicChaletCard(
      chaletData: chaletData,
      docId: chaletDoc.id,
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
                : (isLeft
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
                : (isLeft
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
    );
  }
}
