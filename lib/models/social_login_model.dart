import 'package:flutter_space_dee/models/user_model.dart';

class SocialLoginModel {
  final Map data;

  SocialLoginModel({required this.data});

  String get accessToken => data['access_token'] ?? '';

  String get refreshToken => data['refresh_token'] ?? '';

  int get expiresIn => data['expires_in'] ?? 0;

  UserModel get user => UserModel(data: data['user'] ?? {});
}
