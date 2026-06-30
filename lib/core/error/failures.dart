abstract class Failure {
  final String message;

  const Failure({required this.message});
}

class ServerFailure extends Failure {
  const ServerFailure({required super.message});
}

class NetworkFailure extends Failure {
  const NetworkFailure({required super.message});
}

class DatabaseFailure extends Failure {
  const DatabaseFailure({required super.message});
}

class PermissionFailure extends Failure {
  const PermissionFailure({required super.message});
}

class LocationFailure extends Failure {
  const LocationFailure({required super.message});
}

class TelegramFailure extends Failure {
  const TelegramFailure({required super.message});
}

class SmsFailure extends Failure {
  const SmsFailure({required super.message});
}
