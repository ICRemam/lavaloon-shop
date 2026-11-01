import 'package:equatable/equatable.dart';
import 'package:lavaloon_assessment/data/models/auth_user.dart';

enum AuthStatus {
  initial,
  restoring,
  unauthenticated,
  authenticating,
  authenticated,
  failure
  ;

  bool get isRestoring => this == AuthStatus.restoring;
  bool get isAuthenticating => this == AuthStatus.authenticating;
  bool get isAuthenticated => this == AuthStatus.authenticated;
  bool get isUnauthenticated => this == AuthStatus.unauthenticated;
  bool get isFailure => this == AuthStatus.failure;
}

class AuthState extends Equatable {
  final AuthStatus status;
  final AuthUser? user;
  final String? errorMessage;
  final bool isOfflineSession;

  const AuthState({this.status = AuthStatus.initial, this.user, this.errorMessage, this.isOfflineSession = false});

  @override
  List<Object?> get props => [status, user, errorMessage, isOfflineSession];
}
