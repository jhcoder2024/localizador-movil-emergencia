import 'package:flutter/foundation.dart';
import 'package:flutter_sms/flutter_sms.dart';
import 'package:localizador_movil_emergencia/domain/repositories/sms_repository.dart';

class SmsRepositoryImpl implements SmsRepository {
  @override
  Future<bool> enviarSms(String telefono, String mensaje) async {
    try {
      await sendSMS(message: mensaje, recipients: [telefono]);
      return true;
    } catch (e) {
      debugPrint('[SmsRepository] Error: $e');
      return false;
    }
  }
}
