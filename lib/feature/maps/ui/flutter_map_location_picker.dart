import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:geolocator/geolocator.dart';
import 'package:dio/dio.dart';
import 'package:geocoding/geocoding.dart';
import 'package:rebtal/core/utils/constant/color_manager.dart';
import 'package:rebtal/core/utils/helper/snack_bar_helper.dart';
import 'package:rebtal/core/utils/theme/dynamic_theme_manager.dart';

class FlutterGoogleMapLocationPicker extends StatefulWidget {
  final String? initialAddress;
  final double? initialLat;
  final double? initialLon;

  const FlutterGoogleMapLocationPicker({
    super.key,
    this.initialAddress,
    this.initialLat,
    this.initialLon,
  });

  @override
  State<FlutterGoogleMapLocationPicker> createState() =>
      _FlutterGoogleMapLocationPickerState();
}

class _FlutterGoogleMapLocationPickerState
    extends State<FlutterGoogleMapLocationPicker> {
  // ✅ Google Maps Controller
  final Completer<GoogleMapController> _controller = Completer();

  // ✅ Google Maps API Key (Used ONLY for Map Rendering now)

  final Dio _dio = Dio();
  final TextEditingController _searchController = TextEditingController();

  LatLng _selectedLocation = const LatLng(30.0444, 31.2357); // Cairo default
  String? _selectedAddress;
  bool _isLoading = false;
  bool _isSearching = false;
  List<Map<String, dynamic>> _searchSuggestions = [];
  Timer? _debounce;
  Set<Marker> _markers = {};

  @override
  void initState() {
    super.initState();
    if (widget.initialLat != null && widget.initialLon != null) {
      _selectedLocation = LatLng(widget.initialLat!, widget.initialLon!);
      _selectedAddress = widget.initialAddress;
      _searchController.text = widget.initialAddress ?? '';
      _updateMarker(_selectedLocation);
    } else {
      _getCurrentLocation();
    }
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _updateMarker(LatLng position) {
    setState(() {
      _markers = {
        Marker(
          markerId: const MarkerId('selected_location'),
          position: position,
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
        ),
      };
    });
  }

  Future<void> _reverseGeocode(LatLng position) async {
    setState(() => _isLoading = true);
    try {
      // ✅ محاولة استخدام خدمة الهاتف الداخلية (مجانية وسريعة)
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        // تجميع العنوان بشكل منسق
        String address = [
          place.street,
          place.subLocality,
          place.locality,
          place.administrativeArea,
          place.country,
        ].where((element) => element != null && element.isNotEmpty).join('، ');

        if (address.isEmpty) {
          address = '${position.latitude}, ${position.longitude}';
        }

        setState(() {
          _selectedAddress = address;
          if (!_isSearching) {
            _searchController.text = address;
          }
        });
      } else {
        setState(() {
          _selectedAddress =
              'موقع محدد (${position.latitude.toStringAsFixed(4)}, ${position.longitude.toStringAsFixed(4)})';
        });
      }
    } catch (e) {
      debugPrint('Reverse geocode error: $e');
      setState(() {
        _selectedAddress =
            'موقع محدد (${position.latitude.toStringAsFixed(4)}, ${position.longitude.toStringAsFixed(4)})';
      });
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
      // ✅ استخدام OpenStreetMap (Nominatim) للبحث المجاني والمفتوح
      // هذا يعمل دائماً ولا يحتاج مفتاح API خاص
      final response = await _dio.get(
        'https://nominatim.openstreetmap.org/search',
        queryParameters: {
          'q': query,
          'format': 'json',
          'limit': 5,
          'addressdetails': 1,
          'countrycodes': 'eg', // التركيز على مصر
        },
        options: Options(headers: {'User-Agent': 'rebtal-app/1.0'}),
      );

      if (response.statusCode == 200) {
        final data = response.data as List;
        setState(() {
          _searchSuggestions = data
              .map(
                (e) => {
                  'display': e['display_name'],
                  'lat': double.parse(e['lat']),
                  'lon': double.parse(e['lon']),
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

  // دالة اختيار النتيجة وتحريك الخريطة
  void _selectSuggestion(Map<String, dynamic> suggestion) async {
    final lat = suggestion['lat'] as double;
    final lon = suggestion['lon'] as double;
    final position = LatLng(lat, lon);

    // إخفاء لوحة المفاتيح
    FocusScope.of(context).unfocus();

    // تحريك كاميرا جوجل ماب
    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newLatLngZoom(position, 17));

    setState(() {
      _selectedLocation = position;
      _searchController.text = suggestion['display'];
      _searchSuggestions = [];
      _isSearching = false;
      _selectedAddress = suggestion['display'];
    });

    _updateMarker(position);
  }

  void _onSearchChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () {
      _searchLocation(value);
    });
  }

  Future<void> _getCurrentLocation() async {
    final status = await Permission.location.request();

    if (status.isDenied) {
      if (mounted) {
        SnackBarHelper.showWarning(context, 'يجب السماح بالوصول للموقع');
      }
      return;
    }

    if (status.isPermanentlyDenied) {
      if (mounted) {
        await openAppSettings();
      }
      return;
    }

    setState(() => _isLoading = true);

    try {
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );

      final latLng = LatLng(position.latitude, position.longitude);

      final GoogleMapController controller = await _controller.future;
      controller.animateCamera(CameraUpdate.newLatLngZoom(latLng, 16));

      setState(() {
        _selectedLocation = latLng;
      });
      _updateMarker(latLng);

      await _reverseGeocode(latLng);
    } catch (e) {
      debugPrint('Get location error: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _onMapTap(LatLng position) {
    setState(() {
      _selectedLocation = position;
    });
    _updateMarker(position);
    _reverseGeocode(position);
  }

  void _confirmLocation() {
    // قبول الموقع حتى لو لم يتم تحميل الاسم النصي
    Navigator.pop(context, {
      'address':
          _selectedAddress ??
          '${_selectedLocation.latitude}, ${_selectedLocation.longitude}',
      'lat': _selectedLocation.latitude,
      'lon': _selectedLocation.longitude,
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = DynamicThemeManager.isDarkMode(context);

    return Scaffold(
      body: Stack(
        children: [
          // ✅ Google Map Widget
          GoogleMap(
            mapType: MapType.normal,
            initialCameraPosition: CameraPosition(
              target: _selectedLocation,
              zoom: 14.4746,
            ),
            onMapCreated: (GoogleMapController controller) {
              _controller.complete(controller);
            },
            onTap: _onMapTap,
            markers: _markers,
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
            zoomControlsEnabled: false,
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
                  colors: [
                    ColorManager.black.withOpacity(0.3),
                    ColorManager.transparent,
                  ],
                ),
              ),
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              color: isDark
                                  ? ColorManager.darkGrey2D2D44
                                  : ColorManager.white,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: ColorManager.black.withOpacity(0.1),
                                  blurRadius: 8,
                                ),
                              ],
                            ),
                            child: IconButton(
                              onPressed: () => Navigator.pop(context),
                              icon: const Icon(Icons.arrow_back),
                              color: isDark
                                  ? ColorManager.white
                                  : ColorManager.chaletGrey800,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Material(
                              elevation: 4,
                              borderRadius: BorderRadius.circular(12),
                              color: Colors.transparent,
                              child: TextField(
                                controller: _searchController,
                                style: TextStyle(
                                  color: isDark ? Colors.white : Colors.black,
                                ),
                                decoration: InputDecoration(
                                  hintText: 'ابحث عن موقع...',
                                  hintStyle: TextStyle(
                                    color: isDark
                                        ? Colors.grey[400]
                                        : Colors.grey[600],
                                  ),
                                  prefixIcon: Icon(
                                    Icons.search,
                                    color: isDark
                                        ? Colors.white70
                                        : Colors.blue,
                                  ),
                                  suffixIcon: _isSearching || _isLoading
                                      ? Padding(
                                          padding: const EdgeInsets.all(12),
                                          child: SizedBox(
                                            width: 20,
                                            height: 20,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              color: isDark
                                                  ? Colors.white70
                                                  : Colors.blue,
                                            ),
                                          ),
                                        )
                                      : _searchController.text.isNotEmpty
                                      ? IconButton(
                                          icon: Icon(
                                            Icons.clear,
                                            color: isDark
                                                ? Colors.white70
                                                : Colors.grey,
                                          ),
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
                                  fillColor: isDark
                                      ? ColorManager.darkGrey2D2D44
                                      : Colors.white,
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
                      if (_searchSuggestions.isNotEmpty)
                        Container(
                          margin: const EdgeInsets.only(top: 8),
                          constraints: const BoxConstraints(maxHeight: 250),
                          decoration: BoxDecoration(
                            color: isDark
                                ? ColorManager.darkGrey2D2D44
                                : Colors.white,
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
                            separatorBuilder: (context, index) => Divider(
                              height: 1,
                              color: isDark
                                  ? Colors.grey[700]
                                  : Colors.grey[300],
                            ),
                            itemBuilder: (context, index) {
                              final suggestion = _searchSuggestions[index];
                              return ListTile(
                                leading: Icon(
                                  Icons.place,
                                  color: isDark
                                      ? Colors.blueAccent
                                      : Colors.blue,
                                ),
                                title: Text(
                                  suggestion['display'],
                                  style: TextStyle(
                                    color: isDark ? Colors.white : Colors.black,
                                  ),
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

          // Selected address display
          if (_selectedAddress != null && _selectedAddress!.isNotEmpty)
            Positioned(
              bottom: 100,
              left: 16,
              right: 16,
              child: Material(
                elevation: 8,
                borderRadius: BorderRadius.circular(16),
                color: Colors.transparent,
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isDark ? ColorManager.darkGrey2D2D44 : Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.place,
                        color: isDark ? Colors.blueAccent : Colors.blue,
                        size: 24,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'الموقع المحدد',
                              style: TextStyle(
                                fontSize: 12,
                                color: isDark ? Colors.grey[400] : Colors.grey,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _selectedAddress!,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: isDark ? Colors.white : Colors.black,
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
              label: const Text('تأكيد الموقع'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 100),
        child: FloatingActionButton(
          onPressed: _getCurrentLocation,
          backgroundColor: isDark ? ColorManager.darkGrey2D2D44 : Colors.white,
          child: Icon(
            Icons.my_location,
            color: isDark ? Colors.white : Colors.blue,
          ),
        ),
      ),
    );
  }
}

/*
// ==========================================
// 🔴 OLD FLUTTER MAP (OPENSTREETMAP) CODE 🔴
// ==========================================

/*
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

  // ... (REST OF OLD CODE)
  
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
              // ...
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                // ...
              ),
              // ...
            ],
          ),
          // ...
        ],
      ),
    );
  }
}
*/
*/
