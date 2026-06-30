# Guía de Despliegue — Localizador Móvil de Emergencia

| Campo | Valor |
|-------|-------|
| **ID** | DEPLOY-001 |
| **Versión** | 2.0 |
| **Fecha** | 26/06/2026 |
| **App ID (Android)** | `com.localizador.emergencia` |
| **Bundle ID (iOS)** | `com.localizador.emergencia` |

---

## Índice

1. [Prerrequisitos](#1-prerrequisitos)
2. [Generar APK Firmado](#2-generar-apk-firmado)
3. [Generar AAB para Google Play](#3-generar-aab-para-google-play)
4. [Compilar para iOS](#4-compilar-para-ios)
5. [Configurar Telegram Bot](#5-configurar-telegram-bot)
6. [Publicar en Google Play](#6-publicar-en-google-play)
7. [Publicar en App Store](#7-publicar-en-app-store)
8. [Lista de Verificación Pre-Lanzamiento](#8-lista-de-verificación-pre-lanzamiento)

---

## 1. Prerrequisitos

| Herramienta | Versión mínima | Descarga |
|-------------|----------------|----------|
| Flutter SDK | 3.2+ | [flutter.dev](https://flutter.dev/) |
| Dart | 3.2+ | Incluido con Flutter |
| Android Studio | Hedgehog (2023.1.1) | [developer.android.com/studio](https://developer.android.com/studio) |
| Xcode | 15+ | App Store (solo macOS, para iOS) |
| Git | Cualquiera | [git-scm.com](https://git-scm.com/) |

### Verificar instalación

```bash
flutter --version
# Flutter 3.2+
# Dart 3.2+

flutter doctor
# Verifica todos los componentes necesarios

dart --version
# Dart SDK 3.2+
```

---

## 2. Generar APK Firmado

### 2.1 Desde Android Studio

1. **Build > Flutter > Build APK**
2. Para firma manual, configura el keystore en `android/app/build.gradle.kts`.

### 2.2 Desde Línea de Comandos

1. Crear archivo `android/key.properties` en la raíz del proyecto (NO committear):

```properties
storePassword=tu_contraseña
keyPassword=tu_contraseña
keyAlias=localizador-release
storeFile=D:/keystores/localizador.jks
```

2. Agregar la configuración en `android/app/build.gradle.kts`:

```kotlin
val keystoreProperties = Properties()
val keystorePropertiesFile = rootProject.file("key.properties")
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(keystorePropertiesFile.inputStream())
}

android {
    signingConfigs {
        create("release") {
            keyAlias = keystoreProperties["keyAlias"] as String
            keyPassword = keystoreProperties["keyPassword"] as String
            storeFile = keystoreProperties["storeFile"]?.let { file(it) }
            storePassword = keystoreProperties["storePassword"] as String
        }
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("release")
            isMinifyEnabled = true
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
        }
    }
}
```

3. Compilar:

```bash
# Asegúrate de tener assets/.env configurado con TELEGRAM_BOT_TOKEN
flutter build apk --release
```

APK firmado en: `build/app/outputs/flutter-apk/app-release.apk`

---

## 3. Generar AAB para Google Play

```bash
flutter build appbundle --release
```

AAB generado en: `build/app/outputs/bundle/release/app-release.aab`

Google Play recomienda AAB sobre APK.

---

## 4. Compilar para iOS

Solo disponible en **macOS** con Xcode instalado.

### 4.1 Configuración previa

```bash
# Instalar dependencias de CocoaPods (si aplica)
cd ios && pod install && cd ..

# Verificar certificados y perfiles en Xcode
open ios/Runner.xcworkspace
```

### 4.2 Compilar

```bash
flutter build ios --release
```

Esto genera un build de Xcode en `build/ios/`. Para obtener un IPA:

1. Abre `ios/Runner.xcworkspace` en Xcode.
2. Selecciona **Product > Archive**.
3. En el Organizer, selecciona **Distribute App**.
4. Elige método de distribución (App Store Connect, Ad Hoc, etc.).
5. Sigue los pasos de firmado y exporta el IPA.

---

## 5. Configurar Telegram Bot

### 5.1 Crear el Bot

1. Abre Telegram y busca **@BotFather**.
2. Envía `/newbot`.
3. Sigue las instrucciones:
   - **Nombre:** `Localizador Emergencia` (visible para los usuarios).
   - **Username:** `localizador_emergencia_bot` (debe terminar en `bot`).
4. @BotFather responderá con un mensaje similar a:

```
Done! Congratulations on your new bot. You will find it at t.me/localizador_emergencia_bot.
Use this token to access the HTTP API:
123456789:ABCdefGHIjklMNOpqrsTUVwxyz
```

### 5.2 Configurar el Token en Flutter

Edita `assets/.env` (NO committear):

```env
TELEGRAM_BOT_TOKEN=123456789:ABCdefGHIjklMNOpqrsTUVwxyz

```

### 5.3 Compilar Release

```bash
# Con assets/.env configurado
flutter build apk --release
# o
flutter build appbundle --release
```

---

## 6. Publicar en Google Play

### 6.1 Crear Cuenta de Desarrollador

1. Ve a [play.google.com/console](https://play.google.com/console).
2. Regístrate como desarrollador (pago único de $25 USD).
3. Acepta los términos del programa.

### 6.2 Preparar el Listing

| Elemento | Requisito |
|----------|-----------|
| **Título** | Localizador Móvil de Emergencia |
| **Descripción corta** (80 caracteres) | Envía tu ubicación a tus contactos en emergencias |
| **Descripción larga** | Explica funcionalidad, requisitos, canales |
| **Capturas de pantalla** | 2-8 capturas (Android e iOS si aplica) |
| **Icono** | 512x512px, PNG de 32 bits |
| **Gráfico destacado** | 1024x500px |
| **Categoría** | Tools / Comunicación |
| **Clasificación** | PEGI 3 / ESRB Everyone |
| **Política de privacidad** | No aplica (solo almacenamiento local) |

### 6.3 Subir el AAB

1. En Play Console: **Producción > Crear nueva versión**.
2. Sube el **Android App Bundle** (`.aab`) desde `build/app/outputs/bundle/release/`.
3. Completa los detalles de la versión (notas de la versión).
4. Revisa y despliega.

### 6.4 Revisar Políticas de Google Play

La app usa permisos sensibles que requieren revisión:

| Permiso | Política aplicable |
|---------|--------------------|
| `SEND_SMS` | [Permisos SMS/Call Log](https://support.google.com/googleplay/android-developer/answer/9047303) |
| `ACCESS_BACKGROUND_LOCATION` | [Permisos de ubicación](https://support.google.com/googleplay/android-developer/answer/9799150) |
| `READ_CONTACTS` | Permisos de contactos |

**Requisitos para aprobación:**

- ✅ La funcionalidad principal de la app depende de estos permisos.
- ✅ Se solicita justo a tiempo, no al inicio sin contexto.
- ✅ Se provee un video demostrando el uso del permiso (opcional).
- ✅ El usuario puede usar la app con funcionalidad reducida si deniega.

---

## 7. Publicar en App Store

### 7.1 Crear Cuenta de Desarrollador Apple

1. Ve a [developer.apple.com](https://developer.apple.com).
2. Regístrate como desarrollador ($99 USD/año).
3. Crea un **App ID** en Certificates, Identifiers & Profiles.

### 7.2 Preparar en App Store Connect

1. Ve a [appstoreconnect.apple.com](https://appstoreconnect.apple.com).
2. Crea una nueva app con el Bundle ID `com.localizador.emergencia`.
3. Completa la información de la app (nombre, descripción, capturas, etc.).

### 7.3 Subir el IPA

1. En Xcode: **Product > Archive**.
2. En el Organizer, selecciona **Distribute App > App Store Connect**.
3. Sigue los pasos para firmar y subir.

### 7.4 Revisión de Apple

- La app será revisada por Apple (24-48 horas hábiles).
- Permisos de ubicación en segundo plano requieren justificación.
- iOS no permite envío automático de SMS; se usa `sms:` URI que abre la app de Mensajes.

---

## 8. Lista de Verificación Pre-Lanzamiento

Marca cada elemento antes de publicar:

### Técnico

- [ ] `assets/.env` configurado con token de Telegram
- [ ] `flutter build apk --release` compila sin errores
- [ ] `flutter build appbundle --release` compila sin errores
- [ ] `flutter build ios --release` compila sin errores (si aplica)
- [ ] `flutter test` pasa sin errores
- [ ] `flutter analyze` sin warnings nuevos
- [ ] Minificación/obfuscación habilitada en release (`--obfuscate`)
- [ ] APK/AAB firmado con keystore de release (no debug)
- [ ] Versión de `versionCode`/`versionName` incrementada en `pubspec.yaml`

### Seguridad y Privacidad

- [ ] `.env` no está en el repositorio (`.gitignore`)
- [ ] Logs de depuración deshabilitados en release
- [ ] No hay tokens hardcodeados en el código
- [ ] Keystore y contraseñas no están en el repositorio
- [ ] Política de privacidad disponible y enlazada

### Usabilidad

- [ ] Permisos solicitados en cadena y con justificación
- [ ] Traducciones completas en español e inglés (`l10n/`)
- [ ] Strings de permisos explicativos visibles en UI
- [ ] Diálogo de advertencia de costos SMS visible
- [ ] Notificación persistente funciona en Android 13+ (API 33)
- [ ] Foreground Service funciona en Android 14+ (API 34+)

### Google Play / App Store

- [ ] Capturas de pantalla actualizadas
- [ ] Descripción larga completa y en ambos idiomas
- [ ] Clasificación de contenido asignada
- [ ] Declaración de permisos enviada (SMS, ubicación en segundo plano)
- [ ] Video de demostración preparado (si aplica)
- [ ] Precios y distribución configurados

### Documentación

- [ ] Manual de usuario actualizado
- [ ] Changelog actualizado con los cambios de la versión
- [ ] Versión incrementada en `pubspec.yaml`

---

> **¿Problemas?** Consulta la [Guía del Desarrollador](../developer-guide/DEV-GUIDE-001-guia-desarrollador.md) o abre un issue en el repositorio.
