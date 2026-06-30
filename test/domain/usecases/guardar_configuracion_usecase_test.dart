import 'package:flutter_test/flutter_test.dart';
import 'package:localizador_movil_emergencia/domain/entities/configuracion.dart';
import 'package:localizador_movil_emergencia/domain/usecases/guardar_configuracion_usecase.dart';
import 'package:localizador_movil_emergencia/domain/repositories/config_repository.dart';
import 'package:mocktail/mocktail.dart';

class MockConfigRepository extends Mock implements ConfigRepository {}

void main() {
  late GuardarConfiguracionUseCase useCase;
  late MockConfigRepository mockRepository;

  setUp(() {
    mockRepository = MockConfigRepository();
    useCase = GuardarConfiguracionUseCase(mockRepository);
  });

  final testConfig = const Configuracion(
    intervaloMinutos: 5,
    contactos: [],
    idioma: 'es',
    telegramToken: null,
  );

  test('debe llamar a guardarConfiguracion en el repositorio', () async {
    when(() => mockRepository.guardarConfiguracion(testConfig))
        .thenAnswer((_) async {});

    await useCase(testConfig);

    verify(() => mockRepository.guardarConfiguracion(testConfig)).called(1);
  });

  test('debe lanzar excepción cuando la configuración no es válida', () async {
    final configInvalida = const Configuracion(intervaloMinutos: 0);

    expect(
      () => useCase(configInvalida),
      throwsException,
    );

    verifyNever(() => mockRepository.guardarConfiguracion(any()));
  });
}
