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
      child: Padding(
        padding: EdgeInsets.zero,
        child: BlocBuilder<ServicesCubit, ServicesState>(
          builder: (context, state) {
            final hasAmenities =
                state is ServicesLoaded && state.amenities.isNotEmpty;
            if (!hasAmenities) {
              return const SizedBox.shrink();
            }

            return StatefulBuilder(
              builder: (context, setState) {
                // Determine if we need to show the "Show all" button
                // (Only if > 5 items)
                // If isExpanded is true (we need to track this state), show all.
                // Since StatefulBuilder doesn't hold state across rebuilds of PARENT,
                // but holds it for itself: we need a variable *outside* the builder?
                // No, StatefulBuilder's state is preserved as long as it's in the tree.
                // Wait, StatefulBuilder just provides setState. It doesn't hold custom vars itself unless we initialize them?
                // Actually, I can't hold `isExpanded` inside StatefulBuilder easily without a closure variable that persists?
                // Better to convert `PropertyFeaturesCard` to `StatefulWidget`.
                // BUT, sticking to stateless for minimize diffs: I'll use a local `ValueNotifier` or similar if I can, but converting to StatefulWidget is cleaner.
                // Let's assume I can't easily convert to Stateful in one go without replacing the whole file header.
                // I will use a custom wrapper or just `StatefulBuilder` with a boolean variable defined in `build`? No, that resets on rebuild.
                // Screw it, I'll replace the CLASS definition to be StatefulWidget.
                return _AmenitiesList(
                  amenities: state.amenities,
                  isDark: isDark,
                );
              },
            );
          },
        ),
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

class _AmenitiesListState extends State<_AmenitiesList>
    with SingleTickerProviderStateMixin {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final showButton = widget.amenities.length > 5;
    final visibleCount = _isExpanded ? widget.amenities.length : 5;
    final itemsToShow = widget.amenities.take(visibleCount).toList();

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

        // List with implicit animation (Size/Fade could be added but simpler update first)
        // List with animation
        AnimatedSize(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          alignment: Alignment.topCenter,
          child: ListView.separated(
            key: ValueKey(
              _isExpanded,
            ), // Helps with animation context? Not strictly needed for AnimatedSize but good
            padding: EdgeInsets.zero, // Remove padding to avoid jump
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: itemsToShow.length,
            separatorBuilder: (context, index) => const SizedBox(height: 16),
            itemBuilder: (context, index) {
              final item = itemsToShow[index];
              return Row(
                children: [
                  Icon(
                    item['icon'] as IconData,
                    size: 24,
                    color: widget.isDark
                        ? Colors.white70
                        : const Color(0xFF222222),
                  ),
                  const SizedBox(width: 16),
                  Text(
                    context.tr(item['l10nKey'] as String? ?? 'chalet_pool'),
                    style: TextStyle(
                      fontSize: 16,
                      color: widget.isDark
                          ? Colors.white70
                          : const Color(0xFF222222),
                      fontWeight: FontWeight.w400,
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
              onPressed: () {
                setState(() {
                  _isExpanded = !_isExpanded;
                });
              },
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
