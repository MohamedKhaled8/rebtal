import 'package:flutter/material.dart';
import 'package:rebtal/feature/admin/presentation/widgets/requests_list.dart';

class PendingRequestsTab extends StatelessWidget {
  const PendingRequestsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return const RequestsList(status: 'pending');
  }
}
