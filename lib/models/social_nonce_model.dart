class SocialNonceModel {
  final Map data;

  SocialNonceModel({required this.data});

  int get expiresIn => data['expires_in'] ?? 0;

  String get nonce => data['nonce'] ?? '';
}
