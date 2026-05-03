// lib/core/error/failures.dart


abstract class Failure {
  final String message;
  const Failure({required this.message});
}

class ServerFailure extends Failure {
  final int? statusCode;
  const ServerFailure({required super.message, this.statusCode});
}

class NetworkFailure extends Failure {
  const NetworkFailure({super.message = 'Pas de connexion internet'});
}

class CacheFailure extends Failure {
  const CacheFailure({super.message = 'Erreur de cache local'});
}

class UnauthorizedFailure extends Failure {
  const UnauthorizedFailure({
    super.message = 'Session expirée, veuillez vous reconnecter',
  });
}

class GraphQLFailure extends Failure {
  final List<String> errors;
  const GraphQLFailure({required super.message, this.errors = const []});
}

class UnknownFailure extends Failure {
  UnknownFailure({super.message = 'Une erreur inconnue est survenue'});
  // ← pas de const ici
}