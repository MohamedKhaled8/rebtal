import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

@immutable
abstract class AdminState {}

class AdminInitial extends AdminState {}

class AdminLoading extends AdminState {}

class AdminError extends AdminState {
  final String message;
  AdminError(this.message);
}

class AdminSearchChanged extends AdminState {
  final String query;
  AdminSearchChanged(this.query);
}

class AdminTabChanged extends AdminState {
  final int index;
  AdminTabChanged(this.index);
}

class AdminCurrentIndex extends AdminState {
  final int currentIndex;
  AdminCurrentIndex(this.currentIndex);
}

class AdminStatusUpdated extends AdminState {
  final String status;
  AdminStatusUpdated(this.status);
}

// Data Streams State
class AdminDataLoaded extends AdminState {
  final List<QueryDocumentSnapshot<Map<String, dynamic>>> users;
  final List<QueryDocumentSnapshot<Map<String, dynamic>>> owners;
  final List<QueryDocumentSnapshot<Map<String, dynamic>>> admins;
  final List<QueryDocumentSnapshot<Map<String, dynamic>>> chalets;
  final List<QueryDocumentSnapshot<Map<String, dynamic>>> bookings;
  final List<QueryDocumentSnapshot<Map<String, dynamic>>> paymentProofs;

  AdminDataLoaded({
    required this.users,
    required this.owners,
    required this.admins,
    required this.chalets,
    required this.bookings,
    required this.paymentProofs,
  });
}
