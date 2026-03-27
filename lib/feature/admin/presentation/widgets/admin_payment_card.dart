import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:rebtal/core/utils/constant/color_manager.dart';
import 'package:rebtal/core/utils/helper/app_image_helper.dart';
import 'package:rebtal/feature/payment/models/payment_proof.dart';

class AdminPaymentCard extends StatelessWidget {
  final PaymentProof proof;
  final Map<String, dynamic>? bookingData;
  final bool isDark;
  final bool isExpanded;
  final VoidCallback onToggleExpand;

  const AdminPaymentCard({
    super.key, 
    required this.proof, 
    required this.bookingData, 
    required this.isDark,
    required this.isExpanded,
    required this.onToggleExpand,
  });

  @override
  Widget build(BuildContext context) {
    if (bookingData == null) {
      return Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: isDark ? ColorsManager.darkBlue1A1A2E : ColorsManager.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Center(child: Text('Booking data missing')),
      );
    }

    final bookingFrom = _parseDate(bookingData!['from']) ?? DateTime.now();
    final bookingTo = _parseDate(bookingData!['to']) ?? DateTime.now();
    final nights = bookingTo.difference(bookingFrom).inDays + 1;
    final shortId = proof.bookingId.length > 8 ? proof.bookingId.substring(0, 8).toUpperCase() : proof.bookingId.toUpperCase();
    final dateFormat = DateFormat('dd/MM/yyyy');

    return Container(
      margin: const EdgeInsets.only(bottom: 18),
      decoration: BoxDecoration(
        color: isDark ? ColorsManager.darkBlue1A1A2E : ColorsManager.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: isDark ? ColorsManager.white.withOpacity(0.12) : ColorsManager.grey200, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: ColorsManager.black.withOpacity(isDark ? 0.25 : 0.06),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Column(
          children: [
            InkWell(
              onTap: onToggleExpand,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            bookingData!['chaletName'] ?? 'شاليه',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: isDark ? ColorsManager.white : ColorsManager.chaletTextPrimaryLight,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Text('رقم الطلب:', style: TextStyle(fontSize: 12, color: isDark ? ColorsManager.white70 : ColorsManager.grey600)),
                              const SizedBox(width: 4),
                              Text('#$shortId', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: ColorsManager.chaletAccent)),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Row(
                      children: [
                        _buildStatusBadge(proof.status),
                        const SizedBox(width: 12),
                        AnimatedRotation(
                          duration: const Duration(milliseconds: 200),
                          turns: isExpanded ? 0.5 : 0,
                          child: Icon(Icons.keyboard_arrow_down_rounded, color: isDark ? ColorsManager.white70 : ColorsManager.grey600),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            AnimatedCrossFade(
              firstChild: const SizedBox(width: double.infinity),
              secondChild: Container(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Divider(height: 32, thickness: 1, color: isDark ? ColorsManager.white.withOpacity(0.1) : ColorsManager.grey200),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: isDark ? ColorsManager.darkGrey2A2A3E : ColorsManager.grey50,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: isDark ? ColorsManager.white.withOpacity(0.15) : ColorsManager.grey200, width: 1.5),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildDetailRow(Icons.calendar_today_rounded, 'تاريخ الوصول', dateFormat.format(bookingFrom), ColorsManager.primaryColor),
                          const SizedBox(height: 16),
                          _buildDetailRow(Icons.calendar_month_rounded, 'تاريخ المغادرة', dateFormat.format(bookingTo), ColorsManager.red),
                          const SizedBox(height: 16),
                          _buildDetailRow(Icons.nights_stay_rounded, 'المدة', '$nights ليالي', ColorsManager.purple),
                          const SizedBox(height: 16),
                          _buildDetailRow(Icons.monetization_on_rounded, 'المبلغ الإجمالي', '${(bookingData!['amount'] as num?)?.toInt() ?? 0} جنيه', ColorsManager.green, isBold: true),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(18),
                          decoration: BoxDecoration(
                            color: isDark ? ColorsManager.mainBlue.withOpacity(0.15) : const Color(0xFFEFF6FF),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: isDark ? ColorsManager.mainBlue.withOpacity(0.4) : ColorsManager.mainBlue.withOpacity(0.35), width: 1.5),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildSectionTitle('معلومات الضيف', Icons.person_rounded, ColorsManager.green),
                              const SizedBox(height: 16),
                              _buildContactRowFull(Icons.person_outline_rounded, 'الاسم', bookingData!['userName']?.toString() ?? 'غير متوفر'),
                              const SizedBox(height: 12),
                              _buildContactRowFull(Icons.phone_iphone_rounded, 'رقم الهاتف', bookingData!['userPhone']?.toString() ?? 'غير متوفر'),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.all(18),
                          decoration: BoxDecoration(
                            color: isDark ? ColorsManager.orange.withOpacity(0.15) : ColorsManager.grey50,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: isDark ? ColorsManager.orange.withOpacity(0.4) : ColorsManager.orange.withOpacity(0.35), width: 1.5),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildSectionTitle('معلومات المالك', Icons.business_rounded, ColorsManager.orange),
                              const SizedBox(height: 16),
                              _buildContactRowFull(Icons.person_outline_rounded, 'الاسم', bookingData!['ownerName']?.toString() ?? 'غير متوفر'),
                              const SizedBox(height: 12),
                              _buildContactRowFull(Icons.phone_iphone_rounded, 'رقم الهاتف', bookingData!['ownerPhone']?.toString() ?? 'غير متوفر'),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        if (proof.imageUrl != null)
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () => _showProofImage(context, proof.imageUrl!),
                              icon: const Icon(Icons.image_rounded, size: 20),
                              label: const Text('عرض الإيصال', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                                side: BorderSide(color: isDark ? ColorsManager.white.withOpacity(0.25) : ColorsManager.grey300, width: 1.5),
                              ),
                            ),
                          ),
                        if (proof.imageUrl != null) const SizedBox(width: 14),
                        if (proof.status == PaymentProofStatus.pending)
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () => _showReviewDialog(context, proof, bookingData!),
                              icon: const Icon(Icons.check_circle_rounded, size: 20),
                              label: const Text('مراجعة', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: ColorsManager.green,
                                foregroundColor: ColorsManager.white,
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              crossFadeState: isExpanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
              duration: const Duration(milliseconds: 300),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge(PaymentProofStatus status) {
    Color color = ColorsManager.orange;
    String text = 'قيد المراجعة';
    IconData icon = Icons.access_time_rounded;

    if (status == PaymentProofStatus.approved) {
      color = ColorsManager.green;
      text = 'مؤكد';
      icon = Icons.check_circle_rounded;
    } else if (status == PaymentProofStatus.rejected) {
      color = ColorsManager.red;
      text = 'مرفوض';
      icon = Icons.cancel_rounded;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [color.withOpacity(0.15), color.withOpacity(0.08)]),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.4), width: 1.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 6),
          Text(text, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 13)),
        ],
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value, Color color, {bool isBold = false}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(color: color.withOpacity(0.15), borderRadius: BorderRadius.circular(10)),
          child: Icon(icon, size: 20, color: color),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: isDark ? ColorsManager.white70 : ColorsManager.grey600)),
              const SizedBox(height: 4),
              Text(value, style: TextStyle(fontSize: 16, fontWeight: isBold ? FontWeight.bold : FontWeight.w600, color: isDark ? ColorsManager.white : ColorsManager.chaletTextPrimaryLight, height: 1.3)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title, IconData icon, Color color) {
    return Row(
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 6),
        Flexible(child: Text(title, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: color), overflow: TextOverflow.ellipsis, maxLines: 1)),
      ],
    );
  }

  Widget _buildContactRowFull(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: ColorsManager.grey600),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: isDark ? ColorsManager.white70 : ColorsManager.grey600)),
              const SizedBox(height: 4),
              Text(value, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: isDark ? ColorsManager.white : ColorsManager.chaletTextPrimaryLight, height: 1.3)),
            ],
          ),
        ),
      ],
    );
  }

  DateTime? _parseDate(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    if (value.runtimeType.toString() == 'Timestamp') return value.toDate();
    if (value is String) return DateTime.tryParse(value);
    return null;
  }

  void _showProofImage(BuildContext context, String imageUrl) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: ColorsManager.transparent,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ClipRRect(borderRadius: BorderRadius.circular(16), child: AppImageHelper(path: imageUrl, fit: BoxFit.contain)),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: ColorsManager.white,
                foregroundColor: ColorsManager.chaletTextPrimaryLight,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              child: const Text('إغلاق'),
            ),
          ],
        ),
      ),
    );
  }

  void _showReviewDialog(BuildContext context, PaymentProof proof, Map<String, dynamic> bookingMap) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('مراجعة الدفع'),
        content: const Text('الرجاء اختيار الإجراء المناسب لطلب الدفع هذا:'),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        actionsAlignment: MainAxisAlignment.spaceEvenly,
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('إلغاء')),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pop(ctx);
              // TODO: Implement reject in Cubit method
            },
            icon: const Icon(Icons.close_rounded, size: 18),
            label: const Text('رفض'),
            style: ElevatedButton.styleFrom(backgroundColor: ColorsManager.red, foregroundColor: ColorsManager.white, elevation: 0),
          ),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pop(ctx);
              // TODO: Implement approve in Cubit method
            },
            icon: const Icon(Icons.check_rounded, size: 18),
            label: const Text('موافقة'),
            style: ElevatedButton.styleFrom(backgroundColor: ColorsManager.green, foregroundColor: ColorsManager.white, elevation: 0),
          ),
        ],
      ),
    );
  }
}
