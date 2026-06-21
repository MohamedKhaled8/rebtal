import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rebtal/core/utils/helper/app_image_helper.dart';

/// Owner edit → admin review workflow helpers.
class ChaletEditReviewHelper {
  ChaletEditReviewHelper._();

  static const String editReviewPending = 'pending';
  static const String submissionTypeEdit = 'edit';

  static bool isEditReviewPending(Map<String, dynamic> data) =>
      data['editReviewStatus']?.toString() == editReviewPending;

  static bool isApprovedListing(Map<String, dynamic> data) =>
      data['status']?.toString().toLowerCase().trim() == 'approved';

  /// Load form from pending draft when owner re-opens edit while review is open.
  static Map<String, dynamic> dataForOwnerEditForm(Map<String, dynamic> root) {
    final pending = root['pendingEditData'];
    if (isEditReviewPending(root) && pending is Map) {
      return {...root, ...Map<String, dynamic>.from(pending)};
    }
    return Map<String, dynamic>.from(root);
  }

  /// Admin / preview: show proposed changes on top of published doc.
  static Map<String, dynamic> previewDataForAdmin(Map<String, dynamic> root) {
    final pending = root['pendingEditData'];
    if (isEditReviewPending(root) && pending is Map) {
      return {...root, ...Map<String, dynamic>.from(pending)};
    }
    return Map<String, dynamic>.from(root);
  }

  static bool shouldShowInAdminPendingTab(Map<String, dynamic> data) =>
      data['status']?.toString() == 'pending' || isEditReviewPending(data);

  static bool shouldShowAdminApproveActions(
    Map<String, dynamic> data,
    String pageStatus,
  ) =>
      pageStatus == 'pending' || isEditReviewPending(data);

  static String ownerListStatusLabel(Map<String, dynamic> data) {
    if (isEditReviewPending(data)) return 'edit_review_pending';
    return data['status']?.toString() ?? 'pending';
  }

  /// When applying an approved edit, remove day-use fields if the edit disabled them.
  static void applyDayUseFieldDeletesIfNeeded(Map<String, dynamic> merge) {
    if (merge['dayUseEnabled'] == true || merge['dayUseOnly'] == true) {
      return;
    }
    merge['dayUsePrice'] = FieldValue.delete();
    merge['dayUseAmenities'] = FieldValue.delete();
  }

  static const List<String> _compareFieldKeys = [
    'chaletName',
    'description',
    'location',
    'price',
    'bedrooms',
    'bathrooms',
    'phoneNumber',
    'email',
    'chaletArea',
    'childrenCount',
    'dayUsePrice',
    'dayUseEnabled',
    'dayUseOnly',
    'discountEnabled',
    'discountType',
    'discountValue',
  ];

  static String _displayValue(dynamic value) {
    if (value == null) return '—';
    if (value is bool) return value ? 'true' : 'false';
    if (value is num) return value.toString();
    if (value is List) return value.length.toString();
    return value.toString().trim();
  }

  /// Full detail view: pending edits for content + published meta (owner, ratings, coords).
  static Map<String, dynamic> detailViewData(
    Map<String, dynamic> root,
    String role,
  ) {
    final merged = role == 'admin'
        ? previewDataForAdmin(root)
        : role == 'owner'
        ? dataForOwnerEditForm(root)
        : Map<String, dynamic>.from(root);

    if (!isEditReviewPending(root)) return merged;

    final pending = root['pendingEditData'];
    final pendingMap = pending is Map
        ? Map<String, dynamic>.from(pending)
        : null;

    const preserveFromRoot = [
      'ownerId',
      'merchantId',
      'userId',
      'createdAt',
      'updatedAt',
      'averageRating',
      'rating',
      'ratingCount',
      'reviewCount',
      'reviews_count',
      'profileImage',
      'profileImageUrl',
    ];

    for (final key in preserveFromRoot) {
      if (pendingMap != null && pendingMap.containsKey(key)) continue;
      if (root[key] != null) merged[key] = root[key];
    }

    for (final key in ['latitude', 'longitude', 'lat', 'lon']) {
      if (merged[key] == null && root[key] != null) {
        merged[key] = root[key];
      }
    }

    return merged;
  }

  /// Field-level before/after rows for admin review UI.
  static List<({String fieldKey, String before, String after})>
  listPendingFieldChanges(Map<String, dynamic> root) {
    if (!isEditReviewPending(root)) return const [];
    final pending = root['pendingEditData'];
    if (pending is! Map) return const [];

    final proposed = Map<String, dynamic>.from(pending);
    final changes = <({String fieldKey, String before, String after})>[];

    for (final key in _compareFieldKeys) {
      if (!proposed.containsKey(key)) continue;
      final before = _displayValue(root[key]);
      final after = _displayValue(proposed[key]);
      if (before == after) continue;
      changes.add((fieldKey: key, before: before, after: after));
    }

    if (proposed.containsKey('images')) {
      final before = _imagesCountLabel(root['images']);
      final after = _imagesCountLabel(proposed['images']);
      if (before != after) {
        changes.add((fieldKey: 'images', before: before, after: after));
      }
    }

    return changes;
  }

  /// URLs added in pending edit (not in published gallery).
  static List<String> pendingNewImageUrls(Map<String, dynamic> root) {
    if (!isEditReviewPending(root)) return const [];
    final pending = root['pendingEditData'];
    if (pending is! Map) return const [];
    final published = collectChaletImageUrls(root);
    final proposed = collectChaletImageUrls(
      {...root, ...Map<String, dynamic>.from(pending)},
    );
    final publishedSet = published.toSet();
    return proposed.where((url) => !publishedSet.contains(url)).toList();
  }

  static String _imagesCountLabel(dynamic images) {
    if (images is List) return images.length.toString();
    if (images is String && images.isNotEmpty) return '1';
    return '0';
  }
}
