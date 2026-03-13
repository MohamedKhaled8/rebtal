import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rebtal/feature/home/data/datasources/home_remote_data_source.dart';
import 'package:rebtal/feature/home/domain/repositories/base_home_repository.dart';

class HomeRepositoryImpl implements BaseHomeRepository {
  final HomeRemoteDataSource remoteDataSource;

  HomeRepositoryImpl({required this.remoteDataSource});

  @override
  Stream<QuerySnapshot<Map<String, dynamic>>> watchPublicChalets() {
    return remoteDataSource.watchPublicChalets();
  }

  @override
  Stream<QuerySnapshot<Map<String, dynamic>>> watchDiscountedChalets() {
    return remoteDataSource.watchDiscountedChalets();
  }
}

