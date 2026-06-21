// Generic requests list by status
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:rebtal/core/utils/function/user_manger.dart';
import 'package:rebtal/core/utils/home_search_notifier.dart';
import 'package:rebtal/core/utils/localization/translation_extension.dart';
import 'package:rebtal/feature/admin/widget/ChaletRequestCard.dart';
import 'package:rebtal/feature/owner/utils/chalet_edit_review_helper.dart';

class RequestsList extends StatelessWidget {
  final String status;
  final IconData? emptyIcon;
  final String? emptyTitle;
  final String? emptySubtitle;
  final String? ownerId; // 🆕 Add ownerId parameter

  const RequestsList({
    super.key,
    required this.status,
    this.emptyIcon,
    this.emptyTitle,
    this.emptySubtitle,
    this.ownerId, // 🆕 Add ownerId parameter
  });

  @override
  Widget build(BuildContext context) {
    // Build query based on whether ownerId is provided
    Query query = FirebaseFirestore.instance.collection('chalets');

    if (status != 'pending') {
      query = query.where('status', isEqualTo: status);
    }
    
    // Only filter by ownerId if it's provided (for owner view)
    // Admin should see all requests without ownerId filter
    if (ownerId != null && ownerId!.isNotEmpty) {
      query = query.where('ownerId', isEqualTo: ownerId);
    }
    
    return StreamBuilder<QuerySnapshot>(
      stream: query.snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.deepPurple),
            ),
          );
        }
        if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
                const SizedBox(height: 16),
                Text(
                  context.tr('admin_requests_error'),
                  style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                ),
              ],
            ),
          );
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          // Choose localized empty state message based on status
          final String emptyKey;
          switch (status.toLowerCase()) {
            case 'approved':
              emptyKey = 'admin_no_approved_requests';
              break;
            case 'pending':
              emptyKey = 'admin_no_pending_requests';
              break;
            case 'rejected':
              emptyKey = 'admin_no_rejected_requests';
              break;
            default:
              emptyKey = 'admin_no_requests';
          }
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  emptyIcon ?? UserManager.statusIcon(status),
                  size: 72,
                  color: Colors.grey[400],
                ),
                const SizedBox(height: 16),
                Text(
                  emptyTitle ?? context.tr(emptyKey),
                  style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                  textAlign: TextAlign.center,
                ),
                if (emptySubtitle != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    emptySubtitle!,
                    style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                    textAlign: TextAlign.center,
                  ),
                ],
              ],
            ),
          );
        }
        final docs = snapshot.data!.docs;

        return ValueListenableBuilder<SearchFilters>(
          valueListenable: HomeSearch.filters,
          builder: (context, filters, _) {
            final query = filters.query;
            // simple case-insensitive filter by common fields
            final filtered = docs.where((doc) {
              final data = doc.data() as Map<String, dynamic>;
              if (status == 'pending' &&
                  !ChaletEditReviewHelper.shouldShowInAdminPendingTab(data)) {
                return false;
              }
              if (status != 'pending' &&
                  data['status'] != status) {
                return false;
              }
              if (status == 'approved' &&
                  ChaletEditReviewHelper.isEditReviewPending(data)) {
                return false;
              }
              final lcq = query.toLowerCase();
              if (lcq.isEmpty) return true;
              // check common fields
              final candidates = <String?>[
                data['name']?.toString(),
                data['title']?.toString(),
                data['description']?.toString(),
                data['location']?.toString(),
              ];
              return candidates.any(
                (c) => c != null && c.toLowerCase().contains(lcq),
              );
            }).toList();

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: filtered.length,
              itemBuilder: (context, i) {
                final doc = filtered[i];
                final data = doc.data() as Map<String, dynamic>;
                return ChaletRequestCard(
                  requestData: data,
                  docId: doc.id,
                  status: status,
                );
              },
            );
          },
        );
      },
    );
  }
}
