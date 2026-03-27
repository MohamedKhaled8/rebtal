import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rebtal/core/utils/function/user_manger.dart';
import 'package:rebtal/core/utils/home_search_notifier.dart';
import 'package:rebtal/core/utils/localization/translation_extension.dart';
import 'package:rebtal/feature/admin/presentation/cubit/admin_cubit.dart';
import 'package:rebtal/feature/admin/presentation/cubit/admin_state.dart';
import 'package:rebtal/feature/admin/widget/ChaletRequestCard.dart';

class RequestsList extends StatelessWidget {
  final String status;
  final IconData? emptyIcon;
  final String? emptyTitle;
  final String? emptySubtitle;
  final String? ownerId;

  const RequestsList({
    super.key,
    required this.status,
    this.emptyIcon,
    this.emptyTitle,
    this.emptySubtitle,
    this.ownerId,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AdminCubit, AdminState>(
      builder: (context, state) {
        if (state is AdminLoading || state is AdminInitial) {
          return Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.deepPurple),
            ),
          );
        }

        if (state is AdminError) {
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

        List<QueryDocumentSnapshot<Map<String, dynamic>>> chalets = [];
        if (state is AdminDataLoaded) {
          chalets = state.chalets.where((doc) {
            final data = doc.data();
            bool matchesStatus = data['status'] == status;
            bool matchesOwner = true;
            if (ownerId != null && ownerId!.isNotEmpty) {
              matchesOwner = data['ownerId'] == ownerId;
            }
            return matchesStatus && matchesOwner;
          }).toList();
        }

        if (chalets.isEmpty) {
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

        return ValueListenableBuilder<SearchFilters>(
          valueListenable: HomeSearch.filters,
          builder: (context, filters, _) {
            final query = filters.query;
            final filtered = chalets.where((doc) {
              final data = doc.data();
              final lcq = query.toLowerCase();
              if (lcq.isEmpty) return true;
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
                final data = doc.data();
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
