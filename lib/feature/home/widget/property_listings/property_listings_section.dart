import 'package:flutter/material.dart';
import 'package:rebtal/core/utils/constant/color_manager.dart';
import 'package:rebtal/core/utils/helper/app_image_helper.dart';
import 'package:rebtal/core/utils/format/currency.dart';
import 'package:rebtal/feature/home/widget/property_listings/property_detail.dart';

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
        'rating': 4.8,
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
        'rating': 4.6,
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
        'rating': 4.9,
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
        'rating': 4.5,
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
    return Container(
      margin: const EdgeInsets.only(left: 20, right: 20, bottom: 20),
      decoration: BoxDecoration(
        color: ColorsManager.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: ColorsManager.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            child: Stack(
              children: [
                SizedBox(
                  height: 180,
                  width: double.infinity,
                  child: AppImageHelper(
                    path: property['image'],
                    fit: BoxFit.cover,
                  ),
                ),
                Positioned(
                  top: 12,
                  right: 12,
                  child: GestureDetector(
                    onTap: () {},
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.9),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        property['isFavorite']
                            ? Icons.favorite
                            : Icons.favorite_border,
                        color: property['isFavorite']
                            ? ColorsManager.red
                            : Colors.grey,
                        size: 20,
                      ),
                    ),
                  ),
                ),
                if (property['rating'] != null)
                  Positioned(
                    top: 12,
                    left: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.6),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.star, color: Colors.amber, size: 14),
                          const SizedBox(width: 4),
                          Text(
                            '${property['rating']}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        property['name'],
                        style: const TextStyle(
                          color: ColorsManager.black,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Text(
                      CurrencyFormatter.egp(
                        context,
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
                        color: ColorsManager.kPrimaryGradient.colors.first,
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(
                      Icons.location_on_outlined,
                      size: 14,
                      color: ColorsManager.gray,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        property['location'],
                        style: const TextStyle(
                          color: ColorsManager.gray,
                          fontSize: 13,
                          fontWeight: FontWeight.w400,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    PropertyDetail(
                      icon: Icons.bed_outlined,
                      text: '${property['beds']}',
                      compact: true,
                    ),
                    const SizedBox(width: 16),
                    PropertyDetail(
                      icon: Icons.bathtub_outlined,
                      text: '${property['baths']}',
                      compact: true,
                    ),
                    const SizedBox(width: 16),
                    PropertyDetail(
                      icon: Icons.people_outline,
                      text: '${property['guests']}',
                      compact: true,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
