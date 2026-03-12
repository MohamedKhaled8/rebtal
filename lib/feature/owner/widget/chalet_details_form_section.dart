import 'package:flutter/material.dart';
import 'package:rebtal/core/utils/constant/color_manager.dart';
import 'package:rebtal/core/utils/localization/translation_extension.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ChaletDetailsFormSection extends StatelessWidget {
  final String selectedLocation;
  final List<String> locations;
  final bool isAvailable;
  final ValueChanged<String?> onLocationChanged;
  final ValueChanged<bool> onIsAvailableChanged;

  const ChaletDetailsFormSection({
    super.key,
    required this.selectedLocation,
    required this.locations,
    required this.isAvailable,
    required this.onLocationChanged,
    required this.onIsAvailableChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: ColorsManager.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: ColorsManager.gray.withOpacity(0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: ColorsManager.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.info_outline,
                color: ColorsManager.kPrimaryGradient.colors.first,
                size: 24,
              ),
              const SizedBox(width: 10),
              Text(
                context.tr('owner_chalet_details'),
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: ColorsManager.black,
                ),
              ),
            ],
          ),
          const SizedBox(height: 25),
          TextFormField(
            decoration: InputDecoration(
              labelText: context.tr('owner_chalet_name'),
              hintText: context.tr('owner_chalet_name_hint'),
              prefixIcon: Icon(Icons.home, color: ColorsManager.gray),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: BorderSide(
                  color: ColorsManager.kPrimaryGradient.colors.first,
                  width: 2,
                ),
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return context.tr('owner_enter_chalet_name');
              }
              return null;
            },
          ),
          const SizedBox(height: 20),
          DropdownButtonFormField<String>(
            initialValue: selectedLocation,
            decoration: InputDecoration(
              labelText: context.tr('owner_location'),
              prefixIcon: Icon(Icons.location_on, color: ColorsManager.gray),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: BorderSide(
                  color: ColorsManager.kPrimaryGradient.colors.first,
                  width: 2,
                ),
              ),
            ),
            items: locations
                .map(
                  (location) => DropdownMenuItem<String>(
                    value: location,
                    child: Text(location),
                  ),
                )
                .toList(),
            onChanged: onLocationChanged,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return context.tr('owner_select_location_error');
              }
              return null;
            },
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: context.tr('owner_num_rooms'),
                    prefixIcon: Icon(
                      Icons.bedroom_parent,
                      color: ColorsManager.gray,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: BorderSide(
                        color: ColorsManager.kPrimaryGradient.colors.first,
                        width: 2,
                      ),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'Required';
                    if (int.tryParse(value) == null) return 'Invalid number';
                    return null;
                  },
                ),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: TextFormField(
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: context.tr('owner_num_bathrooms'),
                    prefixIcon: Icon(
                      Icons.bathtub_outlined,
                      color: ColorsManager.gray,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: BorderSide(
                        color: ColorsManager.kPrimaryGradient.colors.first,
                        width: 2,
                      ),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty)
                      return context.tr('common_required');
                    if (int.tryParse(value) == null)
                      return context.tr('common_invalid_number');
                    return null;
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          TextFormField(
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: context.tr('owner_price_per_night_usd'),
              hintText: context.tr('owner_price_hint_usd'),
              prefixIcon: Icon(Icons.attach_money, color: ColorsManager.gray),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: BorderSide(
                  color: ColorsManager.kPrimaryGradient.colors.first,
                  width: 2,
                ),
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return context.tr('owner_enter_price_error');
              }
              if (double.tryParse(value) == null) {
                return context.tr('owner_valid_price_error');
              }
              return null;
            },
          ),
          const SizedBox(height: 25),
          Text(
            context.tr('owner_extra_features'),
            style: TextStyle(fontSize: 13, color: ColorsManager.gray),
          ),
          const SizedBox(height: 8),
          TextFormField(
            maxLines: 3,
            decoration: InputDecoration(
              hintText: context.tr('owner_extra_features_hint'),
              prefixIcon: Icon(
                Icons.add_circle_outline,
                color: ColorsManager.gray,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: BorderSide(
                  color: ColorsManager.kPrimaryGradient.colors.first,
                  width: 2,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Function to submit chalet details with ownerId
  void submitChaletDetails(Map<String, dynamic> chaletData) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      chaletData['ownerId'] = user.uid; // Add ownerId to chalet data
      print('Submitting chalet details for ownerId: ${user.uid}');
      try {
        await FirebaseFirestore.instance.collection('chalets').add(chaletData);
        print('Chalet details submitted successfully');
      } catch (e) {
        print('Error submitting chalet details: $e');
      }
    } else {
      print('User not logged in');
    }
  }

  // Function to fetch chalets for the current user
  Stream<QuerySnapshot> getUserChalets() {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      print('Fetching chalets for ownerId: ${user.uid}');
      return FirebaseFirestore.instance
          .collection('chalets')
          .where('ownerId', isEqualTo: user.uid) // Filter chalets by ownerId
          .snapshots();
    } else {
      print('User not logged in');
      throw Exception('User not logged in');
    }
  }

  // Function to clean invalid chalets (without ownerId)
  void cleanInvalidChalets() async {
    print('Cleaning invalid chalets...');
    final chalets = await FirebaseFirestore.instance
        .collection('chalets')
        .get();
    for (var chalet in chalets.docs) {
      if (!chalet.data().containsKey('ownerId')) {
        print('Deleting chalet with id: ${chalet.id} (no ownerId)');
        await chalet.reference.delete();
      }
    }
    print('Invalid chalets cleaned successfully');
  }

  // Function to ensure ownerId is added to chalets
  void ensureOwnerIdInChalets() async {
    print('Ensuring ownerId exists in chalets...');
    final chalets = await FirebaseFirestore.instance
        .collection('chalets')
        .get();
    for (var chalet in chalets.docs) {
      final data = chalet.data();
      if (!data.containsKey('ownerId') || (data['ownerId'] as String).isEmpty) {
        final user = FirebaseAuth.instance.currentUser;
        if (user != null) {
          await chalet.reference.update({'ownerId': user.uid});
          print('Added ownerId for chalet with id: ${chalet.id}');
        } else {
          print('Skipped chalet with id: ${chalet.id} (User not logged in)');
        }
      }
    }
    print('OwnerId ensured for all chalets.');
  }
}
