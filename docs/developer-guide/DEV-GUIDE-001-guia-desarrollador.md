# Guía del Desarrollador — Localizador Móvil de Emergencia

| Campo | Valor |
|-------|-------|
| **ID** | DEV-GUIDE-001 |
| **Versión** | 2.0 |
| **Fecha** | 26/06/2026 |
| **Framework** | Flutter (Dart) |
| **Android mín.** | API 26 (Android 8.0) |
| **iOS mín.** | iOS 14 |

---

## Índice

1. [Arquitectura](#1-arquitectura)
2. [Estructura del Proyecto](#2-estructura-del-proyecto)
3. [Configuración del Entorno](#3-configuración-del-entorno)
4. [Cómo Compilar](#4-cómo-compilar)
5. [Cómo Ejecutar Tests](#5-cómo-ejecutar-tests)
6. [Flujo de Trabajo](#6-flujo-de-trabajo)
7. [Personalización](#7-personalización)
8. [Pruebas](#8-pruebas)
9. [Contribución](#9-contribución)

---

## 1. Arquitectura

La aplicación sigue el patrón **MVVM + Clean Architecture** con 3 capas:

```
┌─────────────────────────────────────────────────────────────────────┐
│                       PRESENTATION LAYER                            │
│  ┌──────────────────────────────────────────────────────────────┐   │
│  │  UI (Flutter Widgets / Material Design 3)                    │   │
│  │  ┌──────────────┐ ┌──────────────┐ ┌────────────────────┐   │   │
│  │  │  MainScreen   │ │ ConfigScreen │ │ PermissionsScreen  │   │   │
│  │  └──────┬────────┘ └──────┬───────┘ └────────────────────┘   │   │
│  │  ┌──────┴─────────────────┴────────────────────────────────┐  │   │
│  │  │  Providers (ChangeNotifiers / MVVM ViewModels)          │  │   │
│  │  │  ┌──────────────────┐  ┌──────────────────────────┐     │  │   │
│  │  │  │  MainProvider     │  │  ConfigProvider           │     │  │   │
│  │  │  └────────┬─────────┘  └───────────┬──────────────┘     │  │   │
│  │  └───────────┼────────────────────────┼─────────────────────┘  │   │
│  │  ┌───────────┴────────────────────────┴─────────────────────┐  │   │
│  │  │  Services (Background & System)                          │  │   │
│  │  │  EmergencyBackgroundService  /  NotificationService      │  │   │
│  │  └──────────────────────────────────────────────────────────┘  │   │
│  └──────────────────────────────────────────────────────────────┘   │
├─────────────────────────────────────────────────────────────────────┤
│                        DOMAIN LAYER                                 │
│  ┌──────────────────────────────────────────────────────────────┐   │
│  │  UseCases / Entities / Repository Interfaces (contratos)     │   │
│  └──────────────────────────────────────────────────────────────┘   │
├─────────────────────────────────────────────────────────────────────┤
│                          DATA LAYER                                  │
│  ┌──────────────────────────────────────────────────────────────┐   │
│  │  Repository Impls / Data Sources / Mappers / Models (DTOs)   │   │
│  │  Local (Drift, SharedPrefs) / Remote (Dio, Telegram) / Device│   │
│  └──────────────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────────────┘
```

### Principios

- **Dependencias hacia adentro:** La capa de dominio no conoce las capas externas.
- **Inyección de dependencias:** GetIt + Injectable registra todas las dependencias automáticamente.
- **ChangeNotifier:** Los Providers exponen estado reactivo que la UI observa con `context.watch()`.
- **flutter_background_service:** El envío periódico se ejecuta en un servicio persistente.

Para más detalle, consulta [ARCH-002-arquitectura-flutter.md](../architecture/ARCH-002-arquitectura-flutter.md).

---

## 2. Estructura del Proyecto

```
localizador_movil_emergencia/
│
├── lib/
│   ├── main.dart                              # Punto de entrada, configureInjection(), runApp()
│   │
│   ├── app/
│   │   ├── app.dart                           # MaterialApp.router, tema M3, rutas
│   │   └── di/
│   │       ├── data_module.dart               # Registro de data sources, repos, DB, clientes
│   │       ├── domain_module.dart             # Registro de use cases
│   │       ├── presentation_module.dart       # Registro de providers y servicios
│   │       └── injection.config.dart          # Generado por Injectable (build_runner)
│   │
│   ├── core/
│   │   ├── constants/
│   │   │   ├── app_constants.dart             # Intervalos, límites, URLs
│   │   │   └── telegram_constants.dart        # Endpoints de Telegram
│   │   ├── error/
│   │   │   ├── exceptions.dart                # Clases de excepción personalizadas
│   │   │   └── failures.dart                  # Clases Failure para Result<T>
│   │   ├── network/
│   │   │   └── dio_client.dart                # Configuración global de Dio
│   │   ├── theme/
│   │   │   ├── app_theme.dart                 # Tema claro/oscuro M3
│   │   │   ├── app_colors.dart                # Colores por tipo de emergencia
│   │   │   └── app_text_styles.dart           # Estilos tipográficos
│   │   └── utils/
│   │       ├── extensions.dart                # Extensiones útiles
│   │       ├── message_builder.dart           # Construcción de mensajes según TipoEmergencia
│   │       └── permission_utils.dart          # Utilidades de permisos
│   │
│   ├── data/
│   │   ├── datasources/
│   │   │   ├── local/
│   │   │   │   ├── app_database.dart          # Definición Drift database (tablas)
│   │   │   │   ├── config_dao.dart            # DAO para configuración (Drift)
│   │   │   │   ├── contacts_dao.dart          # DAO para contactos (Drift)
│   │   │   │   └── shared_prefs_datasource.dart # Token Telegram, preferencias simples
│   │   │   └── remote/
│   │   │       └── telegram_remote_datasource.dart  # Llamadas HTTP a Bot API
│   │   ├── models/
│   │   │   ├── contacto_model.dart            # DTO con anotaciones Drift/JSON
│   │   │   ├── configuracion_model.dart       # DTO serializable
│   │   │   ├── coordenadas_model.dart         # DTO para coordenadas
│   │   │   └── telegram_dto.dart              # SendMessageRequest/Response
│   │   ├── repositories/
│   │   │   ├── contacto_repository_impl.dart
│   │   │   ├── config_repository_impl.dart
│   │   │   ├── emergency_repository_impl.dart
│   │   │   ├── location_repository_impl.dart
│   │   │   ├── sms_repository_impl.dart
│   │   │   ├── telegram_repository_impl.dart
│   │   │   └── whatsapp_repository_impl.dart
│   │   └── mappers/
│   │       ├── contacto_mapper.dart           # ContactoModel <-> ContactoEmergencia
│   │       └── config_mapper.dart             # ConfiguracionModel <-> Configuracion
│   │
│   ├── domain/
│   │   ├── entities/
│   │   │   ├── contacto_emergencia.dart       # Modelo de contacto de emergencia
│   │   │   ├── configuracion.dart             # Modelo de configuración
│   │   │   ├── coordenadas.dart               # Latitud, longitud, timestamp
│   │   │   ├── estado_emergencia.dart         # Estado actual de la emergencia
│   │   │   └── tipo_emergencia.dart           # Enum: extraviado, atrapado, herido
│   │   ├── repositories/
│   │   │   ├── contacto_repository.dart       # Interfaz abstracta
│   │   │   ├── config_repository.dart
│   │   │   ├── emergency_repository.dart
│   │   │   ├── location_repository.dart
│   │   │   ├── sms_repository.dart
│   │   │   ├── telegram_repository.dart
│   │   │   └── whatsapp_repository.dart
│   │   └── usecases/
│   │       ├── activar_emergencia_usecase.dart      # Orquesta activación completa
│   │       ├── cancelar_emergencia_usecase.dart     # Cancela emergencia y libera recursos
│   │       ├── enviar_ubicacion_usecase.dart        # Envía coords por todos los canales
│   │       ├── obtener_contactos_usecase.dart       # Obtiene contactos de agenda
│   │       ├── guardar_configuracion_usecase.dart   # Guarda config local
│   │       ├── obtener_configuracion_usecase.dart   # Lee config local
│   │       └── verificar_disponibilidad_canal_usecase.dart  # Detecta canales disponibles
│   │
│   ├── presentation/
│   │   ├── providers/                         # ChangeNotifiers (MVVM ViewModels)
│   │   │   ├── main_provider.dart             # Estado emergencia, activar/cancelar
│   │   │   └── config_provider.dart           # Configuración, contactos, intervalo
│   │   ├── screens/
│   │   │   ├── main_screen.dart               # 3 botones de emergencia + estado
│   │   │   ├── config_screen.dart             # Contactos, intervalo, canales
│   │   │   └── permissions_screen.dart        # Solicitud de permisos en cadena
│   │   ├── widgets/
│   │   │   ├── emergency_button.dart          # Botón grande con color por tipo
│   │   │   ├── confirmation_dialog.dart       # Confirmación antes de activar
│   │   │   ├── emergency_active_banner.dart   # Banner de emergencia activa
│   │   │   ├── contact_list_section.dart      # Lista de contactos seleccionados
│   │   │   ├── contact_picker_dialog.dart     # Selector de contactos de agenda
│   │   │   └── interval_section.dart          # Selector de intervalo
│   │   └── services/
│   │       ├── emergency_background_service.dart  # Foreground service
│   │       └── notification_service.dart      # Gestión de canales y notificaciones
│   │
│   ├── l10n/                                  # Localización (ARB files)
│   │   ├── app_es.arb                         # Español
│   │   └── app_en.arb                         # Inglés
│   │
│   └── generated/                             # Código generado (Drift, Injectable)
│       └── ...                                # .g.dart, .freezed.dart
│
├── test/
│   ├── data/
│   │   ├── datasources/
│   │   ├── models/
│   │   ├── repositories/
│   │   └── mappers/
│   ├── domain/
│   │   └── usecases/
│   ├── presentation/
│   │   ├── providers/
│   │   ├── screens/
│   │   └── widgets/
│   └── core/
│       └── utils/
│
├── android/
│   ├── app/src/main/AndroidManifest.xml       # Permisos declarados
│   └── build.gradle.kts
│
├── ios/
│   └── Runner/Info.plist                      # Permisos iOS
│
├── assets/
│   ├── .env                                   # Telegram token
│   ├── icons/
│   └── images/
│
├── pubspec.yaml
├── analysis_options.yaml
└── .gitignore
```

---

## 3. Configuración del Entorno

### Requisitos del Sistema

| Herramienta | Versión mínima | Descarga |
|-------------|----------------|----------|
| Flutter SDK | 3.2+ | [flutter.dev](https://flutter.dev/) |
| Dart | 3.2+ | Incluido con Flutter |
| Android Studio | Hedgehog (2023.1.1) o VS Code | [developer.android.com/studio](https://developer.android.com/studio) |
| Xcode | 15+ (solo iOS) | App Store (macOS) |
| Git | Cualquiera | [git-scm.com](https://git-scm.com/) |

### Verificar instalación

```bash
flutter --version
# Flutter 3.2+
# Dart 3.2+

dart --version
# Dart SDK 3.2+

flutter doctor
# Verifica todos los componentes necesarios
```

### Variables de Entorno

Las configuraciones sensibles se almacenan en `assets/.env` (NO committear):

```env
# assets/.env
TELEGRAM_BOT_TOKEN=123456789:ABCdefGHIjklMNOpqrsTUVwxyz
```

Carga con `flutter_dotenv`:

```dart
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  await dotenv.load(fileName: 'assets/.env');
  configureInjection();
  runApp(const LocalizadorApp());
}
```

El archivo `.env` debe incluirse en `.gitignore` para no exponer tokens.

### Configurar Flutter para el proyecto

```bash
# Obtener dependencias
flutter pub get

# Generar código (Drift, Injectable, etc.)
dart run build_runner build
```

---

## 4. Cómo Compilar

### Debug (Android)

```bash
flutter build apk --debug
```

APK generado en: `build/app/outputs/flutter-apk/app-debug.apk`

### Release (Android)

```bash
# Asegúrate de tener TELEGRAM_BOT_TOKEN en assets/.env
flutter build apk --release
```

APK generado en: `build/app/outputs/flutter-apk/app-release.apk`

### Android App Bundle (Google Play)

```bash
flutter build appbundle --release
```

AAB generado en: `build/app/outputs/bundle/release/app-release.aab`

### iOS (solo en macOS)

```bash
flutter build ios --release
```

IPA generado en: `build/ios/ipa/` (requiere exportar desde Xcode)

### Limpiar y reconstruir

```bash
flutter clean && flutter pub get && dart run build_runner build
```

---

## 5. Cómo Ejecutar Tests

### Tests unitarios

```bash
flutter test
```

### Tests con cobertura

```bash
flutter test --coverage
```

### Tests de un archivo específico

```bash
flutter test test/domain/usecases/activar_emergencia_usecase_test.dart
```

### Estructura de tests

```
test/
├── data/
│   ├── datasources/
│   ├── models/
│   ├── repositories/
│   └── mappers/
├── domain/
│   └── usecases/
├── presentation/
│   ├── providers/
│   ├── screens/
│   └── widgets/
└── core/
    └── utils/
```

---

## 6. Flujo de Trabajo

> **Nota sobre el diálogo de confirmación:** Todos los botones de emergencia (`emergency_button.dart`) abren un `ConfirmationCountdownDialog` (StatefulWidget en `confirmation_dialog.dart`). Este widget crea un `Timer` de 10 segundos con una barra de progreso (`LinearProgressIndicator` actualizado cada 100ms). Al llegar a 0, ejecuta `onConfirm()` automáticamente. El botón "ABORTAR" detiene el timer y cierra el diálogo. El botón ABORTAR usa el color `AppColors.emergencyRed` para ser visualmente prominente.

### 6.1 Agregar un Nuevo Canal de Comunicación

1. **Domain layer:** Crear interfaz en `domain/repositories/` (ej. `signal_repository.dart`).
2. **Data layer:** Implementar en `data/repositories/` (ej. `signal_repository_impl.dart`).
3. **DI:** Registrar en `app/di/data_module.dart` con anotación `@Injectable`.
4. **Use case:** Modificar `enviar_ubicacion_usecase.dart` para incluir el nuevo canal.
5. **UI:** Agregar indicador en `config_screen.dart` y `main_screen.dart`.

### 6.2 Agregar un Nuevo Tipo de Emergencia

1. Abrir `domain/entities/tipo_emergencia.dart`.
2. Agregar un nuevo valor al enum:
   ```dart
   enum TipoEmergencia {
     extraviado('Extraviado', 'EXT', AppColors.emergencyYellow),
     atrapado('Atrapado', 'ATR', AppColors.emergencyOrange),
     herido('Herido', 'HER', AppColors.emergencyRed);
     // Nuevo tipo:
     // peligroInmediato('Peligro Inmediato', 'PEL', AppColors.emergencyPurple);
   }
   ```
3. Agregar el mensaje en `mensajeAuxilio()`.
4. Agregar el botón en `main_screen.dart` con su color correspondiente.
5. Agregar las traducciones en `l10n/app_es.arb` y `l10n/app_en.arb`.
6. Actualizar `message_builder.dart` si existe lógica adicional.

### 6.3 Modificar el Intervalo de Envío

El intervalo se configura en `core/constants/app_constants.dart`:

```dart
class AppConstants {
  static const int intervaloMinimoSegundos = 60;      // 1 minuto
  static const int intervaloDefectoSegundos = 300;    // 5 minutos
  static const int intervaloMaximoSegundos = 3600;    // 60 minutos
}
```

Para cambiar el valor por defecto o los límites, modifica estas constantes. La UI en `interval_section.dart` leerá estos valores automáticamente.

---

## 7. Personalización

### 7.1 Cambiar Colores de los Botones

Edita `core/theme/app_colors.dart`:

```dart
class AppColors {
  static const Color emergencyYellow = Color(0xFFFFC107);   // Extraviado
  static const Color emergencyOrange = Color(0xFFFF9800);   // Atrapado
  static const Color emergencyRed = Color(0xFFF44336);      // Herido
}
```

Los componentes `emergency_button.dart` usan estos colores directamente.

### 7.2 Cambiar Mensajes de Auxilio

Edita `domain/entities/tipo_emergencia.dart`, método `mensajeAuxilio()`:

```dart
String mensajeAuxilio(Coordenadas coords) {
  final url = coords.toGoogleMapsUrl();
  return switch (this) {
    TipoEmergencia.extraviado => '¡Emergencia! Estoy extraviado... $url',
    TipoEmergencia.atrapado => '¡Emergencia! Estoy atrapado... $url',
    TipoEmergencia.herido => '¡Emergencia! Estoy herido... $url',
  };
}
```

### 7.3 Configurar Telegram Bot

1. Crea un bot con **@BotFather** en Telegram.
2. Obtén el token.
3. Coloca el token en `assets/.env`: `TELEGRAM_BOT_TOKEN=tu_token_aqui`.
4. Recompila la app.

### 7.4 Cambiar Sonido de Localizador

Reemplazar el archivo `assets/sounds/localizador_alerta.mp3` con tu propio archivo de audio. El servicio usa `audioplayers` para reproducirlo.

---

## 8. Pruebas

### 8.1 Escribir Tests Unitarios

Usamos **flutter_test** + **mockito**.

Ejemplo de test para `ActivarEmergenciaUseCase`:

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

class MockEmergencyRepository extends Mock
    implements EmergencyRepository {}

class MockLocationRepository extends Mock
    implements LocationRepository {}

void main() {
  late ActivarEmergenciaUseCase useCase;
  late MockEmergencyRepository mockEmergencyRepo;
  late MockLocationRepository mockLocationRepo;

  setUp(() {
    mockEmergencyRepo = MockEmergencyRepository();
    mockLocationRepo = MockLocationRepository();
    useCase = ActivarEmergenciaUseCase(
      emergencyRepository: mockEmergencyRepo,
      locationRepository: mockLocationRepo,
    );
  });

  test('activar emergencia should return success', () async {
    const tipo = TipoEmergencia.extraviado;
    when(mockEmergencyRepo.activar(tipo))
        .thenAnswer((_) async => const Result.success(null));

    final result = await useCase(tipo);

    expect(result.isSuccess, true);
    verify(mockEmergencyRepo.activar(tipo)).called(1);
  });
}
```

### 8.2 Reglas Generales

- Usar `Mockito` para mockear dependencias externas (GPS, SMS, Telegram).
- No realizar llamadas de red reales en tests unitarios.
- Los tests de widgets usan `WidgetTester` (`testWidgets`).
- Para tests de providers, instanciar el Provider directamente con dependencias mockeadas.

---

## 9. Contribución

### 9.1 Reportar Issues

Usa el sistema de issues del repositorio. Incluye:
- Versión de la app y dispositivo.
- Pasos para reproducir el error.
- Logs o capturas de pantalla si es posible.

### 9.2 Enviar Pull Requests

1. Haz fork del repositorio.
2. Crea una rama con el nombre descriptivo: `feature/nueva-funcionalidad` o `fix/error-descripcion`.
3. Asegúrate de que los tests existentes pasen.
4. Agrega tests para tu nueva funcionalidad.
5. Actualiza la documentación si es necesario.
6. Envía el PR con una descripción clara.

### 9.3 Estándares de Código

- **Formato:** Usar `dart format .` o el formateador integrado del IDE.
- **Estilo:** Seguir las [convenciones oficiales de Dart](https://dart.dev/effective-dart/style).
- **Comentarios:** Preferir código auto-documentado. No agregar comentarios triviales.
- **Commits:** Usar mensajes descriptivos en inglés o español.

### 9.4 Verificaciones Pre-PR

- [ ] `flutter test` pasa
- [ ] `flutter build apk --debug` compila sin errores
- [ ] `dart format .` no produce cambios
- [ ] No hay warnings de análisis (`flutter analyze`)
- [ ] Traducciones actualizadas (español e inglés en `l10n/`)
- [ ] Documentación actualizada si corresponde
