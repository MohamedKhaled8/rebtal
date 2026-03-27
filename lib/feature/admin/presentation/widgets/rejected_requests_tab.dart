import 'package:flutter/material.dart';
import 'package:rebtal/feature/admin/presentation/widgets/requests_list.dart';

class RejectedRequestsTab extends StatelessWidget {
  const RejectedRequestsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return const RequestsList(status: 'rejected');
  }
}
