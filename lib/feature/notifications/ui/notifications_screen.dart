import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rebtal/feature/auth/cubit/auth_cubit.dart';
import 'package:rebtal/feature/booking/logic/booking_cubit.dart';
import 'package:rebtal/feature/booking/models/booking.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  @override
  void initState() {
    super.initState();
    // الاستماع لتغييرات الحجوزات في الوقت الفعلي
    _listenToBookingChanges();
  }

  void _listenToBookingChanges() {
    FirebaseFirestore.instance
        .collection('bookings')
        .snapshots()
        .listen((snapshot) {
      // إعادة تحميل الحجوزات عند حدوث تغيير
      if (mounted) {
        debugPrint('Firestore change detected, reloading bookings...');
        context.read<BookingCubit>().loadBookings();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final authState = context.read<AuthCubit>().state;
    String currentUid = '';
    if (authState is AuthSuccess) currentUid = authState.user.uid;

    return Scaffold(
      appBar: AppBar(
        title: const Text('الإشعارات'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.read<BookingCubit>().loadBookings();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('تم تحديث البيانات')),
              );
            },
          ),
        ],
      ),
      body: BlocBuilder<BookingCubit, BookingState>(
        builder: (context, state) {
          // تصفية الحجوزات التي تحتوي على إشعارات للمستخدم الحالي
          final notifications = state.bookings
              .where((b) {
                // تطبيع معرف المستخدم للمقارنة
                final normalizedUserId = b.userId.trim();
                final normalizedCurrentUid = currentUid.trim();
                
                // محاولة مطابقة مختلفة
                final isUserMatch = normalizedUserId == normalizedCurrentUid ||
                    b.userId == currentUid ||
                    b.userId.contains(currentUid) ||
                    currentUid.contains(b.userId);
                
                // عرض الحجوزات المقبولة والمرفوضة (الإشعارات)
                final hasNotification = b.status == BookingStatus.approved ||
                    b.status == BookingStatus.rejected;
                
                return isUserMatch && hasNotification;
              })
              .toList();
          
          if (notifications.isEmpty) {
            return _buildEmptyState();
          }

          return _buildNotificationsList(notifications);
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // أيقونة جميلة
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.blue.shade100, Colors.blue.shade50],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.blue.withValues(alpha: 0.1),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Icon(
                Icons.notifications_none,
                size: 60,
                color: Colors.blue.shade400,
              ),
            ),
            const SizedBox(height: 32),
            
            // العنوان الرئيسي
            Text(
              'لا توجد إشعارات جديدة',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade800,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            
            // النص التوضيحي
            Text(
              'ستظهر هنا الإشعارات الخاصة بحجوزاتك عند تحديث حالتها',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade600,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            
            // زر التحديث
            ElevatedButton.icon(
              onPressed: () {
                context.read<BookingCubit>().loadBookings();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('تم تحديث البيانات'),
                    backgroundColor: Colors.green,
                  ),
                );
              },
              icon: const Icon(Icons.refresh),
              label: const Text('تحديث'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationsList(List<Booking> notifications) {
    return Column(
      children: [
        // شريط معلومات
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          margin: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blue.shade50, Colors.blue.shade100],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.blue.shade200),
          ),
          child: Row(
            children: [
              Icon(Icons.notifications_active, color: Colors.blue.shade600, size: 24),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'إشعارات الحجوزات',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue.shade700,
                      ),
                    ),
                    Text(
                      '${notifications.length} إشعار جديد',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.blue.shade600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        
        // قائمة الإشعارات
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: notifications.length,
            itemBuilder: (context, index) {
              final booking = notifications[index];
              return _NotificationCard(booking: booking);
            },
          ),
        ),
      ],
    );
  }
}

class _NotificationCard extends StatelessWidget {
  final Booking booking;

  const _NotificationCard({required this.booking});

  @override
  Widget build(BuildContext context) {
    final isApproved = booking.status == BookingStatus.approved;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isApproved 
              ? [Colors.green.withValues(alpha: 0.1), Colors.green.withValues(alpha: 0.2)]
              : [Colors.red.withValues(alpha: 0.1), Colors.red.withValues(alpha: 0.2)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
          BoxShadow(
            color: (isApproved ? Colors.green : Colors.red).withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
        border: Border.all(
          color: isApproved ? Colors.green.withValues(alpha: 0.3) : Colors.red.withValues(alpha: 0.3), 
          width: 1
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // رأس البطاقة
            Row(
              children: [
                // أيقونة الحالة
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: isApproved 
                          ? [Colors.green, Colors.green.shade700]
                          : [Colors.red, Colors.red.shade700],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    isApproved ? Icons.check_circle : Icons.cancel,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                
                // معلومات الشاليه
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        booking.chaletName,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'صاحب الشاليه: ${booking.ownerName}',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
                
                // شارة الحالة
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: isApproved 
                          ? [Colors.green, Colors.green.shade700]
                          : [Colors.red, Colors.red.shade700],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    isApproved ? 'مقبول' : 'مرفوض',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 20),
            
            // تفاصيل الحجز
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: (isApproved ? Colors.green : Colors.red).withValues(alpha: 0.3)
                ),
              ),
              child: Column(
                children: [
                  // التواريخ
                  Row(
                    children: [
                      Expanded(
                        child: _DetailItem(
                          icon: Icons.calendar_today,
                          label: 'تاريخ البداية',
                          value: _formatDate(booking.from),
                          color: Colors.blue.shade600,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _DetailItem(
                          icon: Icons.event,
                          label: 'تاريخ النهاية',
                          value: _formatDate(booking.to),
                          color: Colors.blue.shade600,
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // مدة الإقامة
                  _DetailItem(
                    icon: Icons.schedule,
                    label: 'مدة الإقامة',
                    value: '${_calculateDays(booking.from, booking.to)} أيام',
                    color: Colors.purple.shade600,
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 20),
            
            // رسالة الإشعار
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: isApproved 
                      ? [Colors.green.withValues(alpha: 0.1), Colors.green.withValues(alpha: 0.2)]
                      : [Colors.red.withValues(alpha: 0.1), Colors.red.withValues(alpha: 0.2)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isApproved ? Colors.green.withValues(alpha: 0.3) : Colors.red.withValues(alpha: 0.3)
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    isApproved ? Icons.celebration : Icons.info_outline, 
                    color: isApproved ? Colors.green : Colors.red, 
                    size: 24
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isApproved 
                              ? 'مبروك! تم قبول حجزك' 
                              : 'تم رفض طلب الحجز',
                          style: TextStyle(
                            color: isApproved ? Colors.green : Colors.red,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          isApproved 
                              ? 'يمكنك الآن الاستمتاع بإقامتك في ${booking.chaletName}'
                              : 'للأسف، لم يتم قبول طلب حجزك في ${booking.chaletName}',
                          style: TextStyle(
                            color: isApproved ? Colors.green.withValues(alpha: 0.8) : Colors.red.withValues(alpha: 0.8),
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  int _calculateDays(DateTime from, DateTime to) {
    return to.difference(from).inDays + 1;
  }
}

class _DetailItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _DetailItem({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        children: [
          Icon(icon, size: 20, color: color),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              color: color,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
