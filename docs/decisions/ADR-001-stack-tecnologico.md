# ADR-001: Decisión de Stack Tecnológico

**Estado:** Aprobado
**Fecha:** 26 de junio de 2026
**Autor:** Product Owner

---

## Contexto

El proyecto "Localizador Móvil de Emergencia" requiere una aplicación móvil que permita a los usuarios enviar alertas de emergencia con su ubicación GPS a contactos de confianza y/o a un bot de Telegram. Se necesita definir el stack tecnológico final que guiará todo el desarrollo del proyecto.

La decisión inicial contemplaba Android nativo con Kotlin, pero durante el proceso de refinamiento el cliente manifestó la necesidad de que la aplicación sea **multiplataforma (Android e iOS)**.

---

## Opciones consideradas y Decisión final

| Componente | Opciones consideradas | Decisión final | Justificación |
|---|---|---|---|
| **Framework** | Flutter, Kotlin Multiplatform (KMP), Android Nativo | **Flutter** | El cliente solicitó explícitamente una solución multiplataforma. Flutter permite un único código base para Android e iOS con excelente rendimiento, amplio ecosistema de paquetes y madurez comprobada en producción. |
| **Lenguaje** | Dart, Kotlin, Java | **Dart** | Lenguaje nativo de Flutter, optimizado para construcción de UIs reactivas, con tipado fuerte y compilación nativa. |
| **UI / Diseño** | Material Design 3, Cupertino, Híbrido | **Material Design 3** | El cliente eligió Material 3 por su aspecto moderno, adaptativo y soporte multiplataforma en Flutter. |
| **Arquitectura** | MVVM + Clean Architecture, BLoC, Riverpod, GetX | **MVVM + Clean Architecture** | El cliente prefirió MVVM + Clean Architecture por su escalabilidad, separación clara de capas (data/domain/presentation) y testabilidad. Es el estándar en proyectos Flutter profesionales. |
| **Inyección de dependencias** | GetIt + Injectable, Riverpod, Provider, BlocProvider | **GetIt + Injectable** | El cliente eligió GetIt + Injectable, la combinación más estándar en Flutter. GetIt actúa como Service Locator e Injectable genera el código de registro automáticamente, similar a Hilt en Android. |
| **Almacenamiento local** | Hive + SharedPreferences, Drift + SharedPreferences, Isar | **Drift + SharedPreferences** | El cliente eligió Drift (ORM SQLite) para datos estructurados y SharedPreferences para configuraciones simples. Drift ofrece consultas complejas, relaciones y tipado seguro, similar a Room en Android. |
| **Backend en la nube** | Firebase, Supabase, Backend propio, Sin nube | **No aplica (solo almacenamiento local)** | La app funciona 100% sin conexión a internet. Todo el almacenamiento es local: Drift (SQLite) + SharedPreferences + FlutterSecureStorage. No se requiere backend en la nube. |
| **Cliente HTTP (Telegram API)** | dart http + dio, Solo dio, Solo http | **dart http + dio** | El cliente eligió la combinación de ambos: `http` para peticiones simples y `dio` para las complejas (interceptors, timeouts, reintentos). Similar a Retrofit + OkHttp en Android. |
| **GPS / Localización** | geolocator, location, google_maps_flutter | **geolocator + google_maps_flutter** (por confirmar en refinamiento) | Flutter tiene paquetes maduros como `geolocator` para obtener ubicación y `google_maps_flutter` para mapas. Se refinará en HU específicas. |
| **Versión mínima Android** | API 23 (Android 6.0), API 26 (Android 8.0), API 29 (Android 10) | **API 26 (Android 8.0)** | El cliente eligió API 26 como mínimo. Cubre ~92% de dispositivos activos y permite usar APIs modernas sin tantos polyfills. En iOS se usará iOS 14 como mínimo. |
| **Versión target** | API 35 (Android 15) | **API 35 (Android 15)** | Se mantiene la versión target más reciente para acceder a las últimas APIs y optimizaciones. |
| **Pruebas** | flutter_test + mockito, flutter_test + mocktail, riverpod testing | **flutter_test + mockito** | El cliente eligió el stack oficial de Flutter: `flutter_test` para tests unitarios/de widget y `mockito` para mocking. Es el estándar de la comunidad con mayor soporte y documentación. |
| **Compilación** | Gradle (Android), Xcode (iOS) | **Flutter build (nativo)** | Flutter compila a código nativo usando Gradle para Android y Xcode para iOS, gestionado a través de `flutter build`. |

---

## Consecuencias

### Positivas
- **Una sola base de código** para Android e iOS, reduciendo costos de desarrollo y mantenimiento a la mitad.
- **Flutter + Dart** ofrece hot reload para desarrollo rápido y compilación nativa para alto rendimiento.
- **Material Design 3** garantiza una experiencia de usuario moderna y consistente en ambas plataformas.
- **MVVM + Clean Architecture** asegura que el código sea mantenible, testeable y escalable a futuro.
- **Sin backend en la nube** simplifica la arquitectura, elimina costos de servidor y garantiza privacidad total de los datos del usuario.
- **Drift** proporciona una base de datos local robusta con consultas SQL tipadas.
- **API 26** como mínimo permite usar APIs modernas (como `NotificationChannel`, `JobScheduler`, etc.) sin código legacy.

### Negativas / Riesgos
- **Flutter** tiene un peso de APK/IPA mayor que una app nativa pura (~15-20 MB adicionales).
- (Eliminado) No aplica riesgo de dependencia de nube.
- **Drift** requiere generación de código (build_runner), lo que añade un paso extra en la compilación.
- **GetIt** es un Service Locator, no un contenedor de inyección de dependencias real. Puede dificultar el testing si no se usa correctamente.
- **API 26** deja fuera ~8% de dispositivos Android (principalmente equipos muy antiguos en mercados emergentes).

### Neutrales
- El equipo de desarrollo deberá tener experiencia en Flutter/Dart. Si viene de Android nativo (Kotlin), requerirá una curva de aprendizaje.
- Las integraciones nativas (GPS, notificaciones, sensores) se harán a través de paquetes Flutter o mediante platform channels si es necesario.

---

## Requerimientos padre

Esta decisión técnica impacta a todos los requerimientos del proyecto. Los componentes específicos se detallarán en las Historias de Usuario correspondientes.

| ID | Descripción |
|---|---|
| REQ-001 | Aplicación móvil multiplataforma Android/iOS |
| REQ-002 | Envío de alertas de emergencia con ubicación GPS |
| REQ-003 | Comunicación con Telegram Bot API |
| REQ-004 | Almacenamiento local de configuraciones e histórico |
| REQ-005 | (Eliminado) Ya no aplica — solo almacenamiento local |
| REQ-006 | Notificaciones push y en segundo plano |

---

## Historial de revisiones

| Versión | Fecha | Cambio |
|---|---|---|
| 1.0 | 26/06/2026 | Versión inicial. Decisión tomada tras refinamiento con el cliente. |
| 2.0 | 26/06/2026 | Actualización completa: migración de Android nativo (Kotlin) a Flutter multiplataforma. |
