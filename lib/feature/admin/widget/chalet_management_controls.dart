import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rebtal/core/utils/config/space.dart';
import 'package:rebtal/core/utils/localization/translation_extension.dart';
import 'package:responsive_screen_master/responsive_screen_master.dart';
import 'package:rebtal/core/utils/helper/snack_bar_helper.dart';
import 'package:rebtal/feature/admin/presentation/cubit/admin_cubit.dart';
import 'package:rebtal/feature/admin/widget/chalet_toggle_button.dart';

class ChaletManagementControls extends StatelessWidget {
  final String docId;
  final bool isVisible;
  final String bookingAvailability;

  const ChaletManagementControls({
    super.key,
    required this.docId,
    required this.isVisible,
    required this.bookingAvailability,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: ChaletToggleButton(
            icon: isVisible ? Icons.visibility : Icons.visibility_off,
            label: isVisible ? (context.tr('common_hidden') ?? 'إخفاء') : (context.tr('common_show') ?? 'إظهار'),
            color: isVisible ? Colors.orange : Colors.green,
            onPressed: () async {
              try {
                await context.read<AdminCubit>().toggleChaletVisibility(docId, isVisible);
                if (context.mounted) {
                  SnackBarHelper.showSuccess(
                    context, 
                    isVisible 
                        ? (context.tr('admin_hide_chalet_success') ?? 'تم إخفاء الشاليه بنجاح')
                        : (context.tr('admin_show_chalet_success') ?? 'تم إظهار الشاليه بنجاح')
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  SnackBarHelper.showError(context, '${context.tr('common_error') ?? 'خطأ'}: $e');
                }
              }
            },
          ),
        ),
        horizintalSpace(2),
        Expanded(
          child: ChaletToggleButton(
            icon: bookingAvailability == 'available' ? Icons.lock_outline : Icons.lock_open,
            label: bookingAvailability == 'available' ? (context.tr('owner_stop_booking') ?? 'إيقاف الحجز') : (context.tr('owner_start_booking') ?? 'بدء الحجز'),
            color: bookingAvailability == 'available' ? Colors.red : Colors.green,
            onPressed: () async {
              try {
                await context.read<AdminCubit>().toggleChaletBookingAvailability(docId, bookingAvailability);
                if (context.mounted) {
                  SnackBarHelper.showSuccess(
                    context, 
                    bookingAvailability == 'available' 
                        ? (context.tr('admin_booking_stopped_success') ?? 'تم إيقاف حجز الشاليه بنجاح')
                        : (context.tr('admin_booking_started_success') ?? 'تم بدء حجز الشاليه بنجاح')
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  SnackBarHelper.showError(context, '${context.tr('common_error') ?? 'خطأ'}: $e');
                }
              }
            },
          ),
        ),
      ],
    );
  }
}
