import 'package:cloud_firestore/cloud_firestore.dart';

/// Firestore user/owner docs may use [name], [fullName], etc.
String displayNameFromProfileMap(Map<String, dynamic>? m) {
  if (m == null) return '';
  final direct = (m['name'] ??
          m['fullName'] ??
          m['displayName'] ??
          m['userName'] ??
          '')
      .toString()
      .trim();
  if (direct.isNotEmpty) return direct;
  final email = m['email']?.toString().trim() ?? '';
  if (email.contains('@')) {
    final local = email.split('@').first;
    if (local.isNotEmpty) return local;
  }
  return '';
}

String? phoneFromProfileMap(Map<String, dynamic>? m) {
  if (m == null) return null;
  for (final k in ['phone', 'phoneNumber', 'mobile', 'tel']) {
    final v = m[k]?.toString().trim();
    if (v != null && v.isNotEmpty) return v;
  }
  return null;
}

/// Tries [Users], [users], then [Owners] — matches how profiles are split across collections.
Future<DocumentSnapshot<Map<String, dynamic>>?> fetchFirestoreProfileDoc(
  String uid, {
  List<String> collections = const ['Users', 'users', 'Owners'],
}) async {
  if (uid.isEmpty) return null;
  for (final col in collections) {
    final ref = FirebaseFirestore.instance.collection(col).doc(uid);
    for (int attempt = 0; attempt < 3; attempt++) {
      try {
        // Prefer server for freshness; fall back to cache on transient outages.
        final d = await ref.get(const GetOptions(source: Source.server));
        if (d.exists) return d;
        break; // doc doesn't exist in this collection → try next collection
      } on FirebaseException catch (e) {
        if (e.code == 'unavailable' || e.code == 'deadline-exceeded') {
          // Exponential backoff: 250ms, 500ms, 1000ms
          final delayMs = 250 * (1 << attempt);
          await Future.delayed(Duration(milliseconds: delayMs));
          try {
            final cached = await ref.get(const GetOptions(source: Source.cache));
            if (cached.exists) return cached;
          } catch (_) {
            // ignore cache miss
          }
          continue;
        }
        rethrow;
      }
    }
  }
  return null;
}

/// Admin payment cards read raw booking maps; merge owner display fields from streamed profile lists.
Map<String, dynamic>? enrichBookingMapWithOwnerProfiles(
  Map<String, dynamic>? booking,
  List<QueryDocumentSnapshot<Map<String, dynamic>>> users,
  List<QueryDocumentSnapshot<Map<String, dynamic>>> owners,
) {
  if (booking == null) return null;
  final out = Map<String, dynamic>.from(booking);
  final oid = out['ownerId']?.toString() ?? '';
  if (oid.isEmpty) return out;

  Map<String, dynamic>? profile;
  for (final d in users) {
    if (d.id == oid) {
      profile = d.data();
      break;
    }
  }
  if (profile == null) {
    for (final d in owners) {
      if (d.id == oid) {
        profile = d.data();
        break;
      }
    }
  }
  if (profile == null) return out;

  final oname = out['ownerName']?.toString().trim() ?? '';
  if (oname.isEmpty) {
    final n = displayNameFromProfileMap(profile);
    if (n.isNotEmpty) out['ownerName'] = n;
  }
  final ophone = out['ownerPhone']?.toString().trim() ?? '';
  if (ophone.isEmpty) {
    final p = phoneFromProfileMap(profile);
    if (p != null && p.isNotEmpty) out['ownerPhone'] = p;
  }
  return out;
}
