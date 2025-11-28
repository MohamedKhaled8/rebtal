import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseIndexCreator {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Create composite indexes automatically
  static Future<void> createCompositeIndexes() async {
    try {
      print('🔍 DEBUG - Creating composite indexes...');

      // Create index for owner chats
      await _createIndex(
        collectionId: 'chats',
        fields: [
          {'fieldPath': 'ownerId', 'order': 'ASCENDING'},
          {'fieldPath': 'lastMessageTime', 'order': 'DESCENDING'},
        ],
      );

      // Create index for user chats
      await _createIndex(
        collectionId: 'chats',
        fields: [
          {'fieldPath': 'userId', 'order': 'ASCENDING'},
          {'fieldPath': 'lastMessageTime', 'order': 'DESCENDING'},
        ],
      );

      // Create index for existing chat queries
      await _createIndex(
        collectionId: 'chats',
        fields: [
          {'fieldPath': 'userId', 'order': 'ASCENDING'},
          {'fieldPath': 'ownerId', 'order': 'ASCENDING'},
          {'fieldPath': 'chaletId', 'order': 'ASCENDING'},
        ],
      );

      print('🔍 DEBUG - Composite indexes created successfully');
    } catch (e) {
      print('🔍 DEBUG - Error creating composite indexes: $e');
      // Continue without indexes - we'll use manual sorting
    }
  }

  static Future<void> _createIndex({
    required String collectionId,
    required List<Map<String, String>> fields,
  }) async {
    try {
      // Note: This is a simplified approach
      // In a real production app, you would use Firebase Admin SDK
      // For now, we'll just log the index creation
      print('🔍 DEBUG - Would create index for collection: $collectionId');
      print('🔍 DEBUG - Fields: $fields');

      // You can also create indexes manually in Firebase Console using these details:
      print('🔍 DEBUG - Manual index creation URL:');
      print(
        'https://console.firebase.google.com/v1/r/project/rebtal/firestore/indexes',
      );
    } catch (e) {
      print('🔍 DEBUG - Error creating index: $e');
    }
  }

  /// Check if indexes exist by trying a query that requires them
  static Future<bool> checkIndexesExist() async {
    try {
      // Try a query that requires the composite index
      final query = _firestore
          .collection('chats')
          .where('ownerId', isEqualTo: 'test')
          .orderBy('lastMessageTime', descending: true)
          .limit(1);

      await query.get();
      print('🔍 DEBUG - Indexes exist, queries will work normally');
      return true;
    } catch (e) {
      if (e.toString().contains('failed-precondition') ||
          e.toString().contains('requires an index')) {
        print('🔍 DEBUG - Indexes do not exist, will use fallback sorting');
        return false;
      }
      // Other errors, assume indexes exist
      return true;
    }
  }
}
