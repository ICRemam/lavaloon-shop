import 'package:lavaloon_assessment/business_layer/repositories/user_repository.dart';
import 'package:lavaloon_assessment/business_layer/useCases/params/login_params.dart';
import 'package:lavaloon_assessment/data/abstract/base_usecase.dart';
import 'package:lavaloon_assessment/data/abstract/integrator.dart';
import 'package:lavaloon_assessment/data/constants/app_constants.dart';
import 'package:lavaloon_assessment/data/exceptions/business_error.dart';
import 'package:lavaloon_assessment/data/exceptions/request_exception.dart';
import 'package:lavaloon_assessment/data/models/auth_response.dart';
import 'package:lavaloon_assessment/data/models/auth_session.dart';
import 'package:lavaloon_assessment/data/models/auth_user.dart';
import 'package:lavaloon_assessment/data_access/storage/session_storage.dart';
import 'package:lavaloon_assessment/utils/jwt_util.dart';

class LoginUseCase extends UseCase<AuthUser, LoginParams> {
  final Integrator _integrator;
  final SessionStorage _sessionStorage;
  final UserRepository _userRepository;
  final DateTime Function() _now;

  LoginUseCase(this._integrator, this._sessionStorage, this._userRepository, {DateTime Function()? now}) : _now = now ?? DateTime.now;

  @override
  Future<AuthUser> call({required LoginParams params}) async {
    final username = params.username.trim();

    if (username.isEmpty || params.password.isEmpty) {
      throw const BusinessException(BusinessExceptionType.inputValuesIsMissingOrIncorrect);
    }

    final AuthResponse response;
    try {
      response = await _integrator.login(LoginParams(username: username, password: params.password));
    } on RequestException catch (e) {
      if (e.type.isRejection) {
        throw const BusinessException(BusinessExceptionType.invalidCredentials);
      }
      rethrow;
    }

    final user = await _integrator.getCurrentUser(response.accessToken);

    final expiresAt = JwtUtil.getExpiry(response.accessToken) ?? _now().add(const Duration(minutes: AppConstants.defaultSessionMinutes));

    await _sessionStorage.saveSession(
      AuthSession(userId: user.id, accessToken: response.accessToken, refreshToken: response.refreshToken, expiresAt: expiresAt),
    );
    await _userRepository.saveUser(user);

    return user;
  }
}
