import 'package:equatable/equatable.dart';

class UserEntity extends Equatable {
  final int id;
  final String? username;
  final String? email;
  final String? firstName;
  final String? lastName;
  final String? image;

  const UserEntity({required this.id, this.username, this.email, this.firstName, this.lastName, this.image});

  @override
  List<Object?> get props => [id, username, email, firstName, lastName, image];
}
