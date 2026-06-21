import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:rebtal/core/utils/error/failure.dart';
import 'package:rebtal/feature/owner/domain/entities/chalet_entity.dart';
import 'package:rebtal/feature/owner/domain/repository/base_owner_repository.dart';

class AddChaletUseCase {
  final BaseOwnerRepository repository;

  AddChaletUseCase(this.repository);

  Future<Either<Failure, String>> call(AddChaletParams params) async {
    return await repository.addChalet(
      chalet: params.chalet,
      images: params.images,
      profileImage: params.profileImage,
      phoneNumber: params.phoneNumber,
      email: params.email,
      merchantName: params.merchantName,
      isAvailable: params.isAvailable,
      availableFrom: params.availableFrom,
      availableTo: params.availableTo,
      chaletArea: params.chaletArea,
      childrenCount: params.childrenCount,
      discountEnabled: params.discountEnabled,
      discountType: params.discountType,
      discountValue: params.discountValue,
      features: params.features,
      dayUseEnabled: params.dayUseEnabled,
      dayUseOnly: params.dayUseOnly,
      dayUsePrice: params.dayUsePrice,
      dayUseAmenities: params.dayUseAmenities,
      pricingPeriods: params.pricingPeriods,
    );
  }
}

class AddChaletParams extends Equatable {
  final ChaletEntity chalet;
  final List<File> images;
  final File? profileImage;
  final String? phoneNumber;
  final String? email;
  final String? merchantName;
  final bool? isAvailable;
  final DateTime? availableFrom;
  final DateTime? availableTo;
  final String? chaletArea;
  final int? childrenCount;
  final bool? discountEnabled;
  final String? discountType;
  final String? discountValue;
  final List<String>? features;
  final bool? dayUseEnabled;
  final bool? dayUseOnly;
  final double? dayUsePrice;
  final List<String>? dayUseAmenities;
  final List<Map<String, dynamic>>? pricingPeriods;

  const AddChaletParams({
    required this.chalet,
    required this.images,
    this.profileImage,
    this.phoneNumber,
    this.email,
    this.merchantName,
    this.isAvailable,
    this.availableFrom,
    this.availableTo,
    this.chaletArea,
    this.childrenCount,
    this.discountEnabled,
    this.discountType,
    this.discountValue,
    this.features,
    this.dayUseEnabled,
    this.dayUseOnly,
    this.dayUsePrice,
    this.dayUseAmenities,
    this.pricingPeriods,
  });

  @override
  List<Object?> get props => [
    chalet,
    images,
    profileImage,
    phoneNumber,
    email,
    merchantName,
    isAvailable,
    availableFrom,
    availableTo,
    chaletArea,
    childrenCount,
    discountEnabled,
    discountType,
    discountValue,
    features,
    dayUseEnabled,
    dayUseOnly,
    dayUsePrice,
    dayUseAmenities,
    pricingPeriods,
  ];
}
