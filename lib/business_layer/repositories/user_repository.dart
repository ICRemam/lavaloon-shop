import 'package:lavaloon_assessment/data/models/auth_user.dart';

abstract class UserRepository {
  Future<void> saveUser(AuthUser user);

  Future<AuthUser?> getCachedUser(int userId);

  Future<void> clearUser();
}
