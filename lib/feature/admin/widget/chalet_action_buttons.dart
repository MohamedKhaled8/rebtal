import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rebtal/core/utils/config/space.dart';
import 'package:rebtal/core/utils/constant/color_manager.dart';
import 'package:rebtal/core/utils/localization/translation_extension.dart';
import 'package:responsive_screen_master/responsive_screen_master.dart';
import 'package:rebtal/feature/admin/presentation/cubit/admin_cubit.dart';
import 'package:rebtal/feature/admin/widget/chalet_toggle_button.dart';
import 'package:rebtal/feature/owner/ui/add_chalet_screen.dart';
import 'package:rebtal/core/utils/helper/snack_bar_helper.dart';

class ChaletActionButtons extends StatelessWidget {
  final String docId;
  final Map<String, dynamic> requestData;

  const ChaletActionButtons({
    super.key,
    required this.docId,
    required this.requestData,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: ChaletToggleButton(
            icon: Icons.edit_rounded,
            label: context.tr('common_edit') ?? 'تعديل',
            color: ColorsManager.blue2563EB,
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => AddChaletScreen(
                    editDocId: docId,
                    initialChaletData: requestData,
                  ),
                ),
              );
            },
          ),
        ),
        horizintalSpace(2),
        Expanded(
          child: ChaletToggleButton(
            icon: Icons.delete_forever_rounded,
            label: context.tr('common_delete') ?? 'حذف',
            color: Colors.red,
            onPressed: () => _showDeleteDialog(context),
          ),
        ),
      ],
    );
  }

  void _showDeleteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.sp)),
        title: Text(
          context.tr('common_confirm_delete') ?? 'تأكيد الحذف',
          style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
        ),
        content: Text(
          context.tr('admin_confirm_delete_chalet') ?? 'هل أنت متأكد من حذف هذا الشاليه نهائياً؟',
          style: TextStyle(fontSize: 14.sp),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              context.tr('common_cancel') ?? 'إلغاء', 
              style: TextStyle(color: Colors.grey, fontSize: 14.sp),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              Navigator.pop(ctx);
              try {
                await context.read<AdminCubit>().deleteChalet(docId);
                if (context.mounted) {
                  SnackBarHelper.showSuccess(
                    context, 
                    context.tr('admin_chalet_deleted_success') ?? 'تم حذف الشاليه بنجاح'
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  SnackBarHelper.showError(context, '${context.tr('common_error') ?? 'خطأ'}: $e');
                }
              }
            },
            child: Text(
              context.tr('common_delete') ?? 'حذف', 
              style: TextStyle(color: Colors.white, fontSize: 14.sp),
            ),
          ),
        ],
      ),
    );
  }
}
