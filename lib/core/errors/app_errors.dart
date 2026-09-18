abstract class AppError implements Exception {
  final String message;
  final String? code;
  final dynamic originalError;

  AppError(this.message, {this.code, this.originalError});

  @override
  String toString() =>
      '$runtimeType: $message${code != null ? ' ($code)' : ''}';
}

class ValidationError extends AppError {
  ValidationError(super.message, {super.code, super.originalError});
}

class DatabaseError extends AppError {
  DatabaseError(super.message, {super.code, super.originalError});
}

class BackupError extends AppError {
  BackupError(super.message, {super.code, super.originalError});
}

class AuthenticationError extends AppError {
  AuthenticationError(super.message, {super.code, super.originalError});
}

class NetworkError extends AppError {
  NetworkError(super.message, {super.code, super.originalError});
}

class RestoreError extends AppError {
  RestoreError(super.message, {super.code, super.originalError});
}

class EncryptionError extends AppError {
  EncryptionError(super.message, {super.code, super.originalError});
}
