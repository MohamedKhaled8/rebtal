import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:rebtal/feature/owner/logic/cubit/owner_cubit.dart';
import 'package:rebtal/feature/owner/logic/cubit/owner_state.dart';
import 'package:rebtal/core/utils/constant/color_manager.dart';
import 'package:rebtal/core/app/cubit/app_cubit.dart';

class LocationPicker extends StatelessWidget {
  const LocationPicker({super.key});

  @override
  Widget build(BuildContext context) {
    // Access cubit via AppCubit as per project pattern
    final ownerCubit = context.read<AppCubit>().ownerCubit;
    Timer? debounce;

    return BlocBuilder<OwnerCubit, OwnerState>(
      bloc: ownerCubit,
      builder: (context, state) {
        final selectedLatLng =
            (state.draft.latitude != null && state.draft.longitude != null)
            ? LatLng(state.draft.latitude!, state.draft.longitude!)
            : null;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              decoration: InputDecoration(
                hintText: 'ابحث عن الموقع (مثال: الرياض، السعودية)',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: state.isLocationLoading
                    ? const Padding(
                        padding: EdgeInsets.all(12.0),
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onChanged: (text) {
                debounce?.cancel();
                debounce = Timer(const Duration(milliseconds: 500), () {
                  ownerCubit.searchLocation(text);
                });
              },
              textInputAction: TextInputAction.search,
            ),
            const SizedBox(height: 8),
            if (state.locationResults.isNotEmpty)
              Container(
                constraints: const BoxConstraints(maxHeight: 180),
                decoration: BoxDecoration(
                  color: ColorsManager.white,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: ColorsManager.black.withOpacity(0.05),
                      blurRadius: 8,
                    ),
                  ],
                ),
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: state.locationResults.length,
                  itemBuilder: (context, i) {
                    final item = state.locationResults[i];
                    return ListTile(
                      dense: true,
                      leading: Icon(
                        Icons.place,
                        color: ColorsManager.primaryColor,
                      ),
                      title: Text(
                        item['display'],
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      onTap: () {
                        ownerCubit.updateGeo(
                          lat: item['lat'],
                          lon: item['lon'],
                          address: item['display'],
                        );
                        ownerCubit.clearLocationResults();
                        FocusScope.of(context).unfocus();
                      },
                    );
                  },
                ),
              ),
            const SizedBox(height: 12),
            if (selectedLatLng != null)
              SizedBox(
                height: 180,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: FlutterMap(
                    options: MapOptions(
                      initialCenter: selectedLatLng,
                      initialZoom: 14,
                      onTap: (tapPos, latlng) {
                        ownerCubit.reverseGeocode(
                          lat: latlng.latitude,
                          lon: latlng.longitude,
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
            const SizedBox(height: 12),
            if (selectedLatLng != null ||
                state.draft.selectedLocation.isNotEmpty)
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: ColorsManager.grey50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  state.draft.selectedLocation,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerLeft,
              child: ElevatedButton.icon(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.check),
                label: const Text('تأكيد الموقع'),
              ),
            ),
          ],
        );
      },
    );
  }
}
