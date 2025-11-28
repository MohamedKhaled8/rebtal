part of 'admin_cubit.dart';

@immutable
sealed class AdminState {}

final class AdminInitial extends AdminState {}

final class AdminSearchChanged extends AdminState {
  final String query;
  AdminSearchChanged(this.query);
}

final class AdminTabChanged extends AdminState {
  final int index;
  AdminTabChanged(this.index);
}

final class AdminCurrentIndex extends AdminState {
  final int currentIndex;
  AdminCurrentIndex(this.currentIndex);
}

/// ---- New States ---- ///
final class AdminStatusUpdated extends AdminState {
  final String status;
  AdminStatusUpdated(this.status);
}

final class AdminError extends AdminState {
  final String message;
  AdminError(this.message);
}

// part of admin_state.dart
final class AdminUserExpanded extends AdminState {
  final String docId;
  final bool isExpanded;
  AdminUserExpanded(this.docId, this.isExpanded);
}

final class AdminUsersLoaded extends AdminState {
  final List<Map<String, dynamic>> users;
  final Map<String, bool> expandedCards;
  AdminUsersLoaded(this.users, this.expandedCards);
}

final class AdminUsersError extends AdminState {
  final String message;
  AdminUsersError(this.message);
}

final class AdminUsersLoading extends AdminState {}
