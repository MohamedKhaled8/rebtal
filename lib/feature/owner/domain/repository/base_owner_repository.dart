import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:rebtal/core/utils/error/failure.dart';
import 'package:rebtal/feature/owner/domain/entities/chalet_entity.dart';

abstract class BaseOwnerRepository {
  Future<Either<Failure, String>> addChalet({
    required ChaletEntity chalet,
    required List<File> images,
    required File? profileImage,
    // Additional data from draft
    String? phoneNumber,
    String? email,
    String? merchantName,
    bool? isAvailable,
    DateTime? availableFrom,
    DateTime? availableTo,
    String? chaletArea,
    int? childrenCount,
    bool? discountEnabled,
    String? discountType,
    String? discountValue,
    List<String>? features,
  });

  // Returns List<dynamic> to preserve all Firestore fields (availableFrom, availableTo, etc.)
  // Each item is a Map<String, dynamic> with all data from Firestore
  Future<Either<Failure, List<dynamic>>> getOwnerChalets(String ownerId);

  Stream<List<dynamic>> getOwnerChaletsStream(String ownerId);

  Future<Either<Failure, void>> updateChalet(ChaletEntity chalet);

  Future<Either<Failure, void>> deleteChalet(String chaletId);
}
