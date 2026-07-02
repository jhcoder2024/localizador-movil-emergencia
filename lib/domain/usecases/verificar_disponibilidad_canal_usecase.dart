import 'package:localizador_movil_emergencia/domain/repositories/sms_repository.dart';
import 'package:localizador_movil_emergencia/domain/repositories/config_repository.dart';

class DisponibilidadCanales {
  final bool smsDisponible;

  const DisponibilidadCanales({
    this.smsDisponible = true,
  });
}

class VerificarDisponibilidadCanalUseCase {
  final SmsRepository _smsRepository;
  final ConfigRepository _configRepository;

  VerificarDisponibilidadCanalUseCase(
    this._smsRepository,
    this._configRepository,
  );

  Future<DisponibilidadCanales> call() async {
    final smsDisponible = await _smsRepository.estaDisponible();

    return DisponibilidadCanales(
      smsDisponible: smsDisponible,
    );
  }
}
