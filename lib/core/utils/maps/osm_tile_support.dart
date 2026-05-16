import 'dart:convert';
import 'dart:io';

import 'package:flutter/painting.dart';

/// 1×1 PNG — used as [TileLayer.errorImage] so failed tiles don't spam the image service.
final ImageProvider kOsmTileErrorImage = MemoryImage(
  base64Decode(
    'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mP8z8BQDwAEhQGAhKmMIQAAAABJRU5ErkJggg==',
  ),
);

/// Whether OSM raster tiles are reachable (HTTPS fetch; stricter than DNS-only checks).
Future<bool> canReachOpenStreetMapTiles() async {
  HttpClient? client;
  try {
    client = HttpClient();
    final req = await client
        .getUrl(Uri.parse('https://tile.openstreetmap.org/0/0/0.png'))
        .timeout(const Duration(seconds: 3));
    req.headers.set(HttpHeaders.userAgentHeader, 'Rebtal/1.0 (contact via app listing)');
    final resp = await req.close().timeout(const Duration(seconds: 6));
    final ok = resp.statusCode == 200;
    try {
      await resp.drain();
    } catch (_) {}
    return ok;
  } catch (_) {
    return false;
  } finally {
    client?.close(force: true);
  }
}
