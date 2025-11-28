import 'dart:io';

import 'package:rebtal/core/Router/export_routes.dart';
import 'package:rebtal/core/utils/constant/color_manager.dart';

class ProfilePictureSection extends StatelessWidget {
  final File? profileImage;
  final VoidCallback onTap;
  const ProfilePictureSection({
    super.key,
    required this.profileImage,
    required this.onTap,
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
                Icons.person,
                color: ColorManager.kPrimaryGradient.colors.first,
                size: 24,
              ),
              const SizedBox(width: 10),
              Text(
                'Profile Picture',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: ColorManager.black,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Center(
            child: GestureDetector(
              onTap: onTap,
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: profileImage != null
                      ? Colors.transparent
                      : ColorManager.kPrimaryGradient.colors.first.withOpacity(
                          0.1,
                        ),
                  borderRadius: BorderRadius.circular(60),
                  border: Border.all(
                    color: profileImage != null
                        ? ColorManager.kPrimaryGradient.colors.first
                        : ColorManager.kPrimaryGradient.colors.first
                              .withOpacity(0.3),
                    width: 2,
                    style: BorderStyle.solid,
                  ),
                ),
                child: profileImage != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(58),
                        child: Image.file(profileImage!, fit: BoxFit.cover),
                      )
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.add_a_photo,
                            color: ColorManager.kPrimaryGradient.colors.first,
                            size: 40,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Add Photo',
                            style: TextStyle(
                              color: ColorManager.kPrimaryGradient.colors.first,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
              ),
            ),
          ),
          const SizedBox(height: 15),
          Text(
            'Upload a clear profile picture to build trust with guests',
            style: TextStyle(color: ColorManager.gray, fontSize: 14),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
