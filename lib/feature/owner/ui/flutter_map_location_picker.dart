import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:geolocator/geolocator.dart';
import 'package:dio/dio.dart';

class FlutterMapLocationPicker extends StatefulWidget {
  final String? initialAddress;
  final double? initialLat;
  final double? initialLon;

  const FlutterMapLocationPicker({
    super.key,
    this.initialAddress,
    this.initialLat,
    this.initialLon,
  });

  @override
  State<FlutterMapLocationPicker> createState() =>
      _FlutterMapLocationPickerState();
}

class _FlutterMapLocationPickerState extends State<FlutterMapLocationPicker> {
  final MapController _mapController = MapController();
  final Dio _dio = Dio();
  final TextEditingController _searchController = TextEditingController();

  LatLng _selectedLocation = const LatLng(30.0444, 31.2357); // Cairo default
  String? _selectedAddress;
  bool _isLoading = false;
  bool _isSearching = false;
  List<Map<String, dynamic>> _searchSuggestions = [];
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    if (widget.initialLat != null && widget.initialLon != null) {
      _selectedLocation = LatLng(widget.initialLat!, widget.initialLon!);
      _selectedAddress = widget.initialAddress;
      _searchController.text = widget.initialAddress ?? '';
    }
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    _mapController.dispose();
    super.dispose();
  }

  Future<void> _reverseGeocode(LatLng position) async {
    setState(() => _isLoading = true);
    try {
      final response = await _dio.get(
        'https://nominatim.openstreetmap.org/reverse',
        queryParameters: {
          'lat': position.latitude,
          'lon': position.longitude,
          'format': 'json',
          'zoom': 18,
          'addressdetails': 1,
        },
        options: Options(headers: {'User-Agent': 'rebtal-app/1.0'}),
      );

      if (response.statusCode == 200) {
        setState(() {
          _selectedAddress = response.data['display_name'];
          if (!_isSearching) {
            _searchController.text = _selectedAddress ?? '';
          }
        });
      }
    } catch (e) {
      debugPrint('Reverse geocode error: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _searchLocation(String query) async {
    if (query.trim().isEmpty) {
      setState(() => _searchSuggestions = []);
      return;
    }

    setState(() => _isSearching = true);

    try {
      final response = await _dio.get(
        'https://nominatim.openstreetmap.org/search',
        queryParameters: {
          'q': query,
          'format': 'json',
          'limit': 8,
          'addressdetails': 1,
          'countrycodes': 'eg', // Focus on Egypt
        },
        options: Options(headers: {'User-Agent': 'rebtal-app/1.0'}),
      );

      if (response.statusCode == 200) {
        final List data = response.data;
        setState(() {
          _searchSuggestions = data
              .map(
                (e) => {
                  'display': e['display_name'],
                  'lat': double.tryParse(e['lat'] ?? '0') ?? 0,
                  'lon': double.tryParse(e['lon'] ?? '0') ?? 0,
                },
              )
              .toList();
        });
      }
    } catch (e) {
      debugPrint('Search error: $e');
    } finally {
      setState(() => _isSearching = false);
    }
  }

  void _onSearchChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () {
      _searchLocation(value);
    });
  }

  void _selectSuggestion(Map<String, dynamic> suggestion) {
    final lat = suggestion['lat'] as double;
    final lon = suggestion['lon'] as double;
    final position = LatLng(lat, lon);

    _mapController.move(position, 16);

    setState(() {
      _selectedLocation = position;
      _searchSuggestions = [];
      _searchController.text = suggestion['display'];
      _isSearching = false;
    });

    _reverseGeocode(position);
  }

  Future<void> _getCurrentLocation() async {
    // Check and request permission
    final status = await Permission.location.request();

    if (status.isDenied) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('يجب السماح بالوصول للموقع'),
            backgroundColor: Colors.orange,
          ),
        );
      }
      return;
    }

    if (status.isPermanentlyDenied) {
      if (mounted) {
        final shouldOpen = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: const Row(
              children: [
                Icon(Icons.location_off, color: Colors.orange),
                SizedBox(width: 8),
                Text('إذن الموقع مطلوب'),
              ],
            ),
            content: const Text(
              'يرجى تفعيل إذن الموقع من الإعدادات لاستخدام هذه الميزة',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('إلغاء'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                ),
                child: const Text('فتح الإعدادات'),
              ),
            ],
          ),
        );

        if (shouldOpen == true) {
          await openAppSettings();
        }
      }
      return;
    }

    setState(() => _isLoading = true);

    try {
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 10),
        ),
      );

      final latLng = LatLng(position.latitude, position.longitude);

      _mapController.move(latLng, 16);

      setState(() {
        _selectedLocation = latLng;
      });

      await _reverseGeocode(latLng);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تم تحديد موقعك الحالي'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      debugPrint('Get location error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تعذر الحصول على الموقع. تأكد من تفعيل GPS'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _onMapTap(TapPosition tapPosition, LatLng position) {
    setState(() {
      _selectedLocation = position;
    });
    _reverseGeocode(position);
  }

  void _confirmLocation() {
    if (_selectedAddress == null || _selectedAddress!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('الرجاء اختيار موقع أولاً'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    Navigator.pop(context, {
      'address': _selectedAddress,
      'lat': _selectedLocation.latitude,
      'lon': _selectedLocation.longitude,
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Flutter Map with OpenStreetMap tiles
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _selectedLocation,
              initialZoom: 14,
              minZoom: 5,
              maxZoom: 18,
              onTap: _onMapTap,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.rebtal',
                maxZoom: 19,
              ),
              MarkerLayer(
                markers: [
                  Marker(
                    point: _selectedLocation,
                    width: 50,
                    height: 50,
                    child: const Icon(
                      Icons.location_on,
                      size: 50,
                      color: Colors.red,
                    ),
                  ),
                ],
              ),
            ],
          ),

          // Top bar with search and back button
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.black.withOpacity(0.3), Colors.transparent],
                ),
              ),
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          // Back button
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 8,
                                ),
                              ],
                            ),
                            child: IconButton(
                              onPressed: () => Navigator.pop(context),
                              icon: const Icon(Icons.arrow_back),
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(width: 12),

                          // Search bar
                          Expanded(
                            child: Material(
                              elevation: 4,
                              borderRadius: BorderRadius.circular(12),
                              child: TextField(
                                controller: _searchController,
                                decoration: InputDecoration(
                                  hintText: 'ابحث عن موقع...',
                                  prefixIcon: const Icon(
                                    Icons.search,
                                    color: Colors.blue,
                                  ),
                                  suffixIcon: _isSearching || _isLoading
                                      ? const Padding(
                                          padding: EdgeInsets.all(12),
                                          child: SizedBox(
                                            width: 20,
                                            height: 20,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                            ),
                                          ),
                                        )
                                      : _searchController.text.isNotEmpty
                                      ? IconButton(
                                          icon: const Icon(Icons.clear),
                                          onPressed: () {
                                            _searchController.clear();
                                            setState(() {
                                              _searchSuggestions = [];
                                              _isSearching = false;
                                            });
                                          },
                                        )
                                      : null,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide.none,
                                  ),
                                  filled: true,
                                  fillColor: Colors.white,
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 14,
                                  ),
                                ),
                                onChanged: _onSearchChanged,
                              ),
                            ),
                          ),
                        ],
                      ),

                      // Search suggestions
                      if (_searchSuggestions.isNotEmpty)
                        Container(
                          margin: const EdgeInsets.only(top: 8),
                          constraints: const BoxConstraints(maxHeight: 250),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.15),
                                blurRadius: 12,
                              ),
                            ],
                          ),
                          child: ListView.separated(
                            shrinkWrap: true,
                            itemCount: _searchSuggestions.length,
                            separatorBuilder: (context, index) =>
                                const Divider(height: 1),
                            itemBuilder: (context, index) {
                              final suggestion = _searchSuggestions[index];
                              return ListTile(
                                leading: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Colors.blue.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Icon(
                                    Icons.place,
                                    color: Colors.blue,
                                    size: 20,
                                  ),
                                ),
                                title: Text(
                                  suggestion['display'],
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(fontSize: 14),
                                ),
                                onTap: () => _selectSuggestion(suggestion),
                              );
                            },
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Selected address display at bottom
          if (_selectedAddress != null && _selectedAddress!.isNotEmpty)
            Positioned(
              bottom: 100,
              left: 16,
              right: 16,
              child: Material(
                elevation: 8,
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.blue.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.place,
                          color: Colors.blue,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'الموقع المحدد',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _selectedAddress!,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

          // Confirm button
          Positioned(
            bottom: 20,
            left: 16,
            right: 16,
            child: ElevatedButton.icon(
              onPressed: _confirmLocation,
              icon: const Icon(Icons.check_circle),
              label: const Text(
                'تأكيد الموقع',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 8,
              ),
            ),
          ),
        ],
      ),

      // Floating action buttons
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          // Current location button
          FloatingActionButton(
            heroTag: 'current_location',
            onPressed: _getCurrentLocation,
            backgroundColor: Colors.white,
            child: _isLoading
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.my_location, color: Colors.blue),
          ),
          const SizedBox(height: 12),

          // Zoom in button
          FloatingActionButton(
            heroTag: 'zoom_in',
            mini: true,
            onPressed: () {
              final currentZoom = _mapController.camera.zoom;
              _mapController.move(
                _mapController.camera.center,
                currentZoom + 1,
              );
            },
            backgroundColor: Colors.white,
            child: const Icon(Icons.add, color: Colors.black87),
          ),
          const SizedBox(height: 8),

          // Zoom out button
          FloatingActionButton(
            heroTag: 'zoom_out',
            mini: true,
            onPressed: () {
              final currentZoom = _mapController.camera.zoom;
              _mapController.move(
                _mapController.camera.center,
                currentZoom - 1,
              );
            },
            backgroundColor: Colors.white,
            child: const Icon(Icons.remove, color: Colors.black87),
          ),
        ],
      ),
    );
  }
}
