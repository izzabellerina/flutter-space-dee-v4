import 'package:flutter_space_dee/models/organization_model.dart';

class UserModel {
  final Map data;

  UserModel({required this.data});

  String get id => data['id'] ?? '';

  String get email => data['email'] ?? '';

  String get name => data['name'] ?? '';

  String get phone => data['phone'] ?? '';

  String get userType => data['user_type'] ?? '';

  bool get isActive => data['is_active'] ?? false;

  bool get emailVerified => data['email_verified'] ?? false;

  bool get twoFactorEnabled => data['two_factor_enabled'] ?? false;

  String get oauthProvider => data['oauth_provider'] ?? '';

  String get oauthId => data['oauth_id'] ?? '';

  Map get metadata => data['metadata'] ?? {};

  DateTime get createdAt => DateTime.parse(data['created_at'] ?? '');

  DateTime get updatedAt => DateTime.parse(data['updated_at'] ?? '');

  List<OrganizationModel> get organizations => List.from(
    data['organizations'] ?? [],
  ).map((e) => OrganizationModel(data: e)).toList();
}
