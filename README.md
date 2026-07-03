# Localizador Móvil de Emergencia

Aplicación Flutter para Android que funciona como **app de SMS completa** con un **botón de emergencia** que envía la ubicación GPS automáticamente a contactos de emergencia.

> 🚧 **Proyecto en desarrollo por fases** — Actualmente en Fase 1 (SMS Mínima)

---

## Fases del Proyecto

### Fase 1: SMS Mínima 🎯 (Actual)
**Objetivo**: Convertir la app en una app de SMS funcional para que Android la reconozca como candidata a app SMS predeterminada y el botón de emergencia pueda enviar SMS automáticamente.

#### Funcionalidades a implementar
| Módulo | Descripción | Estado |
|--------|-------------|--------|
| **Base de datos SMS** | Tablas `conversations` y `sms_messages` en Drift | ❌ Pendiente |
| **Bandeja de entrada** | Lista de conversaciones ordenadas por fecha | ❌ Pendiente |
| **Visor de conversación** | Mensajes de un contacto en formato burbuja | ❌ Pendiente |
| **Enviar SMS** | Campo de texto + botón enviar dentro de la app | ❌ Pendiente |
| **Recibir SMS** | BroadcastReceiver actualiza la bandeja en tiempo real | ❌ Pendiente |
| **Marcar como leído** | Al abrir una conversación, marcar SMS como leídos | ❌ Pendiente |
| **Sincronizar SMS del sistema** | Leer SMS existentes del proveedor de contenido de Android | ❌ Pendiente |
| **Permisos** | Solicitar READ_SMS, WRITE_SMS, RECEIVE_SMS y SEND_SMS | ✅ Listo |
| **App SMS default** | La app aparece en la lista del sistema y puede seleccionarse | ❌ Pendiente |
| **Botón de emergencia** | Envío automático sin abrir otra app | ❌ Pendiente (depende de lo anterior) |

#### Lo que ya funciona (sin cambios)
- ✅ Sonido de alarma (cada 5 segundos durante 3 minutos)
- ✅ Contador de tiempo en banner rojo
- ✅ Notificación con botones RE-ENVIAR SMS y CANCELAR
- ✅ Foreground service para segundo plano
- ✅ Configuración de contactos de emergencia
- ✅ Envíos periódicos cada N minutos
- ✅ GPS optimizado para batería (LocationAccuracy.low)

#### Nuevos archivos previstos
```
lib/
├── data/
│   ├── datasources/
│   │   └── local/
│   │       ├── app_database.dart          (modificar: agregar tablas SMS)
│   │       ├── sms_dao.dart               (nuevo: acceso a SMS)
│   │       └── conversation_dao.dart       (nuevo: acceso a conversaciones)
│   └── repositories/
│       └── sms_inbox_repository_impl.dart  (nuevo: sincronizar con sistema)
├── domain/
│   ├── entities/
│   │   ├── sms_message.dart               (nuevo)
│   │   └── conversation.dart              (nuevo)
│   └── repositories/
│       └── sms_inbox_repository.dart       (nuevo: interfaz)
├── presentation/
│   ├── providers/
│   │   └── sms_provider.dart              (nuevo: state de bandeja)
│   └── screens/
│       ├── inbox_screen.dart              (nuevo: lista de conversaciones)
│       ├── conversation_screen.dart       (nuevo: burbujas de chat)
│       └── compose_screen.dart            (nuevo: nuevo SMS)
```

---

### Fase 2: SMS Completa 🚀 (Futuro)
**Objetivo**: Convertir la app en una app de SMS con todas las funcionalidades modernas.

| Funcionalidad | Descripción |
|---------------|-------------|
| **Editor de texto enriquecido** | Emojis, formato de texto |
| **Búsqueda** | Buscar en conversaciones y mensajes |
| **Archivar / Eliminar** | Gestión de conversaciones |
| **Modo oscuro** | Tema oscuro completo |
| **Material Design 3** | UI moderna con Material You |
| **MMS** | Enviar y recibir fotos, audio, video |
| **Respuesta rápida** | Responder desde la notificación |
| **Mensajes programados** | Programar envío de SMS |
| **Copia de seguridad** | Exportar/importar SMS |
| **Bloqueo de spam** | Bloquear números |
| **Widget** | Acceso rápido desde el escritorio |

---

## Funcionalidades actuales (ya implementadas)

- **Botón de emergencia**: 3 tipos (Extraviado, Atrapado, Herido)
- **Envío de SMS**: Abre la app de SMS con el mensaje pre-llenado (hasta que se complete Fase 1)
- **Envíos periódicos**: Re-envía la ubicación cada N minutos (configurable)
- **Contador de tiempo**: Muestra el tiempo transcurrido desde que se activó la emergencia
- **Notificación permanente**: Con botones "RE-ENVIAR SMS" y "CANCELAR"
- **Sonido de alarma**: Pitido cada 5 segundos a máximo volumen durante 3 minutos
- **Segundo plano**: Foreground service mantiene la app activa
- **Configuración**: Agregar contactos, configurar intervalo de envío
- **GPS optimizado**: LocationAccuracy.low para ahorrar batería

## Requisitos

- Android 8.0+ (API 26+)
- Permisos: Ubicación, SMS, Contactos, Notificaciones
- **A partir de Fase 1**: La app debe ser la app de SMS predeterminada para envío automático

## Instalación

```bash
flutter pub get
flutter pub run build_runner build --delete-conflicting-outputs
flutter run
```

## Arquitectura

```
lib/
├── app/                    # Configuración de DI (GetIt)
│   └── di/
├── core/                   # Utilidades, tema, constantes
├── data/                   # Capa de datos
│   ├── datasources/
│   │   ├── local/          # Drift, SharedPreferences, SecureStorage
│   │   └── remote/         # API remota (Telegram, futura pasarela SMS)
│   ├── mappers/            # Mapeo entre modelos y entidades
│   ├── models/             # Modelos de datos (JSON)
│   └── repositories/       # Implementación de repositorios
├── domain/                 # Capa de dominio
│   ├── entities/           # Entidades de negocio
│   ├── repositories/       # Interfaces de repositorios
│   └── usecases/           # Casos de uso
└── presentation/           # Capa de presentación
    ├── providers/          # State management (Provider)
    ├── screens/            # Pantallas
    ├── services/           # Servicios (notificaciones, sonido, background)
    └── widgets/            # Widgets reutilizables
```

## Notas técnicas

- **SMS en Android 14+**: Google restringió el envío automático de SMS para apps que no son la predeterminada. Al completar la Fase 1, la app será una app de SMS completa y podrá ser seleccionada como predeterminada.
- **Fase 1**: No requiere nuevas dependencias externas. Todo se hace con `drift` (ya incluido) y el proveedor de contenido de SMS de Android.
- **Arquitectura**: Clean Architecture con Provider para state management y GetIt para inyección de dependencias.
- **Base de datos**: Drift (SQLite) para almacenamiento local de SMS y configuraciones.
