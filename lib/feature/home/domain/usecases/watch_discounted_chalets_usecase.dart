import 'package:rebtal/feature/home/domain/entities/home_chalet_entity.dart';
import 'package:rebtal/feature/home/domain/repositories/base_home_repository.dart';

class WatchDiscountedChaletsUseCase {
  final BaseHomeRepository repository;

  WatchDiscountedChaletsUseCase(this.repository);

  Stream<List<HomeChaletEntity>> call() {
    return repository.watchDiscountedChalets();
  }
}

