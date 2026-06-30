import 'package:equatable/equatable.dart';

class Coordenadas extends Equatable {
  final double latitud;
  final double longitud;
  final DateTime timestamp;
  final double precision;

  const Coordenadas({
    required this.latitud,
    required this.longitud,
    required this.timestamp,
    this.precision = 0.0,
  });

  String toGoogleMapsUrl() => 'https://maps.google.com/?q=$latitud,$longitud';

  @override
  List<Object?> get props => [latitud, longitud, timestamp, precision];
}
