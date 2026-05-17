import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rebtal/core/utils/home_search_notifier.dart';
import 'package:rebtal/feature/home/data/datasources/home_favorites_data_source.dart';
import 'package:rebtal/feature/home/domain/entities/home_chalet_entity.dart';
import 'package:rebtal/feature/home/domain/usecases/watch_approved_chalets_usecase.dart';
import 'package:rebtal/feature/home/domain/usecases/watch_discounted_chalets_usecase.dart';
import 'package:rebtal/feature/home/domain/usecases/watch_public_chalets_usecase.dart';
import 'package:rebtal/feature/home/logic/cubit/home_state.dart';
import 'package:rebtal/feature/home/logic/helpers/home_chalet_list_helper.dart';
import 'package:rebtal/feature/home/logic/state/advanced_search_form_state.dart';

class HomeCubit extends Cubit<HomeState> {
  HomeCubit({
    required WatchPublicChaletsUseCase watchPublicChalets,
    required WatchDiscountedChaletsUseCase watchDiscountedChalets,
    required WatchApprovedChaletsUseCase watchApprovedChalets,
    required HomeFavoritesDataSource favoritesDataSource,
  })  : _watchPublicChalets = watchPublicChalets,
        _watchDiscountedChalets = watchDiscountedChalets,
        _watchApprovedChalets = watchApprovedChalets,
        _favoritesDataSource = favoritesDataSource,
        super(
          HomeState(
            publicChalets: _publicMemoryCache ?? const [],
            publicWaitingFirst:
                _publicMemoryCache == null || _publicMemoryCache!.isEmpty,
          ),
        );

  final WatchPublicChaletsUseCase _watchPublicChalets;
  final WatchDiscountedChaletsUseCase _watchDiscountedChalets;
  final WatchApprovedChaletsUseCase _watchApprovedChalets;
  final HomeFavoritesDataSource _favoritesDataSource;

  StreamSubscription<List<HomeChaletEntity>>? _publicSub;
  StreamSubscription<List<HomeChaletEntity>>? _discountedSub;
  StreamSubscription<List<HomeChaletEntity>>? _approvedSub;
  Timer? _promoTimer;

  static List<HomeChaletEntity>? _publicMemoryCache;
  static bool _isWatching = false;

  void ensureWatching() {
    if (_isWatching) return;
    _isWatching = true;

    _publicSub = _watchPublicChalets().listen(
      (chalets) {
        _publicMemoryCache = chalets;
        emit(
          state.copyWith(
            publicChalets: chalets,
            publicWaitingFirst: false,
            clearPublicError: true,
          ),
        );
      },
      onError: (Object error) {
        emit(
          state.copyWith(publicWaitingFirst: false, publicError: error),
        );
      },
    );

    _discountedSub = _watchDiscountedChalets().listen(
      (offers) {
        emit(
          state.copyWith(
            discountedOffers: offers,
            discountedWaitingFirst: false,
            clearDiscountedError: true,
          ),
        );
      },
      onError: (Object error) {
        emit(
          state.copyWith(
            discountedWaitingFirst: false,
            discountedError: error,
          ),
        );
      },
    );

    _approvedSub = _watchApprovedChalets().listen(
      (chalets) {
        emit(
          state.copyWith(
            approvedChalets: chalets,
            approvedWaitingFirst: false,
            clearApprovedError: true,
          ),
        );
      },
      onError: (Object error) {
        emit(
          state.copyWith(approvedWaitingFirst: false, approvedError: error),
        );
      },
    );
  }

  void loadMorePublicChalets() {
    emit(
      state.copyWith(
        displayLimit:
            state.displayLimit + HomeChaletListHelper.loadMoreIncrement,
      ),
    );
  }

  Future<void> refresh() async {
    await Future<void>.delayed(const Duration(milliseconds: 800));
    emit(state.copyWith());
  }

  void startPromoAutoScroll(int bannerCount) {
    _promoTimer?.cancel();
    if (bannerCount <= 1) return;

    _promoTimer = Timer.periodic(const Duration(seconds: 4), (_) {
      final nextPage = state.promoBannerPage < bannerCount - 1
          ? state.promoBannerPage + 1
          : 0;
      emit(state.copyWith(promoBannerPage: nextPage));
    });
  }

  void onPromoPageChanged(int index) {
    emit(state.copyWith(promoBannerPage: index));
  }

  void initAdvancedSearchFromFilters() {
    emit(
      state.copyWith(
        advancedSearch:
            AdvancedSearchFormState.fromFilters(HomeSearch.filters.value),
      ),
    );
  }

  void resetAdvancedSearch() {
    emit(state.copyWith(advancedSearch: const AdvancedSearchFormState()));
    HomeSearch.clear();
  }

  void applyAdvancedSearch() {
    HomeSearch.filters.value = state.advancedSearch.toSearchFilters();
  }

  void updateAdvancedSearch(AdvancedSearchFormState form) {
    emit(state.copyWith(advancedSearch: form));
  }

  void setFavoriteUserId(String? userId) {
    emit(state.copyWith(favoriteUserId: userId));
  }

  Future<void> ensureChaletFavoriteLoaded(String chaletId) async {
    final userId = state.favoriteUserId;
    if (userId == null || state.favoriteLoadedIds.contains(chaletId)) return;

    try {
      final isFavorite = await _favoritesDataSource.isFavorite(
        userId: userId,
        chaletId: chaletId,
      );
      final updatedMap = Map<String, bool>.from(state.favoriteByChaletId)
        ..[chaletId] = isFavorite;
      final updatedLoaded = Set<String>.from(state.favoriteLoadedIds)
        ..add(chaletId);
      emit(
        state.copyWith(
          favoriteByChaletId: updatedMap,
          favoriteLoadedIds: updatedLoaded,
        ),
      );
    } catch (_) {
      final updatedLoaded = Set<String>.from(state.favoriteLoadedIds)
        ..add(chaletId);
      emit(state.copyWith(favoriteLoadedIds: updatedLoaded));
    }
  }

  Future<bool> toggleChaletFavorite({
    required String chaletId,
    required Map<String, dynamic> chaletData,
  }) async {
    final userId = state.favoriteUserId;
    if (userId == null || state.favoriteBusyIds.contains(chaletId)) {
      return false;
    }

    final wasFavorite = state.isFavorite(chaletId);
    final updatedMap = Map<String, bool>.from(state.favoriteByChaletId)
      ..[chaletId] = !wasFavorite;
    final updatedBusy = Set<String>.from(state.favoriteBusyIds)..add(chaletId);

    emit(
      state.copyWith(
        favoriteByChaletId: updatedMap,
        favoriteBusyIds: updatedBusy,
      ),
    );

    try {
      if (wasFavorite) {
        await _favoritesDataSource.removeFavorite(
          userId: userId,
          chaletId: chaletId,
        );
      } else {
        await _favoritesDataSource.addFavorite(
          userId: userId,
          chaletId: chaletId,
          chaletData: chaletData,
        );
      }
      final clearedBusy = Set<String>.from(state.favoriteBusyIds)
        ..remove(chaletId);
      emit(state.copyWith(favoriteBusyIds: clearedBusy));
      return true;
    } catch (_) {
      final revertedMap = Map<String, bool>.from(state.favoriteByChaletId)
        ..[chaletId] = wasFavorite;
      final clearedBusy = Set<String>.from(state.favoriteBusyIds)
        ..remove(chaletId);
      emit(
        state.copyWith(
          favoriteByChaletId: revertedMap,
          favoriteBusyIds: clearedBusy,
        ),
      );
      return false;
    }
  }

  @override
  Future<void> close() {
    _publicSub?.cancel();
    _discountedSub?.cancel();
    _approvedSub?.cancel();
    _promoTimer?.cancel();
    _isWatching = false;
    return super.close();
  }
}
