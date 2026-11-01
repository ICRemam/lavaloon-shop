import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lavaloon_assessment/business_layer/useCases/login_usecase.dart';
import 'package:lavaloon_assessment/business_layer/useCases/logout_usecase.dart';
import 'package:lavaloon_assessment/business_layer/useCases/params/login_params.dart';
import 'package:lavaloon_assessment/business_layer/useCases/params/no_params.dart';
import 'package:lavaloon_assessment/business_layer/useCases/restore_session_usecase.dart';
import 'package:lavaloon_assessment/presentation/shared_cubits/auth/auth_state.dart';
import 'package:lavaloon_assessment/utils/error_message_util.dart';

class AuthCubit extends Cubit<AuthState> {
  final RestoreSessionUseCase _restoreSessionUseCase;
  final LoginUseCase _loginUseCase;
  final LogoutUseCase _logoutUseCase;

  int _sessionGeneration = 0;
  bool _confirmingOnline = false;

  AuthCubit(this._restoreSessionUseCase, this._loginUseCase, this._logoutUseCase) : super(const AuthState());

  int get userId => state.user?.id ?? 0;

  Future<void> restore() async {
    if (state.status.isRestoring) return;

    final generation = ++_sessionGeneration;
    emit(const AuthState(status: AuthStatus.restoring));

    try {
      final result = await _restoreSessionUseCase.call(params: const NoParams());
      if (generation != _sessionGeneration) return;

      if (result.hasSession) {
        emit(AuthState(status: AuthStatus.authenticated, user: result.user, isOfflineSession: result.isOffline));
      } else {
        emit(const AuthState(status: AuthStatus.unauthenticated));
      }
    } catch (_) {
      if (generation != _sessionGeneration) return;
      emit(const AuthState(status: AuthStatus.unauthenticated));
    }
  }

  Future<void> confirmOnlineSession() async {
    if (!state.status.isAuthenticated || !state.isOfflineSession || _confirmingOnline) return;

    _confirmingOnline = true;
    final generation = _sessionGeneration;

    try {
      final result = await _restoreSessionUseCase.call(params: const NoParams());
      if (generation != _sessionGeneration || !state.status.isAuthenticated) return;

      if (!result.hasSession) {
        emit(const AuthState(status: AuthStatus.unauthenticated));
        return;
      }

      if (result.isOffline) return;

      emit(AuthState(status: AuthStatus.authenticated, user: result.user));
    } catch (_) {
      return;
    } finally {
      _confirmingOnline = false;
    }
  }

  Future<void> login(String username, String password) async {
    if (state.status.isAuthenticating) return;

    final generation = ++_sessionGeneration;
    emit(const AuthState(status: AuthStatus.authenticating));

    try {
      final user = await _loginUseCase.call(
        params: LoginParams(username: username, password: password),
      );

      if (generation != _sessionGeneration) {
        await _logoutUseCase.call(params: const NoParams());
        return;
      }

      emit(AuthState(status: AuthStatus.authenticated, user: user));
    } catch (e) {
      if (generation != _sessionGeneration) return;
      emit(AuthState(status: AuthStatus.failure, errorMessage: ErrorMessageUtil.fromError(e)));
    }
  }

  Future<void> logout() async {
    _sessionGeneration++;

    try {
      await _logoutUseCase.call(params: const NoParams());
    } finally {
      emit(const AuthState(status: AuthStatus.unauthenticated));
    }
  }
}
