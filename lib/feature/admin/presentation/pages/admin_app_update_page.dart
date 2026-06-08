import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:rebtal/core/utils/config/space.dart';
import 'package:rebtal/core/utils/constant/color_manager.dart';
import 'package:rebtal/core/utils/localization/translation_extension.dart';
import 'package:rebtal/core/utils/helper/snack_bar_helper.dart';
import 'package:responsive_screen_master/responsive_screen_master.dart';

class AdminAppUpdatePage extends StatefulWidget {
  const AdminAppUpdatePage({super.key});

  @override
  State<AdminAppUpdatePage> createState() => _AdminAppUpdatePageState();
}

class _AdminAppUpdatePageState extends State<AdminAppUpdatePage> {
  final _minBuildController = TextEditingController();
  final _androidUrlController = TextEditingController();
  final _iosUrlController = TextEditingController();
  final _webUrlController = TextEditingController();
  bool _forceUpdate = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadConfig();
  }

  Future<void> _loadConfig() async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('app_config')
          .doc('mobile')
          .get();

      if (doc.exists) {
        final data = doc.data()!;
        _minBuildController.text = data['minBuildNumber']?.toString() ?? '1';
        _forceUpdate = data['forceUpdate'] == true;
        _androidUrlController.text = data['updateUrlAndroid'] ?? '';
        _iosUrlController.text = data['updateUrlIos'] ?? '';
        _webUrlController.text = data['updateUrlWeb'] ?? '';
      }
    } catch (e) {
      if (mounted) {
        SnackBarHelper.showError(context, '${context.tr('common_error') ?? 'Error'}: $e');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _saveConfig() async {
    if (_minBuildController.text.trim().isEmpty) return;

    setState(() => _isLoading = true);
    try {
      final minBuild = int.tryParse(_minBuildController.text.trim()) ?? 1;

      await FirebaseFirestore.instance.collection('app_config').doc('mobile').set({
        'minBuildNumber': minBuild,
        'forceUpdate': _forceUpdate,
        'updateUrlAndroid': _androidUrlController.text.trim(),
        'updateUrlIos': _iosUrlController.text.trim(),
        'updateUrlWeb': _webUrlController.text.trim(),
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      if (mounted) {
        SnackBarHelper.showSuccess(context, context.tr('common_save') ?? 'Saved successfully');
      }
    } catch (e) {
      if (mounted) {
        SnackBarHelper.showError(context, '${context.tr('common_error') ?? 'Error'}: $e');
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  void dispose() {
    _minBuildController.dispose();
    _androidUrlController.dispose();
    _iosUrlController.dispose();
    _webUrlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20.sp),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              context.tr('admin_app_updates') ?? 'إدارة التحديثات',
              style: TextStyle(
                fontSize: 24.sp,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black,
              ),
            ),
            verticalSpace(1),
            Text(
              context.tr('admin_app_updates_desc') ?? 'تحكم في إجبار المستخدمين على تحديث التطبيق',
              style: TextStyle(
                fontSize: 14.sp,
                color: Colors.grey,
              ),
            ),
            verticalSpace(3),
            Container(
              padding: EdgeInsets.all(20.sp),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1A1A2E) : Colors.white,
                borderRadius: BorderRadius.circular(16.sp),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(isDark ? 0.3 : 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        context.tr('admin_force_update_enable') ?? 'تفعيل التحديث الإجباري',
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Switch(
                        value: _forceUpdate,
                        onChanged: (val) => setState(() => _forceUpdate = val),
                        activeColor: ColorsManager.green,
                      ),
                    ],
                  ),
                  verticalSpace(2),
                  _buildTextField(
                    context,
                    controller: _minBuildController,
                    label: context.tr('admin_min_build_number') ?? 'رقم الإصدار الأدنى المطلوب (Build Number)',
                    icon: Icons.numbers_rounded,
                    isDark: isDark,
                    keyboardType: TextInputType.number,
                  ),
                  verticalSpace(2),
                  _buildTextField(
                    context,
                    controller: _androidUrlController,
                    label: context.tr('admin_android_url') ?? 'رابط متجر Android',
                    icon: Icons.android_rounded,
                    isDark: isDark,
                  ),
                  verticalSpace(2),
                  _buildTextField(
                    context,
                    controller: _iosUrlController,
                    label: context.tr('admin_ios_url') ?? 'رابط متجر iOS',
                    icon: Icons.apple_rounded,
                    isDark: isDark,
                  ),
                ],
              ),
            ),
            verticalSpace(4),
            SizedBox(
              width: double.infinity,
              height: 50.sh,
              child: ElevatedButton(
                onPressed: _saveConfig,
                style: ElevatedButton.styleFrom(
                  backgroundColor: ColorsManager.kPrimaryGradient.colors.first,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.sp),
                  ),
                ),
                child: Text(
                  context.tr('common_save') ?? 'حفظ التعديلات',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(
    BuildContext context, {
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    required bool isDark,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF2D2D44).withOpacity(0.5) : ColorsManager.grey50,
        borderRadius: BorderRadius.circular(14.sp),
        border: Border.all(
          color: isDark ? Colors.white.withOpacity(0.1) : ColorsManager.grey300,
          width: 1,
        ),
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        style: TextStyle(
          color: isDark ? Colors.white : Colors.black87,
          fontSize: 16.sp,
        ),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(
            color: isDark ? Colors.white70 : Colors.grey[600],
            fontSize: 14.sp,
          ),
          prefixIcon: Icon(
            icon,
            color: ColorsManager.kPrimaryGradient.colors.first,
            size: 22.sp,
          ),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(
            horizontal: 16.sw,
            vertical: 16.sh,
          ),
          filled: false,
        ),
      ),
    );
  }
}
