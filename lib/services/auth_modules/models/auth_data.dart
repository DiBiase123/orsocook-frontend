class AuthData {
  final String token;
  final String refreshToken;
  final String userId;
  final String username;
  final String? avatarUrl;
  final bool isVerified;
  final DateTime tokenExpiry;

  AuthData({
    required this.token,
    required this.refreshToken,
    required this.userId,
    required this.username,
    this.avatarUrl,
    required this.isVerified,
    required this.tokenExpiry,
  });

  Map<String, dynamic> toJson() => {
        'token': token,
        'refreshToken': refreshToken,
        'userId': userId,
        'username': username,
        'avatarUrl': avatarUrl,
        'isVerified': isVerified,
        'tokenExpiry': tokenExpiry.toIso8601String(),
      };

  factory AuthData.fromJson(Map<String, dynamic> json) => AuthData(
        token: json['token'] as String,
        refreshToken: json['refreshToken'] as String,
        userId: json['userId'] as String,
        username: json['username'] as String,
        avatarUrl: json['avatarUrl'] as String?,
        isVerified: json['isVerified'] as bool? ?? false,
        tokenExpiry: DateTime.parse(json['tokenExpiry'] as String),
      );

  bool get isTokenExpired => DateTime.now().isAfter(tokenExpiry);
  bool get canRefresh => refreshToken.isNotEmpty;

  // Metodo copyWith per creare copie modificate
  AuthData copyWith({
    String? token,
    String? refreshToken,
    String? userId,
    String? username,
    String? avatarUrl,
    bool? isVerified,
    DateTime? tokenExpiry,
  }) {
    return AuthData(
      token: token ?? this.token,
      refreshToken: refreshToken ?? this.refreshToken,
      userId: userId ?? this.userId,
      username: username ?? this.username,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      isVerified: isVerified ?? this.isVerified,
      tokenExpiry: tokenExpiry ?? this.tokenExpiry,
    );
  }
}
