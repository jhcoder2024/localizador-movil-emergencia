import 'package:localizador_movil_emergencia/domain/entities/contacto_emergencia.dart';
import 'package:localizador_movil_emergencia/domain/repositories/whatsapp_repository.dart';
import 'package:localizador_movil_emergencia/domain/repositories/telegram_repository.dart';
import 'package:localizador_movil_emergencia/domain/repositories/config_repository.dart';

class DisponibilidadCanales {
  final bool smsDisponible;
  final bool whatsappDisponible;
  final bool telegramDisponible;

  const DisponibilidadCanales({
    this.smsDisponible = true,
    this.whatsappDisponible = false,
    this.telegramDisponible = false,
  });
}

class VerificarDisponibilidadCanalUseCase {
  final WhatsappRepository _whatsappRepository;
  final TelegramRepository _telegramRepository;
  final ConfigRepository _configRepository;

  VerificarDisponibilidadCanalUseCase(
    this._whatsappRepository,
    this._telegramRepository,
    this._configRepository,
  );

  Future<DisponibilidadCanales> call(ContactoEmergencia contacto) async {
    final config = await _configRepository.obtenerConfiguracion().first;
    final whatsappInstalado = await _whatsappRepository.estaInstalado();
    final tokenValido = config.telegramToken != null
        ? await _telegramRepository.verificarToken(config.telegramToken!)
        : false;

    return DisponibilidadCanales(
      smsDisponible: true,
      whatsappDisponible: contacto.tieneWhatsApp && whatsappInstalado,
      telegramDisponible: contacto.tieneTelegram &&
          contacto.chatIdTelegram != null &&
          tokenValido,
    );
  }
}
