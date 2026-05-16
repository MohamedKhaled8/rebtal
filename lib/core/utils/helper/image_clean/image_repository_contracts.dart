abstract class ProfileRepository {
  Future<void> updateProfileImage({
    required String uid,
    required String role,
    required String profileImageUrl,
  });
}

abstract class ChaletRepository {
  Future<String> createChalet(Map<String, dynamic> payload);
  Future<void> syncChalet(String chaletId, Map<String, dynamic> payload);
}

abstract class AdminNotificationGateway {
  Future<void> notifyNewChaletForReview({
    required String chaletId,
    required String ownerId,
    required String titleKey,
    required String bodyKey,
    Map<String, dynamic>? bodyParams,
  });
}
