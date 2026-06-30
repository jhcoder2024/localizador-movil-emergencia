import 'dart:async';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

class LocalizadorSonidoService {
  static AudioPlayer? _player;
  static Timer? _timer;
  static bool _sonando = false;
  static bool _usarFallback = false;
  static bool _assetVerificado = false;

  static const int _intervaloPitidoSegundos = 10;

  static Future<void> iniciar() async {
    if (_sonando) return;
    _sonando = true;

    if (!_assetVerificado) {
      try {
        await rootBundle.load('assets/sounds/baliza_alerta.mp3');
        _player = AudioPlayer();
        await _player?.setSource(AssetSource('sounds/baliza_alerta.mp3'));
        _player?.setVolume(1.0);
        _player?.setReleaseMode(ReleaseMode.stop);
      } catch (e) {
        debugPrint('[LocalizadorSonido] Asset no encontrado, usando fallback de sistema: $e');
        _usarFallback = true;
      }
      _assetVerificado = true;
    }

    await _reproducirPitido();

    if (!_usarFallback) {
      _timer = Timer.periodic(
        const Duration(seconds: _intervaloPitidoSegundos),
        (_) async {
          await _reproducirPitido();
        },
      );
    }
  }

  static Future<void> _reproducirPitido() async {
    if (_usarFallback) {
      SystemSound.play(SystemSoundType.alert);
      return;
    }
    try {
      if (_player != null) {
        await _player?.stop();
        await _player?.seek(const Duration(seconds: 0));
        await _player?.resume();
      }
    } catch (e) {
      SystemSound.play(SystemSoundType.alert);
      debugPrint('[LocalizadorSonido] Error reproduciendo: $e');
    }
  }

  static Future<void> detener() async {
    _timer?.cancel();
    _timer = null;
    _sonando = false;
    _usarFallback = false;
    _assetVerificado = false;

    try {
      await _player?.stop();
      await _player?.dispose();
      _player = null;
    } catch (e) {
      debugPrint('[LocalizadorSonido] Error al detener: $e');
    }
  }

  static bool get estaSonando => _sonando;
}
