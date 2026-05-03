// lib/features/auth/data/models/auth_response_model.dart

import '../../domain/entities/user_entity.dart';

class AuthResponseModel {
  final String accessToken;
  final UserModel user;

  const AuthResponseModel({
    required this.accessToken,
    required this.user,
  });

  factory AuthResponseModel.fromJson(Map<String, dynamic> json) {
    return AuthResponseModel(
      // ✅ backend envoie 'accessToken' pas 'access_token'
      accessToken: json['accessToken'] as String,
      user: UserModel.fromJson(json['user'] as Map<String, dynamic>),
    );
  }
}

class UserModel {
  final String id;
  final String email;
  final String nom;
  final String prenom;
  final String role;
  final String? avatar;
  final bool isActive;

  const UserModel({
    required this.id,
    required this.email,
    required this.nom,
    required this.prenom,
    required this.role,
    this.avatar,
    this.isActive = true,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    // ✅ nom/prenom sont dans l'objet 'adherent' imbriqué
    final adherent = json['adherent'] as Map<String, dynamic>?;

    // ✅ role est un objet {'id': 2, 'name': 'adherent'}
    final roleObj = json['role'];
    final String roleName = roleObj is Map<String, dynamic>
        ? (roleObj['name'] as String? ?? 'inconnu')
        : (roleObj as String? ?? 'inconnu');

    return UserModel(
      // ✅ id vient directement de user.id (int → String)
      id: json['id'].toString(),

      email: json['email'] as String,

      // ✅ nom/prenom depuis adherent, fallback sur name si adherent null
      nom: adherent?['nom'] as String? ??
          (json['name'] as String? ?? '').split(' ').skip(1).join(' '),
      prenom: adherent?['prenom'] as String? ??
          (json['name'] as String? ?? '').split(' ').first,

      role: roleName,

      // ✅ photo pas avatar
      avatar: json['photo'] as String?,

      // ✅ n'existe pas dans la réponse → toujours true
      isActive: json['isActive'] as bool? ?? true,
    );
  }

  UserEntity toEntity() {
    return UserEntity(
      id: id,
      email: email,
      nom: nom,
      prenom: prenom,
      role: role,
      avatar: avatar,
      isActive: isActive,
    );
  }
}