import 'package:flutter/material.dart';
import 'package:rebtal/core/utils/constant/color_manager.dart';
import 'package:rebtal/core/utils/helper/app_image_helper.dart';
import 'package:rebtal/core/utils/format/currency.dart';
import 'package:rebtal/feature/home/widget/property_detail.dart';

class PropertyListingsSection extends StatelessWidget {
  const PropertyListingsSection({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> properties = [
      {
        'name': 'Saalbach Hinterglemm',
        'location': 'Educt Street, Yogyakatta, Central Java',
        'image': 'assets/images/jpg/language.jpg',
        'price': '\$798',
        'perNight': '/ Night',
        'beds': 2,
        'baths': 2,
        'guests': 3,
        'city': 'Tokyo',
        'isFavorite': false,
      },
      {
        'name': 'Mountain View Resort',
        'location': 'Alpine Valley, Switzerland',
        'image': 'assets/images/jpg/Physics.jpg',
        'price': '\$650',
        'perNight': '/ Night',
        'beds': 3,
        'baths': 2,
        'guests': 4,
        'city': 'Tokyo',
        'isFavorite': true,
      },
      {
        'name': 'Beachfront Paradise',
        'location': 'Coastal Drive, Maldives',
        'image': 'assets/images/jpg/geography.jpg',
        'price': '\$920',
        'perNight': '/ Night',
        'beds': 4,
        'baths': 3,
        'guests': 6,
        'city': 'Tokyo',
        'isFavorite': false,
      },
      {
        'name': 'Urban Luxury Suite',
        'location': 'Downtown District, New York',
        'image': 'assets/images/jpg/history.jpg',
        'price': '\$450',
        'perNight': '/ Night',
        'beds': 1,
        'baths': 1,
        'guests': 2,
        'city': 'Tokyo',
        'isFavorite': true,
      },
    ];

    return SliverList(
      delegate: SliverChildBuilderDelegate((context, index) {
        final property = properties[index];
        return PropertyCard(property: property);
      }, childCount: properties.length),
    );
  }
}

class PropertyCard extends StatelessWidget {
  final Map<String, dynamic> property;

  const PropertyCard({super.key, required this.property});

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        // Base card
        Container(
          margin: const EdgeInsets.only(
            bottom: 32,
            left: 20,
            right: 20,
            top: 48,
          ),
          padding: const EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: 20,
          ),
          decoration: BoxDecoration(
            color: ColorManager.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: ColorManager.black.withOpacity(0.08),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Space for overlapping image
              const SizedBox(height: 70),

              // Title and price
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      property['name'],
                      style: TextStyle(
                        color: ColorManager.black,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Text(
                    CurrencyFormatter.egp(
                      double.tryParse(
                            property['price'].toString().replaceAll(
                              RegExp(r'[^0-9.]'),
                              '',
                            ),
                          ) ??
                          0,
                      withSuffixPerNight: true,
                    ),
                    style: TextStyle(
                      color: ColorManager.kPrimaryGradient.colors.first,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 8),

              // Location
              Text(
                property['location'],
                style: TextStyle(
                  color: ColorManager.gray,
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),

              const SizedBox(height: 16),

              // Details
              Row(
                children: [
                  PropertyDetail(
                    icon: Icons.bed,
                    text: '${property['beds']} Beds',
                  ),
                  const SizedBox(width: 24),
                  PropertyDetail(
                    icon: Icons.bathtub_outlined,
                    text: '${property['baths']} Baths',
                  ),
                  const SizedBox(width: 24),
                  PropertyDetail(
                    icon: Icons.people,
                    text: '${property['guests']} Guests',
                  ),
                ],
              ),
            ],
          ),
        ),

        // Floating/overlapping circular image outside the card
        Positioned(
          top: 0,
          left: 40,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: ColorManager.black.withOpacity(0.15),
                      blurRadius: 24,
                      offset: const Offset(0, 12),
                    ),
                  ],
                ),
                child: ClipOval(
                  child: AppImageHelper(
                    path: property['image'],
                    fit: BoxFit.cover,
                  ),
                ),
              ),

              // Favorite badge
              Positioned(
                bottom: -4,
                right: -4,
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: ColorManager.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: ColorManager.black.withOpacity(0.12),
                        blurRadius: 12,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Icon(
                    property['isFavorite']
                        ? Icons.favorite
                        : Icons.favorite_border,
                    color: ColorManager.red,
                    size: 18,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
