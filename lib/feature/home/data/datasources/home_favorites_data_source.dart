import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rebtal/core/utils/helper/app_image_helper.dart';

abstract class HomeFavoritesDataSource {
  Future<bool> isFavorite({
    required String userId,
    required String chaletId,
  });

  Future<void> addFavorite({
    required String userId,
    required String chaletId,
    required Map<String, dynamic> chaletData,
  });

  Future<void> removeFavorite({
    required String userId,
    required String chaletId,
  });
}

class HomeFavoritesDataSourceImpl implements HomeFavoritesDataSource {
  HomeFavoritesDataSourceImpl({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  @override
  Future<bool> isFavorite({
    required String userId,
    required String chaletId,
  }) async {
    final doc = await _firestore
        .collection('users')
        .doc(userId)
        .collection('favorites')
        .doc(chaletId)
        .get();
    return doc.exists;
  }

  @override
  Future<void> addFavorite({
    required String userId,
    required String chaletId,
    required Map<String, dynamic> chaletData,
  }) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('favorites')
        .doc(chaletId)
        .set({
      'chaletId': chaletId,
      'name': chaletData['chaletName'] ?? 'Unnamed Chalet',
      'location': chaletData['location'] ?? '',
      'image': resolveChaletCoverImageUrl(chaletData),
      'price': chaletData['price'],
      'createdAt': FieldValue.serverTimestamp(),
      'chaletData': chaletData,
    });
  }

  @override
  Future<void> removeFavorite({
    required String userId,
    required String chaletId,
  }) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('favorites')
        .doc(chaletId)
        .delete();
  }
}
