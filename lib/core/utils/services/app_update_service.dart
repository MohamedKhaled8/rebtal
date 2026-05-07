import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:package_info_plus/package_info_plus.dart';

class AppUpdateInfo {
  final bool mustUpdate;
  final String? updateUrl;
  final int? minBuildNumber;
  final int currentBuildNumber;

  const AppUpdateInfo({
    required this.mustUpdate,
    required this.currentBuildNumber,
    this.updateUrl,
    this.minBuildNumber,
  });
}

class AppUpdateService {
  static const String _collection = 'app_config';
  static const String _docId = 'mobile';

  Future<AppUpdateInfo> checkForRequiredUpdate() async {
    final packageInfo = await PackageInfo.fromPlatform();
    final currentBuild = int.tryParse(packageInfo.buildNumber) ?? 0;

    try {
      final doc = await FirebaseFirestore.instance
          .collection(_collection)
          .doc(_docId)
          .get(const GetOptions(source: Source.serverAndCache));

      final data = doc.data() ?? const <String, dynamic>{};
      final minBuild = _asInt(data['minBuildNumber']);
      final forceEnabled = data['forceUpdate'] == true;

      final mustUpdate =
          forceEnabled && minBuild != null && currentBuild < minBuild;

      return AppUpdateInfo(
        mustUpdate: mustUpdate,
        currentBuildNumber: currentBuild,
        minBuildNumber: minBuild,
        updateUrl: _resolveStoreUrl(data),
      );
    } catch (_) {
      return AppUpdateInfo(mustUpdate: false, currentBuildNumber: currentBuild);
    }
  }

  int? _asInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value);
    return null;
  }

  String? _resolveStoreUrl(Map<String, dynamic> data) {
    if (kIsWeb) return data['updateUrlWeb']?.toString();
    if (Platform.isAndroid) return data['updateUrlAndroid']?.toString();
    if (Platform.isIOS) return data['updateUrlIos']?.toString();
    return data['updateUrl']?.toString();
  }
}
