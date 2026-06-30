import 'package:localizador_movil_emergencia/domain/entities/tipo_emergencia.dart';
import 'package:localizador_movil_emergencia/domain/repositories/config_repository.dart';
import 'package:localizador_movil_emergencia/domain/repositories/emergency_repository.dart';
import 'package:localizador_movil_emergencia/domain/repositories/location_repository.dart';
import 'package:localizador_movil_emergencia/domain/repositories/sms_repository.dart';
import 'package:localizador_movil_emergencia/domain/repositories/telegram_repository.dart';
import 'package:localizador_movil_emergencia/domain/repositories/whatsapp_repository.dart';
import 'package:localizador_movil_emergencia/domain/entities/configuracion.dart';

class EnviarUbicacionUseCase {
  final LocationRepository _locationRepository;
  final EmergencyRepository _emergencyRepository;
  final ConfigRepository _configRepository;
  final SmsRepository _smsRepository;
  final WhatsappRepository _whatsappRepository;
  final TelegramRepository _telegramRepository;

  EnviarUbicacionUseCase(
    this._locationRepository,
    this._emergencyRepository,
    this._configRepository,
    this._smsRepository,
    this._whatsappRepository,
    this._telegramRepository,
  );

  Future<void> call(TipoEmergencia tipo) async {
    // 1. Obtener ubicación (puntual, no streaming)
    final coordenadas = await _locationRepository.obtenerUbicacionActual();

    // 2. Actualizar estado con coordenada actual
    await _emergencyRepository.actualizarCoordenada(coordenadas);

    // 3. Obtener configuración y contactos
    final config = await _configRepository.obtenerConfiguracion().first;
    final mensaje = tipo.construirMensaje(
      coordenadas.latitud,
      coordenadas.longitud,
    );

    // 4. Enviar SECUENCIALMENTE para evitar picos de batería
    for (final contacto in config.contactos) {
      // SMS siempre (es lo más importante, funciona sin datos)
      await _smsRepository.enviarSms(contacto.telefono, mensaje);

      // WhatsApp si está disponible
      if (contacto.tieneWhatsApp) {
        await _whatsappRepository.abrirWhatsApp(contacto.telefono, mensaje);
      }

      // Telegram si tiene chatId configurado
      if (contacto.tieneTelegram &&
          contacto.chatIdTelegram != null &&
          config.telegramToken != null) {
        await _telegramRepository.enviarMensajeTelegram(
          contacto.chatIdTelegram!,
          mensaje,
          config.telegramToken!,
        );
      }

      // Pequeña pausa entre contactos para no saturar
      await Future.delayed(const Duration(milliseconds: 500));
    }

  }
}
