import 'package:rebtal/feature/home/domain/entities/home_chalet_entity.dart';
import 'package:rebtal/feature/home/domain/repositories/base_home_repository.dart';

class WatchApprovedChaletsUseCase {
  WatchApprovedChaletsUseCase(this._repository);

  final BaseHomeRepository _repository;

  Stream<List<HomeChaletEntity>> call() => _repository.watchApprovedChalets();
}
