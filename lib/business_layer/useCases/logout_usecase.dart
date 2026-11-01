import 'package:lavaloon_assessment/business_layer/repositories/user_repository.dart';
import 'package:lavaloon_assessment/business_layer/useCases/params/no_params.dart';
import 'package:lavaloon_assessment/data/abstract/base_usecase.dart';
import 'package:lavaloon_assessment/data_access/storage/session_storage.dart';

class LogoutUseCase extends UseCase<void, NoParams> {
  final SessionStorage _sessionStorage;
  final UserRepository _userRepository;

  LogoutUseCase(this._sessionStorage, this._userRepository);

  @override
  Future<void> call({required NoParams params}) async {
    await _sessionStorage.clearSession();
    await _userRepository.clearUser();
  }
}
