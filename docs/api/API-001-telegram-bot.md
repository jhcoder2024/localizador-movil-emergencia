# 🤖 API de Telegram Bot — Localizador Móvil de Emergencia

| Campo | Valor |
|-------|-------|
| **ID** | API-001 |
| **Versión** | 1.0 |
| **Fecha** | 26/06/2026 |
| **Endpoint base** | `https://api.telegram.org/bot{token}/` |

---

## Índice

1. [Endpoint](#1-endpoint)
2. [Request](#2-request)
3. [Response](#3-response)
4. [Códigos de Error](#4-códigos-de-error)
5. [Rate Limiting](#5-rate-limiting)
6. [Seguridad](#6-seguridad)
7. [Implementación en la App](#7-implementación-en-la-app)

---

## 1. Endpoint

### Enviar Mensaje

```
POST https://api.telegram.org/bot{TOKEN}/sendMessage
```

### Headers

| Header | Valor |
|--------|-------|
| `Content-Type` | `application/json` |

### Parámetros de URL

| Parámetro | Tipo | Obligatorio | Descripción |
|-----------|------|-------------|-------------|
| `token` | String | Sí | Token del bot obtenido de @BotFather |

---

## 2. Request

### Cuerpo (JSON)

```json
{
    "chat_id": "123456789",
    "text": "¡Emergencia! Estoy extraviado, necesito ayuda. Mi ubicación: https://maps.google.com/?q=19.4326,-99.1332",
    "parse_mode": "HTML"
}
```

### Campos

| Campo | Tipo | Obligatorio | Descripción |
|-------|------|-------------|-------------|
| `chat_id` | String | Sí | ID único del chat del contacto |
| `text` | String | Sí | Mensaje a enviar (máx. 4096 caracteres) |
| `parse_mode` | String | No | Formato: `"HTML"` o `"MarkdownV2"`. Se usa `HTML` |

### Mensaje de ejemplo según tipo de emergencia

**Extraviado:**
```json
{
    "chat_id": "123456789",
    "text": "🚨 <b>¡EMERGENCIA!</b>\n\nEstoy <b>extraviado</b> y necesito ayuda.\n\n📍 <b>Mi ubicación:</b>\n<a href=\"https://maps.google.com/?q=19.4326,-99.1332\">Ver en Google Maps</a>\n\n📅 26/06/2026 14:30\n\nPor favor, ayuda a localizarme.",
    "parse_mode": "HTML"
}
```

**Atrapado:**
```json
{
    "chat_id": "123456789",
    "text": "🚨 <b>¡EMERGENCIA!</b>\n\nEstoy <b>atrapado</b> y necesito ayuda.\n\n📍 <b>Mi ubicación:</b>\n<a href=\"https://maps.google.com/?q=19.4326,-99.1332\">Ver en Google Maps</a>\n\n📅 26/06/2026 14:30\n\nPor favor, ayuda a localizarme.",
    "parse_mode": "HTML"
}
```

**Herido:**
```json
{
    "chat_id": "123456789",
    "text": "🚨 <b>¡EMERGENCIA!</b>\n\nEstoy <b>herido</b> y necesito <b>ayuda médica urgente</b>.\n\n📍 <b>Mi ubicación:</b>\n<a href=\"https://maps.google.com/?q=19.4326,-99.1332\">Ver en Google Maps</a>\n\n📅 26/06/2026 14:30\n\nPor favor, envíen auxilio médico inmediatamente.",
    "parse_mode": "HTML"
}
```

---

## 3. Response

### Éxito (HTTP 200)

```json
{
    "ok": true,
    "result": {
        "message_id": 1234,
        "from": {
            "id": 123456,
            "is_bot": true,
            "first_name": "MiBotEmergencia",
            "username": "mi_bot_emergencia_bot"
        },
        "chat": {
            "id": 123456789,
            "first_name": "Juan",
            "type": "private"
        },
        "date": 1719409800,
        "text": "🚨 ¡EMERGENCIA!..."
    }
}
```

### Error (HTTP 200 con `ok: false`)

Telegram siempre responde con HTTP 200 incluso en errores. El estado se indica en el campo `ok`:

```json
{
    "ok": false,
    "error_code": 400,
    "description": "Bad Request: chat not found"
}
```

---

## 4. Códigos de Error

| `error_code` | `description` | Causa | Acción en la app |
|--------------|---------------|-------|------------------|
| 400 | `Bad Request: chat not found` | El chat_id no existe o el contacto no inició conversación con el bot | Marcar contacto como "Telegram no disponible" |
| 400 | `Bad Request: can't parse entities` | Formato HTML inválido en el texto | Sanitizar el mensaje antes de enviar |
| 401 | `Unauthorized` | Token del bot inválido | Notificar al usuario "Token de Telegram inválido" |
| 403 | `Forbidden: bot was blocked by the user` | El contacto bloqueó al bot | Marcar contacto como "Telegram no disponible" |
| 403 | `Forbidden: user is deactivated` | La cuenta de Telegram del contacto fue eliminada | Marcar contacto como "Telegram no disponible" |
| 404 | `Not Found` | Token mal formado o endpoint incorrecto | Verificar la URL del endpoint |
| 420 | `Too Many Requests: retry after X` | Rate limit excedido | Reintentar con backoff exponencial |
| 429 | `Too Many Requests` | Demasiadas solicitudes | Reintentar después del tiempo indicado en `retry_after` |

### Manejo de errores en la app

```kotlin
// TelegramRepositoryImpl.kt - fragmento
when {
    response.code() == 401 -> Result.failure(TelegramError.TOKEN_INVALIDO)
    response.code() == 403 -> Result.failure(TelegramError.CONTACTO_BLOQUEO_BOT)
    response.code() == 429 -> {
        val retryAfter = response.headers()["retry-after"]?.toLongOrNull() ?: 10
        Result.failure(TelegramError.RATE_LIMIT(retryAfter))
    }
    else -> Result.failure(TelegramError.DESCONOCIDO)
}
```

---

## 5. Rate Limiting

### Límites de Telegram Bot API

| Límite | Valor |
|--------|-------|
| Mensajes por segundo por chat | ~30 |
| Mensajes por minuto por bot | ~1,200 |
| Caracteres por mensaje | 4,096 |
| Longitud total de la cola | 1,000 mensajes |

### Estrategia de Backoff

Ante un error 429, la app:

1. Lee el header `retry-after` (segundos sugeridos por Telegram).
2. Espera ese tiempo antes de reintentar.
3. Si vuelve a fallar, incrementa el tiempo de espera (backoff exponencial: 2x, 4x, 8x...).
4. Después de 3 intentos fallidos consecutivos, omite Telegram para ese ciclo y reintenta en el próximo envío.

---

## 6. Seguridad

### Token del Bot

- **No almacenar en texto plano** en el código fuente.
- El token se inyecta en `BuildConfig.TELEGRAM_BOT_TOKEN` mediante variables de entorno.
- **Nunca** committear el token real al repositorio.

```kotlin
// build.gradle.kts
buildTypes {
    debug {
        buildConfigField(
            "String",
            "TELEGRAM_BOT_TOKEN",
            "\"${System.getenv("TELEGRAM_BOT_TOKEN_DEBUG") ?: ""}\""
        )
    }
    release {
        buildConfigField(
            "String",
            "TELEGRAM_BOT_TOKEN",
            "\"${System.getenv("TELEGRAM_BOT_TOKEN_RELEASE") ?: ""}\""
        )
    }
}
```

### HTTPS Obligatorio

- Todas las solicitudes a `https://api.telegram.org` usan **HTTPS**.
- La app usa OkHttp con verificación de certificados TLS (por defecto).
- Configuración de Network Security Config en `res/xml/network_security_config.xml`:

```xml
<?xml version="1.0" encoding="utf-8"?>
<network-security-config>
    <domain-config cleartextTrafficPermitted="false">
        <domain includeSubdomains="true">api.telegram.org</domain>
    </domain-config>
</network-security-config>
```

### Datos sensibles

- Los `chat_id` se almacenan en DataStore encriptado (`SecurePrefs.kt`).
- No se loguean tokens ni chat_ids en la consola en builds release.
- Los backups automáticos de Android excluyen el token y chat_ids mediante reglas en `@xml/backup_rules`.

---

## 7. Implementación en la App

### Retrofit Interface

```kotlin
interface TelegramApiService {
    @POST("bot{token}/sendMessage")
    suspend fun sendMessage(
        @Path("token") token: String,
        @Body request: SendMessageRequest
    ): Response<SendMessageResponse>
}
```

### DTOs

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

### Configuración de Retrofit

```kotlin
// NetworkModule.kt
@Module
@InstallIn(SingletonComponent::class)
object NetworkModule {

    @Provides
    @Singleton
    fun provideOkHttpClient(): OkHttpClient {
        return OkHttpClient.Builder()
            .connectTimeout(10, TimeUnit.SECONDS)
            .readTimeout(10, TimeUnit.SECONDS)
            .addInterceptor(HttpLoggingInterceptor().apply {
                level = if (BuildConfig.DEBUG)
                    HttpLoggingInterceptor.Level.BODY
                else
                    HttpLoggingInterceptor.Level.NONE
            })
            .build()
    }

    @Provides
    @Singleton
    fun provideTelegramApiService(okHttpClient: OkHttpClient): TelegramApiService {
        return Retrofit.Builder()
            .baseUrl("https://api.telegram.org/")
            .client(okHttpClient)
            .addConverterFactory(GsonConverterFactory.create())
            .build()
            .create(TelegramApiService::class.java)
    }
}
```

---

> **Referencia externa:** [Telegram Bot API — sendMessage](https://core.telegram.org/bots/api#sendmessage)
