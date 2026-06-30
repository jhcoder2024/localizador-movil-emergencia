import 'package:equatable/equatable.dart';

class ContactoEmergencia extends Equatable {
  final String id;
  final String nombre;
  final String telefono;
  final bool tieneWhatsApp;
  final bool tieneTelegram;
  final String? chatIdTelegram;

  const ContactoEmergencia({
    required this.id,
    required this.nombre,
    required this.telefono,
    this.tieneWhatsApp = false,
    this.tieneTelegram = false,
    this.chatIdTelegram,
  });

  ContactoEmergencia copyWith({
    String? id,
    String? nombre,
    String? telefono,
    bool? tieneWhatsApp,
    bool? tieneTelegram,
    String? chatIdTelegram,
  }) {
    return ContactoEmergencia(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
      telefono: telefono ?? this.telefono,
      tieneWhatsApp: tieneWhatsApp ?? this.tieneWhatsApp,
      tieneTelegram: tieneTelegram ?? this.tieneTelegram,
      chatIdTelegram: chatIdTelegram ?? this.chatIdTelegram,
    );
  }

  @override
  List<Object?> get props => [id, nombre, telefono, tieneWhatsApp, tieneTelegram, chatIdTelegram];
}
