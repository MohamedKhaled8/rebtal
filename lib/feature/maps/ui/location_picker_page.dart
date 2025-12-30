import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:location/location.dart' as l;
import 'package:latlong2/latlong.dart';

class LocationPickerPage extends StatefulWidget {
  final String? initialAddress;
  final bool autoLocate;
  const LocationPickerPage({
    super.key,
    this.initialAddress,
    this.autoLocate = false,
  });

  @override
  State<LocationPickerPage> createState() => _LocationPickerPageState();
}

class _LocationPickerPageState extends State<LocationPickerPage> {
  final Dio _dio = Dio();
  final TextEditingController _search = TextEditingController();
  Timer? _debounce;

  LatLng? _selected;
  bool _loading = false;
  String? _selectedAddress;
  List<Map<String, dynamic>> _suggestions = [];

  @override
  void initState() {
    super.initState();
    if (widget.autoLocate) {
      // طلب تحديد الموقع مباشرة بعد الدخول
      WidgetsBinding.instance.addPostFrameCallback(
        (_) => _initCurrentLocation(),
      );
    } else if (widget.initialAddress != null &&
        widget.initialAddress!.isNotEmpty) {
      _search.text = widget.initialAddress!;
      _geocode(widget.initialAddress!);
    }
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _search.dispose();
    super.dispose();
  }

  void _onSearchChanged(String q) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () {
      if (q.trim().isEmpty) {
        setState(() => _suggestions = []);
      } else {
        _fetchSuggestions(q);
      }
    });
  }

  Future<void> _fetchSuggestions(String q) async {
    try {
      final res = await _dio.get(
        'https://nominatim.openstreetmap.org/search',
        queryParameters: {'q': q, 'format': 'json', 'limit': 6},
        options: Options(headers: {'User-Agent': 'rebtal-app/1.0'}),
      );
      final List data = res.data as List;
      setState(() {
        _suggestions = data
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

  Future<void> _geocode(String q) async {
    if (q.trim().isEmpty) return;
    setState(() => _loading = true);
    try {
      final res = await _dio.get(
        'https://nominatim.openstreetmap.org/search',
        queryParameters: {'q': q, 'format': 'json', 'limit': 1},
        options: Options(headers: {'User-Agent': 'rebtal-app/1.0'}),
      );
      final List data = res.data as List;
      if (data.isNotEmpty) {
        final lat = double.tryParse(data.first['lat'] ?? '0') ?? 0;
        final lon = double.tryParse(data.first['lon'] ?? '0') ?? 0;
        setState(() {
          _selected = LatLng(lat, lon);
          _selectedAddress = data.first['display_name'];
        });
      }
    } catch (_) {
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _reverseGeocode(LatLng p) async {
    setState(() => _loading = true);
    try {
      final res = await _dio.get(
        'https://nominatim.openstreetmap.org/reverse',
        queryParameters: {
          'lat': p.latitude,
          'lon': p.longitude,
          'format': 'json',
          'zoom': 16,
        },
        options: Options(headers: {'User-Agent': 'rebtal-app/1.0'}),
      );
      setState(() {
        _selected = p;
        _selectedAddress = res.data['display_name'] as String?;
      });
    } catch (_) {
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _initCurrentLocation() async {
    try {
      final ok = await _ensureLocationReady();
      if (!ok) return;
      setState(() => _loading = true);
      LatLng? p;
      try {
        final pos = await Geolocator.getCurrentPosition(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.best,
          ),
        ).timeout(const Duration(seconds: 8));
        p = LatLng(pos.latitude, pos.longitude);
      } catch (_) {
        final last = await Geolocator.getLastKnownPosition();
        if (last != null) {
          p = LatLng(last.latitude, last.longitude);
        }
      }

      if (p == null) {
        // Fallback: IP-based geolocation (approximate)
        try {
          final res = await _dio.get('https://ipapi.co/json/');
          final lat = (res.data['latitude'] as num?)?.toDouble();
          final lon = (res.data['longitude'] as num?)?.toDouble();
          if (lat != null && lon != null) {
            p = LatLng(lat, lon);
          }
        } catch (_) {}
      }

      if (p != null) {
        setState(() {
          _selected = p;
        });
        await _reverseGeocode(p);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('تعذر تحديد موقعك. حاول مرة أخرى.')),
          );
        }
      }
    } catch (_) {
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<bool> _ensureLocationReady() async {
    // Enforce GPS via location package dialog
    final loc = l.Location();
    bool serviceEnabled = await loc.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await loc.requestService();
      if (!serviceEnabled) return false;
    }

    // Ensure permission granted
    // Ensure permission granted
    var permission = await loc.hasPermission();
    if (permission == l.PermissionStatus.denied) {
      permission = await loc.requestPermission();
      if (permission == l.PermissionStatus.denied) return false;
    }
    if (permission == l.PermissionStatus.deniedForever) {
      return false;
    }
    return true;
  }

  void _selectSuggestion(Map<String, dynamic> s) {
    final lat = (s['lat'] as double?) ?? 0;
    final lon = (s['lon'] as double?) ?? 0;
    setState(() {
      _selected = LatLng(lat, lon);
      _selectedAddress = s['display'] as String?;
      _suggestions = [];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('اختيار الموقع'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            tooltip: 'موقعي الحالي',
            onPressed: () async {
              try {
                bool serviceEnabled =
                    await Geolocator.isLocationServiceEnabled();
                if (!serviceEnabled) {
                  await Geolocator.openLocationSettings();
                  return;
                }
                LocationPermission permission =
                    await Geolocator.checkPermission();
                if (permission == LocationPermission.denied) {
                  permission = await Geolocator.requestPermission();
                  if (permission == LocationPermission.denied) return;
                }
                if (permission == LocationPermission.deniedForever) return;

                final pos = await Geolocator.getCurrentPosition();
                final p = LatLng(pos.latitude, pos.longitude);
                setState(() {
                  _selected = p;
                });
                await _reverseGeocode(p);
              } catch (_) {}
            },
            icon: const Icon(Icons.my_location),
          ),
          TextButton.icon(
            onPressed: _selectedAddress == null
                ? null
                : () {
                    Navigator.pop(context, {
                      'address': _selectedAddress,
                      'lat': _selected?.latitude,
                      'lon': _selected?.longitude,
                    });
                  },
            icon: const Icon(Icons.check, color: Colors.white),
            label: const Text('حفظ', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 6),
            child: TextField(
              controller: _search,
              decoration: InputDecoration(
                hintText: 'اكتب العنوان للبحث...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _loading
                    ? const Padding(
                        padding: EdgeInsets.all(12),
                        child: SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      )
                    : IconButton(
                        icon: const Icon(Icons.my_location),
                        onPressed: () => _geocode(_search.text),
                      ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onChanged: _onSearchChanged,
              onSubmitted: _geocode,
              textInputAction: TextInputAction.search,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _loading ? null : _initCurrentLocation,
                icon: const Icon(Icons.my_location),
                label: const Text('حدد موقعي الآن'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
          ),
          if (_suggestions.isNotEmpty)
            Container(
              constraints: const BoxConstraints(maxHeight: 180),
              margin: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 8,
                  ),
                ],
              ),
              child: ListView.builder(
                itemCount: _suggestions.length,
                itemBuilder: (context, i) {
                  final s = _suggestions[i];
                  return ListTile(
                    leading: const Icon(Icons.place, color: Colors.blue),
                    title: Text(
                      s['display'],
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    onTap: () => _selectSuggestion(s),
                  );
                },
              ),
            ),
          const SizedBox(height: 6),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 6, 12, 12),
            child: Row(
              children: [
                const Icon(Icons.place, size: 18, color: Colors.blueGrey),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    _selectedAddress ?? 'اضغط على الخريطة لاختيار الموقع',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
