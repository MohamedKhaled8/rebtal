import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:rebtal/core/utils/error/failure.dart';
import 'package:rebtal/feature/chalet/data/datasources/chalet_remote_data_source.dart';
import 'package:rebtal/feature/chalet/domain/repository/base_chalet_repository.dart';

class ChaletRepositoryImpl implements BaseChaletRepository {
  final ChaletRemoteDataSource _remoteDataSource;
 
  ChaletRepositoryImpl({required ChaletRemoteDataSource remoteDataSource})
      : _remoteDataSource = remoteDataSource;

  @override
  Future<Either<Failure, List<DateTime>>> getBookedDates(
    String chaletId,
  ) async {
    try {
      final snapshot = await _remoteDataSource.getChaletBookings(chaletId);

      final List<DateTime> bookedDates = [];

      for (var doc in snapshot.docs) {
        final data = doc.data();
        final from = (data['from'] as Timestamp?)?.toDate();
        final to = (data['to'] as Timestamp?)?.toDate();

        if (from != null && to != null) {
          DateTime current = from;
          while (current.isBefore(to) || current.isAtSameMomentAs(to)) {
            bookedDates.add(current);
            current = current.add(const Duration(days: 1));
          }
        }
      }

      bookedDates.sort();
      return Right(bookedDates);
    } on FirebaseException catch (e) {
      return Left(ServerFailure(e.message ?? e.code));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> updateStatus({
    required String docId,
    required String newStatus,
  }) async {
    try {
      await _remoteDataSource.updateChaletStatus(
        docId: docId,
        newStatus: newStatus,
      );
      return const Right(null);
    } on FirebaseException catch (e) {
      return Left(ServerFailure(e.message ?? e.code));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, String>> toggleBookingAvailability({
    required String docId,
    required String currentAvailability,
  }) async {
    try {
      final newAvailability =
          await _remoteDataSource.toggleBookingAvailability(
        docId: docId,
        currentAvailability: currentAvailability,
      );

      return Right(newAvailability);
    } on FirebaseException catch (e) {
      return Left(ServerFailure(e.message ?? e.code));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Stream<QuerySnapshot<Map<String, dynamic>>> watchApprovedVisibleChalets() {
    return _remoteDataSource.watchApprovedVisibleChalets();
  }

  @override
  Stream<QuerySnapshot<Map<String, dynamic>>> watchDiscountedChalets() {
    return _remoteDataSource.watchDiscountedChalets();
  }
}

