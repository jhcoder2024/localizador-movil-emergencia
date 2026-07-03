import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:localizador_movil_emergencia/domain/repositories/sms_repository.dart';

class SmsRepositoryImpl implements SmsRepository {
  static const _channel = MethodChannel('com.example.localizador_movil_emergencia/sms');

  String _normalizarTelefono(String telefono) {
    String limpio = telefono.replaceAll(RegExp(r'[^\d+]'), '');
    if (limpio.startsWith('+')) return limpio;
    if (limpio.startsWith('0')) return '+58${limpio.substring(1)}';
    if (limpio.startsWith('58')) return '+$limpio';
    if (limpio.length <= 10) return '+58$limpio';
    return '+$limpio';
  }

  @override
  Future<bool> enviarSms(String telefono, String mensaje) async {
    try {
      final telefonoNormalizado = _normalizarTelefono(telefono);
      debugPrint('[SmsRepository] Enviando SMS a $telefono (normalizado: $telefonoNormalizado)');

      // Envío directo con SmsManager
      // Con target SDK 33, funciona aunque no seamos la app SMS default
      final result = await _channel.invokeMethod<bool>('sendSms', {
        'telefono': telefonoNormalizado,
        'mensaje': mensaje,
      });
      
      if (result == true) {
        debugPrint('[SmsRepository] SMS enviado directamente');
        return true;
      } else {
        debugPrint('[SmsRepository] Error: SMS no enviado');
        return false;
      }
    } catch (e) {
      debugPrint('[SmsRepository] Error: $e');
      return false;
    }
  }

  @override
  Future<bool> estaDisponible() async {
    return true;
  }

  @override
  Future<bool> esAppSmsDefault() async {
    try {
      final result = await _channel.invokeMethod<bool>('esAppSmsDefault');
      return result ?? false;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<bool> solicitarSerSmsDefault() async {
    try {
      final result = await _channel.invokeMethod<bool>('solicitarSerSmsDefault');
      return result ?? false;
    } catch (e) {
      debugPrint('[SmsRepository] Error solicitando ser default: $e');
      return false;
    }
  }
}
