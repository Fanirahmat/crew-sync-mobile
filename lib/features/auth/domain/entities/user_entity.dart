/// Domain entity representing an authenticated event crew user.
class UserEntity {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String role; // e.g. STAGE_MANAGER, RUNNER, USHER, CATERING, SOUND
  final String? vendorName;
  final String? avatarUrl;

  const UserEntity({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.role,
    this.vendorName,
    this.avatarUrl,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserEntity &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          email == other.email;

  @override
  int get hashCode => id.hashCode ^ email.hashCode;
}
