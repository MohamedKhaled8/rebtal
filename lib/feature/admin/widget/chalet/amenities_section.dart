import 'package:flutter/material.dart';
import 'package:rebtal/core/utils/config/space.dart';
import 'package:rebtal/feature/admin/widget/chalet/amenities_grid.dart';
// import 'package:screen_go/extensions/responsive_nums.dart';

class AmenitiesSection extends StatelessWidget {
  const AmenitiesSection({super.key, required this.requestData});

  final Map<String, dynamic> requestData;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 24,
            offset: const Offset(0, 6),
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFF14B8A6).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.apartment_outlined,
                  color: Color(0xFF14B8A6),
                  size: 20,
                ),
              ),
              horizintalSpace(2),
              const Text(
                'Amenities',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1F2937),
                ),
              ),
            ],
          ),

          AmenitiesGrid(requestData: requestData),
        ],
      ),
    );
  }
}
