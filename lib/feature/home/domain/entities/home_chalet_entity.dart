import 'package:equatable/equatable.dart';

class HomeChaletEntity extends Equatable {
  final String id;
  final Map<String, dynamic> data;

  const HomeChaletEntity({
    required this.id,
    required this.data,
  });

  @override
  List<Object?> get props => [id, data];
}

