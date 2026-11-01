import 'package:equatable/equatable.dart';
import 'package:lavaloon_assessment/data/models/auth_user.dart';

class RestoreSessionResult extends Equatable {
  final AuthUser? user;
  final bool isOffline;

  const RestoreSessionResult({this.user, this.isOffline = false});

  bool get hasSession => user != null;

  @override
  List<Object?> get props => [user, isOffline];
}
