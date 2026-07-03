import 'package:localizador_movil_emergencia/domain/repositories/sms_repository.dart';

class DisponibilidadCanales {
  final bool smsDisponible;

  const DisponibilidadCanales({
    this.smsDisponible = true,
  });
}

class VerificarDisponibilidadCanalUseCase {
  final SmsRepository _smsRepository;

  VerificarDisponibilidadCanalUseCase(
    this._smsRepository,
  );

  Future<DisponibilidadCanales> call() async {
    final smsDisponible = await _smsRepository.estaDisponible();

    return DisponibilidadCanales(
      smsDisponible: smsDisponible,
    );
  }
}
