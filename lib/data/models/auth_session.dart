import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'generated/auth_session.g.dart';

@JsonSerializable()
class AuthSession extends Equatable {
  final int userId;
  final String accessToken;
  final String? refreshToken;
  final DateTime expiresAt;

  const AuthSession({required this.userId, required this.accessToken, this.refreshToken, required this.expiresAt});

  factory AuthSession.fromJson(Map<String, dynamic> json) => _$AuthSessionFromJson(json);

  Map<String, dynamic> toJson() => _$AuthSessionToJson(this);

  bool isExpiredAt(DateTime now) => !now.isBefore(expiresAt);

  @override
  List<Object?> get props => [userId, accessToken, refreshToken, expiresAt];
}
