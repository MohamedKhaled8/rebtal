import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:rebtal/feature/owner/logic/cubit/owner_cubit.dart';

class InlineLocationPicker extends StatefulWidget {
  final String initialQuery;
  const InlineLocationPicker({super.key, required this.initialQuery});

  @override
  State<InlineLocationPicker> createState() => _InlineLocationPickerState();
}

class _InlineLocationPickerState extends State<InlineLocationPicker> {
  final Dio _dio = Dio();
  LatLng _selected = const LatLng(24.7136, 46.6753); // Riyadh as default
  String? _address;
  bool _loadingAddress = false;

  @override
  void initState() {
    super.initState();
    // If initialQuery present, try geocoding once
    if (widget.initialQuery.trim().isNotEmpty) {
      _reverseGeocode(_selected);
    }
  }

  Future<void> _reverseGeocode(LatLng point) async {
    setState(() => _loadingAddress = true);
    try {
      final res = await _dio.get(
        'https://nominatim.openstreetmap.org/reverse',
        queryParameters: {
          'lat': point.latitude,
          'lon': point.longitude,
          'format': 'json',
          'zoom': 16,
        },
        options: Options(headers: {'User-Agent': 'rebtal-app/1.0'}),
      );
      final display = res.data['display_name'] as String?;
      setState(() => _address = display ?? '');
      if (display != null && mounted) {
        context.read<OwnerCubit>().updateLocation(display);
      }
    } catch (_) {
    } finally {
      if (mounted) setState(() => _loadingAddress = false);
    }
  }

  void _handleTap(LatLng latlng) {
    setState(() => _selected = latlng);
    _reverseGeocode(latlng);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 220,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: FlutterMap(
              options: MapOptions(
                initialCenter: _selected,
                initialZoom: 14,
                onTap: (tapPosition, point) {
                  _handleTap(point);
                },
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.example.rebtal',
                ),
                MarkerLayer(
                  markers: [
                    Marker(
                      width: 40,
                      height: 40,
                      point: _selected,
                      child: const Icon(
                        Icons.location_on,
                        color: Colors.red,
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
            const Icon(Icons.place, size: 18, color: Colors.blueGrey),
            const SizedBox(width: 6),
            Expanded(
              child: _loadingAddress
                  ? const Text('جاري تحديد العنوان من الخريطة...')
                  : Text(
                      _address?.isNotEmpty == true
                          ? _address!
                          : 'اضغط على الخريطة لاختيار العنوان',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
            ),
          ],
        ),
      ],
    );
  }
}
