import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:rebtal/core/utils/constant/color_manager.dart';
import 'package:rebtal/core/utils/theme/dynamic_theme_manager.dart';
import 'package:rebtal/feature/home/widget/public_chalets_list.dart';

class DayUsePage extends StatelessWidget {
  const DayUsePage({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = DynamicThemeManager.isDarkMode(context);
    return Scaffold(
      backgroundColor: isDark
          ? ColorManager.chaletBackgroundDark
          : ColorManager.chaletBackgroundLight,
      appBar: AppBar(
        title: Text(
          'شاليهات داي يوز (Day Use)',
          style: TextStyle(
            color: isDark ? ColorManager.white : ColorManager.black,
            fontWeight: FontWeight.bold,
            fontSize: 18,
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
                    size: 80,
                    color: isDark ? Colors.white24 : Colors.grey.shade300,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'لا توجد شاليهات داي يوز حالياً',
                    style: TextStyle(
                      color: isDark
                          ? ColorManager.white70
                          : ColorManager.grey700,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            );
          }

          final chalets = snapshot.data!.docs;

          return ListView.builder(
            itemCount: chalets.length,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            itemBuilder: (context, index) {
              final chaletDoc = chalets[index];
              final chaletData = chaletDoc.data() as Map<String, dynamic>;
              return PublicChaletCard(
                chaletData: chaletData,
                docId: chaletDoc.id,
              );
            },
          );
        },
      ),
    );
  }
}
