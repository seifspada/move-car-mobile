// lib/core/utils/extensions.dart

import '../error/exceptions.dart';
import '../error/failures.dart';

extension ExceptionToFailure on Exception {
  Failure toFailure() {
    if (this is ServerException) {
      return ServerFailure(
        message: (this as ServerException).message,
        statusCode: (this as ServerException).statusCode,
      );
    } else if (this is NetworkException) {
      return NetworkFailure(message: (this as NetworkException).message);
    } else if (this is CacheException) {
      return CacheFailure(message: (this as CacheException).message);
    } else if (this is UnauthorizedException) {
      return UnauthorizedFailure(
        message: (this as UnauthorizedException).message,
      );
    } else if (this is GraphQLException) {
      return GraphQLFailure(
        message: (this as GraphQLException).message,
        errors: (this as GraphQLException).errors,
      );
    }
    return UnknownFailure(); // ← pas de const
  }
}

extension StringExtensions on String {
  bool get isValidEmail =>
      RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(this);

  bool get isValidPassword => length >= 8;

  String get capitalize {
    if (isEmpty) return this;
    return '${this[0].toUpperCase()}${substring(1)}';
  }
}

extension DateTimeExtensions on DateTime {
  String get formatted =>
      '$day/${month.toString().padLeft(2, '0')}/$year';

  String get timeAgo {
    final diff = DateTime.now().difference(this);
    if (diff.inMinutes < 1) return 'À l\'instant';
    if (diff.inHours < 1) return 'Il y a ${diff.inMinutes} min';
    if (diff.inDays < 1) return 'Il y a ${diff.inHours}h';
    return 'Il y a ${diff.inDays}j';
  }
}