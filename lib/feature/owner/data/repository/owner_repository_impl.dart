import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:http/http.dart' as http;
import 'package:rebtal/core/utils/error/failure.dart';
import 'package:rebtal/feature/owner/domain/entities/chalet_entity.dart';
import 'package:rebtal/feature/owner/domain/repository/base_owner_repository.dart';
import 'package:rebtal/feature/owner/data/model/chalet_model.dart';
import 'package:rebtal/core/utils/services/notification_service.dart';
import 'package:rebtal/core/models/notification_type.dart';

class OwnerRepositoryImpl implements BaseOwnerRepository {
  final FirebaseFirestore _firestore;

  // Cloudinary configuration
  static const String _cloudName = "dwobtaa6a";
  static const String _apiKey = "249478428416757";
  static const String _uploadPreset = "Mmkkkkk";

  OwnerRepositoryImpl({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  /// Upload image to Cloudinary with retry logic for network errors
  Future<String> _uploadToCloudinary(
    File imageFile, {
    int maxRetries = 2,
  }) async {
    for (int attempt = 1; attempt <= maxRetries; attempt++) {
      try {
        final uri = Uri.parse(
          "https://api.cloudinary.com/v1_1/$_cloudName/image/upload",
        );

        final request = http.MultipartRequest('POST', uri)
          ..fields['upload_preset'] = _uploadPreset
          ..fields['api_key'] = _apiKey
          ..files.add(
            await http.MultipartFile.fromPath('file', imageFile.path),
          );

        // Add timeout for connection
        final response = await request.send().timeout(
          const Duration(seconds: 30),
          onTimeout: () {
            throw TimeoutException(
              'Connection timeout - please check your internet connection',
            );
          },
        );

        if (response.statusCode == 200) {
          final respStr = await response.stream.bytesToString();
          final jsonResp = jsonDecode(respStr);
          return jsonResp['secure_url'];
        } else {
          final respStr = await response.stream.bytesToString();
          print("🌐 Cloudinary error body: $respStr");
          throw Exception(
            "Cloudinary upload failed with status: ${response.statusCode}",
          );
        }
      } on SocketException catch (e) {
        print("🌐 Network error (attempt $attempt/$maxRetries): $e");
        if (attempt == maxRetries) {
          throw Exception(
            'فشل الاتصال بالإنترنت. يرجى التحقق من الاتصال والمحاولة مرة أخرى.',
          );
        }
        // Wait before retry
        await Future.delayed(Duration(seconds: attempt * 2));
      } on TimeoutException catch (e) {
        print("🌐 Timeout error (attempt $attempt/$maxRetries): $e");
        if (attempt == maxRetries) {
          throw Exception(
            'انتهت مهلة الاتصال. يرجى التحقق من الاتصال والمحاولة مرة أخرى.',
          );
        }
        await Future.delayed(Duration(seconds: attempt * 2));
      } catch (e) {
        print("🌐 Cloudinary upload error (attempt $attempt/$maxRetries): $e");
        if (attempt == maxRetries) {
          // Check if it's a network error
          final errorStr = e.toString().toLowerCase();
          if (errorStr.contains('socket') ||
              errorStr.contains('network') ||
              errorStr.contains('host lookup') ||
              errorStr.contains('connection')) {
            throw Exception(
              'فشل الاتصال بالإنترنت. يرجى التحقق من الاتصال والمحاولة مرة أخرى.',
            );
          }
          rethrow;
        }
        await Future.delayed(Duration(seconds: attempt * 2));
      }
    }
    throw Exception('Failed to upload after $maxRetries attempts');
  }

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
  }) async {
    try {
      print(
        '📦 Using Cloudinary for image uploads (no Firebase Storage needed)',
      );

      // 1. Create Document Reference to get ID
      final docRef = _firestore.collection('chalets').doc();
      final String chaletId = docRef.id;

      List<String> imageUrls = [];
      String? profileImageUrl;

      // 2. Upload Profile Image to Cloudinary (if exists)
      if (profileImage != null) {
        try {
          profileImageUrl = await _uploadToCloudinary(profileImage);
        } catch (e) {
          print('❌ Failed to upload profile image to Cloudinary: $e');
        }
      }

      // 3. Upload Gallery Images to Cloudinary - مع معالجة أخطاء أفضل
      print('📤 Starting upload of ${images.length} images to Cloudinary...');
      int successCount = 0;
      int failCount = 0;

      // Upload images with individual error handling
      final uploadResults = await Future.wait(
        images.map((img) async {
          try {
            final url = await _uploadToCloudinary(img);
            successCount++;
            print(
              '✅ Image uploaded successfully ($successCount/${images.length})',
            );
            return url;
          } catch (e) {
            failCount++;
            print('❌ Failed to upload image ${failCount}: $e');
            return null; // Return null on error instead of throwing
          }
        }),
        eagerError: false, // Don't stop on first error
      );

      // Filter out null values (failed uploads)
      imageUrls.addAll(uploadResults.whereType<String>());

      if (failCount > 0) {
        print('⚠️ Upload summary: $successCount succeeded, $failCount failed');
      } else {
        print('✅ All $successCount images uploaded successfully!');
      }

      // Build final images list (even if empty - we'll save the chalet anyway)
      final List<String> allImages = [...imageUrls];

      // Add profile image as first image if available
      if (profileImageUrl != null) {
        allImages.insert(0, profileImageUrl);
      }

      // 4. Create Model - حفظ البيانات حتى لو لم ترفع أي صورة
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

        // إضافة lat و lon للتوافق مع LocationMapCard
        if (chalet.latitude != null) {
          dataMap['lat'] = chalet.latitude;
        }
        if (chalet.longitude != null) {
          dataMap['lon'] = chalet.longitude;
        }

        // Debug: Print all data being saved
        print('📝 Saving chalet data to Firestore:');
        print('   - ID: $chaletId');
        print('   - ownerId: ${dataMap['ownerId']}');
        print('   - ownerName: ${dataMap['ownerName']}');
        print('   - merchantName: ${dataMap['merchantName']}');
        print('   - phoneNumber: ${dataMap['phoneNumber']}');
        print('   - email: ${dataMap['email']}');
        print('   - bookingAvailability: ${dataMap['bookingAvailability']}');
        print('   - isAvailable: ${dataMap['isAvailable']}');
        print('   - availableFrom: ${dataMap['availableFrom']}');
        print('   - availableTo: ${dataMap['availableTo']}');
        print(
          '   - latitude: ${dataMap['latitude']}, longitude: ${dataMap['longitude']}',
        );
        print('   - lat: ${dataMap['lat']}, lon: ${dataMap['lon']}');
        print('   - status: ${dataMap['status']}');
        print('   - chaletName: ${dataMap['chaletName']}');
        print('   - images count: ${(dataMap['images'] as List).length}');

        await docRef.set(dataMap);
        print('✅ Chalet saved to Firestore successfully (ID: $chaletId)');

        // ✅ إرسال إشعارات للأدمن
        try {
          final adminsSnapshot = await _firestore.collection('Admin').get();

          print(
            '📧 Sending notifications to ${adminsSnapshot.docs.length} admin(s)',
          );

          for (var adminDoc in adminsSnapshot.docs) {
            await NotificationService().sendNotification(
              userId: adminDoc.id,
              title: 'شاليه جديد قيد المراجعة 🏗️',
              body:
                  'قام ${chalet.ownerName} برفع شاليه جديد (${chalet.chaletName}) وهو بانتظار موافقتك.',
              type: NotificationType.chaletSubmission,
              relatedId: chaletId,
              data: {
                'chaletId': chaletId,
                'ownerId': chalet.ownerId,
                'ownerName': chalet.ownerName,
              },
            );
          }

          print('✅ Notifications sent to all admins successfully');
        } catch (e) {
          print('⚠️ Error sending admin notifications: $e');
          // لا نوقف العملية إذا فشل إرسال الإشعارات
        }

        // إذا فشل رفع بعض الصور، نعطي تحذير لكن نكمل العملية
        if (allImages.isEmpty) {
          print('⚠️ Chalet saved without images - images can be added later');
          return Right(chaletId);
        } else if (failCount > 0) {
          print(
            '⚠️ Chalet saved with ${allImages.length} images (${failCount} failed)',
          );
          return Right(chaletId);
        } else {
          print(
            '✅ Chalet saved with all ${allImages.length} images successfully',
          );
          return Right(chaletId);
        }
      } catch (e) {
        print('❌ Failed to save chalet to Firestore: $e');
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
          // Index not created yet - use simpler query without orderBy
          print('⚠️ Firestore index not found, using simpler query');
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

              final aTime = aData['createdAt'] as Timestamp?;
              final bTime = bData['createdAt'] as Timestamp?;
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

              final aTime = aData['createdAt'] as Timestamp?;
              final bTime = bData['createdAt'] as Timestamp?;
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
