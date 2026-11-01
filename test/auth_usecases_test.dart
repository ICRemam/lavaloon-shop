import 'package:flutter_test/flutter_test.dart';
import 'package:lavaloon_assessment/business_layer/useCases/login_usecase.dart';
import 'package:lavaloon_assessment/business_layer/useCases/logout_usecase.dart';
import 'package:lavaloon_assessment/business_layer/useCases/params/login_params.dart';
import 'package:lavaloon_assessment/business_layer/useCases/params/no_params.dart';
import 'package:lavaloon_assessment/business_layer/useCases/restore_session_usecase.dart';
import 'package:lavaloon_assessment/data/exceptions/business_error.dart';
import 'package:lavaloon_assessment/data/exceptions/request_error_type.dart';
import 'package:lavaloon_assessment/data/exceptions/request_exception.dart';
import 'package:lavaloon_assessment/data/models/auth_response.dart';
import 'package:lavaloon_assessment/data/models/auth_session.dart';

import 'support/fakes.dart';
import 'support/fixtures.dart';

void main() {
  late MemorySessionStorage sessions;
  late MemoryUserRepository users;
  late FakeIntegrator integrator;
  late LoginUseCase login;
  late RestoreSessionUseCase restore;
  late LogoutUseCase logout;
  final now = DateTime(2026, 11, 1, 12);

  setUp(() {
    sessions = MemorySessionStorage();
    users = MemoryUserRepository();
    integrator = FakeIntegrator();
    login = LoginUseCase(integrator, sessions, users, now: () => now);
    restore = RestoreSessionUseCase(integrator, sessions, users, now: () => now);
    logout = LogoutUseCase(sessions, users);
  });

  test('login stores the token and the current user', () async {
    final token = jwtExpiringAt(now.add(const Duration(minutes: 30)));
    integrator.loginResponse = AuthResponse(accessToken: token, refreshToken: 'refresh', user: emily);
    integrator.currentUser = emily;

    final user = await login.call(params: const LoginParams(username: ' emilys ', password: 'emilyspass'));

    expect(user, emily);
    expect(sessions.session?.userId, emily.id);
    expect(sessions.session?.accessToken, token);
    expect(sessions.session?.refreshToken, 'refresh');
    expect(sessions.session?.expiresAt, DateTime.fromMillisecondsSinceEpoch(now.add(const Duration(minutes: 30)).millisecondsSinceEpoch));
    expect(users.user, emily);
  });

  test('a rejected login does not store a session', () async {
    integrator.loginError = const RequestException(RequestErrorType.unAuthorized, 'Invalid credentials');

    expect(
      login.call(params: const LoginParams(username: 'emilys', password: 'wrong')),
      throwsA(isA<BusinessException>().having((error) => error.type, 'type', BusinessExceptionType.invalidCredentials)),
    );
    expect(sessions.session, isNull);
    expect(users.user, isNull);
  });

  test('a network failure during login is not treated as a bad password', () async {
    integrator.loginError = const RequestException(RequestErrorType.networkError, 'offline');

    expect(
      login.call(params: const LoginParams(username: 'emilys', password: 'emilyspass')),
      throwsA(isA<RequestException>().having((error) => error.type, 'type', RequestErrorType.networkError)),
    );
  });

  test('blank credentials never reach the server', () async {
    expect(
      login.call(params: const LoginParams(username: ' ', password: '')),
      throwsA(isA<BusinessException>().having((error) => error.type, 'type', BusinessExceptionType.inputValuesIsMissingOrIncorrect)),
    );
    expect(integrator.loginCalls, 0);
  });

  test('a valid token restores the user from the server', () async {
    sessions.session = AuthSession(
      userId: emily.id,
      accessToken: jwtExpiringAt(now.add(const Duration(hours: 1))),
      expiresAt: now.add(const Duration(hours: 1)),
    );
    integrator.currentUser = emily;

    final result = await restore.call(params: const NoParams());

    expect(result.hasSession, isTrue);
    expect(result.isOffline, isFalse);
    expect(result.user, emily);
    expect(users.user, emily);
  });

  test('an expired token is cleared', () async {
    sessions.session = AuthSession(
      userId: emily.id,
      accessToken: 'old',
      expiresAt: now.subtract(const Duration(seconds: 1)),
    );
    users.user = emily;

    final result = await restore.call(params: const NoParams());

    expect(result.hasSession, isFalse);
    expect(sessions.session, isNull);
    expect(users.user, isNull);
    expect(integrator.currentUser, isNull);
  });

  test('a token the server rejects is cleared', () async {
    sessions.session = AuthSession(
      userId: emily.id,
      accessToken: 'rejected',
      expiresAt: now.add(const Duration(hours: 1)),
    );
    users.user = emily;
    integrator.currentUserError = const RequestException(RequestErrorType.unAuthorized, '401');

    final result = await restore.call(params: const NoParams());

    expect(result.hasSession, isFalse);
    expect(sessions.session, isNull);
    expect(users.user, isNull);
  });

  test('a cached profile is used when the network is down', () async {
    sessions.session = AuthSession(
      userId: emily.id,
      accessToken: 'token',
      expiresAt: now.add(const Duration(hours: 1)),
    );
    users.user = emily;
    integrator.currentUserError = const RequestException(RequestErrorType.cannotConnectToServer, 'offline');

    final result = await restore.call(params: const NoParams());

    expect(result.user, emily);
    expect(result.isOffline, isTrue);
    expect(sessions.session, isNotNull);
  });

  test('logout removes the token and the cached user', () async {
    sessions.session = AuthSession(userId: emily.id, accessToken: 'token', expiresAt: now.add(const Duration(hours: 1)));
    users.user = emily;

    await logout.call(params: const NoParams());

    expect(sessions.session, isNull);
    expect(users.user, isNull);
  });
}
