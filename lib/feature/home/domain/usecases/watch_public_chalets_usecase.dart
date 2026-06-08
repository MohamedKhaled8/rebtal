import 'package:rebtal/feature/home/domain/entities/home_chalet_entity.dart';
import 'package:rebtal/feature/home/domain/repositories/base_home_repository.dart';

class WatchPublicChaletsUseCase {
  final BaseHomeRepository repository;

  WatchPublicChaletsUseCase(this.repository);

  Stream<List<HomeChaletEntity>> call({int? limit}) {
    return repository.watchPublicChalets(limit: limit);
  }
}

