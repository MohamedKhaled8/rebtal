import 'package:flutter/foundation.dart';

/// Simple shared search notifier for HomeScreen lists.
class HomeSearch {
  static final ValueNotifier<String> q = ValueNotifier<String>('');
}
