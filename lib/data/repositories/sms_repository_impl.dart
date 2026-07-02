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

      // 1. Intentar envío directo (SmsManager)
      try {
        final result = await _channel.invokeMethod<bool>('sendSms', {
          'telefono': telefonoNormalizado,
          'mensaje': mensaje,
        });
        if (result == true) {
          debugPrint('[SmsRepository] SMS enviado directamente');
          return true;
        }
      } catch (e) {
        debugPrint('[SmsRepository] Envío directo falló: $e');
      }

      // 2. Verificar si somos app SMS default
      final esDefault = await esAppSmsDefault();
      if (!esDefault) {
        debugPrint('[SmsRepository] No somos app SMS default. Solicitando...');
        // Mostrar diálogo de confirmación en la UI mejor aquí
      }

      // 3. Fallback: abrir app de SMS
      debugPrint('[SmsRepository] Abriendo app de SMS como fallback...');
      await _channel.invokeMethod('abrirAppSms', {
        'telefono': telefonoNormalizado,
        'mensaje': mensaje,
      });
      return true;
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
