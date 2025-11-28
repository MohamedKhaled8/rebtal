import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:rebtal/feature/owner/logic/cubit/owner_cubit.dart';

class LocationPicker extends StatefulWidget {
  const LocationPicker({super.key});

  @override
  State<LocationPicker> createState() => _LocationPickerState();
}

class _LocationPickerState extends State<LocationPicker> {
  final TextEditingController _query = TextEditingController();
  final Dio _dio = Dio();
  Timer? _debounce;
  List<Map<String, dynamic>> _results = [];
  LatLng? _selected;

  @override
  void dispose() {
    _query.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  Future<void> _search(String text) async {
    if (text.trim().isEmpty) {
      setState(() => _results = []);
      return;
    }
    try {
      final res = await _dio.get(
        'https://nominatim.openstreetmap.org/search',
        queryParameters: {'q': text, 'format': 'json', 'limit': 5},
        options: Options(headers: {'User-Agent': 'rebtal-app/1.0'}),
      );
      final List data = res.data as List;
      setState(() {
        _results = data
            .map(
              (e) => {
                'display': e['display_name'],
                'lat': double.tryParse(e['lat'] ?? '0') ?? 0,
                'lon': double.tryParse(e['lon'] ?? '0') ?? 0,
              },
            )
            .toList();
      });
    } catch (_) {}
  }

  void _onDebounced(String text) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () => _search(text));
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: _query,
          decoration: InputDecoration(
            hintText: 'ابحث عن الموقع (مثال: الرياض، السعودية)',
            prefixIcon: const Icon(Icons.search),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
          onChanged: _onDebounced,
          textInputAction: TextInputAction.search,
        ),
        const SizedBox(height: 8),
        if (_results.isNotEmpty)
          Container(
            constraints: const BoxConstraints(maxHeight: 180),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8),
              ],
            ),
            child: ListView.builder(
              itemCount: _results.length,
              itemBuilder: (context, i) {
                final item = _results[i];
                return ListTile(
                  dense: true,
                  leading: const Icon(Icons.place, color: Colors.blue),
                  title: Text(
                    item['display'],
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  onTap: () {
                    setState(() {
                      _selected = LatLng(item['lat'], item['lon']);
                      _results = [];
                      _query.text = item['display'];
                    });
                    context.read<OwnerCubit>().updateLocation(_query.text);
                  },
                );
              },
            ),
          ),
        const SizedBox(height: 12),
        if (_selected != null)
          SizedBox(
            height: 180,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: FlutterMap(
                options: MapOptions(
                  initialCenter: _selected!,
                  initialZoom: 14,
                  onTap: (tapPos, latlng) {
                    setState(() => _selected = latlng);
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
                        point: _selected!,
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
        const SizedBox(height: 12),
        Align(
          alignment: Alignment.centerLeft,
          child: ElevatedButton.icon(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: const Icon(Icons.check),
            label: const Text('تأكيد الموقع'),
          ),
        ),
      ],
    );
  }
}
