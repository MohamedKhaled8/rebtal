import 'package:flutter/material.dart';
import 'package:rebtal/core/utils/constant/color_manager.dart';
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
        color: ColorManager.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: ColorManager.gray.withOpacity(0.3), width: 1),
        boxShadow: [
          BoxShadow(
            color: ColorManager.black.withOpacity(0.05),
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
                color: ColorManager.kPrimaryGradient.colors.first,
                size: 24,
              ),
              const SizedBox(width: 10),
              Text(
                'Chalet Details',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: ColorManager.black,
                ),
              ),
            ],
          ),
          const SizedBox(height: 25),
          TextFormField(
            decoration: InputDecoration(
              labelText: 'Chalet Name',
              hintText: 'Enter your chalet name',
              prefixIcon: Icon(Icons.home, color: ColorManager.gray),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: BorderSide(
                  color: ColorManager.kPrimaryGradient.colors.first,
                  width: 2,
                ),
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter chalet name';
              }
              return null;
            },
          ),
          const SizedBox(height: 20),
          DropdownButtonFormField<String>(
            value: selectedLocation,
            decoration: InputDecoration(
              labelText: 'Geographical Location',
              prefixIcon: Icon(Icons.location_on, color: ColorManager.gray),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: BorderSide(
                  color: ColorManager.kPrimaryGradient.colors.first,
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
                return 'Please select a location';
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
                    labelText: 'Number of Rooms',
                    prefixIcon: Icon(
                      Icons.bedroom_parent,
                      color: ColorManager.gray,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: BorderSide(
                        color: ColorManager.kPrimaryGradient.colors.first,
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
                    labelText: 'Number of Bathrooms',
                    prefixIcon: Icon(
                      Icons.bathtub_outlined,
                      color: ColorManager.gray,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: BorderSide(
                        color: ColorManager.kPrimaryGradient.colors.first,
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
            ],
          ),
          const SizedBox(height: 20),
          TextFormField(
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: 'Price per Night (\$)',
              hintText: 'Enter price in USD',
              prefixIcon: Icon(Icons.attach_money, color: ColorManager.gray),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: BorderSide(
                  color: ColorManager.kPrimaryGradient.colors.first,
                  width: 2,
                ),
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter price per night';
              }
              if (double.tryParse(value) == null) {
                return 'Please enter a valid price';
              }
              return null;
            },
          ),
          const SizedBox(height: 25),
          Text(
            'Additional Features & Amenities',
            style: TextStyle(fontSize: 13, color: ColorManager.gray),
          ),
          const SizedBox(height: 8),
          TextFormField(
            maxLines: 3,
            decoration: InputDecoration(
              hintText:
                  'Describe any additional features, amenities, or special notes about your chalet...',
              prefixIcon: Icon(
                Icons.add_circle_outline,
                color: ColorManager.gray,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: BorderSide(
                  color: ColorManager.kPrimaryGradient.colors.first,
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
