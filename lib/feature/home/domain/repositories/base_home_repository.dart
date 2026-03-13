import 'package:cloud_firestore/cloud_firestore.dart';

abstract class BaseHomeRepository {
  Stream<QuerySnapshot<Map<String, dynamic>>> watchPublicChalets();

  Stream<QuerySnapshot<Map<String, dynamic>>> watchDiscountedChalets();
}

