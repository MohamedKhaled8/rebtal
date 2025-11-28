// Pending Requests Tab
import 'package:flutter/material.dart';
import 'package:rebtal/feature/admin/widget/requests_list.dart';

class PendingRequestsTab extends StatelessWidget {
  const PendingRequestsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return RequestsList(status: 'pending');
  }
}