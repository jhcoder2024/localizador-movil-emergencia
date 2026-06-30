import 'package:localizador_movil_emergencia/domain/entities/coordenadas.dart';
import 'package:localizador_movil_emergencia/domain/entities/configuracion.dart';

class MessageBuilder {
  MessageBuilder._();

  static String buildSmsMensaje(Coordenadas ubicacion,
      {String? mensajePersonalizado}) {
    final base =
        mensajePersonalizado ?? '¡EMERGENCIA! Necesito ayuda. Mi ubicación: ';
    return '$base${_formatoTexto(ubicacion)}';
  }

  static String buildTelegramMensaje(Coordenadas ubicacion,
      {String? mensajePersonalizado}) {
    final base = mensajePersonalizado ??
        '🚨 *ALERTA DE EMERGENCIA*\n\nNecesito ayuda urgente.\n\nMi ubicación: ';
    return '$base${_formatoTexto(ubicacion)}';
  }

  static String buildWhatsappMensaje(Coordenadas ubicacion,
      {String? mensajePersonalizado}) {
    final base = mensajePersonalizado ??
        '🚨 EMERGENCIA - Necesito ayuda. Mi ubicación: ';
    return '$base${_formatoTexto(ubicacion)}';
  }

  static String buildMensajeCompleto(
      Coordenadas ubicacion, Configuracion config) {
    final mensaje = StringBuffer();
    mensaje.writeln('🚨 ALERTA DE EMERGENCIA');
    mensaje.writeln('');
    mensaje.writeln('¡Necesito ayuda urgente!');
    mensaje.writeln('');
    mensaje.writeln('📍 Mi ubicación:');
    mensaje.writeln(_formatoTexto(ubicacion));
    mensaje.writeln('');
    mensaje.writeln('🕐 Hora: ${ubicacion.timestamp.toIso8601String()}');
    return mensaje.toString();
  }

  static String _formatoTexto(Coordenadas u) {
    return 'https://maps.google.com/?q=${u.latitud},${u.longitud}';
  }
}
