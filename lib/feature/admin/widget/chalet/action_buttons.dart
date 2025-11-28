import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rebtal/feature/admin/logic/cubit/admin_cubit.dart';
import 'package:rebtal/feature/auth/cubit/auth_cubit.dart';
import 'package:rebtal/feature/booking/ui/booking_bridge_widget.dart';

class ActionButtons extends StatelessWidget {
  final String status;
  final String docId;
  final Map<String, dynamic> requestData;

  const ActionButtons({
    super.key,
    required this.status,
    required this.docId,
    required this.requestData,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, authState) {
        if (authState is AuthSuccess) {
          final role = authState.user.role.toLowerCase();

          if (role == 'admin') {
            return _buildAdminButtons(context);
          } else if (role == 'user') {
            return _buildUserButtons(context, requestData, docId);
          } else if (role == 'owner') {
            return _buildOwnerButtons(context);
          }
        }

        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildAdminButtons(BuildContext context) {
    final cubit = context.read<AdminCubit>();

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 40),
      child: status == 'pending'
          ? Column(
              children: [
                // Approve Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => cubit.updateStatus(
                      context,
                      docId: docId,
                      newStatus: 'approved',
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF10B981),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      elevation: 0,
                      shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.check_circle_outline, size: 22),
                        SizedBox(width: 12),
                        Text(
                          'Approve Request',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                // Reject Button
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () => cubit.updateStatus(
                      context,
                      docId: docId,
                      newStatus: 'rejected',
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFFEF4444),
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      side: const BorderSide(
                        color: Color(0xFFEF4444),
                        width: 2,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.cancel_outlined, size: 22),
                        SizedBox(width: 12),
                        Text(
                          'Reject Request',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            )
          : Container(
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF3B82F6), Color(0xFF1D4ED8)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF3B82F6).withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ElevatedButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text(
                        'Request already processed',
                        style: TextStyle(color: Colors.white),
                      ),
                      backgroundColor: const Color(0xFF1F2937),
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      status == 'approved' ? Icons.check_circle : Icons.cancel,
                      size: 22,
                      color: Colors.white,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      status == 'approved'
                          ? 'Request Approved'
                          : 'Request Rejected',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildUserButtons(
    BuildContext context,
    Map<String, dynamic> requestData,
    String docId,
  ) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 40),
      child: _buildBookingButton(context, requestData, docId),
    );
  }

  Widget _buildOwnerButtons(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 40),
      child: Column(
        children: [
          _buildBookingToggleButton(context),
          const SizedBox(height: 16),
          _buildOwnerStatusButton(context),
        ],
      ),
    );
  }

  Widget _buildBookingButton(
    BuildContext context,
    Map<String, dynamic> requestData,
    String docId,
  ) {
    final authCubit = context.read<AuthCubit>();
    final currentUser = authCubit.getCurrentUser();

    if (currentUser == null) return const SizedBox.shrink();

    // Check booking availability
    final bookingAvailability =
        requestData['bookingAvailability'] ?? 'available';
    final isBookingAvailable = bookingAvailability == 'available';

    var ownerId = requestData['ownerId'] ?? requestData['userId'] ?? '';
    if (ownerId.isEmpty) {
      debugPrint('Warning: ownerId is empty for requestData: $requestData');
      // Do NOT fallback to current user (that makes ownerId == userId).
      // Leave ownerId empty and let BookingBridgeWidget.resolveOwner fetch
      // the real ownerId from the chalet document.
      ownerId = '';
    }

    final chaletId = docId;
    final chaletName =
        requestData['chaletName'] ?? requestData['name'] ?? 'شاليه';
    final ownerName =
        requestData['merchantName'] ??
        requestData['ownerName'] ??
        'صاحب الشاليه';

    debugPrint('Building booking button with ownerId: $ownerId');
    debugPrint('RequestData: $requestData');

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: isBookingAvailable
            ? const LinearGradient(
                colors: [Color(0xFF10B981), Color(0xFF059669)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : const LinearGradient(
                colors: [Color(0xFF6B7280), Color(0xFF4B5563)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color:
                (isBookingAvailable
                        ? const Color(0xFF10B981)
                        : const Color(0xFF6B7280))
                    .withOpacity(0.4),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: isBookingAvailable
            ? () => showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (ctx) => BookingBridgeWidget(
                  parentContext: context,
                  userId: currentUser.uid,
                  userName: (currentUser.name.isNotEmpty
                      ? currentUser.name
                      : currentUser.uid),
                  chaletId: chaletId,
                  chaletName: chaletName,
                  ownerId: ownerId,
                  ownerName: ownerName,
                  requestData: requestData,
                ),
              )
            : () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text(
                      'الحجز غير متاح حالياً',
                      style: TextStyle(color: Colors.white),
                    ),
                    backgroundColor: const Color(0xFFEF4444),
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                );
              },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          padding: const EdgeInsets.symmetric(vertical: 18),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isBookingAvailable ? Icons.bookmark_outline : Icons.lock,
              size: 22,
              color: Colors.white,
            ),
            const SizedBox(width: 12),
            Text(
              isBookingAvailable ? 'Booking Now' : 'الحجز مغلق',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // BookingBridgeWidget moved to booking/ui/booking_bridge_widget.dart

  Widget _buildBookingToggleButton(BuildContext context) {
    final bookingAvailability =
        requestData['bookingAvailability'] ?? 'available';
    final isBookingAvailable = bookingAvailability == 'available';

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: isBookingAvailable
            ? const LinearGradient(
                colors: [Color(0xFFEF4444), Color(0xFFDC2626)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : const LinearGradient(
                colors: [Color(0xFF10B981), Color(0xFF059669)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color:
                (isBookingAvailable
                        ? const Color(0xFFEF4444)
                        : const Color(0xFF10B981))
                    .withOpacity(0.4),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: () => _toggleBookingAvailability(context),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          padding: const EdgeInsets.symmetric(vertical: 18),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isBookingAvailable ? Icons.pause : Icons.play_arrow,
              size: 22,
              color: Colors.white,
            ),
            const SizedBox(width: 12),
            Text(
              isBookingAvailable ? 'إيقاف الحجز' : 'تشغيل الحجز',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _toggleBookingAvailability(BuildContext context) async {
    try {
      final currentAvailability =
          requestData['bookingAvailability'] ?? 'available';
      final newAvailability = currentAvailability == 'available'
          ? 'unavailable'
          : 'available';

      await FirebaseFirestore.instance.collection('chalets').doc(docId).update({
        'bookingAvailability': newAvailability,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              newAvailability == 'available'
                  ? 'تم تشغيل الحجز بنجاح'
                  : 'تم إيقاف الحجز بنجاح',
            ),
            backgroundColor: newAvailability == 'available'
                ? Colors.green
                : Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('خطأ في تحديث حالة الحجز: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    }
  }

  Widget _buildOwnerStatusButton(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 18),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.info_outline, size: 22, color: Colors.grey[600]),
            const SizedBox(width: 12),
            Text(
              'Your Chalet',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
