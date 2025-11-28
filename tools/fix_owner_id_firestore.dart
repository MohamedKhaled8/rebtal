import 'package:cloud_firestore/cloud_firestore.dart';

Future<void> fixOwnerIdInFirestore() async {
  final collectionRef = FirebaseFirestore.instance.collection('chalets');

  try {
    final querySnapshot = await collectionRef.get();

    for (var doc in querySnapshot.docs) {
      final data = doc.data();

      if (data['ownerId'] == null || (data['ownerId'] as String).isEmpty) {
        final updatedOwnerId = data['userId'] ?? '';

        if (updatedOwnerId.isNotEmpty) {
          await doc.reference.update({'ownerId': updatedOwnerId});
          print('Updated ownerId for document: ${doc.id}');
        } else {
          print('Skipped document: ${doc.id} (No valid ownerId or userId)');
        }
      }
    }

    print('Fix completed successfully.');
  } catch (e) {
    print('Error fixing ownerId in Firestore: $e');
  }
}

void main() async {
  await fixOwnerIdInFirestore();
}
