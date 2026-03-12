import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:rebtal/feature/owner/logic/cubit/owner_cubit.dart';
import 'package:rebtal/feature/owner/logic/cubit/owner_state.dart';
import 'package:rebtal/core/utils/constant/color_manager.dart';
import 'package:rebtal/core/app/cubit/app_cubit.dart';

class InlineLocationPicker extends StatelessWidget {
  const InlineLocationPicker({super.key});

  @override
  Widget build(BuildContext context) {
    final ownerCubit = context.read<AppCubit>().ownerCubit;

    return BlocBuilder<OwnerCubit, OwnerState>(
      bloc: ownerCubit,
      builder: (context, state) {
        final selectedLatLng =
            (state.draft.latitude != null && state.draft.longitude != null)
            ? LatLng(state.draft.latitude!, state.draft.longitude!)
            : const LatLng(24.7136, 46.6753); // Default to Riyadh if none

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 220,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: FlutterMap(
                  options: MapOptions(
                    initialCenter: selectedLatLng,
                    initialZoom: 14,
                    onTap: (tapPosition, point) {
                      ownerCubit.reverseGeocode(
                        lat: point.latitude,
                        lon: point.longitude,
                      );
                    },
                  ),
                  children: [
                    TileLayer(
                      urlTemplate:
                          'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.example.rebtal',
                    ),
                    MarkerLayer(
                      markers: [
                        Marker(
                          width: 40,
                          height: 40,
                          point: selectedLatLng,
                          child: const Icon(
                            Icons.location_on,
                            color: ColorsManager.red,
                            size: 36,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.place, size: 18, color: ColorsManager.grey),
                const SizedBox(width: 6),
                Expanded(
                  child: state.isLocationLoading
                      ? const Text('جاري تحديد العنوان من الخريطة...')
                      : Text(
                          state.draft.selectedLocation.isNotEmpty
                              ? state.draft.selectedLocation
                              : 'اضغط على الخريطة لاختيار العنوان',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}
