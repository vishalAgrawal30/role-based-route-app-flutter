class LoginResponse {
  final String token;
  final String role;
  final int userId;
  LoginResponse({
    required this.token,
    required this.role,
    required this.userId,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      token: json['accessToken'] ?? '',
      role: json['user']?['role'] ?? '',
      userId: json['user']?['id'] ?? 0,
    ); // ✅ Correctly handles the nested structure);
  }

  Map<String, dynamic> toJson() {
    return {'accessToken': token, 'role': role, 'id': userId};
  }
}
