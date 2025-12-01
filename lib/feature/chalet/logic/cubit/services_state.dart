part of 'services_cubit.dart';

abstract class ServicesState {}

class ServicesInitial extends ServicesState {}

class ServicesLoaded extends ServicesState {
  final List<Map<String, dynamic>> amenities;
  ServicesLoaded(this.amenities);
}
