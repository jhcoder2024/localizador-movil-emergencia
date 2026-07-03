import 'dart:async';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// Configuración de audio para Android.
/// Usa el canal de música con altavoz y foco transitorio
/// para máxima compatibilidad y volumen.
final _audioContext = AudioContext(
  android: AudioContextAndroid(
    isSpeakerphoneOn: true,
    stayAwake: false,
    contentType: AndroidContentType.music,
    usageType: AndroidUsageType.media,
    audioFocus: AndroidAudioFocus.gainTransient,
  ),
);

class LocalizadorSonidoService {
  static AudioPlayer? _player;
  static Timer? _pitidoTimer;
  static Timer? _duracionTimer;
  static bool _sonando = false;
  static bool _usarFallback = false;
  static bool _assetVerificado = false;

  /// Inicia el pitido intermitente.
  /// Suena cada 5 segundos a máximo volumen.
  /// [duracionSegundos]: duración del pitido (default: 180 = 3 minutos).
  /// Luego se detiene automáticamente para ahorrar batería.
  static Future<void> iniciar({int duracionSegundos = 180}) async {
    if (_sonando) return;
    _sonando = true;

    if (!_assetVerificado) {
      try {
        await rootBundle.load('assets/sounds/baliza_alerta.wav');
        _player = AudioPlayer();
        await _player?.setAudioContext(_audioContext);
        await _player?.setSource(AssetSource('sounds/baliza_alerta.wav'));
        _player?.setVolume(1.0);
        _player?.setReleaseMode(ReleaseMode.stop);
        debugPrint('[LocalizadorSonido] Usando archivo WAV');
      } catch (e) {
        debugPrint('[LocalizadorSonido] Asset WAV no encontrado: $e');
        _usarFallback = true;
      }
      _assetVerificado = true;
    }

    // Primer pitido inmediato
    await _reproducirPitido();

    // Pitidos cada 5 segundos
    _pitidoTimer = Timer.periodic(
      const Duration(seconds: 5),
      (_) async {
        await _reproducirPitido();
      },
    );

    // Auto-detener después de la duración especificada
    _duracionTimer = Timer(
      Duration(seconds: duracionSegundos),
      () {
        debugPrint('[LocalizadorSonido] Tiempo de pitido cumplido (${duracionSegundos}s), deteniendo...');
        _detenerPitidos();
      },
    );
  }

  static Future<void> _reproducirPitido() async {
    if (_usarFallback) {
      // Fallback: usar SystemSound que funciona en la mayoría de dispositivos
      await SystemSound.play(SystemSoundType.alert);
      // En algunos dispositivos el SystemSound no se escucha,
      // así que también vibramos como respaldo
      HapticFeedback.heavyImpact();
      return;
    }
    try {
      if (_player != null) {
        await _player?.stop();
        await _player?.seek(const Duration(seconds: 0));
        await _player?.resume();
      }
    } catch (e) {
      debugPrint('[LocalizadorSonido] Error reproduciendo: $e');
      await SystemSound.play(SystemSoundType.alert);
    }
  }

  static void _detenerPitidos() {
    _pitidoTimer?.cancel();
    _pitidoTimer = null;
    _duracionTimer?.cancel();
    _duracionTimer = null;
    _sonando = false;

    try {
      _player?.stop();
    } catch (e) {
      debugPrint('[LocalizadorSonido] Error al detener player: $e');
    }
  }

  /// Detiene el sonido inmediatamente (llamado al cancelar emergencia)
  static Future<void> detener() async {
    _detenerPitidos();
    _usarFallback = false;
    _assetVerificado = false;

    try {
      await _player?.dispose();
      _player = null;
    } catch (e) {
      debugPrint('[LocalizadorSonido] Error al dispose: $e');
    }
  }

  static bool get estaSonando => _sonando;
}
