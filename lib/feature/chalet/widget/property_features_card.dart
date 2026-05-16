import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rebtal/feature/chalet/logic/cubit/services_cubit.dart';
import 'package:rebtal/core/utils/localization/translation_extension.dart';

/// Rebuild [ServicesCubit] when merged listing data changes (e.g. after edit save).
String _propertyFeaturesSignature(Map<String, dynamic> r) {
  final buf = StringBuffer();
  buf.write(r['bathrooms']);
  buf.write('|');
  final am = r['amenities'];
  if (am is List) {
    buf.write(am.map((e) => e.toString()).join(','));
  }
  const keys = <String>[
    'hasWifi',
    'hasPool',
    'hasAirConditioning',
    'hasParking',
    'hasGarden',
    'hasBBQ',
    'hasBeachView',
    'hasHousekeeping',
    'hasPetsAllowed',
    'hasGym',
    'hasKitchen',
    'hasTV',
  ];
  for (final k in keys) {
    buf.write('$k:${r[k]}|');
  }
  return buf.toString();
}

class PropertyFeaturesCard extends StatelessWidget {
  final Map<String, dynamic> requestData;
  final bool isDark;

  const PropertyFeaturesCard({
    super.key,
    required this.requestData,
    this.isDark = false,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      key: ValueKey(_propertyFeaturesSignature(requestData)),
      create: (context) => ServicesCubit()..loadAmenities(requestData),
      child: BlocBuilder<ServicesCubit, ServicesState>(
        builder: (context, state) {
          final hasAmenities =
              state is ServicesLoaded && state.amenities.isNotEmpty;
          if (!hasAmenities) {
            return const SizedBox.shrink();
          }

          return _AmenitiesList(
            amenities: state.amenities,
            isDark: isDark,
          );
        },
      ),
    );
  }
}

class _AmenitiesList extends StatefulWidget {
  final List<Map<String, dynamic>> amenities;
  final bool isDark;

  const _AmenitiesList({required this.amenities, required this.isDark});

  @override
  State<_AmenitiesList> createState() => _AmenitiesListState();
}

class _AmenitiesListState extends State<_AmenitiesList> {
  static const int _collapsedCount = 6;

  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final showButton = widget.amenities.length > _collapsedCount;
    final visibleCount =
        _isExpanded ? widget.amenities.length : _collapsedCount;
    final itemsToShow = widget.amenities.take(visibleCount).toList();
    final itemColor =
        widget.isDark ? Colors.white70 : const Color(0xFF222222);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          context.tr('chalet_what_offers'),
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w600,
            color: widget.isDark ? Colors.white : const Color(0xFF222222),
          ),
        ),
        const SizedBox(height: 24),
        AnimatedSize(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOutCubic,
          alignment: Alignment.topCenter,
          child: GridView.builder(
            padding: EdgeInsets.zero,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: 3.2,
            ),
            itemCount: itemsToShow.length,
            itemBuilder: (context, index) {
              final item = itemsToShow[index];
              return Row(
                children: [
                  Icon(
                    item['icon'] as IconData,
                    size: 24,
                    color: itemColor,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      context.tr(item['l10nKey'] as String? ?? 'chalet_pool'),
                      style: TextStyle(
                        fontSize: 16,
                        color: itemColor,
                        fontWeight: FontWeight.w400,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              );
            },
          ),
        ),
        if (showButton) ...[
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: OutlinedButton(
              onPressed: () => setState(() => _isExpanded = !_isExpanded),
              style: OutlinedButton.styleFrom(
                side: BorderSide(
                  color: widget.isDark ? Colors.white24 : Colors.black,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                foregroundColor: widget.isDark ? Colors.white : Colors.black,
              ),
              child: Text(
                _isExpanded
                    ? context.tr('chalet_show_less')
                    : context
                          .tr('chalet_show_all_amenities')
                          .replaceFirst(
                            '{}',
                            widget.amenities.length.toString(),
                          ),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}
