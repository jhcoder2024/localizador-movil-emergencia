import 'package:equatable/equatable.dart';

enum MensajeType { received, sent }

class SmsMessage extends Equatable {
  final int? id;
  final String conversationId;
  final String remitente;
  final String telefono;
  final String cuerpo;
  final DateTime fecha;
  final MensajeType tipo;
  final bool leido;
  final bool tieneMms;
  final String estadoEnvio;

  const SmsMessage({
    this.id,
    required this.conversationId,
    required this.remitente,
    required this.telefono,
    required this.cuerpo,
    required this.fecha,
    required this.tipo,
    this.leido = false,
    this.tieneMms = false,
    this.estadoEnvio = 'sent',
  });

  SmsMessage copyWith({
    int? id,
    String? conversationId,
    String? remitente,
    String? telefono,
    String? cuerpo,
    DateTime? fecha,
    MensajeType? tipo,
    bool? leido,
    bool? tieneMms,
    String? estadoEnvio,
  }) {
    return SmsMessage(
      id: id ?? this.id,
      conversationId: conversationId ?? this.conversationId,
      remitente: remitente ?? this.remitente,
      telefono: telefono ?? this.telefono,
      cuerpo: cuerpo ?? this.cuerpo,
      fecha: fecha ?? this.fecha,
      tipo: tipo ?? this.tipo,
      leido: leido ?? this.leido,
      tieneMms: tieneMms ?? this.tieneMms,
      estadoEnvio: estadoEnvio ?? this.estadoEnvio,
    );
  }

  @override
  List<Object?> get props => [id, conversationId, remitente, telefono, cuerpo, fecha, tipo, leido, tieneMms, estadoEnvio];
}
