# Documento de Arquitectura Flutter - Localizador Móvil de Emergencia

| Campo | Valor |
|-------|-------|
| **ID** | ARCH-002 |
| **Nombre** | Arquitectura Flutter de la Aplicación Localizador Móvil de Emergencia |
| **Versión** | 1.0 |
| **Fecha** | 26/06/2026 |
| **Estado** | Aprobado |
| **Autor** | Arquitecto de Software |
| **Framework** | Flutter (Dart) |
| **Stack** | MVVM + Clean Architecture, GetIt + Injectable, Drift (Solo local) |

---

## Índice

1. [Diagrama de Arquitectura](#1-diagrama-de-arquitectura)
2. [Estructura de Paquetes del Proyecto Flutter](#2-estructura-de-paquetes-del-proyecto-flutter)
3. [Modelo de Datos (Entidades de Dominio)](#3-modelo-de-datos-entidades-de-dominio)
4. [Flujo de la Emergencia (Paso a Paso)](#4-flujo-de-la-emergencia-paso-a-paso)
5. [Estrategia de Permisos en Flutter](#5-estrategia-de-permisos-en-flutter)
6. [Estrategia de Telegram Bot API](#6-estrategia-de-telegram-bot-api)
7. [Estrategia de WhatsApp](#7-estrategia-de-whatsapp)
8. [Estrategia de SMS](#8-estrategia-de-sms)
9. [Estrategia de GPS](#9-estrategia-de-gps)
10. [Estrategia de Ahorro de Batería](#10-estrategia-de-ahorro-de-batería)
11. [Estrategia de Notificaciones](#11-estrategia-de-notificaciones)
12. [Dependencias Principales (pubspec.yaml)](#12-dependencias-principales-pubspecyaml)

---

## 1. Diagrama de Arquitectura

### 1.1 Vista General de Capas (Clean Architecture + MVVM)

```
┌─────────────────────────────────────────────────────────────────────┐
│                       PRESENTATION LAYER                            │
│  ┌──────────────────────────────────────────────────────────────┐   │
│  │  UI Layer (Flutter Widgets / Material Design 3)              │   │
│  │  ┌──────────────┐ ┌──────────────┐ ┌────────────────────┐   │   │
│  │  │  MainScreen   │ │ ConfigScreen │ │ PermissionsScreen  │   │   │
│  │  │  (3 botones)  │ │ (contactos,  │ │ (solicitud en     │   │   │
│  │  │               │ │  intervalo)  │ │  cadena)           │   │   │
│  │  └──────┬────────┘ └──────┬───────┘ └────────────────────┘   │   │
│  │         │                 │                                    │   │
│  │  ┌──────┴─────────────────┴────────────────────────────────┐  │   │
│  │  │  Providers (ChangeNotifiers / MVVM ViewModels)          │  │   │
│  │  │  ┌──────────────────┐  ┌──────────────────────────┐     │  │   │
│  │  │  │  MainProvider     │  │  ConfigProvider           │     │  │   │
│  │  │  │  - estadoEmerg   │  │  - configuracion          │     │  │   │
│  │  │  │  - activar()      │  │  - guardarConfig()       │     │  │   │
│  │  │  │  - cancelar()     │  │  - cargarContactos()     │     │  │   │
│  │  │  └────────┬─────────┘  └───────────┬──────────────┘     │  │   │
│  │  └───────────┼────────────────────────┼─────────────────────┘  │   │
│  │              │                        │                        │   │
│  │  ┌───────────┴────────────────────────┴─────────────────────┐  │   │
│  │  │  Services (Background & System)                          │  │   │
│  │  │  ┌────────────────────────────────────┐                  │  │   │
│  │  │  │ EmergencyBackgroundService         │                  │  │   │
│  │  │  │ (flutter_background_service)       │                  │  │   │
│  │  │  │  - Ciclo de envío periódico       │                  │  │   │
│  │  │  │  - Gestión de GPS                 │                  │  │   │
│  │  │  └────────────────────────────────────┘                  │  │   │
│  │  │  ┌────────────────────────────────────┐                  │  │   │
│  │  │  │ NotificationService                │                  │  │   │
│  │  │  │ (flutter_local_notifications)      │                  │  │   │
│  │  │  │  - Canal emergencia               │                  │  │   │
│  │  │  │  - Notificación persistente        │                  │  │   │
│  │  │  └────────────────────────────────────┘                  │  │   │
│  │  └──────────────────────────────────────────────────────────┘  │   │
│  └──────────────────────────────────────────────────────────────┘   │
├─────────────────────────────────────────────────────────────────────┤
│                        DOMAIN LAYER                                 │
│  ┌──────────────────────────────────────────────────────────────┐   │
│  │  Use Cases                                                    │   │
│  │  ┌──────────────┐ ┌──────────────┐ ┌───────────────────┐    │   │
│  │  │ActivEmergenc │ │CancelEmerg   │ │EnviarUbicacion    │    │   │
│  │  └──────┬───────┘ └──────┬───────┘ └───────┬───────────┘    │   │
│  │  ┌──────┴───────┐ ┌──────┴───────┐ ┌───────┴───────────┐    │   │
│  │  │GuardarConfig │ │ObtenerConfig│ │VerifDisponibilidad│    │   │
│  │  └──────────────┘ └──────────────┘ └───────────────────┘    │   │
│  │                                                              │   │
│  │  ┌────────────────────────────────────────────────────────┐  │   │
│  │  │  Repository Interfaces (Contratos abstractos)          │  │   │
│  │  │  IContactoRepository, IConfigRepository,               │  │   │
│  │  │  IEmergencyRepository, ILocationRepository,            │  │   │
│  │  │  ISmsRepository, ITelegramRepository,                  │  │   │
│  │  │  IWhatsAppRepository                                   │  │   │
│  │  └────────────────────────────────────────────────────────┘  │   │
│  │                                                              │   │
│  │  ┌────────────────────────────────────────────────────────┐  │   │
│  │  │  Entities (Modelos de dominio puros)                   │  │   │
│  │  │  ContactoEmergencia, Configuracion, Coordenadas,       │  │   │
│  │  │  EstadoEmergencia, TipoEmergencia                      │  │   │
│  │  └────────────────────────────────────────────────────────┘  │   │
│  └──────────────────────────────────────────────────────────────┘   │
├─────────────────────────────────────────────────────────────────────┤
│                          DATA LAYER                                  │
│  ┌──────────────────────────────────────────────────────────────┐   │
│  │  Repository Implementations                                  │   │
│  │  ┌────────────────────────────────────────────────────────┐  │   │
│  │  │ ContactoRepoImpl  ConfigRepoImpl  EmergencyRepoImpl    │  │   │
│  │  │ LocationRepoImpl  SmsRepoImpl     TelegramRepoImpl     │  │   │
│  │  │ WhatsAppRepoImpl                                        │  │   │
│  │  └────────────────────────────────────────────────────────┘  │   │
│  │                                                              │   │
│  │  ┌──────────────────┐  ┌──────────────────┐  ┌────────────┐  │   │
│  │  │   Local Sources  │  │  Remote Sources  │  │   Device   │  │   │
│  │  │ ┌──────────────┐ │  │ ┌──────────────┐│  │ ┌────────┐ │  │   │
│  │  │ │ Drift (SQLite)│ │  │ │Telegram Bot  ││  │ │Geolocat│ │  │   │
│  │  │ │ ConfigDAO     │ │  │ │API (dio)     ││  │ │or      │ │  │   │
│  │  │ │ ContactsDAO   │ │  │ └──────────────┘│  │ └────────┘ │  │   │
│  │  │ └──────────────┘ │  │ ┌──────────────┐│  │ ┌────────┐ │  │   │
│  │  │ ┌──────────────┐ │  │ │              ││  │ │url_lau │ │  │   │
│  │  │ │SharedPrefs   │ │  │ │(solo Telegram)││  │ │ncher   │ │  │   │
│  │  │ └──────────────┘ │  │ └──────────────┘│  │ └────────┘ │  │   │
│  │  └──────────────────┘  └──────────────────┘  └────────────┘  │   │
│  │                                                              │   │
│  │  ┌────────────────────────────────────────────────────────┐  │   │
│  │  │  Mappers (Data <-> Domain)                             │  │   │
│  │  │  ContactoMapper, ConfigMapper                          │  │   │
│  │  └────────────────────────────────────────────────────────┘  │   │
│  │                                                              │   │
│  │  ┌────────────────────────────────────────────────────────┐  │   │
│  │  │  Models (DTOs específicos de Data Layer)               │  │   │
│  │  │  ContactoModel, ConfiguracionModel,                    │  │   │
│  │  │  CoordenadasModel, TelegramDto                         │  │   │
│  │  └────────────────────────────────────────────────────────┘  │   │
│  └──────────────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────────────┘
```

### 1.2 Flujo de Datos entre Capas

```
               Widgets (UI)
                   │  Escucha ChangeNotifier con context.watch() / context.select()
                   ▼
            Provider (ChangeNotifier)
                   │  Ejecuta Use Cases
                   ▼
              Use Case
                   │  Llama a interfaz de repositorio (contrato abstracto)
                   ▼
          Repository (interfaz - domain)
                   │  Implementada en Data Layer (inyectada por GetIt)
                   ▼
       Repository (implementación - data)
              │               │
              ▼               ▼
       Local Source       Remote/Device Source
      (Drift/SharedPrefs) (Dio/Geolocator/Sms)
```

**Principio de dependencia:** Las dependencias apuntan hacia adentro. La capa `domain/` no conoce nada de `data/` ni de `presentation/`. La capa `data/` implementa las interfaces definidas en `domain/`. La capa `presentation/` depende de `domain/` pero no de `data/` directamente.

### 1.3 Inyección de Dependencias (GetIt + Injectable)

```
┌─────────────────────────────────────────────┐
│            main.dart (runApp)                │
│   - configureInjection()  ← GetIt           │
│   - runApp(LocalizadorApp())                      │
└─────────────────────────────────────────────┘
                       │
        ┌──────────────┼──────────────┐
        ▼              ▼              ▼
┌──────────────┐ ┌────────────┐ ┌──────────────┐
│ DataModule   │ │DomainModule│ │Presentation  │
│              │ │            │ │Module        │
│ - Drift DB   │ │ - UseCases │ │              │
│ - DAOs       │ │            │ │ - Providers  │
│ - Repo Impls │ │            │ │ - Services   │
│ - Dio Client │ │            │ │              │
│            │ │            │ │              │
└──────────────┘ └────────────┘ └──────────────┘
```

**GetIt** actúa como Service Locator. **Injectable** genera automáticamente el código de registro en `injection.config.dart` a partir de anotaciones `@injectable`, `@singleton`, `@factoryParam`, etc.

---

## 2. Estructura de Paquetes del Proyecto Flutter

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
│   │       └── presentation_module.dart       # Registro de providers y servicios
│   │       └── injection.config.dart          # Generado por Injectable (build_runner)
│   │
│   ├── core/
│   │   ├── constants/
│   │   │   ├── app_constants.dart             # Intervalos, límites, URLs
│   │   │   └── telegram_constants.dart        # Endpoints de Telegram, tokens
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
│   │       ├── extensions.dart                # Extensiones útiles (String, BuildContext)
│   │       ├── message_builder.dart           # Construcción de mensajes según TipoEmergencia
│   │       └── permission_utils.dart          # Utilidades de permisos
│   │
│   ├── data/
│   │   ├── datasources/
│   │   │   ├── local/
│   │   │   │   ├── app_database.dart          # Definición Drift database (tables)
│   │   │   │   ├── config_dao.dart            # DAO para configuración (Drift)
│   │   │   │   ├── contacts_dao.dart          # DAO para contactos (Drift)
│   │   │   │   └── shared_prefs_datasource.dart # Token Telegram, preferencias simples
│   │   │   └── remote/
│   │   │       └── telegram_remote_datasource.dart  # Llamadas HTTP a Bot API (solo Telegram)
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
│   │       └── verificar_disponibilidad_canal_usecase.dart  # Detecta qué canales están disponibles
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
│   │       ├── emergency_background_service.dart  # Foreground service con flutter_background_service
│   │       ├── notification_service.dart      # Gestión de canales y notificaciones
│   │       └── localizador_sonido_service.dart       # Reproducción de pitido periódico (RF-14)
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
│   ├── app/
│   │   └── src/
│   │       └── main/
│   │           └── AndroidManifest.xml        # Permisos declarados
│   └── build.gradle.kts
│
├── ios/
│   └── Runner/
│       └── Info.plist                         # Permisos iOS
│
├── assets/
│   ├── .env                                   # Telegram token
│   ├── icons/                                 # Iconos de la app
│   └── images/                                # Imágenes del theme
│
├── pubspec.yaml
├── analysis_options.yaml
└── .gitignore
```

### 2.1 Modularidad y Separación de Responsabilidades

| Capa | Responsabilidad | Dependencias permitidas |
|------|----------------|------------------------|
| **presentation/** | UI, estado, navegación, servicios de sistema | domain/ |
| **domain/** | Reglas de negocio, entidades, contratos | Ninguna (capa más interna) |
| **data/** | Implementaciones, APIs, DB, mappers | domain/, paquetes externos |
| **core/** | Utilidades transversales | Ninguna (librerías std) |
| **app/** | Configuración, DI | Todas las capas |

---

## 3. Modelo de Datos (Entidades de Dominio)

### 3.1 `TipoEmergencia` (Enum)

```dart
enum TipoEmergencia {
  extraviado('Extraviado', 'EXT', AppColors.emergencyYellow),
  atrapado('Atrapado', 'ATR', AppColors.emergencyOrange),
  herido('Herido', 'HER', AppColors.emergencyRed);

  final String displayName;
  final String codigo;
  final Color color;

  const TipoEmergencia(this.displayName, this.codigo, this.color);

  String mensajeAuxilio(Coordenadas coords) {
    final url = coords.toGoogleMapsUrl();
    return switch (this) {
      TipoEmergencia.extraviado =>
        '¡Emergencia! Estoy extraviado, necesito ayuda. Mi ubicación: $url',
      TipoEmergencia.atrapado =>
        '¡Emergencia! Estoy atrapado, necesito ayuda. Mi ubicación: $url',
      TipoEmergencia.herido =>
        '¡Emergencia! Estoy herido, necesito ayuda médica urgente. Mi ubicación: $url',
    };
  }
}
```

### 3.2 `ContactoEmergencia`

```dart
class ContactoEmergencia {
  final String id;                // ID único (URI del contacto en agenda)
  final String nombre;
  final String telefono;          // Formato internacional sin +
  final bool tieneWhatsApp;
  final bool tieneTelegram;
  final String? chatIdTelegram;   // Chat ID para Telegram Bot

  const ContactoEmergencia({
    required this.id,
    required this.nombre,
    required this.telefono,
    this.tieneWhatsApp = false,
    this.tieneTelegram = false,
    this.chatIdTelegram,
  });

  ContactoEmergencia copyWith({...});
}
```

### 3.3 `Configuracion`

```dart
class Configuracion {
  final int intervaloMinutos;                  // Mínimo: 1, Default: 5
  final List<ContactoEmergencia> contactos;    // Máximo: 10
  final String idioma;                         // 'es' o 'en'

  const Configuracion({
    this.intervaloMinutos = 5,
    this.contactos = const [],
    this.idioma = 'es',
  });
}
```

### 3.4 `Coordenadas`

```dart
class Coordenadas {
  final double latitud;
  final double longitud;
  final DateTime timestamp;
  final double precision;  // En metros

  const Coordenadas({
    required this.latitud,
    required this.longitud,
    DateTime? timestamp,
    this.precision = 0,
  }) : timestamp = timestamp ?? DateTime.now();

  String toGoogleMapsUrl() =>
      'https://maps.google.com/?q=$latitud,$longitud';
}
```

### 3.5 `EstadoEmergencia`

```dart
class EstadoEmergencia {
  final bool activa;
  final TipoEmergencia? tipo;
  final DateTime? inicioTimestamp;
  final DateTime? ultimoEnvioTimestamp;
  final int enviosRealizados;
  final Coordenadas? coordenadaActual;

  const EstadoEmergencia({
    this.activa = false,
    this.tipo,
    this.inicioTimestamp,
    this.ultimoEnvioTimestamp,
    this.enviosRealizados = 0,
    this.coordenadaActual,
  });

  Duration get tiempoTranscurrido {
    if (inicioTimestamp == null) return Duration.zero;
    return DateTime.now().difference(inicioTimestamp!);
  }
}
```

### 3.6 Modelos de Datos (Data Layer - Drift)

```dart
// app_database.dart (Drift)
@DriftDatabase(tables: [Contactos, Configuraciones])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;
}

// Contactos table
@DataClassName('ContactoModel')
class Contactos extends Table {
  TextColumn get id => text()();
  TextColumn get nombre => text()();
  TextColumn get telefono => text()();
  BoolColumn get tieneWhatsApp => boolean().withDefault(const Constant(false))();
  BoolColumn get tieneTelegram => boolean().withDefault(const Constant(false))();
  TextColumn get chatIdTelegram => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

// Configuraciones table
@DataClassName('ConfiguracionModel')
class Configuraciones extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get intervaloMinutos => integer().withDefault(const Constant(5))();
  TextColumn get idioma => text().withDefault(const Constant('es'))();
}
```

---

## 4. Flujo de la Emergencia (Paso a Paso)

```
[Usuario presiona botón "Extraviado"]
        │
        ▼
┌─────────────────────────────────────┐
│ 1. Vibrar dispositivo               │  ← RF-09
│ 2. Mostrar diálogo confirmación     │  ← ConfirmationCountdownDialog
│    con contador regresivo de 10s    │     (StatefulWidget + Timer)
│    "¿Activar emergencia como        │
│     Extraviado?"                    │
│    ┌─────────────────────────┐      │
│    │ ▓▓▓▓▓▓▓░░░ 7s          │      │  ← Barra de progreso
│    │ [ 🔴 ABORTAR ]          │      │  ← Botón rojo prominente
│    └─────────────────────────┘      │
│    • Si el Timer llega a 0:         │
│      auto-ejecuta onConfirm()       │
│    • Si presiona ABORTAR:           │
│      cancela el Timer y cierra      │
└─────────────┬───────────────────────┘
        │ (Confirma automático o manual)
        ▼
┌─────────────────────────────────────┐
│ 3. MainProvider.activarEmergencia() │
│    → context.read<MainProvider>()   │
│      .activar(tipo)                 │
└─────────────┬───────────────────────┘
        │
        ▼
┌─────────────────────────────────────┐
│ 4. ActivarEmergenciaUseCase(tipo)   │
│    Orquesta:                        │
│    a. Verificar permisos            │
│    b. Guardar estado en repositorio │
│    c. Iniciar background service    │
└─────────────┬───────────────────────┘
        │
        ▼
┌─────────────────────────────────────┐
│ 5. EmergencyBackgroundService.start │
│    → flutter_background_service     │
│    → Inicia foreground con          │
│      notificación persistente       │
│      "🚨 Emergencia activa -        │
│       Extraviado"                   │
└─────────────┬───────────────────────┘
        │
        ▼
┌─────────────────────────────────────┐
│ 6. Iniciar pitido de localizador         │  ← RF-14
│    → LocalizadorSonidoService.iniciar()  │
│    → Pitido cada 10 segundos        │
│    → Fallback: SystemSound.alert    │
└─────────────┬───────────────────────┘
        │
        ▼
┌─────────────────────────────────────┐
│ 7. Intentar ahorro de batería       │  ← RF-06
│    → PowerManager (platform channel)│
│    → Si denegado: mostrar diálogo   │
│      pidiendo activación manual     │
└─────────────┬───────────────────────┘
        │
        ▼
┌─────────────────────────────────────┐
│ 8. Obtener coordenadas GPS          │  ← RF-04
│    → LocationRepositoryImpl         │
│      .getCurrentLocation()          │
│    → geolocator.getCurrentPosition  │
│    → Timeout: 30 seg                │
└─────────────┬───────────────────────┘
        │
        ▼
┌─────────────────────────────────────┐
│ 9. EnviarUbicacionUseCase(coords)   │
│    → Para cada contacto (SECUENCIAL):│
│    │   (pausa 500ms entre contactos)│
│    │                                │
│    ├── SMS  → SmsRepositoryImpl     │  ← Automático, sin datos móviles
│    │                                │
│    ├── WhatsApp → WhatsAppRepoImpl  │  ← Abre wa.me (usuario envía)
│    │                                │
│    └── Telegram → TelegramRepoImpl  │  ← Automático (si chatId != null)
│        dio POST sendMessage         │
│                                      │
│    → Generar resumen de envíos      │
└─────────────┬───────────────────────┘
        │
        ▼
┌─────────────────────────────────────┐
│ 10. Programar próximo envío         │  ← RF-05
│     → Timer.periodic() en el        │
│       background service            │
│     → Cada N minutos (configurable) │
│     → Repetir pasos 7-11            │
└─────────────┬───────────────────────┘
        │
        ├── [Usuario cancela] ───────────────────┐
        │                                        │
        ▼                                        ▼
┌───────────────────────────────┐    ┌───────────────────────────────┐
│ 11. CancelarEmergenciaUseCase │    │ (continúa hasta cancelar)     │
│     → Detener Timer           │    │     → Sigue enviando          │
│     → Detener GPS             │    │     → Actualiza notificación  │
│     → Detener pitido de localizador│    │     → Actualiza estado UI     │
│     → Cerrar Foreground       │    └───────────────────────────────┘
│       Service                 │
│     → Eliminar notificación   │
│     → Restaurar batería       │
│     → MainProvider.cancelar() │
│     → Actualizar UI           │
└───────────────────────────────┘
```

### 4.1 Diagrama de Secuencia

```
User     MainScreen     MainProvider   ActivarEmergenciaUC   BgService   LocationRepo   SmsRepo   TelegramRepo   WhatsAppRepo
 │           │               │                 │                │            │            │           │             │
 │─[Boton]──▶│               │                 │                │            │            │           │             │
 │◀─[Dialog]─│               │                 │                │            │            │           │             │
 │─[Confir]─▶│               │                 │                │            │            │           │             │
 │           │─[activar()]──▶│                 │                │            │            │           │             │
 │           │               │─[invoke]───────▶│                │            │            │           │             │
 │           │               │                 │─[start()]─────▶│            │            │           │             │
 │           │               │                 │                │─[getLoc()]─▶│            │           │             │
 │           │               │                 │                │◀─[coords]───│            │           │             │
 │           │               │                 │                │─[sendSms]───────────────▶│           │             │
 │           │               │                 │                │─[sendTg]─────────────────────────────▶│             │
 │           │               │                 │                │─[openWa]───────────────────────────────────────────▶│
 │           │               │                 │                │─[Timer]     │            │           │             │
 │           │               │                 │                │  (repite)   │            │           │             │
```

---

## 5. Estrategia de Permisos en Flutter

### 5.1 Permisos Requeridos

Se utiliza el paquete `permission_handler` para solicitar permisos en tiempo de ejecución.

| Permiso | Propósito | Android | iOS |
|---------|-----------|---------|-----|
| `contacts` | Leer agenda para seleccionar contactos | `READ_CONTACTS` | `Contacts` |
| `sms` | Enviar SMS con coordenadas | `SEND_SMS` | No aplica |
| `location` | GPS de alta precisión | `ACCESS_FINE_LOCATION` | `locationWhenInUse` |
| `locationAlways` | GPS en segundo plano | `ACCESS_BACKGROUND_LOCATION` | `locationAlways` |
| `ignoreBatteryOptimizations` | Evitar Doze | `REQUEST_IGNORE_BATTERY_OPTIMIZATIONS` | No aplica |
| `notification` | Notificación persistente | `POST_NOTIFICATIONS` (API 33+) | `UNAuthorizationOptionAlert` |

### 5.2 Declaración en AndroidManifest.xml

```xml
<uses-permission android:name="android.permission.READ_CONTACTS" />
<uses-permission android:name="android.permission.SEND_SMS" />
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
<uses-permission android:name="android.permission.ACCESS_BACKGROUND_LOCATION" />
<uses-permission android:name="android.permission.REQUEST_IGNORE_BATTERY_OPTIMIZATIONS" />
<uses-permission android:name="android.permission.POST_NOTIFICATIONS" />
<uses-permission android:name="android.permission.INTERNET" />
<uses-permission android:name="android.permission.FOREGROUND_SERVICE" />
<uses-permission android:name="android.permission.FOREGROUND_SERVICE_LOCATION" />
<uses-permission android:name="android.permission.VIBRATE" />
<uses-permission android:name="android.permission.RECEIVE_BOOT_COMPLETED" />
```

### 5.3 Declaración en Info.plist (iOS)

```xml
<key>NSContactsUsageDescription</key>
<string>Localizador necesita acceder a tus contactos para seleccionar contactos de emergencia</string>
<key>NSLocationWhenInUseUsageDescription</key>
<string>Localizador necesita tu ubicación para enviarla a tus contactos durante una emergencia</string>
<key>NSLocationAlwaysAndWhenInUseUsageDescription</key>
<string>Localizador necesita tu ubicación incluso en segundo plano para enviar actualizaciones periódicas</string>
<key>UIBackgroundModes</key>
<array>
    <string>fetch</string>
    <string>location</string>
</array>
```

### 5.4 Flujo de Solicitud en Cadena

```
App Inicia por primera vez
       │
       ▼
┌──────────────────────────────────────────┐
│ PermissionsScreen                         │
│ (sin acción del usuario no se avanza)     │
└───────────────────┬──────────────────────┘
                    │
                    ▼
┌──────────────────────────────────────────────┐
│ Permiso #1: Notification (Android 13+)        │
│ permission_handler: Permission.notification   │
└─────────────────────┬────────────────────────┘
                      │
                      ▼ (concedido o saltado)
┌──────────────────────────────────────────────┐
│ Permiso #2: Location (When In Use)            │
│ permission_handler: Permission.location      │
│ Mensaje: "Necesario para obtener tu           │
│  ubicación durante la emergencia"             │
└─────────────────────┬────────────────────────┘
                      │
                      ▼ (concedido)
┌──────────────────────────────────────────────┐
│ Permiso #3: Location (Always) [Android 29+ / │
│            iOS]                               │
│ permission_handler: Permission.locationAlways│
│ Mensaje: "Necesario para enviar ubicación     │
│  incluso en segundo plano"                    │
└─────────────────────┬────────────────────────┘
                      │
                      ▼ (concedido)
┌──────────────────────────────────────────────┐
│ Permiso #4: SMS                               │
│ permission_handler: Permission.sms            │
│ Mensaje: "Esto puede generar cargos por SMS"  │
└─────────────────────┬────────────────────────┘
                      │
                      ▼ (concedido)
┌──────────────────────────────────────────────┐
│ Permiso #5: Contacts                          │
│ permission_handler: Permission.contacts       │
└─────────────────────┬────────────────────────┘
                      │
                      ▼ (concedido)
┌──────────────────────────────────────────────┐
│ Permiso #6: IgnoreBatteryOptimizations        │
│ (se solicitará al ACTIVAR emergencia)         │
└─────────────────────┬────────────────────────┘
                      │
                      ▼
            ┌──────────────────┐
            │ Navegar a        │
            │ MainScreen       │
            └──────────────────┘
```

### 5.5 Implementación en Flutter

```dart
// permission_utils.dart
import 'package:permission_handler/permission_handler.dart';

class PermissionUtils {
  static Future<bool> requestContactPermission() async {
    final status = await Permission.contacts.request();
    return status.isGranted;
  }

  static Future<bool> requestSmsPermission() async {
    final status = await Permission.sms.request();
    return status.isGranted;
  }

  static Future<bool> requestLocationPermission() async {
    final status = await Permission.location.request();
    return status.isGranted;
  }

  static Future<bool> requestBackgroundLocationPermission() async {
    final status = await Permission.locationAlways.request();
    return status.isGranted;
  }

  static Future<bool> requestNotificationPermission() async {
    final status = await Permission.notification.request();
    return status.isGranted;
  }

  static Future<bool> isPermissionGranted(Permission permission) async {
    return await permission.status.isGranted;
  }

  /// Verifica si el usuario marcó "No volver a preguntar"
  static Future<bool> isPermanentlyDenied(Permission permission) async {
    final status = await permission.status;
    return status.isPermanentlyDenied;
  }

  /// Abre configuración de la app en el sistema
  static Future<bool> openAppSettings() async {
    return await openAppSettings();
  }
}
```

### 5.6 Manejo de Denegaciones

```dart
// En el Provider o Screen
Future<void> handlePermissionResult(
  Permission permission,
  bool granted,
  VoidCallback onRetry,
  VoidCallback onRedirectToSettings,
) async {
  if (granted) return;

  if (await permission.status.isPermanentlyDenied) {
    // Usuario marcó "No volver a preguntar" → redirigir a settings
    onRedirectToSettings();
  } else {
    // Mostrar rationale y reintentar
    onRetry();
  }
}
```

---

## 6. Estrategia de Telegram Bot API

### 6.1 Configuración

1. El usuario crea un bot via [@BotFather](https://t.me/BotFather) y obtiene un token.
2. El token se almacena en `assets/.env` y se carga con `flutter_dotenv`.
3. El archivo `.env` está en `.gitignore` para no exponer el token.

```
# assets/.env (NO COMMITTEAR)
TELEGRAM_BOT_TOKEN=123456:ABC-DEF1234ghIkl-zyx57W2v1u123ew11
```

### 6.2 Endpoint

```
POST https://api.telegram.org/bot{TOKEN}/sendMessage
Content-Type: application/json

{
    "chat_id": "123456789",
    "text": "¡Emergencia! Estoy extraviado... https://maps.google.com/?q=19.4326,-99.1332",
    "parse_mode": "HTML"
}
```

### 6.3 Implementación con Dio

```dart
// telegram_remote_datasource.dart
@injectable
class TelegramRemoteDataSource {
  final DioClient _dioClient;
  final String _token;

  TelegramRemoteDataSource(this._dioClient)
      : _token = dotenv.env['TELEGRAM_BOT_TOKEN'] ?? '';

  Future<TelegramSendResponse> sendMessage({
    required String chatId,
    required String text,
  }) async {
    final response = await _dioClient.dio.post(
      'https://api.telegram.org/bot$_token/sendMessage',
      data: {
        'chat_id': chatId,
        'text': text,
        'parse_mode': 'HTML',
      },
    );
    return TelegramSendResponse.fromJson(response.data);
  }
}
```

### 6.4 Manejo de Errores

| Código HTTP | Significado | Acción |
|-------------|-------------|--------|
| 200 | Éxito | Continuar |
| 400 | Bad Request (chat_id inválido) | Marcar contacto como "Telegram no disponible" |
| 401 | Token inválido | Notificar al usuario |
| 403 | Bot bloqueado por el contacto | Marcar contacto como "Telegram no disponible" |
| 429 | Rate limit | Reintentar con backoff exponencial |
| Timeout | Red lenta | Reintentar en el próximo ciclo |

```dart
// telegram_repository_impl.dart
@override
Future<Result<bool>> sendMessage({
  required String chatId,
  required String message,
}) async {
  try {
    final response = await _remoteDataSource.sendMessage(
      chatId: chatId,
      text: message,
    );
    return Result.success(response.ok);
  } on DioException catch (e) {
    if (e.response?.statusCode == 403) {
      return Result.success(false); // Bot bloqueado
    }
    return Result.failure(TelegramFailure(e.message ?? 'Error desconocido'));
  }
}
```

---

## 7. Estrategia de WhatsApp

### 7.1 Envío vía wa.me

```
URI: https://wa.me/{codigoPais}{numero}?text={mensajeUrlEncoded}

Ejemplo:
https://wa.me/5215512345678?text=%C2%A1Emergencia%21%20Estoy%20extraviado...
```

### 7.2 Implementación con url_launcher

```dart
// whatsapp_repository_impl.dart
@injectable
class WhatsAppRepositoryImpl implements WhatsAppRepository {
  @override
  Future<bool> openWhatsApp({
    required String phoneNumber,
    required String message,
  }) async {
    final normalizedPhone = phoneNumber.replaceAll(RegExp(r'[\s\-+]'), '');
    final encodedMessage = Uri.encodeComponent(message);
    final uri = Uri.parse('https://wa.me/$normalizedPhone?text=$encodedMessage');

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
      return true;
    }
    return false; // WhatsApp no instalado
  }

  @override
  Future<bool> isWhatsAppInstalled() async {
    final uri = Uri.parse('https://wa.me/00000000000');
    return await canLaunchUrl(uri);
  }
}
```

### 7.3 Limitaciones

- **No es automático:** WhatsApp no permite envío automático. El Intent abre WhatsApp con el mensaje precargado, el usuario debe presionar "Enviar".
- **No hay API pública:** `wa.me` es la única vía disponible.
- **Detección de instalación:** Usar `canLaunchUrl()` de `url_launcher` para verificar.

### 7.4 Formato de Número

- El número debe estar en formato internacional **sin el signo `+`**.
- La app normaliza eliminando espacios, guiones y el signo `+`.

---

## 8. Estrategia de SMS

### 8.1 Envío vía sms: URI con url_launcher

```dart
// sms_repository_impl.dart
@injectable
class SmsRepositoryImpl implements SmsRepository {
  @override
  Future<bool> sendSms({
    required String phoneNumber,
    required String message,
  }) async {
    final uri = Uri.parse('sms:$phoneNumber?body=${Uri.encodeComponent(message)}');

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
      return true;
    }
    return false;
  }
}
```

**Nota:** A diferencia de Android nativo, en Flutter no hay una API directa para enviar SMS automáticamente sin abrir la app de mensajería. Para envío automático se puede usar:
- `sms` package: permite envío directo sin UI intermedia en Android.
- O implementar un MethodChannel hacia `SmsManager` nativo en Android.

Estrategia recomendada: Usar `sms` package para envío automático en Android y `url_launcher` como fallback.

```dart
// Alternativa con 'sms' package
import 'package:sms/sms.dart';

@override
Future<bool> sendSmsAuto(String phoneNumber, String message) async {
  if (Platform.isAndroid) {
    final sms = SmsSender();
    await sms.sendSms(SmsMessage(phoneNumber, message));
    return true;
  }
  // Fallback a URI para iOS
  return sendSmsViaUrl(phoneNumber, message);
}
```

### 8.2 Advertencia al Usuario

- En la pantalla de configuración:
  > "Al activar la emergencia se enviarán SMS. Esto puede generar cargos según tu plan telefónico."
- En el diálogo de confirmación antes de activar:
  > "Se enviarán SMS a tus contactos. ¿Estás seguro?"

### 8.3 Consideraciones

- **Límite de 160 caracteres:** Los mensajes con URL pueden exceder; usar multipart si es necesario.
- **Sin confirmación:** El SMS se envía automáticamente (con `sms` package).
- **Cobertura:** Los SMS funcionan sin datos móviles.

---

## 9. Estrategia de GPS

### 9.1 Principio: Peticiones Puntuales, No Streaming Continuo

Para maximizar el ahorro de batería, **no se usa streaming continuo de ubicación**. En su lugar, se obtiene la ubicación con `getCurrentPosition()` solo cuando es necesario (al enviar la señal de emergencia).

```dart
// location_repository_impl.dart
class LocationRepositoryImpl implements LocationRepository {
  final GeolocatorPlatform _geolocator;

  LocationRepositoryImpl(this._geolocator);

  @override
  Future<Coordenadas> obtenerUbicacionActual() async {
    final position = await _geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        timeLimit: Duration(seconds: 30),
      ),
    );
    return Coordenadas(
      latitud: position.latitude,
      longitud: position.longitude,
      timestamp: DateTime.fromMillisecondsSinceEpoch(
        position.timestamp?.millisecondsSinceEpoch ?? DateTime.now().millisecondsSinceEpoch,
      ),
      precision: position.accuracy,
    );
  }

  @override
  Stream<Coordenadas> obtenerActualizacionesUbicacion() {
    // NO USAR streaming continuo para ahorrar batería
    // En su lugar, el servicio en segundo plano llama a obtenerUbicacionActual() periódicamente
    throw UnimplementedError('Usar obtenerUbicacionActual() con Timer en su lugar');
  }
}
```

### 9.2 Manejo de Errores

| Error | Causa | Acción |
|-------|-------|--------|
| `LocationServiceDisabledException` | GPS desactivado | Mostrar notificación. Reintentar en próximo ciclo. |
| Sin señal | Interior, túneles | Reintentar en próximo ciclo. |
| Timeout | No se obtuvo fix | Reintentar en próximo ciclo con `LocationAccuracy.medium`. |
| Permiso denegado | Ubicación no concedida | Enviar mensaje sin coordenadas. |

### 9.3 Background Service: Llamada Puntual con Timer

```dart
// emergency_background_service.dart
@pragma('vm:entry-point')
static void onStart(ServiceInstance service) {
  Timer? timer;

  service.on('start').listen((event) async {
    final config = await configRepo.obtenerConfiguracion().first;
    final intervalo = Duration(minutes: config.intervaloMinutos);

    timer = Timer.periodic(intervalo, (_) async {
      final estado = await emergencyRepo.obtenerEstado().first;
      if (estado.activa && estado.tipo != null) {
        await enviarUbicacion.call(estado.tipo!);
      }
    });
  });

  service.on('stop').listen((_) {
    timer?.cancel();
    timer = null;
    service.stopSelf();
  });
}
```

---

## 10. Estrategia de Ahorro de Batería

### 10.1 Principios Rectores

| Principio | Descripción |
|-----------|-------------|
| **GPS puntual** | Usar `getCurrentPosition()` en lugar de `getPositionStream()` |
| **Envío secuencial** | SMS → WhatsApp → Telegram, nunca en paralelo, con pausa de 500ms entre contactos |
| **Intervalo mínimo** | Nunca menor a 1 minuto (reforzado en la entidad `Configuracion.intervaloMinimo = 1`) |
| **Liberación inmediata** | Al cancelar emergencia: detener Timer, liberar GPS, eliminar wakelock, cerrar foreground service |
| **Notificación silenciosa** | Notificación persistente con `Importance.low`, sin sonido, sin vibración |

### 10.2 Algoritmo

```
Al activar emergencia:
1. Verificar si el ahorro de batería ya está activo (Android PowerManager)
2. Si no: solicitar permiso REQUEST_IGNORE_BATTERY_OPTIMIZATIONS
3. Si concedido: intentar activar modo ahorro vía Platform Channel
4. Si denegado: mostrar diálogo pidiendo activación manual
```

### 10.3 Envío Secuencial (Evitar Picos de Consumo)

```dart
// En EnviarUbicacionUseCase
for (final contacto in config.contactos) {
  // SMS siempre (es lo más importante, funciona sin datos)
  await _smsRepository.enviarSms(contacto.telefono, mensaje);

  // WhatsApp si está disponible
  if (contacto.tieneWhatsApp) {
    await _whatsappRepository.abrirWhatsApp(contacto.telefono, mensaje);
  }

  // Telegram si tiene chatId
  if (contacto.tieneTelegram && contacto.chatIdTelegram != null) {
    await _telegramRepository.enviarMensajeTelegram(
      contacto.chatIdTelegram!, mensaje, config.telegramToken ?? '',
    );
  }

  // Pausa entre contactos para evitar saturación
  await Future.delayed(const Duration(milliseconds: 500));
}
```

### 10.4 Platform Channel para PowerManager (Android)

```dart
class BatteryOptimization {
  static const _channel = MethodChannel('com.localizador.emergencia/battery');

  static Future<bool> isPowerSaveMode() async {
    try {
      return await _channel.invokeMethod('isPowerSaveMode');
    } catch (e) {
      return false;
    }
  }

  static Future<bool> requestBatteryOptimization() async {
    try {
      return await _channel.invokeMethod('requestIgnoreBatteryOptimization');
    } catch (e) {
      return false;
    }
  }
}
```

### 10.5 Implementación Nativa Android

```kotlin
class BatteryPlugin : FlutterPlugin, MethodCallHandler {
    override fun onMethodCall(call: MethodCall, result: Result) {
        when (call.method) {
            "isPowerSaveMode" -> {
                val pm = context.getSystemService(Context.POWER_SERVICE) as PowerManager
                result.success(pm.isPowerSaveMode)
            }
            "requestIgnoreBatteryOptimization" -> {
                val intent = Intent(Settings.ACTION_REQUEST_IGNORE_BATTERY_OPTIMIZATIONS).apply {
                    data = Uri.parse("package:${context.packageName}")
                }
                result.success(true)
            }
        }
    }
}
```

### 10.6 Buenas Prácticas

- No usar ubicación continua (`getPositionStream`). Usar peticiones puntuales (`getCurrentPosition`).
- Al cancelar emergencia: detener Timer, liberar GPS, cancelar wakelock, cerrar foreground service.
- Liberar recursos explícitamente en `stop()` del background service.
- Enviar de forma secuencial para evitar picos de consumo de batería y red.
- La notificación persistente debe usar `Importance.low` sin sonido ni vibración.
- El pitido de localizador cada 10s tiene un impacto mínimo en la batería (una reproducción corta cada 10 segundos).

---

## 11. Estrategia de Notificaciones

### 11.1 Canal de Notificación

```dart
// notification_service.dart
@injectable
class NotificationService {
  final FlutterLocalNotificationsPlugin _plugin;
  static const String channelId = 'localizador_channel';
  static const int notificationId = 1001;

  NotificationService() : _plugin = FlutterLocalNotificationsPlugin();

  Future<void> initialize() async {
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    await _plugin.initialize(
      const InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      ),
    );

    await _createChannel();
  }

  Future<void> _createChannel() async {
    const androidPlugin = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();

    await androidPlugin?.createNotificationChannel(
      AndroidNotificationChannel(
        channelId,
        'Emergencia',
        description: 'Notificaciones de emergencia activa',
        importance: Importance.low,
        playSound: false,
        enableVibration: false,
      ),
    );
  }

  Future<void> showEmergencyNotification({
    required TipoEmergencia tipo,
    required String tiempoTranscurrido,
  }) async {
    await _plugin.show(
      notificationId,
      '🚨 Emergencia activa - ${tipo.displayName}',
      'Tiempo transcurrido: $tiempoTranscurrido',
      const NotificationDetails(
        android: AndroidNotificationDetails(
          channelId,
          'Emergencia',
          channelDescription: 'Notificaciones de emergencia activa',
          importance: Importance.low,
          priority: Priority.low,
          ongoing: true,
          autoCancel: false,
          actions: <AndroidNotificationAction>[
            AndroidNotificationAction(
              'cancel_action',
              'Cancelar emergencia',
              showsUserInterface: true,
              cancelNotification: true,
            ),
          ],
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: false,
          presentSound: false,
        ),
      ),
    );
  }

  Future<void> cancelEmergencyNotification() async {
    await _plugin.cancel(notificationId);
  }
}
```

### 11.2 Compatibilidad

| Plataforma | API Level | Comportamiento |
|------------|-----------|---------------|
| Android 8+ (API 26+) | `NotificationChannel` | Requerido |
| Android 13+ (API 33+) | `POST_NOTIFICATIONS` | Solicitar permiso runtime |
| Android 10+ (API 29+) | `FOREGROUND_SERVICE_LOCATION` | Tipo de foreground service |
| iOS 14+ | `UNUserNotificationCenter` | Solicitar permiso |

---

## 12. Dependencias Principales (pubspec.yaml)

```yaml
name: localizador_movil_emergencia
description: Aplicación de emergencia para compartir ubicación GPS con contactos de confianza
version: 1.0.0+1

environment:
  sdk: '>=3.2.0 <4.0.0'

dependencies:
  flutter:
    sdk: flutter

  # UI / Material Design 3
  flutter_localizations:
    sdk: flutter
  intl: ^0.19.0

  # Inyección de dependencias
  get_it: ^7.7.0
  injectable: ^2.4.0

  # Almacenamiento local
  drift: ^2.21.0
  sqlite3_flutter_libs: ^0.5.0
  shared_preferences: ^2.3.0

  # Red
  dio: ^5.4.0
  http: ^1.2.0

  # GPS / Localización
  geolocator: ^12.0.0

  # Notificaciones
  flutter_local_notifications: ^17.2.0

  # Background Service
  flutter_background_service: ^5.0.0
  flutter_background_service_android: ^6.0.0
  flutter_background_service_ios: ^5.0.0

  # Permisos
  permission_handler: ^11.3.0

  # URL Launcher (WhatsApp, SMS)
  url_launcher: ^6.2.0

  # Variables de entorno
  flutter_dotenv: ^5.1.0

  # Contactos (leer agenda)
  contacts_service: ^0.6.3

  # Vibración
  vibration: ^2.0.0

  # Utilidades
  equatable: ^2.0.5
  collection: ^1.18.0
  uuid: ^4.4.0

dev_dependencies:
  flutter_test:
    sdk: flutter
  integration_test:
    sdk: flutter

  # Generación de código
  drift_dev: ^2.21.0
  injectable_generator: ^2.6.0
  build_runner: ^2.4.0

  # Testing
  mockito: ^5.4.0
  mocktail: ^1.0.0
  bloc_test: ^9.1.0

  # Análisis estático
  flutter_lints: ^4.0.0
  very_good_analysis: ^6.0.0

flutter:
  uses-material-design: true

  assets:
    - assets/.env
    - assets/icons/
    - assets/images/

  generate: true  # Habilitar generación ARB para l10n
```

### 13.1 Versiones Mínimas por Plataforma

| Platform | Configuración |
|----------|--------------|
| **Android** | `minSdkVersion = 26` (API 26, Android 8.0) |
| **iOS** | `platform :ios, '14.0'` |
| **Kotlin** | `ext.kotlin_version = '1.9.0'` |
| **Gradle** | `distributionUrl=https\://services.gradle.org/distributions/gradle-8.7-all.zip` |
| **AGP** | `com.android.tools.build:gradle:8.5.0` |

### 13.2 Configuración de AndroidManifest.xml

```xml
<manifest xmlns:android="http://schemas.android.com/apk/res/android"
    package="com.localizador.emergencia">

    <uses-permission android:name="android.permission.READ_CONTACTS" />
    <uses-permission android:name="android.permission.SEND_SMS" />
    <uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
    <uses-permission android:name="android.permission.ACCESS_BACKGROUND_LOCATION" />
    <uses-permission android:name="android.permission.REQUEST_IGNORE_BATTERY_OPTIMIZATIONS" />
    <uses-permission android:name="android.permission.POST_NOTIFICATIONS" />
    <uses-permission android:name="android.permission.INTERNET" />
    <uses-permission android:name="android.permission.FOREGROUND_SERVICE" />
    <uses-permission android:name="android.permission.FOREGROUND_SERVICE_LOCATION" />
    <uses-permission android:name="android.permission.VIBRATE" />
    <uses-permission android:name="android.permission.RECEIVE_BOOT_COMPLETED" />

    <!-- API 33+ notification permission requerido -->
    <uses-permission android:maxSdkVersion="32" android:name="android.permission.POST_NOTIFICATIONS" />

    <application
        android:name=".Application"
        android:label="Localizador Emergencia"
        android:icon="@mipmap/ic_launcher"
        android:allowBackup="true"
        android:supportsRtl="true"
        android:theme="@style/Theme.Localizador">

        <service
            android:name="com.dexterous.flutterlocalnotifications.ForegroundService"
            android:exported="false" />

        <service
            android:name="id.flutter.flutter_background_service.BackgroundService"
            android:exported="false"
            android:foregroundServiceType="location" />

    </application>
</manifest>
```

---

## Apéndice A: Comandos de Generación de Código

```bash
# Generar código para Injectable
dart run build_runner build --delete-conflicting-outputs

# Generar código para Drift
dart run build_runner build

# Generar localización (ARB)
flutter gen-l10n

# Ejecutar tests
flutter test

# Ejecutar análisis estático
flutter analyze

# Construir APK Debug
flutter build apk --debug

# Construir APK Release
flutter build apk --release

# Construir IPA (solo macOS)
flutter build ios --release
```

---

## Apéndice B: Mapeo entre Arquitectura Android (Nat-Kotlin) y Flutter (Dart)

| Concepto Android (Nat-Kotlin) | Concepto Flutter (Dart) |
|------------------------------|------------------------|
| Jetpack Compose Widget | Flutter Widget |
| ViewModel (StateFlow) | ChangeNotifier / Provider |
| Hilt (Dagger) | GetIt + Injectable |
| Room (SQLite) | Drift (SQLite) |
| DataStore Preferences | SharedPreferences |
| Retrofit + OkHttp | Dio |
| FusedLocationProviderClient | geolocator |
| SmsManager | sms package / url_launcher |
| Intent wa.me | url_launcher |
| WorkManager | flutter_background_service |
| NotificationCompat | flutter_local_notifications |
| Firebase Firestore | No aplica (solo local) |
| Navigation Compose | Navigator 2.0 (GoRouter) |
| Manifest permisos | permission_handler |
| BuildConfig | flutter_dotenv |
| Gradle (Kotlin DSL) | pubspec.yaml |

---

## Apéndice C: Estructura de Tests

```
test/
├── data/
│   ├── datasources/
│   │   ├── local/
│   │   │   ├── config_dao_test.dart
│   │   │   ├── contacts_dao_test.dart
│   │   │   └── shared_prefs_datasource_test.dart
│   │   └── remote/
│   │       └── telegram_remote_datasource_test.dart
│   ├── models/
│   │   ├── contacto_model_test.dart
│   │   ├── configuracion_model_test.dart
│   │   └── telegram_dto_test.dart
│   ├── repositories/
│   │   ├── contacto_repository_impl_test.dart
│   │   ├── config_repository_impl_test.dart
│   │   ├── emergency_repository_impl_test.dart
│   │   ├── location_repository_impl_test.dart
│   │   ├── sms_repository_impl_test.dart
│   │   ├── telegram_repository_impl_test.dart
│   │   └── whatsapp_repository_impl_test.dart
│   └── mappers/
│       ├── contacto_mapper_test.dart
│       └── config_mapper_test.dart
├── domain/
│   └── usecases/
│       ├── activar_emergencia_usecase_test.dart
│       ├── cancelar_emergencia_usecase_test.dart
│       ├── enviar_ubicacion_usecase_test.dart
│       ├── obtener_contactos_usecase_test.dart
│       ├── guardar_configuracion_usecase_test.dart
│       ├── obtener_configuracion_usecase_test.dart
│       └── verificar_disponibilidad_canal_usecase_test.dart
├── presentation/
│   ├── providers/
│   │   ├── main_provider_test.dart
│   │   └── config_provider_test.dart
│   ├── screens/
│   │   ├── main_screen_test.dart
│   │   └── config_screen_test.dart
│   └── widgets/
│       ├── emergency_button_test.dart
│       ├── confirmation_dialog_test.dart
│       ├── emergency_active_banner_test.dart
│       ├── contact_list_section_test.dart
│       └── interval_section_test.dart
└── core/
    └── utils/
        ├── message_builder_test.dart
        └── permission_utils_test.dart
```
