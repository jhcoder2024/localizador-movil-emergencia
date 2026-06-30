import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:localizador_movil_emergencia/data/datasources/remote/telegram_remote_datasource.dart';
import 'package:localizador_movil_emergencia/data/models/telegram_dto.dart';
import 'package:localizador_movil_emergencia/data/repositories/telegram_repository_impl.dart';

class MockTelegramRemoteDataSource extends Mock
    implements TelegramRemoteDataSource {}

void main() {
  late TelegramRepositoryImpl repository;
  late MockTelegramRemoteDataSource mockRemoteDataSource;

  setUp(() {
    mockRemoteDataSource = MockTelegramRemoteDataSource();
    repository = TelegramRepositoryImpl(mockRemoteDataSource);
  });

  test('enviarMensajeTelegram retorna true cuando el envío es exitoso', () async {
    when(() => mockRemoteDataSource.sendMessage(
      any(),
      any(),
    )).thenAnswer((_) async => const SendMessageResponse(ok: true));

    final result = await repository.enviarMensajeTelegram(
      '@testchat',
      'Mensaje de prueba',
      'token123',
    );

    expect(result, isTrue);
  });

  test('enviarMensajeTelegram retorna false cuando falla', () async {
    when(() => mockRemoteDataSource.sendMessage(any(), any()))
        .thenThrow(Exception('Error de red'));

    final result = await repository.enviarMensajeTelegram(
      '@testchat',
      'Mensaje de prueba',
      'token123',
    );

    expect(result, isFalse);
  });

  test('verificarToken retorna true si el token es válido', () async {
    when(() => mockRemoteDataSource.verifyToken(any()))
        .thenAnswer((_) async => true);

    final result = await repository.verificarToken('token123');

    expect(result, isTrue);
  });

  test('verificarToken retorna false si el token es inválido', () async {
    when(() => mockRemoteDataSource.verifyToken(any()))
        .thenAnswer((_) async => false);

    final result = await repository.verificarToken('token_invalido');

    expect(result, isFalse);
  });
}
