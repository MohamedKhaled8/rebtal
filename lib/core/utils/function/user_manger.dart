import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:rebtal/feature/admin/widget/request/approved_requests_tab.dart';
import 'package:rebtal/feature/admin/widget/request/pending_requsted_tab.dart';
import 'package:rebtal/feature/admin/widget/request/rejected_requests_tab.dart';
import 'package:rebtal/feature/admin/widget/user/user_tab.dart';
import 'package:rebtal/feature/admin/ui/admin_payments_page.dart';
import 'package:rebtal/feature/admin/ui/admin_cancellations_page.dart';

class UserManager {
  /// لون حسب الدور
  static Color roleColor(String r) {
    switch (r.toLowerCase()) {
      case 'admin':
        return Colors.red;
      case 'owner':
        return Colors.orange;
      default:
        return Colors.blue;
    }
  }

  /// تنسيق التاريخ
  static String formatDate(dynamic dateField) {
    if (dateField == null) return 'Unknown';
    try {
      DateTime d;
      if (dateField is Timestamp) {
        d = dateField.toDate();
      } else if (dateField is String && dateField.isNotEmpty) {
        d = DateTime.parse(dateField);
      } else if (dateField is DateTime) {
        d = dateField;
      } else {
        return dateField.toString();
      }
      return '${d.day}/${d.month}/${d.year} ${d.hour}:${d.minute.toString().padLeft(2, '0')}';
    } catch (_) {
      return 'Invalid date';
    }
  }

  /// تعديل المستخدم
  static void editUser({
    required BuildContext ctx,
    required Map<String, dynamic> userData,
    required String collection,
    required String docId,
  }) {
    final nameController = TextEditingController(text: userData['name'] ?? '');
    final emailController = TextEditingController(
      text: userData['email'] ?? '',
    );
    final phoneController = TextEditingController(
      text: userData['phone'] ?? '',
    );
    final passwordController = TextEditingController(
      text: userData['password'] ?? '',
    );

    final isDark = Theme.of(ctx).brightness == Brightness.dark;

    showDialog(
      context: ctx,
      barrierColor: Colors.black.withOpacity(0.5),
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(20),
        child: Container(
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1A1A2E) : Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(isDark ? 0.5 : 0.1),
                blurRadius: 20,
                spreadRadius: 2,
              ),
            ],
          ),
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: isDark
                              ? const Color(0xFF2D2D44)
                              : const Color(0xFF667EEA).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          Icons.edit_rounded,
                          color: isDark
                              ? const Color(0xFF667EEA)
                              : const Color(0xFF667EEA),
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'تعديل بيانات العميل',
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: isDark ? Colors.white : Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'تعديل معلومات المستخدم',
                              style: TextStyle(
                                fontSize: 14,
                                color: isDark
                                    ? Colors.white70
                                    : Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: Icon(
                          Icons.close_rounded,
                          color: isDark ? Colors.white70 : Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  // Name Field
                  _buildTextField(
                    context: context,
                    controller: nameController,
                    label: 'الاسم',
                    icon: Icons.person_outline_rounded,
                    isDark: isDark,
                  ),
                  const SizedBox(height: 20),
                  // Email Field
                  _buildTextField(
                    context: context,
                    controller: emailController,
                    label: 'البريد الإلكتروني',
                    icon: Icons.email_outlined,
                    keyboardType: TextInputType.emailAddress,
                    isDark: isDark,
                  ),
                  const SizedBox(height: 20),
                  // Phone Field
                  _buildTextField(
                    context: context,
                    controller: phoneController,
                    label: 'رقم الهاتف',
                    icon: Icons.phone_outlined,
                    keyboardType: TextInputType.phone,
                    isDark: isDark,
                  ),
                  const SizedBox(height: 20),
                  // Password Field
                  _buildPasswordField(
                    context: context,
                    controller: passwordController,
                    label: 'كلمة المرور',
                    icon: Icons.lock_outline_rounded,
                    isDark: isDark,
                  ),
                  const SizedBox(height: 32),
                  // Action Buttons
                  Row(
                    children: [
                      Expanded(
                        child: _buildButton(
                          context: context,
                          label: 'إلغاء',
                          onPressed: () => Navigator.pop(context),
                          isPrimary: false,
                          isDark: isDark,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildButton(
                          context: context,
                          label: 'حفظ التغييرات',
                          onPressed: () async {
                            if (nameController.text.trim().isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: const Text('الرجاء إدخال الاسم'),
                                  backgroundColor: Colors.red,
                                ),
                              );
                              return;
                            }
                            if (emailController.text.trim().isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: const Text(
                                    'الرجاء إدخال البريد الإلكتروني',
                                  ),
                                  backgroundColor: Colors.red,
                                ),
                              );
                              return;
                            }
                            if (passwordController.text.trim().isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: const Text(
                                    'الرجاء إدخال كلمة المرور',
                                  ),
                                  backgroundColor: Colors.red,
                                ),
                              );
                              return;
                            }

                            try {
                              await FirebaseFirestore.instance
                                  .collection(collection)
                                  .doc(docId)
                                  .update({
                                    'name': nameController.text.trim(),
                                    'email': emailController.text.trim(),
                                    'phone': phoneController.text.trim(),
                                    'password': passwordController.text.trim(),
                                  });
                              if (!context.mounted) return;
                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: const Text(
                                    'تم تحديث بيانات المستخدم بنجاح',
                                  ),
                                  backgroundColor: Colors.green,
                                  behavior: SnackBarBehavior.floating,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                              );
                            } catch (e) {
                              if (!context.mounted) return;
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('خطأ: $e'),
                                  backgroundColor: Colors.red,
                                  behavior: SnackBarBehavior.floating,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                              );
                            }
                          },
                          isPrimary: true,
                          isDark: isDark,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  static Widget _buildTextField({
    required BuildContext context,
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    required bool isDark,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: isDark
            ? const Color(0xFF2D2D44).withOpacity(0.5)
            : Colors.grey[50],
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark
              ? Colors.white.withOpacity(0.1)
              : Colors.grey[300]!,
          width: 1,
        ),
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        style: TextStyle(
          color: isDark ? Colors.white : Colors.black87,
          fontSize: 16,
        ),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(
            color: isDark ? Colors.white70 : Colors.grey[600],
            fontSize: 14,
          ),
          prefixIcon: Icon(
            icon,
            color: isDark
                ? const Color(0xFF667EEA)
                : const Color(0xFF667EEA),
            size: 22,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
          filled: false,
        ),
      ),
    );
  }

  static Widget _buildPasswordField({
    required BuildContext context,
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required bool isDark,
  }) {
    return _PasswordFieldWidget(
      controller: controller,
      label: label,
      icon: icon,
      isDark: isDark,
    );
  }

  static Widget _buildButton({
    required BuildContext context,
    required String label,
    required VoidCallback onPressed,
    required bool isPrimary,
    required bool isDark,
  }) {
    return Container(
      height: 50,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        gradient: isPrimary
            ? LinearGradient(
                colors: isDark
                    ? [
                        const Color(0xFF667EEA),
                        const Color(0xFF764BA2),
                      ]
                    : [
                        const Color(0xFF667EEA),
                        const Color(0xFF764BA2),
                      ],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              )
            : null,
        color: isPrimary
            ? null
            : (isDark
                ? const Color(0xFF2D2D44)
                : Colors.grey[200]),
        border: isPrimary
            ? null
            : Border.all(
                color: isDark
                    ? Colors.white.withOpacity(0.2)
                    : Colors.grey[300]!,
              ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(12),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                color: isPrimary
                    ? Colors.white
                    : (isDark ? Colors.white70 : Colors.black87),
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// حذف المستخدم
  static void deleteUser({
    required BuildContext ctx,
    required String collection,
    required String docId,
  }) {
    final isDark = Theme.of(ctx).brightness == Brightness.dark;
    
    showDialog(
      context: ctx,
      barrierColor: Colors.black.withOpacity(0.5),
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(20),
        child: Container(
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1A1A2E) : Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(isDark ? 0.5 : 0.1),
                blurRadius: 20,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.warning_rounded,
                    color: Colors.red,
                    size: 48,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'حذف المستخدم',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'هل أنت متأكد من حذف هذا المستخدم؟\nلا يمكن التراجع عن هذا الإجراء.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: isDark ? Colors.white70 : Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 32),
                Row(
                  children: [
                    Expanded(
                      child: _buildButton(
                        context: context,
                        label: 'إلغاء',
                        onPressed: () => Navigator.pop(context),
                        isPrimary: false,
                        isDark: isDark,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Container(
                        height: 50,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          gradient: LinearGradient(
                            colors: [Colors.red, Colors.red[700]!],
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                          ),
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () async {
                              try {
                                await FirebaseFirestore.instance
                                    .collection(collection)
                                    .doc(docId)
                                    .delete();
                                if (!context.mounted) return;
                                Navigator.pop(context);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: const Text('تم حذف المستخدم بنجاح'),
                                    backgroundColor: Colors.green,
                                    behavior: SnackBarBehavior.floating,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                );
                              } catch (e) {
                                if (!context.mounted) return;
                                Navigator.pop(context);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('خطأ: $e'),
                                    backgroundColor: Colors.red,
                                    behavior: SnackBarBehavior.floating,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                );
                              }
                            },
                            borderRadius: BorderRadius.circular(12),
                            child: const Center(
                              child: Text(
                                'حذف',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  static IconData statusIcon(String s) {
    switch (s) {
      case 'approved':
        return Icons.check_circle_outline;
      case 'rejected':
        return Icons.cancel_outlined;
      default:
        return Icons.pending_actions;
    }
  }

  static Color statusColor(String s) {
    switch (s.toLowerCase()) {
      case 'approved':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      case 'pending':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  static final List<Widget> tabs = const [
    UsersTab(),
    PendingRequestsTab(),
    AdminPaymentsPage(),
    AdminCancellationsPage(), // New Tab
    ApprovedRequestsTab(),
    RejectedRequestsTab(),
  ];

  static final List<String> tabTitles = const [
    'Users',
    'Pending',
    'Payments',
    'Cancellations', // New Title
    'Approved',
    'Rejected',
  ];

  static final List<IconData> tabIcons = const [
    Icons.people,
    Icons.pending_actions,
    Icons.payment,
    Icons.cancel_presentation, // New Icon
    Icons.check_circle,
    Icons.cancel,
  ];
}

class _PasswordFieldWidget extends StatefulWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final bool isDark;

  const _PasswordFieldWidget({
    required this.controller,
    required this.label,
    required this.icon,
    required this.isDark,
  });

  @override
  State<_PasswordFieldWidget> createState() => _PasswordFieldWidgetState();
}

class _PasswordFieldWidgetState extends State<_PasswordFieldWidget> {
  bool obscureText = true;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: widget.isDark
            ? const Color(0xFF2D2D44).withOpacity(0.5)
            : Colors.grey[50],
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: widget.isDark
              ? Colors.white.withOpacity(0.1)
              : Colors.grey[300]!,
          width: 1,
        ),
      ),
      child: TextField(
        controller: widget.controller,
        obscureText: obscureText,
        style: TextStyle(
          color: widget.isDark ? Colors.white : Colors.black87,
          fontSize: 16,
        ),
        decoration: InputDecoration(
          labelText: widget.label,
          labelStyle: TextStyle(
            color: widget.isDark ? Colors.white70 : Colors.grey[600],
            fontSize: 14,
          ),
          prefixIcon: Icon(
            widget.icon,
            color: widget.isDark
                ? const Color(0xFF667EEA)
                : const Color(0xFF667EEA),
            size: 22,
          ),
          suffixIcon: IconButton(
            icon: Icon(
              obscureText
                  ? Icons.visibility_outlined
                  : Icons.visibility_off_outlined,
              color: widget.isDark ? Colors.white70 : Colors.grey[600],
            ),
            onPressed: () {
              setState(() {
                obscureText = !obscureText;
              });
            },
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
          filled: false,
        ),
      ),
    );
  }
}
