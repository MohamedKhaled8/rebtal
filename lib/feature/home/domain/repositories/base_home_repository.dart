import 'package:rebtal/feature/home/domain/entities/home_chalet_entity.dart';

abstract class BaseHomeRepository {
  Stream<List<HomeChaletEntity>> watchPublicChalets();

  Stream<List<HomeChaletEntity>> watchDiscountedChalets();

  Stream<List<HomeChaletEntity>> watchApprovedChalets();
}
