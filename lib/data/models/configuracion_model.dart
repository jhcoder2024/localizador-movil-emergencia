import 'package:json_annotation/json_annotation.dart';
import 'package:localizador_movil_emergencia/data/models/contacto_model.dart';

part 'configuracion_model.g.dart';

@JsonSerializable()
class ConfiguracionModel {
  final int intervaloMinutos;
  final List<ContactoModel> contactos;
  final String idioma;
  final String? telegramToken;

  const ConfiguracionModel({
    this.intervaloMinutos = 5,
    this.contactos = const [],
    this.idioma = 'es',
    this.telegramToken,
  });

  factory ConfiguracionModel.fromJson(Map<String, dynamic> json) =>
      _$ConfiguracionModelFromJson(json);

  Map<String, dynamic> toJson() => _$ConfiguracionModelToJson(this);
}
