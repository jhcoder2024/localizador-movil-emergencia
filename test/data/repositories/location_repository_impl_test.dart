import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:geolocator/geolocator.dart';
import 'package:localizador_movil_emergencia/data/repositories/location_repository_impl.dart';
import 'package:localizador_movil_emergencia/domain/entities/coordenadas.dart';

class MockGeolocatorPlatform extends Mock implements GeolocatorPlatform {}

void main() {
  late LocationRepositoryImpl repository;
  late MockGeolocatorPlatform mockGeolocator;

  setUp(() {
    mockGeolocator = MockGeolocatorPlatform();
    repository = LocationRepositoryImpl(mockGeolocator);
  });

  final testPosition = Position(
    latitude: 19.4326,
    longitude: -99.1332,
    timestamp: DateTime.now(),
    accuracy: 10.0,
    altitude: 0.0,
    altitudeAccuracy: 0.0,
    heading: 0.0,
    headingAccuracy: 0.0,
    speed: 0.0,
    speedAccuracy: 0.0,
    floor: 0,
    isMocked: false,
  );

  test('obtenerUbicacionActual retorna Coordenadas', () async {
    when(() => mockGeolocator.getCurrentPosition(
      locationSettings: any(named: 'locationSettings'),
    )).thenAnswer((_) async => testPosition);

    final result = await repository.obtenerUbicacionActual();

    expect(result, isA<Coordenadas>());
    expect(result.latitud, equals(19.4326));
    expect(result.longitud, equals(-99.1332));
  });
}
