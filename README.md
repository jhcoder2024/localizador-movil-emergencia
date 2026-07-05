# Localizador Móvil de Emergencia

**Versión:** 1.1.0

Aplicación Flutter para Android que funciona como **app de SMS completa** con un **botón de emergencia** que envía la ubicación GPS automáticamente a contactos de emergencia.

## Funcionalidades

### App de SMS Completa
- 📥 **Bandeja de entrada** con lista de conversaciones, preview, hora y badge de no leídos
- 💬 **Chat** con burbujas de mensajes (recibidos gris/izquierda, enviados rojo/derecha)
- ✏️ **Enviar SMS** directamente desde la app
- 📡 **Sincronización** automática con los SMS del sistema
- 🔄 **Pull-to-refresh** para sincronizar nuevos mensajes
- 🔍 **Búsqueda** de mensajes con debounce de 300ms
- 📦 **Archivar** y desarchivar conversaciones
- 🗑️ **Eliminar** conversaciones con confirmación
- 😀 **Selector de emojis** en el editor de mensajes
- 📷 **MMS** con imágenes (lectura y envío)
- 🚫 **Bloqueo de spam** para números no deseados
- 📤 **Exportar** SMS a archivo JSON
- 📥 **Importar** SMS desde archivo JSON
- 🌗 **Modo oscuro** con 3 estados: Claro / Oscuro / Seguir sistema
- 🎨 **Material Design 3** con colores dinámicos
- 📱 **Widget de emergencia** en la pantalla de inicio

### Botón de Emergencia
- 🚨 **3 tipos**: Extraviado, Atrapado, Herido
- 📍 **Envío automático** de ubicación GPS vía SMS
- 🔁 **Re-envío periódico** cada N minutos (mínimo 5 min)
- 🔊 **Sonido de alarma** cada 5 segundos (duración = mitad del intervalo)
- 🔔 **Notificación permanente** con botón CANCELAR
- 📱 **Foreground service** para funcionar en segundo plano
- ⚡ **GPS optimizado** (LocationAccuracy.low) para ahorrar batería

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
