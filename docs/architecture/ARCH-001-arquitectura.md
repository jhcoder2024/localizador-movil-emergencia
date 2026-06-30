# Documento de Arquitectura - Localizador Móvil de Emergencia

| Campo | Valor |
|-------|-------|
| **ID** | ARCH-001 |
| **Nombre** | Arquitectura de la Aplicación Localizador Móvil de Emergencia |
| **Versión** | 1.0 |
| **Fecha** | 26/06/2026 |
| **Estado** | Aprobado |
| **Autor** | Arquitecto de Software |

---

## Índice

1. [Diagrama de Arquitectura](#1-diagrama-de-arquitectura)
2. [Estructura de Paquetes](#2-estructura-de-paquetes)
3. [Modelo de Datos](#3-modelo-de-datos)
4. [Flujo de la Emergencia](#4-flujo-de-la-emergencia-paso-a-paso)
5. [Estrategia de Permisos](#5-estrategia-de-permisos)
6. [Estrategia de Telegram Bot API](#6-estrategia-de-telegram-bot-api)
7. [Estrategia de WhatsApp](#7-estrategia-de-whatsapp)
8. [Estrategia de SMS](#8-estrategia-de-sms)
9. [Estrategia de GPS](#9-estrategia-de-gps)
10. [Estrategia de Ahorro de Batería](#10-estrategia-de-ahorro-de-batería)
11. [Estrategia de Notificaciones](#11-estrategia-de-notificaciones)
12. [Consideraciones de Seguridad](#12-consideraciones-de-seguridad)

---

## 1. Diagrama de Arquitectura

### 1.1 Vista General de Capas

La aplicación sigue una arquitectura **Clean Architecture** con 3 capas principales:

```
┌─────────────────────────────────────────────────────────┐
│                   PRESENTATION LAYER                     │
│  ┌──────────────────────────────────────────────────┐   │
│  │  UI (Jetpack Compose)                            │   │
│  │  ┌──────────┐ ┌──────────┐ ┌───────────────┐    │   │
│  │  │ MainScreen│ │ConfigScre│ │EmergencyService│    │   │
│  │  │ (3botones)│ │ (contact)│ │ (Foreground)   │    │   │
│  │  └─────┬─────┘ └────┬─────┘ └───────┬───────┘    │   │
│  │        └──────┬──────┘              │              │   │
│  │               │ State               │ Intent       │   │
│  │         ┌─────▼──────┐              │              │   │
│  │         │  ViewModel │◄─────────────┘              │   │
│  │         └─────┬──────┘                             │   │
│  └───────────────┼────────────────────────────────────┘   │
├──────────────────┼────────────────────────────────────────┤
│                   DOMAIN LAYER                             │
│  ┌───────────────┴────────────────────────────────────┐   │
│  │  UseCases                                          │   │
│  │  ┌──────────────┐ ┌─────────────┐ ┌─────────────┐ │   │
│  │  │ActivateEmerg │ │CancelEmerg  │ │SendLocation │ │   │
│  │  └──────┬───────┘ └──────┬──────┘ └──────┬──────┘ │   │
│  │         │                │                │          │   │
│  │  ┌──────▼────────────────▼────────────────▼──────┐  │   │
│  │  │            Repository Interfaces               │  │   │
│  │  │  EmergencyRepository, ContactRepository,       │  │   │
│  │  │  LocationRepository, ConfigRepository,         │  │   │
│  │  │  SmsRepository, TelegramRepository,            │  │   │
│  │  │  WhatsAppRepository                            │  │   │
│  │  └────────────────────────────────────────────────┘  │   │
│  └──────────────────────────────────────────────────────┘   │
├──────────────────────────────────────────────────────────────┤
│                  DATA LAYER                                  │
│  ┌────────────────────────────────────────────────────────┐  │
│  │  Data Sources                                         │  │
│  │  ┌──────────────┐ ┌──────────────┐ ┌──────────────┐  │  │
│  │  │   Local      │ │   Remote     │ │   Device     │  │  │
│  │  │  ┌────────┐  │ │ ┌──────────┐ │ │ ┌──────────┐ │  │  │
│  │  │  │DataStor│  │ │ │Telegram  │ │ │ │Fused     │ │  │  │
│  │  │  │e       │  │ │ │Bot API   │ │ │ │Location  │ │  │  │
│  │  │  └────────┘  │ │ └──────────┘ │ │ │Provider  │ │  │  │
│  │  │              │ │ ┌──────────┐ │ │ └──────────┘ │  │  │
│  │  │              │ │ │(Eliminado)│ │ │ ┌──────────┐ │  │  │
│  │  │              │ │ │Firestore │ │ │ │SmsManager│ │  │  │
│  │  │              │ │ └──────────┘ │ │ └──────────┘ │  │  │
│  │  └──────────────┘ └──────────────┘ └──────────────┘  │  │
│  │                                                       │  │
│  │  ┌────────────────────────────────────────────────┐   │  │
│  │  │           Repository Implementations            │   │  │
│  │  └────────────────────────────────────────────────┘   │  │
│  └──────────────────────────────────────────────────────┘   │
└──────────────────────────────────────────────────────────────┘
```

### 1.2 Flujo de Datos entre Capas

```
                    UI (Compose)
                        │  Observa StateFlow / LiveData
                        ▼
                    ViewModel
                        │  Ejecuta UseCases
                        ▼
                    UseCases
                        │  Llama a interfaces de repositorio
                        ▼
                 Repository (interfaz)
                        │  Implementada en Data Layer
                        ▼
              Repository (implementación)
                   │              │
                   ▼              ▼
              Local Source    Remote/Device Source
              (DataStore)     (Telegram, GPS, SMS)
```

**Principio de dependencia:** Las dependencias apuntan hacia adentro. La capa de Domain no conoce nada de las capas externas. La capa Data implementa las interfaces definidas en Domain. La capa Presentation depende de Domain pero no de Data directamente.

### 1.3 Inyección de Dependencias (Hilt)

```
┌─────────────────────────────────────────────┐
│                 LocalizadorApp                    │
│         @HiltAndroidApp Application          │
└─────────────────────┬───────────────────────┘
                      │
        ┌─────────────┼─────────────┐
        ▼             ▼             ▼
┌────────────┐ ┌────────────┐ ┌────────────┐
│ DataModule │ │ NetworkMod │ │ ServiceMod │
│ (repo,     │ │ ule        │ │ ule        │
│  local,    │ │ (OkHttp,   │ │ (Foregroun │
│  GPS)      │ │ Retrofit)  │ │ d Service) │
└────────────┘ └────────────┘ └────────────┘
```

---

## 2. Estructura de Paquetes

```
com.localizador.emergencia/
│
├── LocalizadorApp.kt                              # @HiltAndroidApp Application class
│
├── di/                                        # Módulos de inyección de dependencias (Hilt)
│   ├── AppModule.kt                           # Módulo principal (Context, DataStore)
│   ├── LocationModule.kt                      # FusedLocationProviderClient
│   ├── NetworkModule.kt                       # OkHttpClient, Retrofit (Telegram API)
│   └── ServiceModule.kt                       # Foreground Service dependencies
│
├── data/
│   ├── local/
│   │   ├── ConfigDataStore.kt                 # DataStore para configuración del usuario
│   │   └── ContactSerializer.kt               # Serializador de contactos para DataStore
│   │
│   ├── remote/
│   │   ├── telegram/
│   │   │   ├── TelegramApiService.kt          # Interface Retrofit: POST sendMessage
│   │   │   ├── TelegramRequest.kt             # DTOs para request/response de Telegram
│   │   │   └── TelegramClient.kt              # Cliente HTTP con OkHttp (manejo de errores)
│   │   └── (Eliminado) firebase/  # Ya no aplica — solo almacenamiento local
│   │
│   │
│   ├── repository/
│   │   ├── EmergencyRepositoryImpl.kt         # Implementación del repositorio de emergencia
│   │   ├── ContactRepositoryImpl.kt           # Implementación: lee contactos de agenda
│   │   ├── ConfigRepositoryImpl.kt            # Implementación: DataStore
│   │   ├── LocationRepositoryImpl.kt          # Implementación: FusedLocationProviderClient
│   │   ├── SmsRepositoryImpl.kt               # Implementación: SmsManager
│   │   ├── TelegramRepositoryImpl.kt          # Implementación: Telegram Bot API
│   │   └── WhatsAppRepositoryImpl.kt          # Implementación: Intent wa.me
│   │
│   └── mapper/
│       ├── ContactMapper.kt                   # Mapeo ContactDto ↔ ContactoEmergencia
│       └── ConfigMapper.kt                    # Mapeo ConfigDto ↔ Configuracion
│
├── domain/
│   ├── model/
│   │   ├── ContactoEmergencia.kt              # Modelo de contacto de emergencia
│   │   ├── Configuracion.kt                   # Modelo de configuración
│   │   ├── Coordenadas.kt                     # Modelo de coordenadas GPS
│   │   ├── TipoEmergencia.kt                  # Enum: EXTRAVIADO, ATRAPADO, HERIDO
│   │   └── EstadoEmergencia.kt                # Estado de la emergencia actual
│   │
│   ├── repository/
│   │   ├── EmergencyRepository.kt             # Interfaz: gestión de estado de emergencia
│   │   ├── ContactRepository.kt               # Interfaz: obtención de contactos
│   │   ├── ConfigRepository.kt                # Interfaz: lectura/escritura de configuración
│   │   ├── LocationRepository.kt              # Interfaz: obtención de coordenadas GPS
│   │   ├── SmsRepository.kt                   # Interfaz: envío de SMS
│   │   ├── TelegramRepository.kt               # Interfaz: envío por Telegram Bot API
│   │   └── WhatsAppRepository.kt              # Interfaz: apertura de WhatsApp
│   │
│   └── usecase/
│       ├── ActivarEmergenciaUseCase.kt        # Orquesta activación: GPS + notificaciones + envíos
│       ├── CancelarEmergenciaUseCase.kt       # Detiene servicio, libera recursos
│       ├── EnviarUbicacionUseCase.kt          # Envía coordenadas por todos los canales
│       ├── ObtenerContactosUseCase.kt         # Obtiene contactos del repositorio
│       ├── GuardarConfiguracionUseCase.kt     # Guarda configuración en DataStore
│       ├── ObtenerConfiguracionUseCase.kt     # Lee configuración de DataStore
│       └── VerificarDisponibilidadCanalUseCase.kt  # Verifica qué canales están disponibles
│
├── presentation/
│   ├── ui/
│   │   ├── main/
│   │   │   ├── MainScreen.kt                 # Pantalla principal: 3 botones de emergencia
│   │   │   ├── MainScreenViewModel.kt        # ViewModel de la pantalla principal
│   │   │   ├── EmergencyButton.kt            # Componente reutilizable de botón de emergencia
│   │   │   ├── ConfirmationDialog.kt         # Diálogo de confirmación antes de activar
│   │   │   └── EmergencyActiveBanner.kt      # Banner que muestra emergencia activa
│   │   │
│   │   ├── config/
│   │   │   ├── ConfigScreen.kt               # Pantalla de configuración
│   │   │   ├── ConfigScreenViewModel.kt      # ViewModel de configuración
│   │   │   ├── ContactListSection.kt         # Sección de lista de contactos
│   │   │   ├── ContactPickerDialog.kt        # Diálogo para seleccionar contactos
│   │   │   ├── IntervalSection.kt            # Sección de configuración de intervalo
│   │   │   └── (Eliminado) CloudBackupSection.kt  # Ya no aplica — solo local
│   │   │
│   │   ├── permissions/
│   │   │   └── PermissionScreen.kt           # Pantalla de solicitud de permisos en cadena
│   │   │
│   │   └── theme/
│   │       ├── Theme.kt                      # Tema Material3 (claro/oscuro)
│   │       ├── Color.kt                      # Colores: amarillo (extraviado), naranja (atrapado), rojo (herido)
│   │       ├── Type.kt                       # Tipografía
│   │       └── Shape.kt                      # Formas
│   │
│   ├── service/
│   │   └── EmergencyForegroundService.kt     # Foreground Service: ciclo de envío periódico
│   │
│   ├── notification/
│   │   └── NotificationHelper.kt             # Creación de canal y notificaciones
│   │
│   └── navigation/
│       └── NavGraph.kt                       # Navegación: Main ↔ Config ↔ Permissions
│
└── util/
    ├── Constants.kt                          # Constantes: valores por defecto, URLs
    ├── Extensions.kt                         # Extension functions (Context, etc.)
    ├── MessageBuilder.kt                     # Construcción de mensajes según TipoEmergencia
    └── NetworkUtil.kt                        # Utilidades de red (PackageManager, etc.)
```

---

## 3. Modelo de Datos

### 3.1 Modelos de Dominio (Domain Layer)

#### `ContactoEmergencia.kt`

```kotlin
data class ContactoEmergencia(
    val id: String,                    // ID único (URI del contacto en agenda)
    val nombre: String,                // Nombre del contacto
    val telefono: String,              // Número telefónico (formato internacional)
    val tieneWhatsApp: Boolean = false,// True si WhatsApp está instalado
    val tieneTelegram: Boolean = false,// True si tiene chat_id configurado
    val chatIdTelegram: String? = null // Chat ID para Telegram Bot
)
```

#### `Configuracion.kt`

```kotlin
data class Configuracion(
    val intervaloMinutos: Int = 5,                 // Mínimo: 1, Default: 5
    val contactos: List<ContactoEmergencia> = emptyList(),
    val idioma: String = "es",                     // "es" o "en"
    // (Eliminado) respaldoNubeActivado ya no aplica — solo almacenamiento local
)
```

#### `Coordenadas.kt`

```kotlin
data class Coordenadas(
    val latitud: Double,
    val longitud: Double,
    val timestamp: Long = System.currentTimeMillis(),
    val precision: Float = 0f           // Precisión en metros
) {
    fun toGoogleMapsUrl(): String = "https://maps.google.com/?q=$latitud,$longitud"
}
```

#### `TipoEmergencia.kt`

```kotlin
enum class TipoEmergencia(val displayName: String, val codigo: String) {
    EXTRAVIADO("Extraviado", "EXT"),
    ATRAPADO("Atrapado", "ATR"),
    HERIDO("Herido", "HER");

    fun mensajeAuxilio(coordenadas: Coordenadas): String = when (this) {
        EXTRAVIADO -> "¡Emergencia! Estoy extraviado, necesito ayuda. Mi ubicación: ${coordenadas.toGoogleMapsUrl()}"
        ATRAPADO -> "¡Emergencia! Estoy atrapado, necesito ayuda. Mi ubicación: ${coordenadas.toGoogleMapsUrl()}"
        HERIDO -> "¡Emergencia! Estoy herido, necesito ayuda médica urgente. Mi ubicación: ${coordenadas.toGoogleMapsUrl()}"
    }
}
```

#### `EstadoEmergencia.kt`

```kotlin
data class EstadoEmergencia(
    val activa: Boolean = false,
    val tipo: TipoEmergencia? = null,
    val inicioTimestamp: Long? = null,
    val ultimoEnvioTimestamp: Long? = null,
    val enviosRealizados: Int = 0,
    val coordenadaActual: Coordenadas? = null
)
```

### 3.2 DTOs (Data Layer)

#### `TelegramRequest.kt`

```kotlin
data class SendMessageRequest(
    @SerializedName("chat_id") val chatId: String,
    @SerializedName("text") val text: String,
    @SerializedName("parse_mode") val parseMode: String = "HTML"
)

data class SendMessageResponse(
    @SerializedName("ok") val ok: Boolean,
    @SerializedName("result") val result: MessageResult? = null,
    @SerializedName("description") val description: String? = null
)

data class MessageResult(
    @SerializedName("message_id") val messageId: Long
)
```

#### `FirebaseConfigDto.kt` — (Eliminado)

```kotlin
// (Eliminado) Todo el almacenamiento es local. No se requiere Firebase.
```

### 3.3 Serialización DataStore (Local)

```kotlin
// ConfigDataStore almacena un objeto Configuracion serializado como JSON
// usando un JsonSerializer personalizado para DataStore Preferences.
// Alternativa: DataStore Proto para tipado fuerte.
```

---

## 4. Flujo de la Emergencia (Paso a Paso)

```
[Usuario presiona botón "Extraviado"]
        │
        ▼
┌─────────────────────────────────────┐
│ 1. Vibrar dispositivo               │  ← RF-09
│ 2. Mostrar diálogo de confirmación  │  ← "¿Activar emergencia como Extraviado?"
└─────────────┬───────────────────────┘
        │ (Confirma)
        ▼
┌─────────────────────────────────────┐
│ 3. ViewModel.activarEmergencia()    │
│    → ActivarEmergenciaUseCase()      │
└─────────────┬───────────────────────┘
        │
        ▼
┌─────────────────────────────────────┐
│ 4. Iniciar Foreground Service       │  ← RF-10, RF-08
│    → EmergencyForegroundService     │
│    → Notificación persistente       │
│      "🚨 Emergencia activa - Extraviado"│
└─────────────┬───────────────────────┘
        │
        ▼
┌─────────────────────────────────────┐
│ 5. Intentar ahorro de batería       │  ← RF-06
│    → PowerManager.isPowerSaveMode() │
│    → Si no: solicitar permiso       │
│      ACTION_REQUEST_IGNORE_BATTERY  │
└─────────────┬───────────────────────┘
        │
        ▼
┌─────────────────────────────────────┐
│ 6. Obtener coordenadas GPS          │  ← RF-04
│    → FusedLocationProviderClient    │
│    → PRIORITY_HIGH_ACCURACY         │
│    → Timeout: 30 seg                │
└─────────────┬───────────────────────┘
        │
        ▼
┌─────────────────────────────────────┐
│ 7. Enviar a TODOS los contactos     │  ← RF-03
│    ├── Para cada contacto:          │
│    │   ├── SMS  → SmsManager        │  ← Automático
│    │   ├── WhatsApp → Intent wa.me  │  ← Abre app (usuario envía)
│    │   └── Telegram → Bot API       │  ← Automático (si tiene chatId)
│    │                                 │
│    └── Generar resumen de envíos    │
└─────────────┬───────────────────────┘
        │
        ▼
┌─────────────────────────────────────┐
│ 8. Programar próximo envío          │  ← RF-05
│    → Handler.postDelayed()          │
│    → Cada N minutos (configurable)  │
│    → Repetir pasos 6-8              │
└─────────────┬───────────────────────┘
        │
        ├── [Usuario cancela] ───────────────────┐
        │                                        │
        ▼                                        ▼
┌───────────────────────────────┐    ┌───────────────────────────────┐
│ 9. CancelarEmergenciaUseCase │    │ 9. (continúa hasta cancelar)  │
│    → Detener GPS              │    │    → Sigue enviando           │
│    → Detener Handler          │    │    → Actualiza notificación   │
│    → Cerrar Foreground Service│    │    → Actualiza estado UI      │
│    → Eliminar notificación    │    └───────────────────────────────┘
│    → Restaurar batería        │
│    → Actualizar estado UI     │
└───────────────────────────────┘
```

### 4.1 Diagrama de Secuencia (Simplificado)

```
Usuario    MainScreen    ViewModel    ActivateUseCase    ForegroundService    GPS    SmsManager    TelegramAPI    WhatsApp
   │            │            │              │                   │              │         │             │            │
   │──[Boton]──▶│            │              │                   │              │         │             │            │
   │◀─[Dialog]──│            │              │                   │              │         │             │            │
   │──[Confir]─▶│            │              │                   │              │         │             │            │
   │            │──[activa]─▶│              │                   │              │         │             │            │
   │            │            │──[invoke]───▶│                   │              │         │             │            │
   │            │            │              │──[startService]─▶│              │         │             │            │
   │            │            │              │                  │──[getLoc]───▶│         │             │            │
   │            │            │              │                  │◀─[coords]────│         │             │            │
   │            │            │              │                  │──[sendSMS]─────────────▶│             │            │
   │            │            │              │                  │──[sendTg]───────────────────────────▶│            │
   │            │            │              │                  │──[openWa]───────────────────────────────────────▶│
   │            │            │              │                  │──[postDelay]│         │             │            │
   │            │            │              │                  │  (repite)   │         │             │            │
```

---

## 5. Estrategia de Permisos

### 5.1 Permisos Requeridos

| Permiso | Propósito | API Mínima | Tipo |
|---------|-----------|------------|------|
| `READ_CONTACTS` | Leer agenda para seleccionar contactos | API 23 | Peligroso |
| `SEND_SMS` | Enviar SMS con coordenadas | API 23 | Peligroso |
| `ACCESS_FINE_LOCATION` | GPS de alta precisión | API 23 | Peligroso |
| `ACCESS_BACKGROUND_LOCATION` | GPS en segundo plano | API 29 | Peligroso |
| `REQUEST_IGNORE_BATTERY_OPTIMIZATIONS` | Evitar Doze / ahorro extremo | API 23 | Especial |
| `POST_NOTIFICATIONS` | Notificación persistente | API 33 (Android 13+) | Normal (runtime) |
| `INTERNET` | Telegram API | API 1 | Normal |
| `FOREGROUND_SERVICE` | Foreground Service | API 28 | Normal (manifest) |

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
```

### 5.3 Flujo de Solicitud en Cadena

```
App Inicia por primera vez
       │
       ▼
┌──────────────────────────┐
│ Pantalla de Bienvenida / │
│ Permisos Iniciales        │
└───────────┬──────────────┘
            │
            ▼
┌──────────────────────────────────────────────────┐
│ Solicitar permiso #1: POST_NOTIFICATIONS (13+)    │
│ (si API >= 33)                                    │
└─────────────────────┬────────────────────────────┘
                      │
                      ▼ (concedido o saltado)
┌──────────────────────────────────────────────────┐
│ Solicitar permiso #2: ACCESS_FINE_LOCATION        │
│ (necesario para funcionalidad principal)          │
└─────────────────────┬────────────────────────────┘
                      │
                      ▼ (concedido)
┌──────────────────────────────────────────────────┐
│ Solicitar permiso #3: ACCESS_BACKGROUND_LOCATION  │
│ (si API >= 29)                                    │
│ Informar: "Necesario para enviar ubicación en     │
│  segundo plano"                                    │
└─────────────────────┬────────────────────────────┘
                      │
                      ▼ (concedido)
┌──────────────────────────────────────────────────┐
│ Solicitar permiso #4: SEND_SMS                     │
│ Informar: "Esto puede generar cargos por SMS"     │
└─────────────────────┬────────────────────────────┘
                      │
                      ▼ (concedido)
┌──────────────────────────────────────────────────┐
│ Solicitar permiso #5: READ_CONTACTS               │
└─────────────────────┬────────────────────────────┘
                      │
                      ▼ (concedido)
┌──────────────────────────────────────────────────┐
│ Permiso #6: REQUEST_IGNORE_BATTERY_OPTIMIZATIONS  │
│ (se solicitará al ACTIVAR emergencia, no al inicio)│
└─────────────────────┬────────────────────────────┘
                      │
                      ▼
            ┌──────────────────┐
            │ Navegar a MainScreen│
            └──────────────────┘
```

### 5.4 Manejo de Denegaciones

- Si el usuario deniega un permiso, se muestra un mensaje informativo explicando por qué es necesario.
- Se ofrece un botón "Reintentar" que vuelve a solicitar el permiso.
- Si el usuario selecciona "No volver a preguntar", se redirige a la pantalla de Configuración del sistema (`Settings.ACTION_APPLICATION_DETAILS_SETTINGS`).
- La app **no debe bloquearse** si faltan permisos; debe funcionar con funcionalidad reducida (ej: sin SMS si falta SEND_SMS).

```kotlin
// Fragmento: Manejo de denegación con "No volver a preguntar"
fun handlePermissionResult(
    permission: String,
    granted: Boolean,
    shouldShowRationale: Boolean,
    onRedirectToSettings: () -> Unit,
    onRetry: () -> Unit
) {
    if (granted) return
    if (shouldShowRationale) {
        // Mostrar rationale y botón Reintentar
        onRetry()
    } else {
        // Usuario marcó "No volver a preguntar"
        // Mostrar diálogo → Abrir Configuración del sistema
        onRedirectToSettings()
    }
}
```

---

## 6. Estrategia de Telegram Bot API

### 6.1 Configuración del Bot

1. El usuario crea un bot en Telegram via [@BotFather](https://t.me/BotFather) y obtiene un token.
2. El token se almacena en `BuildConfig.TELEGRAM_BOT_TOKEN` usando `buildConfigField` en `build.gradle.kts` (no en texto plano en el código).
3. Los contactos del usuario deben iniciar una conversación con el bot en Telegram y enviar `/start`.
4. Cada contacto obtiene su `chat_id` y lo comparte con el usuario (ej: el bot puede responder con el chat_id).

**Flujo de configuración del chat_id para un contacto:**
```
1. Contacto abre Telegram
2. Busca el bot: @nombre_del_bot
3. Envía: /start
4. El bot responde: "Tu chat_id es 123456789. Comparte este número con [nombre_usuario]."
5. El usuario ingresa ese chat_id en la app para ese contacto.
```

### 6.2 API Endpoint

```
POST https://api.telegram.org/bot{TOKEN}/sendMessage
Content-Type: application/json

{
    "chat_id": "123456789",
    "text": "¡Emergencia! Estoy extraviado... https://maps.google.com/?q=19.4326,-99.1332",
    "parse_mode": "HTML"
}
```

### 6.3 Implementación Retrofit

```kotlin
interface TelegramApiService {
    @POST("bot{token}/sendMessage")
    suspend fun sendMessage(
        @Path("token") token: String,
        @Body request: SendMessageRequest
    ): Response<SendMessageResponse>
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

---

## 7. Estrategia de WhatsApp

### 7.1 Envío vía Intent wa.me

```
URI: https://wa.me/{codigoPais}{numero}?text={mensajeUrlEncoded}

Ejemplo:
https://wa.me/5215512345678?text=%C2%A1Emergencia%21%20Estoy%20extraviado...
```

### 7.2 Implementación

```kotlin
fun openWhatsApp(context: Context, contacto: ContactoEmergencia, mensaje: String) {
    val uri = Uri.parse("https://wa.me/${contacto.telefono}?text=${URLEncoder.encode(mensaje, "UTF-8")}")
    val intent = Intent(Intent.ACTION_VIEW, uri)

    // Verificar si WhatsApp está instalado
    val packageManager = context.packageManager
    val activities = packageManager.queryIntentActivities(intent, 0)
    if (activities.isNotEmpty()) {
        context.startActivity(intent)
    } else {
        // WhatsApp no está instalado → solo enviar SMS
        // Marcar contacto como "sin WhatsApp" en memoria
    }
}
```

### 7.3 Limitaciones

- **No es automático:** WhatsApp no permite envío automático sin interacción del usuario. El Intent abre WhatsApp con el mensaje precargado, pero el usuario debe presionar "Enviar".
- **No hay API pública:** No existe SDK oficial de WhatsApp para envío automatizado. `wa.me` es la única vía.
- **Detección de instalación:** Usar `PackageManager.queryIntentActivities()` para verificar si WhatsApp está instalado.

### 7.4 Formato de Número

El número debe estar en formato internacional **sin el signo `+`**:
- Correcto: `5215512345678`
- Incorrecto: `+5215512345678`
- Incorrecto: `55 1234 5678`

La app debe normalizar el número del contacto eliminando espacios, guiones y el signo `+`.

---

## 8. Estrategia de SMS

### 8.1 Envío con SmsManager

```kotlin
fun sendSms(phoneNumber: String, message: String): Result<Unit> {
    return try {
        val smsManager = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
            context.getSystemService(SmsManager::class.java)
        } else {
            @Suppress("DEPRECATION")
            SmsManager.getDefault()
        }

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP_MR1) {
            // API 22+: Send multipart if message > 160 chars
            val parts = smsManager.divideMessage(message)
            smsManager.sendMultipartTextMessage(phoneNumber, null, parts, null, null)
        } else {
            smsManager.sendTextMessage(phoneNumber, null, message, null, null)
        }
        Result.success(Unit)
    } catch (e: Exception) {
        Result.failure(e)
    }
}
```

### 8.2 Advertencia al Usuario

- En la pantalla de configuración, al seleccionar contactos, se muestra:
  > "Al activar la emergencia se enviarán SMS. Esto puede generar cargos según tu plan telefónico."
- En el diálogo de confirmación antes de activar emergencia:
  > "Se enviarán SMS a tus contactos. ¿Estás seguro?"

### 8.3 Consideraciones

- **Límite de 160 caracteres:** Usar `divideMessage()` para mensajes largos (los mensajes incluyen URL de Google Maps, que pueden exceder 160 caracteres).
- **Sin confirmación:** El SMS se envía automáticamente, sin necesidad de interacción del usuario.
- **Cobertura:** Los SMS funcionan sin datos móviles, lo que es crítico en zonas sin internet.

---

## 9. Estrategia de GPS

### 9.1 FusedLocationProviderClient

```kotlin
class LocationRepositoryImpl @Inject constructor(
    @ApplicationContext private val context: Context
) : LocationRepository {

    private val fusedLocationClient = LocationServices.getFusedLocationProviderClient(context)

    override suspend fun getCurrentLocation(timeoutMs: Long = 30_000): Result<Coordenadas> {
        return suspendCancellableCoroutine { continuation ->
            val request = LocationRequest.Builder(
                Priority.PRIORITY_HIGH_ACCURACY,
                60_000  // Intervalo de actualización (1 min)
            ).apply {
                setMinUpdateIntervalMillis(30_000)  // Mínimo 30 seg
                setMaxUpdateDelayMillis(120_000)     // Máximo 2 min
            }.build()

            val cancellationTokenSource = CancellationTokenSource()

            // Timeout
            val handler = Handler(Looper.getMainLooper())
            val timeoutRunnable = Runnable {
                cancellationTokenSource.cancel()
                if (continuation.isActive) {
                    continuation.resume(Result.failure(TimeoutException("GPS timeout")))
                }
            }
            handler.postDelayed(timeoutRunnable, timeoutMs)

            fusedLocationClient.getCurrentLocation(
                Priority.PRIORITY_HIGH_ACCURACY,
                cancellationTokenSource.token
            ).addOnSuccessListener { location ->
                handler.removeCallbacks(timeoutRunnable)
                if (location != null && continuation.isActive) {
                    continuation.resume(Result.success(Coordenadas(
                        latitud = location.latitude,
                        longitud = location.longitude,
                        precision = location.accuracy
                    )))
                } else if (continuation.isActive) {
                    continuation.resume(Result.failure(Exception("Location is null")))
                }
            }.addOnFailureListener { e ->
                handler.removeCallbacks(timeoutRunnable)
                if (continuation.isActive) {
                    continuation.resume(Result.failure(e))
                }
            }
        }
    }
}
```

### 9.2 Manejo de Errores

| Error | Causa | Acción |
|-------|-------|--------|
| GPS desactivado | Usuario apagó GPS | Mostrar notificación "GPS desactivado. Actívalo desde ajustes." Reintentar en próximo ciclo. |
| Sin señal | Interior, túneles | Reintentar en próximo ciclo. Incluir última ubicación conocida si está disponible. |
| Timeout | No se obtuvo fix | Reintentar en próximo ciclo con prioridad PRIORITY_BALANCED_POWER_ACCURACY. |
| Permiso denegado | Ubicación no concedida | Si el permiso fue denegado, enviar mensaje sin coordenadas. |

### 9.3 Intervalo Configurable

- **Valor por defecto:** 5 minutos
- **Valor mínimo:** 1 minuto
- **Límite superior recomendado:** 60 minutos
- **Implementación:** `Handler.postDelayed()` en el Foreground Service. No usar AlarmManager ni WorkManager, ya que necesitamos ejecución precisa sin demoras.

---

## 10. Estrategia de Ahorro de Batería

### 10.1 Algoritmo

```
Al activar emergencia:
1. PowerManager.isPowerSaveMode()
   ├── True → Ya está activado, continuar.
   └── False → Intentar activar:

2. Verificar permiso REQUEST_IGNORE_BATTERY_OPTIMIZATIONS
   ├── Concedido → Usar PowerManager para solicitar ahorro.
   └── No concedido → Solicitar permiso:

3. Intent ACTION_REQUEST_IGNORE_BATTERY_OPTIMIZATIONS
   ├── Concedido → Activar ahorro.
   └── Denegado → Mostrar diálogo:
        "Para maximizar la batería durante la emergencia,
         activa manualmente el ahorro de batería en:
         Ajustes > Batería > Ahorro de batería"
```

### 10.2 Implementación

```kotlin
fun requestBatteryOptimization(context: Context) {
    val intent = Intent(Settings.ACTION_REQUEST_IGNORE_BATTERY_OPTIMIZATIONS).apply {
        data = Uri.parse("package:${context.packageName}")
    }
    context.startActivity(intent)
}
```

### 10.3 Buenas Prácticas Adicionales

- **Intervalo de GPS:** No usar ubicación continua. Usar peticiones puntuales (`getCurrentLocation`) en lugar de `requestLocationUpdates`.
- **Liberar recursos:** Al cancelar emergencia, detener todas las solicitudes de GPS y limpiar handlers.
- **WorkManager:** No usar WorkManager para el envío periódico, ya que puede retrasar la ejecución. Usar Handler con postDelayed en el Foreground Service.

---

## 11. Estrategia de Notificaciones

### 11.1 Canal de Notificación

```kotlin
object NotificationHelper {
    private const val CHANNEL_ID = "localizador_channel"
    private const val CHANNEL_NAME = "Emergencia"
    private const val NOTIFICATION_ID = 1001

    fun createNotificationChannel(context: Context) {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val channel = NotificationChannel(
                CHANNEL_ID,
                CHANNEL_NAME,
                NotificationManager.IMPORTANCE_LOW  // No hacer sonido
            ).apply {
                description = "Notificaciones de emergencia activa"
                setSound(null, null)               // Silencio
                enableVibration(false)
                setShowBadge(false)
            }
            val notificationManager = context.getSystemService(NotificationManager::class.java)
            notificationManager.createNotificationChannel(channel)
        }
    }

    fun buildEmergencyNotification(
        context: Context,
        tipo: TipoEmergencia,
        tiempoTranscurrido: String
    ): Notification {
        val cancelIntent = PendingIntent.getService(
            context,
            0,
            Intent(context, EmergencyForegroundService::class.java).apply {
                action = EmergencyForegroundService.ACTION_CANCEL
            },
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )

        return NotificationCompat.Builder(context, CHANNEL_ID)
            .setContentTitle("🚨 Emergencia activa - ${tipo.displayName}")
            .setContentText("Tiempo transcurrido: $tiempoTranscurrido")
            .setSmallIcon(R.drawable.ic_emergency)
            .setOngoing(true)                          // No descartable
            .setPriority(NotificationCompat.PRIORITY_LOW)
            .addAction(R.drawable.ic_cancel, "Cancelar emergencia", cancelIntent)
            .build()
    }
}
```

### 11.2 Foreground Service

```kotlin
@AndroidEntryPoint
class EmergencyForegroundService : Service() {

    companion object {
        const val ACTION_START = "com.localizador.emergencia.action.START"
        const val ACTION_CANCEL = "com.localizador.emergencia.action.CANCEL"
        const val ACTION_UPDATE = "com.localizador.emergencia.action.UPDATE"
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        when (intent?.action) {
            ACTION_START -> {
                val tipo = intent.getSerializableExtra("tipo") as TipoEmergencia
                startForeground(NOTIFICATION_ID, buildNotification(tipo))
                iniciarCicloEnvio()
            }
            ACTION_CANCEL -> {
                detenerEmergencia()
            }
            ACTION_UPDATE -> {
                actualizarNotificacion()
            }
        }
        return START_STICKY
    }
}
```

### 11.3 Compatibilidad

| API Level | Comportamiento |
|-----------|---------------|
| API 23-25 | Notificación normal. Sin canales. |
| API 26+ | Usar NotificationChannel (requerido). |
| API 33+ | Solicitar permiso POST_NOTIFICATIONS. |
| API 34+ | Foreground Service con tipo `location`. |

---

## 12. Consideraciones de Seguridad

### 12.1 Token de Telegram

- **No almacenar en texto plano en el código fuente.**
- Usar `buildConfigField` en `build.gradle.kts`:
  ```kotlin
  // build.gradle.kts (app)
  buildTypes {
      debug {
          buildConfigField("String", "TELEGRAM_BOT_TOKEN", "\"${System.getenv("TELEGRAM_BOT_TOKEN_DEBUG")}\"")
      }
      release {
          buildConfigField("String", "TELEGRAM_BOT_TOKEN", "\"${System.getenv("TELEGRAM_BOT_TOKEN_RELEASE")}\"")
      }
  }
  ```
- **No committear el token real** en el repositorio. Usar variables de entorno o un archivo `secrets.properties` en `.gitignore`.
- Opcionalmente, ofuscar el token con NDK (C/C++) para mayor seguridad.

### 12.2 Datos del Usuario

- **No compartir datos con terceros.** La app no debe enviar contactos, coordenadas ni configuración a ningún servidor no autorizado.
- **(Eliminado)** El respaldo en la nube ya no forma parte del proyecto. Todo el almacenamiento es exclusivamente local.

### 12.4 Sanitización de Mensajes

- **URLs:** Asegurarse de que las URLs de Google Maps estén correctamente formateadas usando `URLEncoder.encode()`.
- **Inyección de caracteres:** Sanitizar el nombre del contacto y el mensaje antes de insertarlo en URLs o enviarlo a APIs. Aunque el riesgo es bajo (los datos provienen de la agenda del usuario), se debe codificar correctamente para evitar URLs malformadas.
- **HTML en Telegram:** Si se usa `parse_mode=HTML`, escapar los caracteres `<`, `>`, `&` en los mensajes para evitar inyección HTML.

### 12.5 Otras Consideraciones

| Aspecto | Medida |
|---------|--------|
| Permisos | Solicitar solo los necesarios, en contexto |
| ProGuard | Ofuscar el código en release para dificultar ingeniería inversa |
| Logs | No loguear tokens, chat_ids ni coordenadas en producción |
| Android Backup | No incluir el token de Telegram en el backup automático de Android |

---

## Apéndice A: Dependencias Principales (build.gradle.kts)

```kotlin
dependencies {
    // Core
    implementation("androidx.core:core-ktx:1.13.1")
    implementation("androidx.lifecycle:lifecycle-runtime-ktx:2.8.6")
    implementation("androidx.activity:activity-compose:1.9.3")

    // Compose
    implementation(platform("androidx.compose:compose-bom:2024.09.00"))
    implementation("androidx.compose.ui:ui")
    implementation("androidx.compose.material3:material3")
    implementation("androidx.compose.ui:ui-tooling-preview")
    implementation("androidx.navigation:navigation-compose:2.8.2")

    // Hilt
    implementation("com.google.dagger:hilt-android:2.52")
    kapt("com.google.dagger:hilt-compiler:2.52")
    implementation("androidx.hilt:hilt-navigation-compose:1.2.0")

    // Google Play Services - Location
    implementation("com.google.android.gms:play-services-location:21.3.0")

    // DataStore
    implementation("androidx.datastore:datastore-preferences:1.1.1")

    // Networking (Telegram API)
    implementation("com.squareup.retrofit2:retrofit:2.11.0")
    implementation("com.squareup.retrofit2:converter-gson:2.11.0")
    implementation("com.squareup.okhttp3:okhttp:4.12.0")
    implementation("com.squareup.okhttp3:logging-interceptor:4.12.0")
    implementation("com.google.code.gson:gson:2.11.0")

    // (Eliminado) Firebase ya no se usa — todo el almacenamiento es local

    // Coroutines
    implementation("org.jetbrains.kotlinx:kotlinx-coroutines-android:1.8.1")
}
```

---

## Apéndice B: Configuración de AndroidManifest.xml

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

    <application
        android:name=".LocalizadorApp"
        android:allowBackup="true"
        android:dataExtractionRules="@xml/data_extraction_rules"
        android:fullBackupContent="@xml/backup_rules"
        android:icon="@mipmap/ic_launcher"
        android:label="@string/app_name"
        android:roundIcon="@mipmap/ic_launcher_round"
        android:supportsRtl="true"
        android:theme="@style/Theme.LocalizadorMovilEmergencia">

        <activity
            android:name=".MainActivity"
            android:exported="true"
            android:theme="@style/Theme.LocalizadorMovilEmergencia">
            <intent-filter>
                <action android:name="android.intent.action.MAIN" />
                <category android:name="android.intent.category.LAUNCHER" />
            </intent-filter>
        </activity>

        <service
            android:name=".presentation.service.EmergencyForegroundService"
            android:foregroundServiceType="location"
            android:exported="false" />

    </application>
</manifest>
```

---

## Apéndice C: Diagrama de Estados de Emergencia

```
                         ┌──────────────┐
              ┌──────────│  INACTIVA    │◄──────────┐
              │          └──────┬───────┘           │
              │                 │                    │
              │     [Usuario presiona botón]        │
              │                 │                    │
              │                 ▼                    │
              │          ┌──────────────┐           │
              │          │ CONFIRMANDO  │           │
              │          │  (Diálogo)   │           │
              │          └──────┬───────┘           │
              │                 │                    │
              │          [Confirma]                  │
              │                 │                    │
              │                 ▼                    │
              │          ┌──────────────┐           │
              │          │  ACTIVANDO   │           │
              │          │ (Foreground  │           │
              │          │  Service)    │           │
              │          └──────┬───────┘           │
              │                 │                    │
              │                 ▼                    │
              │          ┌──────────────┐           │
              │  ┌───────│   ACTIVA    │────────────┘
              │  │       │ (Envío cícl.)│  [Cancela]
              │  │       └──────────────┘
              │  │              │
              │  │      [Error GPS]
              │  │              │
              │  │              ▼
              │  │       ┌──────────────┐
              │  │       │  ACTIVA_SIN  │
              │  │       │  GPS         │
              │  │       │ (reintenta)  │
              │  │       └──────────────┘
              │  │              │
              │  │      [GPS recuperado]
              │  │              │
              │  └──────────────┘
              │
              └──────────────────── [Cancela]
```

---

*Fin del documento ARCH-001-arquitectura.md*
