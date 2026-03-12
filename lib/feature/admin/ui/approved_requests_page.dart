import 'package:flutter/material.dart';
import 'package:rebtal/core/utils/helper/snack_bar_helper.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rebtal/core/utils/constant/color_manager.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rebtal/core/utils/theme/cubit/theme_cubit.dart';

class ApprovedRequestsPage extends StatefulWidget {
  const ApprovedRequestsPage({super.key});

  @override
  State<ApprovedRequestsPage> createState() => _ApprovedRequestsPageState();
}

class _ApprovedRequestsPageState extends State<ApprovedRequestsPage> {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeCubit, ThemeState>(
      builder: (context, themeState) {
        final isDark =
            themeState.themeMode == ThemeMode.dark ||
            (themeState.themeMode == ThemeMode.system &&
                MediaQuery.of(context).platformBrightness == Brightness.dark);

        return Scaffold(
          backgroundColor: isDark
              ? ColorsManager.darkBackground0F0F1E
              : ColorsManager.bookingsBackgroundLight,
          body: SafeArea(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('chats')
                  .where('status', isEqualTo: 'approved')
                  .orderBy('lastMessageTime', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      'حدث خطأ: ${snapshot.error}',
                      style: TextStyle(
                        color: isDark
                            ? ColorsManager.white
                            : ColorsManager.black,
                      ),
                    ),
                  );
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: CircularProgressIndicator(
                      color: ColorsManager.chaletAccent,
                    ),
                  );
                }

                final approvedChats = snapshot.data?.docs ?? [];

                if (approvedChats.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(40),
                          decoration: BoxDecoration(
                            color: isDark
                                ? ColorsManager.white.withOpacity(0.05)
                                : ColorsManager.grey100,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.check_circle_outline,
                            size: 80,
                            color: ColorsManager.grey400,
                          ),
                        ),
                        const SizedBox(height: 24),
                        Text(
                          'لا توجد طلبات موافق عليها',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: ColorsManager.grey600,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: ColorsManager.green.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.check_circle,
                              color: ColorsManager.green,
                              size: 28,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Text(
                            'الطلبات الموافق عليها',
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: isDark
                                  ? ColorsManager.white
                                  : ColorsManager.chaletTextPrimaryLight,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 32),

                      ...approvedChats.map((doc) {
                        final chatData = doc.data() as Map<String, dynamic>;
                        return ApprovedRequestCard(
                          chatData: chatData,
                          isDark: isDark,
                        );
                      }),
                    ],
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }
}

class ApprovedRequestCard extends StatelessWidget {
  final Map<String, dynamic> chatData;
  final bool isDark;

  const ApprovedRequestCard({
    super.key,
    required this.chatData,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? ColorsManager.darkBlue1A1A2E : ColorsManager.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? ColorsManager.white10 : ColorsManager.grey200,
        ),
        boxShadow: [
          BoxShadow(
            color: ColorsManager.black.withOpacity(isDark ? 0.2 : 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with status
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: ColorsManager.green.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: ColorsManager.green.withOpacity(0.5),
                  ),
                ),
                child: const Text(
                  'موافق عليه',
                  style: TextStyle(
                    color: ColorsManager.green,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
              const Spacer(),
              Icon(
                Icons.check_circle,
                color: ColorsManager.chaletActionGreen,
                size: 24,
              ),
            ],
          ),

          Divider(
            height: 32,
            color: isDark ? ColorsManager.white10 : ColorsManager.grey300,
          ),

          // Chalet Information
          Text(
            chatData['chaletName'] ?? 'شاليه',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: isDark
                  ? ColorsManager.white
                  : ColorsManager.chaletTextPrimaryLight,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'معرف الشاليه: ${chatData['chaletId'] ?? 'غير محدد'}',
            style: TextStyle(
              fontSize: 14,
              color: isDark ? ColorsManager.white70 : ColorsManager.grey600,
            ),
          ),

          const SizedBox(height: 24),

          // User and Owner Information
          Text(
            'المعلومات',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: isDark ? ColorsManager.white70 : ColorsManager.grey600,
            ),
          ),
          const SizedBox(height: 12),

          Row(
            children: [
              Expanded(
                child: _buildInfoItem(
                  title: 'العميل',
                  name: chatData['userName'] ?? 'غير محدد',
                  icon: Icons.person,
                  color: ColorsManager.green,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildInfoItem(
                  title: 'المالك',
                  name: chatData['ownerName'] ?? 'غير محدد',
                  icon: Icons.business,
                  color: ColorsManager.primaryColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Timestamps
          Row(
            children: [
              Expanded(
                child: _buildTimestamp(
                  label: 'تاريخ الطلب',
                  timestamp: chatData['createdAt'],
                  icon: Icons.access_time,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildTimestamp(
                  label: 'تاريخ الموافقة',
                  timestamp: chatData['lastMessageTime'],
                  icon: Icons.check_circle_outline,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Actions
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    // Navigate logic can be added later
                  },
                  icon: const Icon(Icons.chat, size: 20),
                  label: const Text('عرض المحادثة'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: ColorsManager.primaryColor,
                    side: const BorderSide(color: ColorsManager.primaryColor),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    _showCompleteDialog(context);
                  },
                  icon: const Icon(Icons.done_all, size: 20),
                  label: const Text('إكمال الحجز'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ColorsManager.green,
                    foregroundColor: ColorsManager.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem({
    required String title,
    required String name,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 16),
              const SizedBox(width: 6),
              Text(
                title,
                style: TextStyle(
                  fontSize: 12,
                  color: color,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            name,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: isDark
                  ? ColorsManager.white
                  : ColorsManager.chaletTextPrimaryLight,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildTimestamp({
    required String label,
    required dynamic timestamp,
    required IconData icon,
  }) {
    DateTime dateTime;
    if (timestamp is String) {
      dateTime = DateTime.tryParse(timestamp) ?? DateTime.now();
    } else if (timestamp is Timestamp) {
      dateTime = timestamp.toDate();
    } else {
      dateTime = DateTime.now();
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? ColorsManager.darkGrey252540 : ColorsManager.grey100,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? ColorsManager.white10 : ColorsManager.transparent,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: ColorsManager.grey600, size: 16),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: ColorsManager.grey600,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            '${dateTime.day}/${dateTime.month}/${dateTime.year}',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: isDark
                  ? ColorsManager.white
                  : ColorsManager.chaletTextPrimaryLight,
            ),
          ),
        ],
      ),
    );
  }

  void _showCompleteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark
            ? ColorsManager.darkBlue1A1A2E
            : ColorsManager.white,
        title: Text(
          'إكمال الحجز',
          style: TextStyle(
            color: isDark ? ColorsManager.white : ColorsManager.black,
          ),
        ),
        content: Text(
          'هل أنت متأكد من أنك تريد إكمال هذا الحجز؟',
          style: TextStyle(
            color: isDark
                ? ColorsManager.white70
                : ColorsManager.chaletTextPrimaryLight,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              SnackBarHelper.showSuccess(context, 'تم إكمال الحجز بنجاح');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: ColorsManager.green,
              foregroundColor: ColorsManager.white,
            ),
            child: const Text('تأكيد'),
          ),
        ],
      ),
    );
  }
}
