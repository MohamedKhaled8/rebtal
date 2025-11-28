
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:rebtal/core/utils/constant/color_manager.dart';

class ImageUploadSection extends StatelessWidget {
  final List<File> images;
  final VoidCallback onAdd;
  final ValueChanged<int> onRemove;
  const ImageUploadSection({
    super.key,
    required this.images,
    required this.onAdd,
    required this.onRemove,
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
                Icons.photo_library,
                color: ColorManager.kPrimaryGradient.colors.first,
                size: 24,
              ),
              const SizedBox(width: 10),
              Text(
                'Chalet Photos',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: ColorManager.black,
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          Row(
            children: [
              Expanded(
                child: Text(
                  'Upload clear, high-quality photos of your chalet (minimum 3 photos)',
                  style: TextStyle(color: ColorManager.gray, fontSize: 14),
                ),
              ),
              if (images.isNotEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: ColorManager.kPrimaryGradient.colors.first.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${images.length} ${images.length == 1 ? 'photo' : 'photos'}',
                    style: TextStyle(
                      color: ColorManager.kPrimaryGradient.colors.first,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 20),
          if (images.isNotEmpty)
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: 1,
              ),
              itemCount: images.length,
              itemBuilder: (context, index) {
                return Stack(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15),
                        image: DecorationImage(
                          image: FileImage(images[index]),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    Positioned(
                      top: 5,
                      right: 5,
                      child: GestureDetector(
                        onTap: () => onRemove(index),
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: ColorManager.red,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.close,
                            color: ColorManager.white,
                            size: 16,
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          const SizedBox(height: 20),
          Container(
            width: double.infinity,
            height: 120,
            decoration: BoxDecoration(
              color: ColorManager.kPrimaryGradient.colors.first.withOpacity(
                0.1,
              ),
              borderRadius: BorderRadius.circular(15),
              border: Border.all(
                color: ColorManager.kPrimaryGradient.colors.first.withOpacity(
                  0.3,
                ),
                width: 2,
                style: BorderStyle.solid,
              ),
            ),
            child: InkWell(
              onTap: onAdd,
              borderRadius: BorderRadius.circular(15),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.add_photo_alternate,
                    color: ColorManager.kPrimaryGradient.colors.first,
                    size: 40,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Add Chalet Photos',
                    style: TextStyle(
                      color: ColorManager.kPrimaryGradient.colors.first,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Tap to select multiple photos',
                    style: TextStyle(
                      color: ColorManager.gray,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}