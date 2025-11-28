import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';
import 'package:rebtal/core/Router/export_routes.dart';

void showMessage(BuildContext context, String message, QuickAlertType type) {
  QuickAlert.show(
    context: context,
    type: type,
    text: message,
  );
}
