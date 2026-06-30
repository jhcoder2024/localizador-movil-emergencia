abstract class SmsRepository {
  Future<bool> enviarSms(String telefono, String mensaje);
}
