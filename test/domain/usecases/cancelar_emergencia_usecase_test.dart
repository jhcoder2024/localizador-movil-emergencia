import 'package:flutter_test/flutter_test.dart';
import 'package:localizador_movil_emergencia/domain/usecases/cancelar_emergencia_usecase.dart';
import 'package:localizador_movil_emergencia/domain/repositories/emergency_repository.dart';
import 'package:mocktail/mocktail.dart';

class MockEmergencyRepository extends Mock implements EmergencyRepository {}

void main() {
  late CancelarEmergenciaUseCase useCase;
  late MockEmergencyRepository mockRepository;

  setUp(() {
    mockRepository = MockEmergencyRepository();
    useCase = CancelarEmergenciaUseCase(mockRepository);
  });

  test('debe llamar a cancelarEmergencia en el repositorio', () async {
    when(() => mockRepository.cancelarEmergencia()).thenAnswer((_) async {});

    await useCase();

    verify(() => mockRepository.cancelarEmergencia()).called(1);
  });
}
