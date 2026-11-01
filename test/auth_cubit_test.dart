import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lavaloon_assessment/business_layer/useCases/login_usecase.dart';
import 'package:lavaloon_assessment/business_layer/useCases/logout_usecase.dart';
import 'package:lavaloon_assessment/business_layer/useCases/restore_session_usecase.dart';
import 'package:lavaloon_assessment/data/exceptions/request_error_type.dart';
import 'package:lavaloon_assessment/data/exceptions/request_exception.dart';
import 'package:lavaloon_assessment/data/models/auth_response.dart';
import 'package:lavaloon_assessment/data/models/auth_session.dart';
import 'package:lavaloon_assessment/presentation/shared_cubits/auth/auth_cubit.dart';
import 'package:lavaloon_assessment/presentation/shared_cubits/auth/auth_state.dart';

import 'support/fakes.dart';
import 'support/fixtures.dart';

void main() {
  late MemorySessionStorage sessions;
  late MemoryUserRepository users;
  late FakeIntegrator integrator;
  late AuthCubit cubit;
  final now = DateTime(2026, 11, 1, 12);

  setUp(() {
    sessions = MemorySessionStorage();
    users = MemoryUserRepository();
    integrator = FakeIntegrator();
    cubit = AuthCubit(
      RestoreSessionUseCase(integrator, sessions, users, now: () => now),
      LoginUseCase(integrator, sessions, users, now: () => now),
      LogoutUseCase(sessions, users),
    );
  });

  tearDown(() async {
    await cubit.close();
  });

  blocTest<AuthCubit, AuthState>(
    'login moves from authenticating to the signed-in user',
    build: () => cubit,
    setUp: () {
      final token = jwtExpiringAt(now.add(const Duration(hours: 1)));
      integrator.loginResponse = AuthResponse(accessToken: token, user: emily);
      integrator.currentUser = emily;
    },
    act: (cubit) => cubit.login('emilys', 'emilyspass'),
    expect: () => [
      const AuthState(status: AuthStatus.authenticating),
      const AuthState(status: AuthStatus.authenticated, user: emily),
    ],
  );

  blocTest<AuthCubit, AuthState>(
    'a second login tap while the first is running is ignored',
    build: () => cubit,
    setUp: () {
      final token = jwtExpiringAt(now.add(const Duration(hours: 1)));
      final pending = Completer<AuthResponse>();
      integrator.pendingLogin = pending.future;
      integrator.currentUser = emily;
      pending.complete(AuthResponse(accessToken: token, user: emily));
    },
    act: (cubit) async {
      final first = cubit.login('emilys', 'emilyspass');
      final second = cubit.login('emilys', 'emilyspass');
      await Future.wait([first, second]);
    },
    expect: () => [
      const AuthState(status: AuthStatus.authenticating),
      const AuthState(status: AuthStatus.authenticated, user: emily),
    ],
    verify: (_) {
      expect(integrator.loginCalls, 1);
    },
  );

  blocTest<AuthCubit, AuthState>(
    'a rejected login shows the credentials message',
    build: () => cubit,
    setUp: () {
      integrator.loginError = const RequestException(RequestErrorType.unAuthorized, 'Invalid credentials');
    },
    act: (cubit) => cubit.login('emilys', 'wrong'),
    expect: () => [
      const AuthState(status: AuthStatus.authenticating),
      const AuthState(status: AuthStatus.failure, errorMessage: 'Invalid username or password.'),
    ],
  );

  blocTest<AuthCubit, AuthState>(
    'an offline restore keeps the cached profile',
    build: () => cubit,
    setUp: () {
      sessions.session = AuthSession(userId: emily.id, accessToken: 'token', expiresAt: now.add(const Duration(hours: 1)));
      users.user = emily;
      integrator.currentUserError = const RequestException(RequestErrorType.networkError, 'offline');
    },
    act: (cubit) => cubit.restore(),
    expect: () => [
      const AuthState(status: AuthStatus.restoring),
      const AuthState(status: AuthStatus.authenticated, user: emily, isOfflineSession: true),
    ],
  );

  blocTest<AuthCubit, AuthState>(
    'coming back online drops the offline banner when the token is accepted',
    build: () => cubit,
    seed: () => const AuthState(status: AuthStatus.authenticated, user: emily, isOfflineSession: true),
    setUp: () {
      sessions.session = AuthSession(userId: emily.id, accessToken: 'token', expiresAt: now.add(const Duration(hours: 1)));
      integrator.currentUser = emily;
    },
    act: (cubit) => cubit.confirmOnlineSession(),
    expect: () => [const AuthState(status: AuthStatus.authenticated, user: emily)],
  );

  blocTest<AuthCubit, AuthState>(
    'coming back online opens login when the server rejects the token',
    build: () => cubit,
    seed: () => const AuthState(status: AuthStatus.authenticated, user: emily, isOfflineSession: true),
    setUp: () {
      sessions.session = AuthSession(userId: emily.id, accessToken: 'token', expiresAt: now.add(const Duration(hours: 1)));
      users.user = emily;
      integrator.currentUserError = const RequestException(RequestErrorType.unAuthorized, '401');
    },
    act: (cubit) => cubit.confirmOnlineSession(),
    expect: () => [const AuthState(status: AuthStatus.unauthenticated)],
    verify: (_) {
      expect(sessions.session, isNull);
      expect(users.user, isNull);
    },
  );

  blocTest<AuthCubit, AuthState>(
    'logout clears the signed-in state',
    build: () => cubit,
    seed: () => const AuthState(status: AuthStatus.authenticated, user: emily),
    setUp: () {
      sessions.session = AuthSession(userId: emily.id, accessToken: 'token', expiresAt: now.add(const Duration(hours: 1)));
      users.user = emily;
    },
    act: (cubit) => cubit.logout(),
    expect: () => [const AuthState(status: AuthStatus.unauthenticated)],
    verify: (_) {
      expect(sessions.session, isNull);
    },
  );
}
