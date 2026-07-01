import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:localizador_movil_emergencia/domain/repositories/sms_repository.dart';

class SmsRepositoryImpl implements SmsRepository {
  static const _channel = MethodChannel('com.example.localizador_movil_emergencia/sms');

  /// Normaliza un número telefónico a formato internacional.
  /// - Elimina guiones, espacios y paréntesis
  /// - Convierte prefijo 0XXX a +58XXX (Venezuela)
  /// - Si ya tiene +, lo respeta
  String _normalizarTelefono(String telefono) {
    // Eliminar caracteres no numéricos excepto +
    String limpio = telefono.replaceAll(RegExp(r'[^\d+]'), '');

    // Si ya tiene código de país, devolverlo limpio
    if (limpio.startsWith('+')) return limpio;

    // Si empieza con 0 (ej: 0412...), reemplazar con +58
    if (limpio.startsWith('0')) {
      return '+58${limpio.substring(1)}';
    }

    // Si empieza con 58 (sin +), agregar +
    if (limpio.startsWith('58')) {
      return '+$limpio';
    }

    // Si solo son dígitos sin prefijo, asumir Venezuela
    if (limpio.length <= 10) {
      return '+58$limpio';
    }

    return '+$limpio';
  }

  @override
  Future<bool> enviarSms(String telefono, String mensaje) async {
    try {
      final telefonoNormalizado = _normalizarTelefono(telefono);
      debugPrint('[SmsRepository] Enviando SMS a $telefono (normalizado: $telefonoNormalizado)');

      final result = await _channel.invokeMethod<bool>('sendSms', {
        'telefono': telefonoNormalizado,
        'mensaje': mensaje,
      });
      final exito = result ?? false;
      debugPrint('[SmsRepository] Envío a $telefonoNormalizado: ${exito ? "EXITOSO" : "FALLIDO"}');
      return exito;
    } catch (e) {
      debugPrint('[SmsRepository] Error al enviar SMS: $e');
      return false;
    }
  }

  @override
  Future<bool> estaDisponible() async {
    try {
      final disponible = await _channel.invokeMethod<bool>('estaDisponible');
      return disponible ?? false;
    } catch (e) {
      debugPrint('[SmsRepository] Error verificando disponibilidad: $e');
      return false;
    }
  }
}
