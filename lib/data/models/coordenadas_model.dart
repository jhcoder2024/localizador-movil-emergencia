import 'package:json_annotation/json_annotation.dart';

part 'coordenadas_model.g.dart';

@JsonSerializable()
class CoordenadasModel {
  final double latitud;
  final double longitud;
  final DateTime timestamp;
  final double precision;

  const CoordenadasModel({
    required this.latitud,
    required this.longitud,
    required this.timestamp,
    this.precision = 0.0,
  });

  factory CoordenadasModel.fromJson(Map<String, dynamic> json) =>
      _$CoordenadasModelFromJson(json);

  Map<String, dynamic> toJson() => _$CoordenadasModelToJson(this);
}
