# 📱 Manual de Usuario — Localizador Móvil de Emergencia

| Campo | Valor |
|-------|-------|
| **ID** | USER-GUIDE-001 |
| **Versión** | 2.0 |
| **Fecha** | 26/06/2026 |
| **Idiomas** | Español, Inglés |

---

## Índice

1. [Introducción](#1-introducción)
2. [Requisitos](#2-requisitos)
3. [Primeros Pasos](#3-primeros-pasos)
4. [Configuración](#4-configuración)
5. [Uso en Emergencia](#5-uso-en-emergencia)
6. [Preguntas Frecuentes (FAQ)](#6-preguntas-frecuentes-faq)
7. [Solución de Problemas](#7-solución-de-problemas)

---

## 1. Introducción

**Localizador Móvil de Emergencia** es una aplicación diseñada para situaciones de peligro. Con solo presionar un botón, la app envía tu ubicación GPS a tus contactos de confianza a través de SMS, WhatsApp y Telegram, de forma periódica, hasta que tú mismo canceles la emergencia.

> Toda tu configuración se guarda localmente en el dispositivo. No se envía a ningún servidor externo.

### ¿Para qué sirve?

- 🚶 **Extraviado** — Si te pierdes en una zona desconocida.
- 🏚️ **Atrapado** — Si quedas atrapado en un edificio, vehículo o situación similar.
- 🩹 **Herido** — Si sufriste una lesión y necesitas auxilio médico.

---

## 2. Requisitos

### Dispositivo

| Requisito | Detalle |
|-----------|---------|
| **Sistema operativo** | Android 8.0 (API 26) o superior / iOS 14 o superior |
| **GPS** | Obligatorio para obtener coordenadas |
| **Internet** | Necesario para WhatsApp y Telegram |
| **Plan SMS** | Necesario para envío de SMS (pueden generar costos) |

### Cuentas externas

- **WhatsApp:** App instalada en el dispositivo (gratuito).
- **Telegram:** Se requiere crear un bot con @BotFather y que tus contactos inicien conversación con él (gratuito).

---

## 3. Primeros Pasos

### 3.1 Instalación

1. Descarga el archivo APK o instala desde Google Play Store.
2. Abre la aplicación.
3. Se mostrará la pantalla de bienvenida con la solicitud de permisos.

### 3.2 Solicitud de Permisos

La app solicitará los siguientes permisos en cadena al primer inicio. **Es necesario concederlos** para el funcionamiento completo.

| Permiso | ¿Para qué sirve? |
|---------|------------------|
| 📍 **Ubicación (ACCESS_FINE_LOCATION)** | Obtener coordenadas GPS de alta precisión |
| 🗺️ **Ubicación en segundo plano (ACCESS_BACKGROUND_LOCATION)** | Enviar ubicación aunque la pantalla esté apagada |
| ✉️ **Enviar SMS (SEND_SMS)** | Enviar mensajes de texto con tu ubicación |
| 👤 **Leer contactos (READ_CONTACTS)** | Seleccionar contactos desde tu agenda |
| 🔔 **Notificaciones (POST_NOTIFICATIONS)** | Mostrar la notificación persistente de emergencia activa |
| 🔋 **Ignorar ahorro de batería** | Evitar que el sistema duerma la app durante la emergencia |

> ⚠️ Si deniegas un permiso, la app funcionará con funcionalidad reducida. Puedes concederlos después desde **Ajustes del sistema > Aplicaciones > Localizador Móvil de Emergencia > Permisos**.

### 3.3 Pantalla de Configuración

Una vez concedidos los permisos, accederás a la pantalla de configuración donde debes:

1. Agregar tus contactos de emergencia
2. Configurar el intervalo de envío
3. (Opcional) Configurar Telegram Bot

---

## 4. Configuración

### 4.1 Seleccionar Contactos de Emergencia

1. Presiona **"Agregar contacto"**.
2. Se abrirá tu agenda telefónica.
3. Selecciona hasta **10 contactos**.
4. Los contactos aparecerán en la lista con su nombre y número.

> 💡 Puedes eliminar un contacto deslizándolo hacia la izquierda o presionando el ícono de eliminar.

### 4.2 Configurar Intervalo de Envío

El intervalo determina cada cuántos minutos se enviará tu ubicación a los contactos.

- **Mínimo:** 1 minuto
- **Valor por defecto:** 5 minutos
- **Máximo recomendado:** 60 minutos

> ⚠️ Un intervalo más corto consume más batería. Elige un balance según tu situación.

### 4.3 Configurar Telegram Bot

Para que la app pueda enviar mensajes automáticos por Telegram:

1. Abre Telegram y busca **@BotFather**.
2. Envía el comando `/newbot`.
3. Sigue las instrucciones para crear un bot (elige nombre y username).
4. @BotFather te dará un **token** (un string como `123456789:ABCdefGHIjklMNOpqrsTUVwxyz`).
5. Guarda el token para usarlo en la compilación (ver guía de despliegue si compilas tú mismo).
6. Pide a cada contacto que abra Telegram, busque el bot por su username y envíe `/start`.
7. El bot responderá con un número: el **chat_id** de ese contacto.
8. Cada contacto debe compartir su chat_id contigo.
9. En la app, al seleccionar un contacto, podrás ingresar su chat_id de Telegram.

> 💡 Si el bot no responde con el chat_id, puedes usar servicios como `@getidsbot` para obtenerlo.

### 4.4 Configurar WhatsApp

WhatsApp funciona automáticamente. Solo requiere que:

- Tengas WhatsApp instalado en el dispositivo.
- El contacto tenga WhatsApp asociado a su número.

No requiere configuración adicional. Al activar la emergencia, se abrirá WhatsApp con el mensaje precargado; tú solo debes presionar **Enviar**.

### 4.5 Advertencia sobre Costos de SMS

> ⚠️ **Importante:** El envío de SMS puede generar costos según tu plan telefónico.  
> Cada mensaje enviado a cada contacto cuenta como un SMS. Si tienes el intervalo en 5 minutos y 5 contactos, serán 5 SMS cada 5 minutos.  
> La app te mostrará un aviso antes de activar la emergencia.

---

## 5. Uso en Emergencia

### 5.1 Los 3 Botones

La pantalla principal muestra 3 botones grandes:

| Botón | Color | Código HTML | Mensaje que se envía |
|-------|-------|-------------|----------------------|
| 🟡 **Extraviado** | Amarillo `#FFC107` | `[EXT]` | "¡Emergencia! Estoy extraviado, necesito ayuda. Mi ubicación: [enlace Maps]" |
| 🟠 **Atrapado** | Naranja `#FF9800` | `[ATR]` | "¡Emergencia! Estoy atrapado, necesito ayuda. Mi ubicación: [enlace Maps]" |
| 🔴 **Herido** | Rojo `#F44336` | `[HER]` | "¡Emergencia! Estoy herido, necesito ayuda médica urgente. Mi ubicación: [enlace Maps]" |

### 5.2 Diálogo de Confirmación con Contador Regresivo

Al presionar cualquier botón:

1. 📳 El dispositivo **vibra** (sin sonido).
2. Aparece un diálogo con:
   - **Título:** "¿Activar emergencia como [tipo]?"
   - **Información:** "Se enviará tu ubicación a tus contactos de emergencia configurados"
   - **Barra de progreso** con cuenta regresiva desde 10 segundos
   - **Botón "ABORTAR"** rojo y prominente
3. Si el usuario **no presiona ABORTAR** en 10 segundos, la emergencia se activa automáticamente.
4. Si el usuario presiona **"ABORTAR"**, la operación se cancela y se vuelve a la pantalla principal.

### 5.3 ¿Qué Sucede al Activar?

```
1. ✅ Se inicia el protocolo de emergencia
2. 📍 Se obtienen las coordenadas GPS (alta precisión)
3. 🔋 Se intenta activar el ahorro de batería
4. ✉️ Se envía la ubicación a TODOS los contactos:
     ├── 📱 SMS → Envío automático
     ├── 💬 WhatsApp → Se abre la app (debes presionar "Enviar")
     └── 🤖 Telegram → Envío automático vía Bot API
5. 🔔 Aparece una notificación persistente: "🚨 Emergencia activa"
6. 🔊 El localizador emite un pitido cada 10 segundos para que puedas ser localizado por el sonido, incluso si no puedes responder.
7. 🔁 Se repite cada N minutos (según configuración)
```

> El pitido se detiene automáticamente al cancelar la emergencia.

### 5.4 Notificación Persistente

Mientras la emergencia esté activa, verás una notificación en la barra de estado:
- **Título:** 🚨 EMERGENCIA ACTIVA
- **Texto:** Tipo de emergencia y tiempo transcurrido
- **Acción:** Botón "CANCELAR" para detener la emergencia

> Esta notificación **no se puede descartar** deslizándola. Debes presionar "CANCELAR" a propósito para evitar cancelaciones accidentales.

### 5.5 Cómo Cancelar la Emergencia

Puedes cancelar de dos formas:

1. **Desde la notificación:** Presiona el botón "CANCELAR" en la notificación persistente.
2. **Desde la app:** Abre la app y presiona el botón "CANCELAR EMERGENCIA" en el banner rojo.

Al cancelar:
- ✅ Se detiene el GPS
- ✅ Se cierra el servicio en segundo plano
- ✅ Se elimina la notificación
- ✅ Se restaura el ahorro de batería (si se activó)

---

## 6. Preguntas Frecuentes (FAQ)

### ❓ ¿Funciona sin internet?

- **SMS:** ✅ Sí, los SMS funcionan sin datos móviles ni WiFi.
- **WhatsApp:** ❌ No, requiere conexión a internet.
- **Telegram:** ❌ No, requiere conexión a internet.

### ❓ ¿Cuánta batería consume?

El consumo depende del intervalo configurado:
- **Cada 1 minuto:** Consumo alto (GPS activo frecuentemente).
- **Cada 5 minutos:** Consumo moderado (valor por defecto).
- **Cada 30-60 minutos:** Consumo bajo.

La app activa automáticamente el ahorro de batería al iniciar la emergencia para maximizar la duración.

### ❓ ¿Qué pasa si un contacto no tiene WhatsApp o Telegram?

La app detecta automáticamente qué canales están disponibles:
- Sin WhatsApp → solo recibe SMS y Telegram (si configurado).
- Sin Telegram → solo recibe SMS y WhatsApp.
- Sin ambos → solo recibe SMS.

### ❓ ¿Cómo sé que mis contactos recibieron la alerta?

- **SMS:** Se muestra un resumen de envío en la app. Puedes verificar el estado con tu operador.
- **WhatsApp:** Debes presionar "Enviar" manualmente, así que sabes que se envió.
- **Telegram:** La API confirma el envío. Si falla, se marca en el resumen.

### ❓ ¿Puedo cambiar el intervalo durante una emergencia?

No. El intervalo se configura antes de activar la emergencia. Si necesitas cambiarlo, debes cancelar la emergencia, ajustar el intervalo y volver a activar.

### ❓ ¿Por qué el localizador emite pitidos?

→ Para que puedas ser localizado por el sonido si estás atrapado, inconsciente o en un lugar donde no puedan verte.

---

## 7. Solución de Problemas

### ❌ GPS no funciona

| Posible causa | Solución |
|---------------|----------|
| GPS desactivado | Actívalo desde Ajustes > Ubicación |
| Permiso denegado | Ve a Ajustes > Apps > Localizador > Permisos > Activar ubicación |
| Mala señal | Muévete a un lugar abierto. La app reintentará en el próximo ciclo. |
| Modo avión activado | Desactívalo |

### ❌ No se envían SMS

| Posible causa | Solución |
|---------------|----------|
| Permiso SEND_SMS denegado | Actívalo en Ajustes > Apps > Localizador > Permisos |
| Plan SMS sin saldo | Verifica con tu operador |
| Número incorrecto | Revisa el formato del número del contacto |
| Sin cobertura | Los SMS requieren señal celular |

### ❌ Telegram no envía mensajes

| Posible causa | Solución |
|---------------|----------|
| Token incorrecto | Verifica el token configurado en la compilación |
| Chat_id inválido | Pide al contacto que envíe `/start` al bot y obtenga su chat_id |
| Bot bloqueado | El contacto debe desbloquear el bot |
| Sin internet | Conéctate a datos móviles o WiFi |
| Rate limit | Espera unos segundos. La app reintentará automáticamente. |

### ❌ La app se cierra inesperadamente

1. Limpia la caché: Ajustes > Apps > Localizador > Almacenamiento > Borrar caché
2. Reinicia el dispositivo
3. Si persiste, desinstala y vuelve a instalar
4. Reporta el error con los pasos para reproducirlo

---

> **¿Necesitas más ayuda?** Contacta al equipo de desarrollo o reporta un issue en el repositorio del proyecto.
