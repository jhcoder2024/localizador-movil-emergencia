import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:localizador_movil_emergencia/data/repositories/sms_repository_impl.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late SmsRepositoryImpl repository;

  setUp(() {
    repository = SmsRepositoryImpl();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      const MethodChannel('com.example.localizador_movil_emergencia/sms_sync'),
      (MethodCall methodCall) async {
        if (methodCall.method == 'sendSmsFromInbox') {
          return {'exito': true};
        }
        return null;
      },
    );
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      const MethodChannel('com.example.localizador_movil_emergencia/sms_sync'),
      null,
    );
  });

  test('enviarSms retorna true cuando el canal responde exitosamente', () async {
    final result = await repository.enviarSms('+525512345678', 'Test mensaje');
    expect(result, isTrue);
  });
}
