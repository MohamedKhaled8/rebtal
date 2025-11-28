import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:rebtal/feature/admin/ui/dashboard.dart';
import 'package:rebtal/feature/admin/widget/user/user_card.dart';

class UsersList extends StatelessWidget {
  final String collection;

  const UsersList({super.key, required this.collection});

  bool _matchesQuery(Map<String, dynamic> d, String q) {
    if (q.isEmpty) return true;
    final low = q.toLowerCase();
    final fields = <String>[
      (d['name'] ?? '').toString(),
      (d['email'] ?? '').toString(),
      (d['phone'] ?? '').toString(),
      (d['uid'] ?? '').toString(),
    ];
    return fields.any((f) => f.toLowerCase().contains(low));
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection(collection).snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.deepPurple),
            ),
          );
        }
        if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
                const SizedBox(height: 16),
                Text(
                  'Error loading data',
                  style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                ),
              ],
            ),
          );
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.people_outline, size: 64, color: Colors.grey[400]),
                const SizedBox(height: 16),
                Text(
                  'No $collection found',
                  style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                ),
              ],
            ),
          );
        }
        final docs = snapshot.data!.docs;

        // listen to global search and filter client-side
        return ValueListenableBuilder<String>(
          valueListenable: AdminSearch.q,
          builder: (context, query, _) {
            final filtered = docs
                .map((d) => d.data() as Map<String, dynamic>..['__id'] = d.id)
                .where((m) => _matchesQuery(m, query))
                .toList();

            if (filtered.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.search_off, size: 64, color: Colors.grey[400]),
                    const SizedBox(height: 12),
                    Text(
                      'No results for "$query"',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ],
                ),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: filtered.length,
              itemBuilder: (context, i) {
                final data = filtered[i];
                final docId = data['__id'] as String;
                return UserCard(
                  userData: data,
                  docId: docId,
                  collection: collection,
                );
              },
            );
          },
        );
      },
    );
  }
}
