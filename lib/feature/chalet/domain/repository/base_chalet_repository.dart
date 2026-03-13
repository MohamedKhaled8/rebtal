import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:rebtal/core/utils/error/failure.dart';

abstract class BaseChaletRepository {
  Future<Either<Failure, List<DateTime>>> getBookedDates(String chaletId);

  Future<Either<Failure, void>> updateStatus({
    required String docId,
    required String newStatus,
  });

  Future<Either<Failure, String>> toggleBookingAvailability({
    required String docId,
    required String currentAvailability,
  });

  /// Public home listing - approved & visible chalets
  Stream<QuerySnapshot<Map<String, dynamic>>> watchApprovedVisibleChalets();

  /// Home exclusive offers - approved chalets with discount enabled
  Stream<QuerySnapshot<Map<String, dynamic>>> watchDiscountedChalets();
}

