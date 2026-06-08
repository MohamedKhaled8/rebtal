import 'package:flutter/material.dart';
import 'package:rebtal/core/utils/services/app_update_service.dart';

class ForceUpdateGate extends StatefulWidget {
  final Widget child;

  const ForceUpdateGate({super.key, required this.child});

  @override
  State<ForceUpdateGate> createState() => _ForceUpdateGateState();
}

class _ForceUpdateGateState extends State<ForceUpdateGate> {
  @override
  void initState() {
    super.initState();
    // Trigger the in-app update check immediately on app startup
    AppUpdateService.checkForUpdate();
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
