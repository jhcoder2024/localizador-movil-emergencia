# Localizador Móvil de Emergencia

Aplicación Flutter para Android que envía la ubicación GPS a contactos de emergencia vía SMS.

## Funcionalidades

- **Botón de emergencia**: 3 tipos (Extraviado, Atrapado, Herido)
- **Envío de SMS**: Abre la app de SMS con el mensaje pre-llenado (el usuario solo toca "Enviar")
- **Envíos periódicos**: Re-envía la ubicación cada N minutos (configurable)
- **Contador de tiempo**: Muestra el tiempo transcurrido desde que se activó la emergencia
- **Notificación permanente**: Notificación en la barra de estado mientras la emergencia está activa
- **Sonido de alarma**: Suena una alerta al activar la emergencia
- **Configuración**: Agregar contactos, configurar intervalo de envío

## Requisitos

- Android 8.0+ (API 26+)
- Permisos: Ubicación, SMS, Contactos, Notificaciones
- **Android 14+**: Para envío automático de SMS sin intervención, la app debe establecerse como app de SMS predeterminada en Ajustes del sistema

## Instalación

```bash
flutter pub get
flutter pub run build_runner build --delete-conflicting-outputs
flutter run
```

## Estructura del proyecto

```
lib/
├── app/                    # Configuración de DI (GetIt)
│   └── di/
├── core/                   # Utilidades, tema, constantes
├── data/                   # Capa de datos
│   ├── datasources/        # Fuentes de datos (local, remoto)
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

- **SMS en Android 14+**: Google restringió el envío automático de SMS para apps que no son la predeterminada. La app abre la app de SMS nativa con el mensaje pre-llenado. Para envío completamente automático, establecer la app como predeterminada en Ajustes > Apps > App de SMS.
- **Background service**: Pendiente de configuración completa para MIUI (Xiaomi/Redmi). Requiere permisos especiales del fabricante.
- **Arquitectura**: Clean Architecture con Provider para state management y GetIt para inyección de dependencias.
