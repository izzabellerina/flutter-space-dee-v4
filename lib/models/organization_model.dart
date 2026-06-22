class OrganizationModel {
  final Map data;

  OrganizationModel({required this.data});

  //------- Section 1 -------//
  String get id => data['id'] ?? '';

  String get name => data['name'] ?? '';

  String get slug => data['slug'] ?? '';

  String get businessType => data['business_type'] ?? '';

  String get ownerName => data['owner_name'] ?? '';

  String get subscriptionStatus => data['subscription_status'] ?? '';

  Map get settings => data['settings'] ?? {};

  DateTime get createdAt => DateTime.parse(data['created_at'] ?? '');

  DateTime get updatedAt => DateTime.parse(data['updated_at'] ?? '');

  //------- Section 2 -------//
  String get userId => data['user_id'] ?? '';

  String get organizationId => data['organization_id'] ?? '';

  String get role => data['role'] ?? '';

  bool get isPrimary => data['is_primary'] ?? false;

  List<String> get assignedPropertyIds => data['assigned_property_ids'] ?? [];

  List<String> get tags => data['tags'] ?? [];

  List<String> get notes => data['notes'] ?? [];

  OrganizationModel get organization =>
      OrganizationModel(data: data['organization'] ?? {});
}
