import 'package:equatable/equatable.dart';
import 'package:lavaloon_assessment/data/models/auth_user.dart';

class AuthResponse extends Equatable {
  final String accessToken;
  final String? refreshToken;
  final AuthUser user;

  const AuthResponse({required this.accessToken, this.refreshToken, required this.user});

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    final token = (json['accessToken'] ?? json['token']) as String?;
    if (token == null || token.isEmpty) {
      throw const FormatException('Missing access token in login response');
    }
    return AuthResponse(
      accessToken: token,
      refreshToken: json['refreshToken'] as String?,
      user: AuthUser.fromJson(json),
    );
  }

  @override
  List<Object?> get props => [accessToken, refreshToken, user];
}
