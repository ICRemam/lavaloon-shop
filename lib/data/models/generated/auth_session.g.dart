// GENERATED CODE - DO NOT MODIFY BY HAND

part of '../auth_session.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AuthSession _$AuthSessionFromJson(Map<String, dynamic> json) => AuthSession(
  userId: (json['userId'] as num).toInt(),
  accessToken: json['accessToken'] as String,
  refreshToken: json['refreshToken'] as String?,
  expiresAt: DateTime.parse(json['expiresAt'] as String),
);

Map<String, dynamic> _$AuthSessionToJson(AuthSession instance) => <String, dynamic>{
  'userId': instance.userId,
  'accessToken': instance.accessToken,
  'refreshToken': instance.refreshToken,
  'expiresAt': instance.expiresAt.toIso8601String(),
};
