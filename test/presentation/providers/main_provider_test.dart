import 'dart:async';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:localizador_movil_emergencia/presentation/providers/main_provider.dart';
import 'package:localizador_movil_emergencia/domain/usecases/activar_emergencia_usecase.dart';
import 'package:localizador_movil_emergencia/domain/usecases/cancelar_emergencia_usecase.dart';
import 'package:localizador_movil_emergencia/domain/usecases/enviar_ubicacion_usecase.dart';
import 'package:localizador_movil_emergencia/domain/usecases/obtener_configuracion_usecase.dart';
import 'package:localizador_movil_emergencia/domain/repositories/emergency_repository.dart';
import 'package:localizador_movil_emergencia/domain/entities/estado_emergencia.dart';
import 'package:localizador_movil_emergencia/domain/entities/configuracion.dart';
import 'package:localizador_movil_emergencia/domain/entities/tipo_emergencia.dart';
import 'package:localizador_movil_emergencia/presentation/services/localizador_sonido_service.dart';

class MockActivarEmergencia extends Mock implements ActivarEmergenciaUseCase {}
class MockCancelarEmergencia extends Mock implements CancelarEmergenciaUseCase {}
class MockEnviarUbicacion extends Mock implements EnviarUbicacionUseCase {}
class MockObtenerConfiguracion extends Mock implements ObtenerConfiguracionUseCase {}
class MockEmergencyRepository extends Mock implements EmergencyRepository {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    registerFallbackValue(TipoEmergencia.extraviado);

    // Mock audio player channel to prevent MissingPluginException
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      const MethodChannel('xyz.luan/audioplayers.global'),
      (MethodCall methodCall) async => null,
    );
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      const MethodChannel('xyz.luan/audioplayers'),
      (MethodCall methodCall) async => 1,
    );
  });

  late MainProvider provider;
  late MockActivarEmergencia mockActivar;
  late MockCancelarEmergencia mockCancelar;
  late MockEnviarUbicacion mockEnviar;
  late MockObtenerConfiguracion mockObtenerConfig;
  late MockEmergencyRepository mockEmergencyRepo;

  setUp(() {
    mockActivar = MockActivarEmergencia();
    mockCancelar = MockCancelarEmergencia();
    mockEnviar = MockEnviarUbicacion();
    mockObtenerConfig = MockObtenerConfiguracion();
    mockEmergencyRepo = MockEmergencyRepository();

    when(() => mockEmergencyRepo.obtenerEstado())
        .thenAnswer((_) => Stream.value(const EstadoEmergencia()));
    when(() => mockObtenerConfig())
        .thenAnswer((_) => Stream.value(const Configuracion()));

    provider = MainProvider(
      activarEmergencia: mockActivar,
      cancelarEmergencia: mockCancelar,
      enviarUbicacion: mockEnviar,
      obtenerConfiguracion: mockObtenerConfig,
      emergencyRepository: mockEmergencyRepo,
    );
  });

  tearDown(() async {
    try {
      await LocalizadorSonidoService.detener();
    } catch (_) {}
  });

  test('estado inicial debe ser inactiva', () {
    expect(provider.estado, equals(const EstadoEmergencia()));
    expect(provider.cargando, isFalse);
    expect(provider.autoEjecutando, isFalse);
    expect(provider.mostrarDialogo, isFalse);
  });

  test('solicitarConfirmacion activa el diálogo y guarda el tipo', () {
    provider.solicitarConfirmacion(TipoEmergencia.extraviado);

    expect(provider.mostrarDialogo, isTrue);
    expect(provider.tipoPendiente, equals(TipoEmergencia.extraviado));
  });

  test('cancelarDialogo limpia el estado del diálogo', () {
    provider.solicitarConfirmacion(TipoEmergencia.extraviado);
    provider.cancelarDialogo();

    expect(provider.mostrarDialogo, isFalse);
    expect(provider.tipoPendiente, isNull);
    expect(provider.autoEjecutando, isFalse);
  });

  test('confirmarEmergencia llama a activar y enviar ubicación', () async {
    when(() => mockActivar.call(any())).thenAnswer((_) async {});
    when(() => mockEnviar.call(any())).thenAnswer((_) async {});

    provider.solicitarConfirmacion(TipoEmergencia.extraviado);
    await provider.confirmarEmergencia();

    verify(() => mockActivar.call(TipoEmergencia.extraviado)).called(1);
    verify(() => mockEnviar.call(TipoEmergencia.extraviado)).called(1);
    expect(provider.autoEjecutando, isFalse);
    expect(provider.cargando, isFalse);
  }, timeout: const Timeout(Duration(seconds: 5)));

  test('confirmarEmergencia maneja errores correctamente', () async {
    when(() => mockActivar.call(any()))
        .thenThrow(Exception('Error de prueba'));

    provider.solicitarConfirmacion(TipoEmergencia.extraviado);
    await provider.confirmarEmergencia();

    expect(provider.error, isNotNull);
    expect(provider.autoEjecutando, isFalse);
    expect(provider.cargando, isFalse);
  });

  test('cancelarEmergenciaActual llama al use case', () async {
    when(() => mockCancelar.call()).thenAnswer((_) async {});

    await provider.cancelarEmergenciaActual();

    verify(() => mockCancelar.call()).called(1);
  });

  test('cancelarEmergenciaActual captura errores', () async {
    when(() => mockCancelar.call())
        .thenThrow(Exception('Error de cancelación'));

    await provider.cancelarEmergenciaActual();

    expect(provider.error, isNotNull);
  });

  test('limpiarError resetea el error', () {
    provider.limpiarError();

    expect(provider.error, isNull);
  });
}
