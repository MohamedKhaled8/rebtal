import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rebtal/feature/home/domain/entities/home_chalet_entity.dart';

class HomeChaletMapper {
  static HomeChaletEntity fromDoc(
    QueryDocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    return HomeChaletEntity(id: doc.id, data: doc.data());
  }

  static List<HomeChaletEntity> fromSnapshot(
    QuerySnapshot<Map<String, dynamic>> snapshot,
  ) {
    return snapshot.docs.map(fromDoc).toList(growable: false);
  }
}
