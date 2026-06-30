import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:localizador_movil_emergencia/data/repositories/sms_repository_impl.dart';

void main() {
  late SmsRepositoryImpl repository;

  setUp(() {
    repository = SmsRepositoryImpl();
  });

  test('enviarSms retorna Future<bool>', () async {
    final result = await repository.enviarSms('+525512345678', 'Test mensaje');
    expect(result, isA<bool>());
  });
}
