import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'generated/auth_user.g.dart';

@JsonSerializable()
class AuthUser extends Equatable {
  final int id;
  final String? username;
  final String? email;
  final String? firstName;
  final String? lastName;
  final String? image;

  const AuthUser({required this.id, this.username, this.email, this.firstName, this.lastName, this.image});

  factory AuthUser.fromJson(Map<String, dynamic> json) => _$AuthUserFromJson(json);

  Map<String, dynamic> toJson() => _$AuthUserToJson(this);

  String get fullName {
    final name = [firstName, lastName].where((part) => part != null && part.trim().isNotEmpty).join(' ');
    if (name.isNotEmpty) return name;
    return username ?? 'User $id';
  }

  @override
  List<Object?> get props => [id, username, email, firstName, lastName, image];
}
