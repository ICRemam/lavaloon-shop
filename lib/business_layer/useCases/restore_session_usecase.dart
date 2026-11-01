import 'package:lavaloon_assessment/business_layer/repositories/user_repository.dart';
import 'package:lavaloon_assessment/business_layer/useCases/params/no_params.dart';
import 'package:lavaloon_assessment/data/abstract/base_usecase.dart';
import 'package:lavaloon_assessment/data/abstract/integrator.dart';
import 'package:lavaloon_assessment/data/exceptions/request_exception.dart';
import 'package:lavaloon_assessment/data/models/restore_session_result.dart';
import 'package:lavaloon_assessment/data_access/storage/session_storage.dart';

class RestoreSessionUseCase extends UseCase<RestoreSessionResult, NoParams> {
  final Integrator _integrator;
  final SessionStorage _sessionStorage;
  final UserRepository _userRepository;
  final DateTime Function() _now;

  RestoreSessionUseCase(this._integrator, this._sessionStorage, this._userRepository, {DateTime Function()? now})
    : _now = now ?? DateTime.now;

  @override
  Future<RestoreSessionResult> call({required NoParams params}) async {
    final session = await _sessionStorage.getSession();
    if (session == null) return const RestoreSessionResult();

    if (session.isExpiredAt(_now())) {
      await _clearStoredSession();
      return const RestoreSessionResult();
    }

    try {
      final user = await _integrator.getCurrentUser(session.accessToken);
      await _userRepository.saveUser(user);
      return RestoreSessionResult(user: user);
    } on RequestException catch (e) {
      if (e.type.isRejection) {
        await _clearStoredSession();
        return const RestoreSessionResult();
      }

      final cachedUser = await _userRepository.getCachedUser(session.userId);
      if (cachedUser == null) return const RestoreSessionResult();

      return RestoreSessionResult(user: cachedUser, isOffline: true);
    }
  }

  Future<void> _clearStoredSession() async {
    await _sessionStorage.clearSession();
    await _userRepository.clearUser();
  }
}
