import 'package:equatable/equatable.dart';
import 'package:rebtal/feature/home/domain/entities/home_chalet_entity.dart';
import 'package:rebtal/feature/home/logic/state/advanced_search_form_state.dart';

class HomeState extends Equatable {
  const HomeState({
    this.publicChalets = const [],
    this.publicWaitingFirst = true,
    this.publicError,
    this.displayLimit = initialDisplayLimit,
    this.approvedChalets = const [],
    this.approvedWaitingFirst = true,
    this.approvedError,
    this.discountedOffers = const [],
    this.discountedWaitingFirst = true,
    this.discountedError,
    this.promoBannerPage = 0,
    this.advancedSearch = const AdvancedSearchFormState(),
    this.favoriteByChaletId = const {},
    this.favoriteBusyIds = const {},
    this.favoriteLoadedIds = const {},
    this.favoriteUserId,
  });

  static const int initialDisplayLimit = 10;

  final List<HomeChaletEntity> publicChalets;
  final bool publicWaitingFirst;
  final Object? publicError;
  final int displayLimit;

  final List<HomeChaletEntity> approvedChalets;
  final bool approvedWaitingFirst;
  final Object? approvedError;

  final List<HomeChaletEntity> discountedOffers;
  final bool discountedWaitingFirst;
  final Object? discountedError;

  final int promoBannerPage;
  final AdvancedSearchFormState advancedSearch;

  final Map<String, bool> favoriteByChaletId;
  final Set<String> favoriteBusyIds;
  final Set<String> favoriteLoadedIds;
  final String? favoriteUserId;

  bool get publicHasCache => publicChalets.isNotEmpty;

  bool get showInitialPublicLoading =>
      publicWaitingFirst && !publicHasCache;

  bool get showDiscountedSection =>
      !discountedWaitingFirst &&
      discountedOffers.isNotEmpty &&
      discountedError == null;

  bool isFavorite(String chaletId) => favoriteByChaletId[chaletId] ?? false;

  bool isFavoriteBusy(String chaletId) => favoriteBusyIds.contains(chaletId);

  HomeState copyWith({
    List<HomeChaletEntity>? publicChalets,
    bool? publicWaitingFirst,
    Object? publicError,
    int? displayLimit,
    List<HomeChaletEntity>? approvedChalets,
    bool? approvedWaitingFirst,
    Object? approvedError,
    List<HomeChaletEntity>? discountedOffers,
    bool? discountedWaitingFirst,
    Object? discountedError,
    int? promoBannerPage,
    AdvancedSearchFormState? advancedSearch,
    Map<String, bool>? favoriteByChaletId,
    Set<String>? favoriteBusyIds,
    Set<String>? favoriteLoadedIds,
    String? favoriteUserId,
    bool clearPublicError = false,
    bool clearApprovedError = false,
    bool clearDiscountedError = false,
  }) {
    return HomeState(
      publicChalets: publicChalets ?? this.publicChalets,
      publicWaitingFirst: publicWaitingFirst ?? this.publicWaitingFirst,
      publicError: clearPublicError ? null : (publicError ?? this.publicError),
      displayLimit: displayLimit ?? this.displayLimit,
      approvedChalets: approvedChalets ?? this.approvedChalets,
      approvedWaitingFirst: approvedWaitingFirst ?? this.approvedWaitingFirst,
      approvedError:
          clearApprovedError ? null : (approvedError ?? this.approvedError),
      discountedOffers: discountedOffers ?? this.discountedOffers,
      discountedWaitingFirst:
          discountedWaitingFirst ?? this.discountedWaitingFirst,
      discountedError: clearDiscountedError
          ? null
          : (discountedError ?? this.discountedError),
      promoBannerPage: promoBannerPage ?? this.promoBannerPage,
      advancedSearch: advancedSearch ?? this.advancedSearch,
      favoriteByChaletId: favoriteByChaletId ?? this.favoriteByChaletId,
      favoriteBusyIds: favoriteBusyIds ?? this.favoriteBusyIds,
      favoriteLoadedIds: favoriteLoadedIds ?? this.favoriteLoadedIds,
      favoriteUserId: favoriteUserId ?? this.favoriteUserId,
    );
  }

  @override
  List<Object?> get props => [
        publicChalets,
        publicWaitingFirst,
        publicError,
        displayLimit,
        approvedChalets,
        approvedWaitingFirst,
        approvedError,
        discountedOffers,
        discountedWaitingFirst,
        discountedError,
        promoBannerPage,
        advancedSearch,
        favoriteByChaletId,
        favoriteBusyIds,
        favoriteLoadedIds,
        favoriteUserId,
      ];
}
