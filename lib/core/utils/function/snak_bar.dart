import 'package:rebtal/core/utils/helper/snack_bar_helper.dart';
import 'package:rebtal/core/Router/export_routes.dart';
import 'package:flutter/material.dart'; // Added for BuildContext
import 'package:quickalert/quickalert.dart'; // Added for QuickAlertType

void showMessage(BuildContext context, String message, QuickAlertType type) {
  if (type == QuickAlertType.success) {
    SnackBarHelper.showSuccess(context, message);
  } else if (type == QuickAlertType.error) {
    SnackBarHelper.showError(context, message);
  } else if (type == QuickAlertType.warning) {
    SnackBarHelper.showWarning(context, message);
  } else {
    SnackBarHelper.showInfo(context, message);
  }
}
