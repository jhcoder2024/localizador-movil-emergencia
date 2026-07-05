import 'package:flutter/foundation.dart';
import 'package:localizador_movil_emergencia/domain/entities/tipo_emergencia.dart';
import 'package:localizador_movil_emergencia/domain/repositories/config_repository.dart';
import 'package:localizador_movil_emergencia/domain/repositories/emergency_repository.dart';
import 'package:localizador_movil_emergencia/domain/repositories/location_repository.dart';
import 'package:localizador_movil_emergencia/domain/repositories/sms_repository.dart';
import 'package:localizador_movil_emergencia/domain/repositories/sms_inbox_repository.dart';
import 'package:localizador_movil_emergencia/domain/entities/sms_message.dart';
import 'package:localizador_movil_emergencia/domain/entities/conversation.dart';

class EnviarUbicacionUseCase {
  final LocationRepository _locationRepository;
  final EmergencyRepository _emergencyRepository;
  final ConfigRepository _configRepository;
  final SmsRepository _smsRepository;
  final SmsInboxRepository _smsInboxRepository;

  EnviarUbicacionUseCase(
    this._locationRepository,
    this._emergencyRepository,
    this._configRepository,
    this._smsRepository,
    this._smsInboxRepository,
  );

  Future<void> call(TipoEmergencia tipo) async {
    final coordenadas = await _locationRepository.obtenerUbicacionActual();
    await _emergencyRepository.actualizarCoordenada(coordenadas);
    final config = await _configRepository.obtenerConfiguracion().first;
    final mensaje = tipo.construirMensaje(
      coordenadas.latitud,
      coordenadas.longitud,
    );

    debugPrint('[EnviarUbicacion] Iniciando envío a ${config.contactos.length} contacto(s)');
    debugPrint('[EnviarUbicacion] Mensaje: $mensaje');

    for (final contacto in config.contactos) {
      debugPrint('[EnviarUbicacion] Enviando a ${contacto.telefono}...');
      
      // Enviar SMS
      final exito = await _smsRepository.enviarSms(contacto.telefono, mensaje);
      debugPrint('[EnviarUbicacion] Resultado envío a ${contacto.telefono}: $exito');
      
      // Guardar en bandeja de entrada local
      try {
        final conversationId = contacto.telefono.replaceAll(RegExp(r'[^\d+]'), '');
        final msg = SmsMessage(
          conversationId: conversationId,
          remitente: 'Yo',
          telefono: contacto.telefono,
          cuerpo: mensaje,
          fecha: DateTime.now(),
          tipo: MensajeType.sent,
          leido: true,
          estadoEnvio: exito ? 'sent' : 'failed',
        );
        await _smsInboxRepository.insertMessage(msg);
        debugPrint('[EnviarUbicacion] Mensaje guardado en inbox');
        
        // Actualizar conversación
        await _smsInboxRepository.upsertConversation(
          Conversation(
            id: conversationId,
            remitente: contacto.nombre.isNotEmpty ? contacto.nombre : contacto.telefono,
            telefono: contacto.telefono,
            ultimoMensaje: mensaje,
            ultimaFecha: DateTime.now(),
            noLeidos: 0,
          ),
        );
      } catch (e) {
        debugPrint('[EnviarUbicacion] Error guardando en inbox: $e');
      }

      await Future.delayed(const Duration(milliseconds: 500));
    }
    
    debugPrint('[EnviarUbicacion] Envíos completados');
  }
}
