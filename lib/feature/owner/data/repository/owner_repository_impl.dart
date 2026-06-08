import 'dart:async';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:rebtal/core/utils/error/failure.dart';
import 'package:rebtal/feature/owner/domain/entities/chalet_entity.dart';
import 'package:rebtal/feature/owner/domain/repository/base_owner_repository.dart';
import 'package:rebtal/feature/owner/data/model/chalet_model.dart';
import 'package:rebtal/core/utils/services/notification_service.dart';
import 'package:rebtal/core/models/notification_type.dart';
import 'package:rebtal/core/utils/helper/cloudinary_upload_helper.dart';

class OwnerRepositoryImpl implements BaseOwnerRepository {
  final FirebaseFirestore _firestore;

  OwnerRepositoryImpl({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  @override
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
    bool? dayUseEnabled,
  }) async {
    try {
      // 1. Create Document Reference to get ID
      final docRef = _firestore.collection('chalets').doc();
      final String chaletId = docRef.id;

      List<String> imageUrls = [];
      String? profileImageUrl;

      // 2. Upload Profile Image to Cloudinary (if exists)
      if (profileImage != null) {
        try {
          profileImageUrl = await CloudinaryUploadHelper.uploadImage(
            profileImage,
          );
        } catch (e) {
          profileImageUrl = null;
        }
      }

      // 3. Upload Gallery Images to Cloudinary
      int failCount = 0;

      final uploadResults = await Future.wait(
        images.map((img) async {
          try {
            final url = await CloudinaryUploadHelper.uploadImage(img);
            return url;
          } catch (e) {
            failCount++;
            return null;
          }
        }),
        eagerError: false,
      );

      imageUrls.addAll(uploadResults.whereType<String>());

      final List<String> allImages = [...imageUrls];

      if (profileImageUrl != null) {
        allImages.insert(0, profileImageUrl);
      }

      // User picked files in the app — do not save a listing with zero URLs
      // (silent Cloudinary failures used to produce empty `images` in Firestore).
      final bool userExpectedPhotos =
          images.isNotEmpty || profileImage != null;
      if (userExpectedPhotos && allImages.isEmpty) {
        return Left(
          ServerFailure(
            'فشل رفع الصور (Cloudinary). تحقق من الإنترنت، أو من إعدادات '
            'الرفع في لوحة Cloudinary، ثم أعد المحاولة. لم يُحفظ الشاليه.',
          ),
        );
      }

      // 4. Create Model
      final ChaletModel newChalet = ChaletModel(
        id: chaletId,
        chaletName: chalet.chaletName,
        location: chalet.location,
        description: chalet.description,
        ownerId: chalet.ownerId,
        ownerName: chalet.ownerName,
        price: chalet.price,
        bedrooms: chalet.bedrooms,
        bathrooms: chalet.bathrooms,
        images: allImages, // قد تكون فارغة إذا فشل رفع الصور
        amenities: chalet.amenities,
        latitude: chalet.latitude,
        longitude: chalet.longitude,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        status: ChaletStatus.pending,
        bookingAvailability: BookingAvailability.available,
        isVisible: true,
        chaletArea: chalet.chaletArea,
        childrenCount: chalet.childrenCount,
        discountEnabled: chalet.discountEnabled,
        discountType: chalet.discountType,
        discountValue: chalet.discountValue,
        features: chalet.features,
      );

      // 5. Save to Firestore - حفظ البيانات دائماً مع جميع الحقول الإضافية
      try {
        final dataMap = newChalet.toMap();

        // إضافة الحقول الإضافية من draft (مثل helper_image.dart)
        if (phoneNumber != null && phoneNumber.isNotEmpty) {
          dataMap['phoneNumber'] = phoneNumber;
        }
        if (email != null && email.isNotEmpty) {
          dataMap['email'] = email;
        }
        // حفظ merchantName و ownerName (للتوافق)
        if (merchantName != null && merchantName.isNotEmpty) {
          dataMap['merchantName'] = merchantName;
        }
        // إذا لم يكن merchantName موجوداً، استخدم ownerName كـ fallback
        if ((merchantName == null || merchantName.isEmpty) &&
            chalet.ownerName.isNotEmpty) {
          dataMap['merchantName'] = chalet.ownerName;
        }
        if (isAvailable != null) {
          dataMap['isAvailable'] = isAvailable;
        } else {
          // إذا لم يكن isAvailable موجوداً، استخدم bookingAvailability
          dataMap['isAvailable'] =
              chalet.bookingAvailability == BookingAvailability.available;
        }
        if (availableFrom != null) {
          dataMap['availableFrom'] = availableFrom.toIso8601String();
        }
        if (availableTo != null) {
          dataMap['availableTo'] = availableTo.toIso8601String();
        }

        // Add new fields (chaletArea, childrenCount, discounts, features)
        if (chaletArea != null) dataMap['chaletArea'] = chaletArea;
        if (childrenCount != null) dataMap['childrenCount'] = childrenCount;
        if (discountEnabled != null)
          dataMap['discountEnabled'] = discountEnabled;
        if (discountType != null) dataMap['discountType'] = discountType;
        if (discountValue != null) dataMap['discountValue'] = discountValue;
        if (features != null) dataMap['features'] = features;
        if (dayUseEnabled != null) dataMap['dayUseEnabled'] = dayUseEnabled;

        // إضافة lat و lon للتوافق مع LocationMapCard
        if (chalet.latitude != null) {
          dataMap['lat'] = chalet.latitude;
        }
        if (chalet.longitude != null) {
          dataMap['lon'] = chalet.longitude;
        }

        await docRef.set(dataMap);

        // إرسال إشعارات للأدمن
        try {
          final adminsSnapshot = await _firestore.collection('Admin').get();
          final adminIds = adminsSnapshot.docs.map((d) => d.id).toSet();
          final merchantTrimmed = merchantName?.trim();
          final displayName =
              (merchantTrimmed != null && merchantTrimmed.isNotEmpty)
                  ? merchantTrimmed
                  : chalet.ownerName;

          for (final adminId in adminIds) {
            await NotificationService().sendNotification(
              userId: adminId,
              titleKey: 'notif_new_chalet_review',
              bodyKey: 'notif_new_chalet_body',
              bodyParams: {
                'name': displayName,
                'chalet': chalet.chaletName,
              },
              type: NotificationType.chaletSubmission,
              relatedId: chaletId,
              data: {
                'chaletId': chaletId,
                'ownerId': chalet.ownerId,
                'ownerName': chalet.ownerName,
              },
            );
          }
        } catch (e) {}

        // إذا فشل رفع بعض الصور، نعطي تحذير لكن نكمل العملية
        if (allImages.isEmpty) {
          return Right(chaletId);
        } else if (failCount > 0) {
          return Right(chaletId);
        } else {
          return Right(chaletId);
        }
      } catch (e) {
        return Left(ServerFailure('فشل حفظ البيانات: $e'));
      }
    } on FirebaseException catch (e) {
      return Left(ServerFailure('Firebase Error: ${e.message ?? e.code}'));
    } catch (e) {
      return Left(ServerFailure('Failed to add chalet: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<dynamic>>> getOwnerChalets(String ownerId) async {
    try {
      // Try with index first, if fails use simpler query
      QuerySnapshot querySnapshot;
      try {
        querySnapshot = await _firestore
            .collection('chalets')
            .where('ownerId', isEqualTo: ownerId)
            .orderBy('createdAt', descending: true)
            .get();
      } on FirebaseException catch (e) {
        if (e.code == 'failed-precondition') {
          querySnapshot = await _firestore
              .collection('chalets')
              .where('ownerId', isEqualTo: ownerId)
              .get();

          // Sort in memory
          final docs = querySnapshot.docs.toList()
            ..sort((a, b) {
              final aData = a.data() as Map<String, dynamic>?;
              final bData = b.data() as Map<String, dynamic>?;
              if (aData == null || bData == null) return 0;

              final aTimeRaw = aData['createdAt'];
              final bTimeRaw = bData['createdAt'];
              
              DateTime? aTime;
              if (aTimeRaw is Timestamp) {
                aTime = aTimeRaw.toDate();
              } else if (aTimeRaw is String) aTime = DateTime.tryParse(aTimeRaw);
              
              DateTime? bTime;
              if (bTimeRaw is Timestamp) {
                bTime = bTimeRaw.toDate();
              } else if (bTimeRaw is String) bTime = DateTime.tryParse(bTimeRaw);

              if (aTime == null || bTime == null) return 0;
              return bTime.compareTo(aTime); // descending
            });

          // ✅ Return raw Map data to preserve ALL fields from Firestore
          final List<dynamic> chalets = docs.map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            data['id'] = doc.id; // Add document ID
            // Return the raw data as Map instead of converting to ChaletModel
            // This preserves extra fields like availableFrom, availableTo, etc.
            return data;
          }).toList();

          return Right(chalets);
        } else {
          rethrow;
        }
      }

      // ✅ Return raw Map data to preserve ALL fields from Firestore
      final List<dynamic> chalets = querySnapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id; // Add document ID
        // Return the raw data as Map instead of converting to ChaletModel
        // This preserves extra fields like availableFrom, availableTo, etc.
        return data;
      }).toList();

      return Right(chalets);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Stream<List<dynamic>> getOwnerChaletsStream(String ownerId) {
    // Using a simpler query without orderBy to avoid 'failed-precondition' (missing index) errors.
    // Soring is done in memory.
    return _firestore
        .collection('chalets')
        .where('ownerId', isEqualTo: ownerId)
        .snapshots()
        .map((snapshot) {
          final docs = snapshot.docs.toList()
            ..sort((a, b) {
              final aData = a.data();
              final bData = b.data();

              final aTimeRaw = aData['createdAt'];
              final bTimeRaw = bData['createdAt'];
              
              DateTime? aTime;
              if (aTimeRaw is Timestamp) {
                aTime = aTimeRaw.toDate();
              } else if (aTimeRaw is String) {
                aTime = DateTime.tryParse(aTimeRaw);
              }
              
              DateTime? bTime;
              if (bTimeRaw is Timestamp) {
                bTime = bTimeRaw.toDate();
              } else if (bTimeRaw is String) {
                bTime = DateTime.tryParse(bTimeRaw);
              }

              if (aTime == null || bTime == null) return 0;
              return bTime.compareTo(aTime); // descending
            });

          return docs.map((doc) {
            final data = doc.data();
            data['id'] = doc.id;
            return data as dynamic;
          }).toList();
        });
  }

  @override
  Future<Either<Failure, String>> uploadChaletImage(File image) async {
    try {
      final url = await CloudinaryUploadHelper.uploadImage(image);
      return Right(url);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> updateChaletFields(
    String chaletId,
    Map<String, dynamic> fields,
  ) async {
    try {
      // Avoid passing null values: on some Firestore versions null removes fields.
      final safe = <String, dynamic>{};
      fields.forEach((k, v) {
        if (v != null) safe[k] = v;
      });
      await _firestore.collection('chalets').doc(chaletId).update(safe);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> updateChalet(ChaletEntity chalet) async {
    try {
      final model = ChaletModel(
        id: chalet.id,
        chaletName: chalet.chaletName,
        location: chalet.location,
        description: chalet.description,
        ownerId: chalet.ownerId,
        ownerName: chalet.ownerName,
        price: chalet.price,
        bedrooms: chalet.bedrooms,
        bathrooms: chalet.bathrooms,
        images: chalet.images,
        amenities: chalet.amenities,
        latitude: chalet.latitude,
        longitude: chalet.longitude,
        createdAt: chalet.createdAt,
        updatedAt: DateTime.now(),
        status: chalet.status,
        bookingAvailability: chalet.bookingAvailability,
        isVisible: chalet.isVisible,
      );

      await _firestore
          .collection('chalets')
          .doc(chalet.id)
          .update(model.toMap());
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteChalet(String chaletId) async {
    try {
      await _firestore.collection('chalets').doc(chaletId).delete();
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
