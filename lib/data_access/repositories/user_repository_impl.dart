import 'dart:convert';
import 'package:lavaloon_assessment/business_layer/controllers/shared_preference_controller.dart';
import 'package:lavaloon_assessment/business_layer/repositories/user_repository.dart';
import 'package:lavaloon_assessment/data/mappers/user_mapper.dart';
import 'package:lavaloon_assessment/data/models/auth_user.dart';

class UserRepositoryImpl implements UserRepository {
  final SharedPreferenceController _preferences;
  final UserMapper _mapper;

  UserRepositoryImpl(this._preferences, {UserMapper? mapper}) : _mapper = mapper ?? UserMapper();

  @override
  Future<void> saveUser(AuthUser user) async {
    final entity = _mapper.convert(user);
    await _preferences.setString(key: SharedPreferenceConstant.cachedUser, value: jsonEncode(_mapper.convertBack(entity).toJson()));
  }

  @override
  Future<AuthUser?> getCachedUser(int userId) async {
    final raw = await _preferences.getString(key: SharedPreferenceConstant.cachedUser);
    if (raw == null || raw.isEmpty) return null;

    try {
      final user = AuthUser.fromJson(jsonDecode(raw) as Map<String, dynamic>);
      final entity = _mapper.convert(user);
      if (entity.id != userId) return null;

      return _mapper.convertBack(entity);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> clearUser() async {
    await _preferences.remove(key: SharedPreferenceConstant.cachedUser);
  }
}
