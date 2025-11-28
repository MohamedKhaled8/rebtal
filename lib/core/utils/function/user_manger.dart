import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:rebtal/feature/admin/widget/request/approved_requests_tab.dart';
import 'package:rebtal/feature/admin/widget/request/pending_requsted_tab.dart';
import 'package:rebtal/feature/admin/widget/request/rejected_requests_tab.dart';
import 'package:rebtal/feature/admin/widget/user/user_tab.dart';

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

    showDialog(
      context: ctx,
      builder: (context) => AlertDialog(
        title: const Text('Edit User'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Name'),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: emailController,
              decoration: const InputDecoration(labelText: 'Email'),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: phoneController,
              decoration: const InputDecoration(labelText: 'Phone'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                await FirebaseFirestore.instance
                    .collection(collection)
                    .doc(docId)
                    .update({
                      'name': nameController.text,
                      'email': emailController.text,
                      'phone': phoneController.text,
                    });
                Navigator.pop(context);
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(const SnackBar(content: Text('User updated')));
              } catch (e) {
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text('Error: $e')));
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  /// حذف المستخدم
  static void deleteUser({
    required BuildContext ctx,
    required String collection,
    required String docId,
  }) {
    showDialog(
      context: ctx,
      builder: (context) => AlertDialog(
        title: const Text('Delete User'),
        content: const Text('Are you sure?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              try {
                await FirebaseFirestore.instance
                    .collection(collection)
                    .doc(docId)
                    .delete();
                Navigator.pop(context);
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(const SnackBar(content: Text('User deleted')));
              } catch (e) {
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text('Error: $e')));
              }
            },
            child: const Text('Delete'),
          ),
        ],
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
static  final List<Widget> tabs = const [
    UsersTab(),
    PendingRequestsTab(),
    ApprovedRequestsTab(),
    RejectedRequestsTab(),
  ];

static  final List<String> tabTitles = const [
    'Users',
    'Pending',
    'Approved',
    'Rejected',
  ];

static  final List<IconData> tabIcons = const [
    Icons.people,
    Icons.pending_actions,
    Icons.check_circle,
    Icons.cancel,
  ];

}
