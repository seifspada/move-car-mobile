// lib/features/auth/domain/entities/user_entity.dart

class UserEntity {
  final String id;
  final String email;
  final String nom;
  final String prenom;
  final String role;
  final String? avatar;
  final bool isActive;

  const UserEntity({
    required this.id,
    required this.email,
    required this.nom,
    required this.prenom,
    required this.role,
    this.avatar,
    this.isActive = true,
  });

  String get fullName => '$prenom $nom';
}