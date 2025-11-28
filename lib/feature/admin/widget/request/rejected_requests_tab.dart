// Rejected Requests Tab
import 'package:flutter/material.dart';
import 'package:rebtal/feature/admin/widget/requests_list.dart';

class RejectedRequestsTab extends StatelessWidget {
  const RejectedRequestsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return RequestsList(status: 'rejected');
  }
}