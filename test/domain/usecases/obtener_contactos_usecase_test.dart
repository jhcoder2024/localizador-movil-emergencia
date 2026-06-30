import 'package:flutter_test/flutter_test.dart';
import 'package:localizador_movil_emergencia/domain/entities/contacto_emergencia.dart';
import 'package:localizador_movil_emergencia/domain/usecases/obtener_contactos_usecase.dart';
import 'package:localizador_movil_emergencia/domain/repositories/contacto_repository.dart';
import 'package:mocktail/mocktail.dart';

class MockContactoRepository extends Mock implements ContactoRepository {}

void main() {
  late ObtenerContactosUseCase useCase;
  late MockContactoRepository mockRepository;

  setUp(() {
    mockRepository = MockContactoRepository();
    useCase = ObtenerContactosUseCase(mockRepository);
  });

  final testContactos = [
    const ContactoEmergencia(id: '1', nombre: 'Test', telefono: '+123456789'),
  ];

  test('debe retornar lista de contactos del repositorio', () async {
    when(() => mockRepository.obtenerContactos()).thenAnswer((_) async => testContactos);

    final result = await useCase();

    expect(result, equals(testContactos));
    verify(() => mockRepository.obtenerContactos()).called(1);
  });

  test('debe retornar lista vacía cuando no hay contactos', () async {
    when(() => mockRepository.obtenerContactos()).thenAnswer((_) async => []);

    final result = await useCase();

    expect(result, isEmpty);
  });
}
