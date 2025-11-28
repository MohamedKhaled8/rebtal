// Approved Requests Tab
import 'package:flutter/material.dart';
import 'package:rebtal/feature/admin/widget/requests_list.dart' show RequestsList;

class ApprovedRequestsTab extends StatelessWidget {
  const ApprovedRequestsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return RequestsList(status: 'approved');
  }
}