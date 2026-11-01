import 'package:lavaloon_assessment/data/abstract/base_mapper.dart';
import 'package:lavaloon_assessment/business_layer/entities/user_entity.dart';
import 'package:lavaloon_assessment/data/models/auth_user.dart';

class UserMapper extends BaseMapper<AuthUser, UserEntity> {
  @override
  UserEntity convert(AuthUser obj) {
    return UserEntity(
      id: obj.id,
      username: obj.username,
      email: obj.email,
      firstName: obj.firstName,
      lastName: obj.lastName,
      image: obj.image,
    );
  }

  @override
  AuthUser convertBack(UserEntity obj) {
    return AuthUser(
      id: obj.id,
      username: obj.username,
      email: obj.email,
      firstName: obj.firstName,
      lastName: obj.lastName,
      image: obj.image,
    );
  }
}
