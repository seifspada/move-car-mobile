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
  // ← Vérification que 'user' existe avant de parser
  final userJson = json['user'];
  if (userJson == null) {
    throw Exception('Réponse serveur invalide : champ "user" manquant. Reçu : $json');
  }
  
  return AuthResponseModel(
    accessToken: json['accessToken'] as String,
    user: UserModel.fromJson(userJson as Map<String, dynamic>),
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
  // ← Guard contre undefined/null en JS
  if (json.isEmpty) throw Exception('UserModel.fromJson: json vide');
  
  final adherent = json['adherent'] as Map<String, dynamic>?;
  final roleObj = json['role'];
  final String roleName = roleObj is Map<String, dynamic>
      ? (roleObj['name'] as String? ?? 'inconnu')
      : (roleObj as String? ?? 'inconnu');

  return UserModel(
    id: json['id']?.toString() ?? '',     // ← ?.toString() au lieu de .toString()
    email: json['email'] as String? ?? '',
    nom: adherent?['nom'] as String? ??
        (json['name'] as String? ?? '').split(' ').skip(1).join(' '),
    prenom: adherent?['prenom'] as String? ??
        (json['name'] as String? ?? '').split(' ').first,
    role: roleName,
    avatar: json['photo'] as String?,
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