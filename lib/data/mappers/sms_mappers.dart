import 'package:drift/drift.dart';
import 'package:localizador_movil_emergencia/data/datasources/local/app_database.dart';
import 'package:localizador_movil_emergencia/domain/entities/conversation.dart';
import 'package:localizador_movil_emergencia/domain/entities/sms_message.dart';

class SmsMappers {
  static Conversation fromConversationTable(ConversationsTableData row) {
    return Conversation(
      id: row.id,
      remitente: row.remitente,
      telefono: row.telefono,
      ultimoMensaje: row.ultimoMensaje,
      ultimaFecha: DateTime.fromMillisecondsSinceEpoch(row.ultimaFecha),
      noLeidos: row.noLeidos,
    );
  }

  static ConversationsTableCompanion toConversationCompanion(Conversation c) {
    return ConversationsTableCompanion(
      id: Value(c.id),
      remitente: Value(c.remitente),
      telefono: Value(c.telefono),
      ultimoMensaje: Value(c.ultimoMensaje),
      ultimaFecha: Value(c.ultimaFecha.millisecondsSinceEpoch),
      noLeidos: Value(c.noLeidos),
    );
  }

  static SmsMessage fromSmsMessageTable(SmsMessagesTableData row) {
    return SmsMessage(
      id: row.id,
      conversationId: row.conversationId,
      remitente: row.remitente,
      telefono: row.telefono,
      cuerpo: row.cuerpo,
      fecha: DateTime.fromMillisecondsSinceEpoch(row.fecha),
      tipo: row.tipo == 1 ? MensajeType.received : MensajeType.sent,
      leido: row.leido,
      tieneMms: row.tieneMms,
      estadoEnvio: row.estadoEnvio,
    );
  }

  static SmsMessagesTableCompanion toSmsMessageCompanion(SmsMessage m) {
    return SmsMessagesTableCompanion(
      conversationId: Value(m.conversationId),
      remitente: Value(m.remitente),
      telefono: Value(m.telefono),
      cuerpo: Value(m.cuerpo),
      fecha: Value(m.fecha.millisecondsSinceEpoch),
      tipo: Value(m.tipo == MensajeType.received ? 1 : 2),
      leido: Value(m.leido),
      tieneMms: Value(m.tieneMms),
      estadoEnvio: Value(m.estadoEnvio),
    );
  }
}
