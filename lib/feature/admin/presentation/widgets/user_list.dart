import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rebtal/feature/admin/presentation/cubit/admin_cubit.dart';
import 'package:rebtal/feature/admin/presentation/cubit/admin_state.dart';
import 'package:rebtal/feature/admin/presentation/pages/dashboard.dart';
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
    return BlocBuilder<AdminCubit, AdminState>(
      builder: (context, state) {
        if (state is AdminLoading || state is AdminInitial) {
          return Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.deepPurple),
            ),
          );
        }

        if (state is AdminError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
                const SizedBox(height: 16),
                Text(
                  'Error loading data: ${state.message}',
                  style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                ),
              ],
            ),
          );
        }

        List<QueryDocumentSnapshot<Map<String, dynamic>>> docs = [];
        if (state is AdminDataLoaded) {
          if (collection == 'Users') docs = state.users;
          else if (collection == 'Owners') docs = state.owners;
          else if (collection == 'Admin') docs = state.admins;
        }

        if (docs.isEmpty) {
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

        return ValueListenableBuilder<String>(
          valueListenable: AdminSearch.q,
          builder: (context, query, _) {
            final filtered = docs
                .map((d) => d.data()..['__id'] = d.id)
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
