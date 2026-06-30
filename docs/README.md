# Localizador Móvil de Emergencia

Aplicación móvil multiplataforma (Android e iOS) que permite notificar de forma rápida y periódica tu ubicación GPS a un grupo de hasta 10 contactos de confianza durante una emergencia, utilizando múltiples canales de comunicación (SMS, WhatsApp y Telegram).

> La aplicación funciona 100% sin conexión a internet. Solo requiere internet para el envío de WhatsApp y Telegram.

## Stack Tecnológico

| Componente | Tecnología |
|------------|------------|
| Framework | Flutter 3.2+ |
| Lenguaje | Dart 3.2+ |
| UI | Material Design 3 (M3) |
| Arquitectura | MVVM + Clean Architecture (3 capas) |
| Inyección de dependencias | GetIt + Injectable |
| Almacenamiento local | Drift (SQLite) + SharedPreferences |
| Red | dio + http (Telegram Bot API) |
| GPS | geolocator |
| Backend | Solo local (Drift SQLite + SharedPreferences) |
| Pruebas | flutter_test + mockito |
| Localización | ARB (español / inglés) |

## Requisitos del Sistema

- **Android:** API 26 (Android 8.0) o superior
- **iOS:** iOS 14 o superior
- **Hardware requerido:** GPS, conectividad a internet (WhatsApp/Telegram), plan SMS activo
- **Idiomas:** Español, Inglés (detección automática)

## Documentación

| Documento | Descripción |
|-----------|-------------|
| [Manual de Usuario](user-guide/USER-GUIDE-001-manual-de-usuario.md) | Guía completa para usuarios finales |
| [Guía del Desarrollador](developer-guide/DEV-GUIDE-001-guia-desarrollador.md) | Arquitectura, configuración y contribución |
| [API de Telegram](api/API-001-telegram-bot.md) | Documentación técnica de la API de Telegram Bot |
| [Guía de Despliegue](deployment/DEPLOY-001-guia-despliegue.md) | Cómo compilar, firmar y publicar la app |
| [Arquitectura (Android Nativo - Histórico)](architecture/ARCH-001-arquitectura.md) | Documento de arquitectura anterior (Kotlin) |
| [Arquitectura Flutter](architecture/ARCH-002-arquitectura-flutter.md) | Documento actual de arquitectura Flutter |
| [Especificación de Requisitos](requirements/REQ-001-especificacion-general.md) | Requisitos funcionales y no funcionales |
| [Decisión de Stack Tecnológico](decisions/ADR-001-stack-tecnologico.md) | ADR con la decisión de migrar a Flutter |

## Enlaces Rápidos

- **Código fuente:** `lib/`
- **Build Android:** `flutter build apk --release`
- **Build iOS:** `flutter build ios --release`
- **Build AAB (Google Play):** `flutter build appbundle --release`
- **Tests:** `flutter test`
- **Generar código:** `dart run build_runner build`
