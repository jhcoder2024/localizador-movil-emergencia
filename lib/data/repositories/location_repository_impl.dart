import 'dart:async';
import 'package:geolocator/geolocator.dart';
import 'package:localizador_movil_emergencia/domain/entities/coordenadas.dart';
import 'package:localizador_movil_emergencia/domain/repositories/location_repository.dart';

class LocationRepositoryImpl implements LocationRepository {
  final GeolocatorPlatform _geolocator;

  LocationRepositoryImpl(this._geolocator);

  @override
  Future<Coordenadas> obtenerUbicacionActual() async {
    final position = await _geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        timeLimit: Duration(seconds: 30),
      ),
    );
    return Coordenadas(
      latitud: position.latitude,
      longitud: position.longitude,
      timestamp: DateTime.fromMillisecondsSinceEpoch(
        position.timestamp?.millisecondsSinceEpoch ??
            DateTime.now().millisecondsSinceEpoch,
      ),
      precision: position.accuracy,
    );
  }

  @override
  Stream<Coordenadas> obtenerActualizacionesUbicacion() {
    // NO USAR streaming continuo para ahorrar batería
    // En su lugar, el servicio en segundo plano llama a obtenerUbicacionActual() periódicamente
    throw UnimplementedError(
        'Usar obtenerUbicacionActual() con Timer en su lugar');
  }
}
