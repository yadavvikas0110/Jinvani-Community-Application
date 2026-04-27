class AuthUser {
  final String id;
  final String name;
  final String? email;
  final String phone;
  final String role;
  final bool isPhoneVerified;
  final bool isEmailVerified;
  final List<String> roles;
  final int profileCompletion;

  AuthUser({
    required this.id,
    required this.name,
    required this.phone,
    required this.role,
    required this.isPhoneVerified,
    required this.isEmailVerified,
    required this.roles,
    required this.profileCompletion,
    this.email,
  });

  factory AuthUser.fromJson(Map<String, dynamic> j) => AuthUser(
        id: j['id'] as String,
        name: j['name'] as String,
        email: j['email'] as String?,
        phone: j['phone'] as String,
        role: j['role'] as String? ?? 'member',
        isPhoneVerified: j['isPhoneVerified'] as bool? ?? false,
        isEmailVerified: j['isEmailVerified'] as bool? ?? false,
        roles: ((j['roles'] ?? const []) as List).map((e) => e.toString()).toList(),
        profileCompletion: (j['profileCompletion'] as num?)?.toInt() ?? 20,
      );
}
