class AuthSessionModel {
  const AuthSessionModel({
    required this.accessToken,
    required this.tokenType,
    required this.user,
  });

  final String accessToken;
  final String tokenType;
  final Map<String, dynamic> user;

  factory AuthSessionModel.fromJson(
    Map<String, dynamic> json,
  ) {
    final dynamic userData = json['user'];

    return AuthSessionModel(
      accessToken: json['accessToken']?.toString() ?? '',
      tokenType: json['tokenType']?.toString() ?? 'Bearer',
      user: userData is Map
          ? Map<String, dynamic>.from(userData)
          : <String, dynamic>{},
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'accessToken': accessToken,
      'tokenType': tokenType,
      'user': user,
    };
  }

  bool get hasValidToken => accessToken.isNotEmpty;

  AuthSessionModel copyWith({
    String? accessToken,
    String? tokenType,
    Map<String, dynamic>? user,
  }) {
    return AuthSessionModel(
      accessToken: accessToken ?? this.accessToken,
      tokenType: tokenType ?? this.tokenType,
      user: user ?? this.user,
    );
  }
}
