import 'package:json_annotation/json_annotation.dart';

part 'contacto_model.g.dart';

@JsonSerializable()
class ContactoModel {
  final String id;
  final String nombre;
  final String telefono;
  final bool tieneWhatsApp;
  final bool tieneTelegram;
  final String? chatIdTelegram;

  const ContactoModel({
    required this.id,
    required this.nombre,
    required this.telefono,
    this.tieneWhatsApp = false,
    this.tieneTelegram = false,
    this.chatIdTelegram,
  });

  factory ContactoModel.fromJson(Map<String, dynamic> json) =>
      _$ContactoModelFromJson(json);

  Map<String, dynamic> toJson() => _$ContactoModelToJson(this);
}
