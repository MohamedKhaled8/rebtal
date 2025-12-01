part of 'chalet_detail_cubit.dart';

@immutable
sealed class ChaletDetailState {}

final class ChaletDetailInitial extends ChaletDetailState {}

final class ChaletDetailLoading extends ChaletDetailState {}

final class ChaletDetailStatusUpdated extends ChaletDetailState {
  final String status;
  ChaletDetailStatusUpdated(this.status);
}

final class ChaletDetailError extends ChaletDetailState {
  final String message;
  ChaletDetailError(this.message);
}

final class ChaletDetailImageIndexChanged extends ChaletDetailState {
  final int index;
  ChaletDetailImageIndexChanged(this.index);
}

final class ChaletDetailLoaded extends ChaletDetailState {
  final List<String> images;
  final int currentImageIndex;
  final bool isDescriptionExpanded;

  ChaletDetailLoaded({
    required this.images,
    this.currentImageIndex = 0,
    this.isDescriptionExpanded = false,
  });

  ChaletDetailLoaded copyWith({
    List<String>? images,
    int? currentImageIndex,
    bool? isDescriptionExpanded,
  }) {
    return ChaletDetailLoaded(
      images: images ?? this.images,
      currentImageIndex: currentImageIndex ?? this.currentImageIndex,
      isDescriptionExpanded:
          isDescriptionExpanded ?? this.isDescriptionExpanded,
    );
  }
}
