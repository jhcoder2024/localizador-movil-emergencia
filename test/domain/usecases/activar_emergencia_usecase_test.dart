import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:localizador_movil_emergencia/domain/entities/configuracion.dart';
import 'package:localizador_movil_emergencia/domain/entities/contacto_emergencia.dart';
import 'package:localizador_movil_emergencia/domain/entities/tipo_emergencia.dart';
import 'package:localizador_movil_emergencia/domain/usecases/activar_emergencia_usecase.dart';
import 'package:localizador_movil_emergencia/domain/repositories/emergency_repository.dart';
import 'package:localizador_movil_emergencia/domain/repositories/config_repository.dart';
import 'package:mocktail/mocktail.dart';

class MockEmergencyRepository extends Mock implements EmergencyRepository {}

class MockConfigRepository extends Mock implements ConfigRepository {}

void main() {
  setUpAll(() {
    registerFallbackValue(TipoEmergencia.extraviado);
  });

  late ActivarEmergenciaUseCase useCase;
  late MockEmergencyRepository mockEmergencyRepository;
  late MockConfigRepository mockConfigRepository;

  setUp(() {
    mockEmergencyRepository = MockEmergencyRepository();
    mockConfigRepository = MockConfigRepository();
    useCase = ActivarEmergenciaUseCase(mockEmergencyRepository, mockConfigRepository);
  });

  final testContactos = [
    const ContactoEmergencia(
      id: '1',
      nombre: 'Test',
      telefono: '+123456789',
    ),
  ];

  final testConfig = Configuracion(contactos: testContactos);

  test('debe llamar a activarEmergencia en el repositorio', () async {
    when(() => mockConfigRepository.obtenerConfiguracion())
        .thenAnswer((_) => Stream.value(testConfig));
    when(() => mockEmergencyRepository.activarEmergencia(TipoEmergencia.extraviado))
        .thenAnswer((_) async {});

    await useCase(TipoEmergencia.extraviado);

    verify(() => mockEmergencyRepository.activarEmergencia(TipoEmergencia.extraviado))
        .called(1);
  });

  test('debe lanzar excepción cuando la configuración no es válida', () async {
    final configInvalida = Configuracion(intervaloMinutos: 0);
    when(() => mockConfigRepository.obtenerConfiguracion())
        .thenAnswer((_) => Stream.value(configInvalida));

    expect(
      useCase(TipoEmergencia.extraviado),
      throwsException,
    );
  });

  test('debe lanzar excepción cuando no hay contactos', () async {
    when(() => mockConfigRepository.obtenerConfiguracion())
        .thenAnswer((_) => Stream.value(const Configuracion()));

    expect(
      useCase(TipoEmergencia.extraviado),
      throwsException,
    );
  });

  test('debe lanzar excepción cuando el repositorio falla', () async {
    when(() => mockConfigRepository.obtenerConfiguracion())
        .thenAnswer((_) => Stream.value(testConfig));
    when(() => mockEmergencyRepository.activarEmergencia(any()))
        .thenThrow(Exception('Error de prueba'));

    expect(
      useCase(TipoEmergencia.extraviado),
      throwsException,
    );
  });
}
