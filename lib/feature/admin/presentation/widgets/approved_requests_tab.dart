import 'package:flutter/material.dart';
import 'package:rebtal/feature/admin/presentation/widgets/requests_list.dart';

class ApprovedRequestsTab extends StatelessWidget {
  const ApprovedRequestsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return const RequestsList(status: 'approved');
  }
}
