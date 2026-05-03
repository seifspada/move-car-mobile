// lib/core/error/exceptions.dart

class ServerException implements Exception {
  final String message;
  final int? statusCode;
  const ServerException({required this.message, this.statusCode});

  @override
  String toString() => 'ServerException: $message (code: $statusCode)';
}

class NetworkException implements Exception {
  final String message;
  const NetworkException({this.message = 'Pas de connexion internet'});

  @override
  String toString() => 'NetworkException: $message';
}

class CacheException implements Exception {
  final String message;
  const CacheException({this.message = 'Erreur de cache local'});

  @override
  String toString() => 'CacheException: $message';
}

class UnauthorizedException implements Exception {
  final String message;
  const UnauthorizedException({
    this.message = 'Non autorisé - token invalide ou expiré',
  });

  @override
  String toString() => 'UnauthorizedException: $message';
}

class GraphQLException implements Exception {
  final String message;
  final List<String> errors;
  const GraphQLException({required this.message, this.errors = const []});

  @override
  String toString() => 'GraphQLException: $message';
}

class UnknownException implements Exception {
  final String message;
  const UnknownException({this.message = 'Erreur inconnue'});

  @override
  String toString() => 'UnknownException: $message';
}