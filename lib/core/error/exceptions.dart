class ServerException implements Exception {
  final String message;
  final int? statusCode;

  const ServerException({required this.message, this.statusCode});

  @override
  String toString() => 'ServerException: $message (statusCode: $statusCode)';
}

class NetworkException implements Exception {
  final String message;

  const NetworkException({required this.message});

  @override
  String toString() => 'NetworkException: $message';
}

class DatabaseException implements Exception {
  final String message;

  const DatabaseException({required this.message});

  @override
  String toString() => 'DatabaseException: $message';
}

class PermissionDeniedException implements Exception {
  final String permission;

  const PermissionDeniedException({required this.permission});

  @override
  String toString() => 'PermissionDeniedException: $permission';
}

class LocationException implements Exception {
  final String message;

  const LocationException({required this.message});

  @override
  String toString() => 'LocationException: $message';
}

class TelegramException implements Exception {
  final String message;

  const TelegramException({required this.message});

  @override
  String toString() => 'TelegramException: $message';
}

class SmsException implements Exception {
  final String message;

  const SmsException({required this.message});

  @override
  String toString() => 'SmsException: $message';
}
