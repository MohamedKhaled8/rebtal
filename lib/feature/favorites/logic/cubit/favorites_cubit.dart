import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'favorites_state.dart';

class FavoritesCubit extends Cubit<FavoritesState> {
  StreamSubscription<QuerySnapshot>? _favoritesSubscription;

  FavoritesCubit() : super(FavoritesInitial());

  void getFavorites(String userId) {
    emit(FavoritesLoading());

    try {
      _favoritesSubscription = FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('favorites')
          .snapshots()
          .listen(
            (snapshot) {
              final favorites = snapshot.docs.map((doc) {
                final data = doc.data();
                return {
                  'id': doc.id,
                  'chaletId': data['chaletId'] ?? doc.id,
                  'chaletData': data['chaletData'] ?? {},
                };
              }).toList();

              emit(FavoritesLoaded(favorites));
            },
            onError: (error) {
              emit(FavoritesError(error.toString()));
            },
          );
    } catch (e) {
      emit(FavoritesError(e.toString()));
    }
  }

  @override
  Future<void> close() {
    _favoritesSubscription?.cancel();
    return super.close();
  }
}
