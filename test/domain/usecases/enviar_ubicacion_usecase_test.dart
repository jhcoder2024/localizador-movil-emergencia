import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:localizador_movil_emergencia/domain/entities/coordenadas.dart';
import 'package:localizador_movil_emergencia/domain/entities/configuracion.dart';
import 'package:localizador_movil_emergencia/domain/entities/contacto_emergencia.dart';
import 'package:localizador_movil_emergencia/domain/entities/tipo_emergencia.dart';
import 'package:localizador_movil_emergencia/domain/usecases/enviar_ubicacion_usecase.dart';
import 'package:localizador_movil_emergencia/domain/repositories/location_repository.dart';
import 'package:localizador_movil_emergencia/domain/repositories/emergency_repository.dart';
import 'package:localizador_movil_emergencia/domain/repositories/config_repository.dart';
import 'package:localizador_movil_emergencia/domain/repositories/sms_repository.dart';
import 'package:localizador_movil_emergencia/domain/repositories/whatsapp_repository.dart';
import 'package:localizador_movil_emergencia/domain/repositories/telegram_repository.dart';
import 'package:mocktail/mocktail.dart';

class MockLocationRepository extends Mock implements LocationRepository {}
class MockEmergencyRepository extends Mock implements EmergencyRepository {}
class MockConfigRepository extends Mock implements ConfigRepository {}
class MockSmsRepository extends Mock implements SmsRepository {}
class MockWhatsappRepository extends Mock implements WhatsappRepository {}
class MockTelegramRepository extends Mock implements TelegramRepository {}

void main() {
  late EnviarUbicacionUseCase useCase;
  late MockLocationRepository mockLocation;
  late MockEmergencyRepository mockEmergency;
  late MockConfigRepository mockConfig;
  late MockSmsRepository mockSms;
  late MockWhatsappRepository mockWhatsapp;
  late MockTelegramRepository mockTelegram;

  setUp(() {
    mockLocation = MockLocationRepository();
    mockEmergency = MockEmergencyRepository();
    mockConfig = MockConfigRepository();
    mockSms = MockSmsRepository();
    mockWhatsapp = MockWhatsappRepository();
    mockTelegram = MockTelegramRepository();
    useCase = EnviarUbicacionUseCase(
      mockLocation,
      mockEmergency,
      mockConfig,
      mockSms,
      mockWhatsapp,
      mockTelegram,
    );
  });

  final testUbicacion = Coordenadas(
    latitud: 19.4326,
    longitud: -99.1332,
    timestamp: DateTime.now(),
  );

  final testContactos = [
    const ContactoEmergencia(
      id: '1',
      nombre: 'Test',
      telefono: '+123456789',
    ),
  ];

  final testConfig = Configuracion(contactos: testContactos);

  test('debe obtener ubicación, config y enviar SMS secuencialmente', () async {
    when(() => mockLocation.obtenerUbicacionActual())
        .thenAnswer((_) async => testUbicacion);
    when(() => mockEmergency.actualizarCoordenada(any()))
        .thenAnswer((_) async {});
    when(() => mockConfig.obtenerConfiguracion())
        .thenAnswer((_) => Stream.value(testConfig));
    when(() => mockSms.enviarSms(any(), any()))
        .thenAnswer((_) async => true);
    when(() => mockConfig.guardarConfiguracion(any()))
        .thenAnswer((_) async {});

    await useCase(TipoEmergencia.extraviado);

    verify(() => mockLocation.obtenerUbicacionActual()).called(1);
    verify(() => mockEmergency.actualizarCoordenada(testUbicacion)).called(1);
    verify(() => mockSms.enviarSms('+123456789', any())).called(1);
  });

  test('debe enviar también WhatsApp y Telegram si el contacto lo soporta', () async {
    final contactosMultiCanal = [
      const ContactoEmergencia(
        id: '1',
        nombre: 'Test',
        telefono: '+123456789',
        tieneWhatsApp: true,
        tieneTelegram: true,
        chatIdTelegram: '@testchat',
      ),
    ];
    final configMulti = Configuracion(contactos: contactosMultiCanal, telegramToken: 'token123');

    when(() => mockLocation.obtenerUbicacionActual())
        .thenAnswer((_) async => testUbicacion);
    when(() => mockEmergency.actualizarCoordenada(any()))
        .thenAnswer((_) async {});
    when(() => mockConfig.obtenerConfiguracion())
        .thenAnswer((_) => Stream.value(configMulti));
    when(() => mockSms.enviarSms(any(), any()))
        .thenAnswer((_) async => true);
    when(() => mockWhatsapp.abrirWhatsApp(any(), any()))
        .thenAnswer((_) async => true);
    when(() => mockTelegram.enviarMensajeTelegram(any(), any(), any()))
        .thenAnswer((_) async => true);
    when(() => mockConfig.guardarConfiguracion(any()))
        .thenAnswer((_) async {});

    await useCase(TipoEmergencia.extraviado);

    verify(() => mockSms.enviarSms('+123456789', any())).called(1);
    verify(() => mockWhatsapp.abrirWhatsApp('+123456789', any())).called(1);
    verify(() => mockTelegram.enviarMensajeTelegram('@testchat', any(), 'token123')).called(1);
  });

  test('debe continuar aunque falle el envío de un canal', () async {
    when(() => mockLocation.obtenerUbicacionActual())
        .thenAnswer((_) async => testUbicacion);
    when(() => mockEmergency.actualizarCoordenada(any()))
        .thenAnswer((_) async {});
    when(() => mockConfig.obtenerConfiguracion())
        .thenAnswer((_) => Stream.value(testConfig));
    when(() => mockSms.enviarSms(any(), any()))
        .thenAnswer((_) async => false);
    when(() => mockConfig.guardarConfiguracion(any()))
        .thenAnswer((_) async {});

    await useCase(TipoEmergencia.extraviado);

    verify(() => mockSms.enviarSms(any(), any())).called(1);
  });
}
