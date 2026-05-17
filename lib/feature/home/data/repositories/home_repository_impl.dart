import 'package:rebtal/feature/home/data/datasources/home_remote_data_source.dart';
import 'package:rebtal/feature/home/data/mappers/home_chalet_mapper.dart';
import 'package:rebtal/feature/home/domain/entities/home_chalet_entity.dart';
import 'package:rebtal/feature/home/domain/repositories/base_home_repository.dart';

class HomeRepositoryImpl implements BaseHomeRepository {
  final HomeRemoteDataSource remoteDataSource;

  HomeRepositoryImpl({required this.remoteDataSource});

  @override
  Stream<List<HomeChaletEntity>> watchPublicChalets() {
    return remoteDataSource
        .watchPublicChalets()
        .map(HomeChaletMapper.fromSnapshot);
  }

  @override
  Stream<List<HomeChaletEntity>> watchDiscountedChalets() {
    return remoteDataSource
        .watchDiscountedChalets()
        .map(HomeChaletMapper.fromSnapshot);
  }

  @override
  Stream<List<HomeChaletEntity>> watchApprovedChalets() {
    return remoteDataSource
        .watchApprovedChalets()
        .map(HomeChaletMapper.fromSnapshot);
  }
}

