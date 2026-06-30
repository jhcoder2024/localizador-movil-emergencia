# Documento de Requerimientos - Localizador Móvil de Emergencia

## 1. Información General

| Campo | Valor |
|-------|-------|
| **Nombre del Proyecto** | Localizador Móvil de Emergencia |
| **Versión del Documento** | 1.0 |
| **Fecha** | 26/06/2026 |
| **Product Owner** | Asignado |
| **Estado** | Aprobado |

---

## 2. Objetivo del Proyecto

Desarrollar una aplicación móvil Android que permita al usuario, en una situación de emergencia, notificar de forma rápida y periódica su ubicación GPS a un grupo predefinido de hasta 10 contactos de confianza, utilizando múltiples canales de comunicación (SMS, WhatsApp y Telegram), con el fin de facilitar su localización y auxilio.

---

## 3. Requisitos Funcionales (RF)

### RF-01: Selección de Contactos de Emergencia
| Campo | Valor |
|-------|-------|
| **ID** | RF-01 |
| **Descripción** | El usuario debe poder seleccionar hasta 10 contactos desde la agenda telefónica del dispositivo. |
| **Prioridad** | Must Have |
| **Dependencias** | Ninguna |

### RF-02: Botones de Emergencia
| Campo | Valor |
|-------|-------|
| **ID** | RF-02 |
| **Descripción** | La aplicación debe tener 3 botones de emergencia claramente identificables: **Extraviado**, **Atrapado** y **Herido**. Cada uno debe activar el protocolo de emergencia con un mensaje de auxilio diferente según el tipo. |
| **Prioridad** | Must Have |
| **Dependencias** | RF-01 |

### RF-03: Envío de Señal de Auxilio Multicanal
| Campo | Valor |
|-------|-------|
| **ID** | RF-03 |
| **Descripción** | Al presionar un botón de emergencia, la app debe enviar un mensaje de auxilio a los 10 contactos seleccionados a través de: SMS (directo), WhatsApp (vía Intent `wa.me`, requiere confirmación del usuario) y Telegram (vía Bot API, envío automático). |
| **Prioridad** | Must Have |
| **Dependencias** | RF-01, RF-02 |

### RF-04: Activación de GPS y Obtención de Coordenadas
| Campo | Valor |
|-------|-------|
| **ID** | RF-04 |
| **Descripción** | Al activarse la emergencia, la app debe activar el GPS del dispositivo y obtener coordenadas geográficas (latitud, longitud) de forma periódica. |
| **Prioridad** | Must Have |
| **Dependencias** | RF-02 |

### RF-05: Intervalo de Envío Configurable
| Campo | Valor |
|-------|-------|
| **ID** | RF-05 |
| **Descripción** | El usuario debe poder configurar el intervalo de tiempo entre envíos de coordenadas. El valor mínimo permitido es 1 minuto. |
| **Prioridad** | Must Have |
| **Dependencias** | RF-04 |

### RF-06: Activación de Ahorro de Batería
| Campo | Valor |
|-------|-------|
| **ID** | RF-06 |
| **Descripción** | Al activarse la emergencia, la app debe intentar activar el modo ahorro de batería automáticamente (vía `PowerManager`). Si no es posible, debe solicitar al usuario que lo active manualmente. |
| **Prioridad** | Should Have |
| **Dependencias** | RF-02 |

### RF-07: Cancelación Manual de Emergencia
| Campo | Valor |
|-------|-------|
| **ID** | RF-07 |
| **Descripción** | El usuario debe poder cancelar la emergencia en cualquier momento desde la notificación persistente o desde la pantalla principal de la app. |
| **Prioridad** | Must Have |
| **Dependencias** | RF-02 |

### RF-08: Notificación Persistente de Emergencia Activa
| Campo | Valor |
|-------|-------|
| **ID** | RF-08 |
| **Descripción** | Mientras la emergencia esté activa, debe mostrarse una notificación persistente (no descartable) en la barra de estado indicando "Emergencia activa" con opción de cancelar. |
| **Prioridad** | Must Have |
| **Dependencias** | RF-02, RF-07 |

### RF-09: Vibración al Activar Emergencia
| Campo | Valor |
|-------|-------|
| **ID** | RF-09 |
| **Descripción** | Al presionar cualquier botón de emergencia, el dispositivo debe vibrar como señal de confirmación. No debe emitir sonido. |
| **Prioridad** | Should Have |
| **Dependencias** | RF-02 |

### RF-10: Funcionamiento en Segundo Plano y Pantalla Bloqueada
| Campo | Valor |
|-------|-------|
| **ID** | RF-10 |
| **Descripción** | La app debe continuar enviando coordenadas aunque la pantalla esté bloqueada o la app esté en segundo plano, mediante un Foreground Service. |
| **Prioridad** | Must Have |
| **Dependencias** | RF-04, RF-08 |

### RF-11: Manejo de Contactos sin WhatsApp o Telegram
| Campo | Valor |
|-------|-------|
| **ID** | RF-11 |
| **Descripción** | Si un contacto no tiene WhatsApp instalado, se le envía solo SMS. Si un contacto no tiene Telegram, se le envía solo SMS. La app debe detectar la disponibilidad de cada canal. |
| **Prioridad** | Must Have |
| **Dependencias** | RF-03 |

~~**RF-12: (Eliminado)** Antiguo requisito de respaldo en la nube. Se decidió que todo el almacenamiento es exclusivamente local.~~

### RF-14: Pitido de localizador
| Campo | Valor |
|-------|-------|
| **ID** | RF-14 |
| **Descripción** | Mientras la emergencia esté activa, la app debe emitir un pitido cada 10 segundos para permitir la localización del dispositivo por sonido. |
| **Prioridad** | Must Have |
| **Dependencias** | RF-02 |

### RF-13: Mensajes de Auxilio Personalizados por Tipo de Emergencia
| Campo | Valor |
|-------|-------|
| **ID** | RF-13 |
| **Descripción** | Cada botón de emergencia debe enviar un mensaje diferente: "Estoy extraviado, necesito ayuda. Mi ubicación: [coordenadas]", "Estoy atrapado, necesito ayuda. Mi ubicación: [coordenadas]", "Estoy herido, necesito ayuda médica urgente. Mi ubicación: [coordenadas]". |
| **Prioridad** | Must Have |
| **Dependencias** | RF-02, RF-03 |

---

## 4. Requisitos No Funcionales (RNF)

### RNF-01: Versión Mínima de Android
| Campo | Valor |
|-------|-------|
| **ID** | RNF-01 |
| **Descripción** | La aplicación debe ser compatible con Android 6.0 (API 23) como versión mínima. |
| **Prioridad** | Must Have |

### RNF-02: Idiomas Soportados
| Campo | Valor |
|-------|-------|
| **ID** | RNF-02 |
| **Descripción** | La aplicación debe estar disponible en español e inglés, detectando automáticamente el idioma del dispositivo. |
| **Prioridad** | Must Have |

### RNF-03: Manejo de Permisos
| Campo | Valor |
|-------|-------|
| **ID** | RNF-03 |
| **Descripción** | Los permisos (leer contactos, enviar SMS, acceso a ubicación, ignorar optimización de batería) deben solicitarse en cadena al primer inicio de la app. Si el usuario rechaza alguno, se le debe recordar más tarde sin forzar el cierre de la app. |
| **Prioridad** | Must Have |

### RNF-04: Almacenamiento Local
| Campo | Valor |
|-------|-------|
| **ID** | RNF-04 |
| **Descripción** | La configuración del usuario debe almacenarse exclusivamente de forma local usando Drift (SQLite) y SharedPreferences. No existe respaldo en la nube. |
| **Prioridad** | Must Have |

### RNF-05: Consumo de Batería
| Campo | Valor |
|-------|-------|
| **ID** | RNF-05 |
| **Descripción** | La app debe minimizar el consumo de batería durante la emergencia: activar ahorro de energía, usar GPS con intervalo configurable (mín. 1 min), y liberar recursos al cancelar la emergencia. |
| **Prioridad** | Should Have |

### RNF-06: Privacidad de Datos
| Campo | Valor |
|-------|-------|
| **ID** | RNF-06 |
| **Descripción** | Los contactos y coordenadas del usuario no deben compartirse con terceros ni almacenarse en servidores externos. Todo el almacenamiento es local en el dispositivo. |
| **Prioridad** | Must Have |

---

## 5. Restricciones Técnicas

| ID | Restricción |
|----|-------------|
| RT-01 | La app debe usar un **Foreground Service** con notificación persistente para funcionar en segundo plano en Android 8+ (API 26+). |
| RT-02 | Para el envío por **Telegram** vía Bot API, se requiere crear un bot de Telegram y que los contactos del usuario inicien conversación con dicho bot. Esto debe documentarse para el usuario. |
| RT-03 | Para el envío por **WhatsApp** vía `wa.me`, la app abrirá WhatsApp con el mensaje pre-cargado, pero el usuario debe presionar "Enviar" manualmente (limitación de la plataforma). |
| RT-04 | El envío de **SMS** tiene costo para el usuario según su plan telefónico. La app debe advertir esto al configurar los contactos. |
| RT-05 | En Android 6.0+, todos los permisos peligrosos (contactos, SMS, ubicación) deben solicitarse en tiempo de ejecución. |
| RT-06 | Para ignorar la optimización de batería, se requiere el permiso `REQUEST_IGNORE_BATTERY_OPTIMIZATIONS` y llevar al usuario a la pantalla de configuración del sistema. |

---

## 6. Suposiciones

| ID | Suposición |
|----|------------|
| S-01 | El usuario tiene un plan de datos o conexión a internet para el envío por WhatsApp y Telegram. |
| S-02 | El usuario tiene la aplicación de WhatsApp instalada en el dispositivo para que funcione el envío vía `wa.me`. |
| S-03 | El usuario y sus contactos tienen Telegram instalado para recibir mensajes vía Bot API. |
| S-04 | El dispositivo tiene GPS funcional para la obtención de coordenadas. |
| S-05 | El usuario es responsable de agregar los contactos correctos y mantener actualizada su lista de emergencia. |
| S-06 | (Eliminada) No aplica — no hay respaldo en la nube. |

---

## 7. Historias de Usuario

### HU-001: Selección de contactos de emergencia

**Como** usuario de la aplicación
**Quiero** seleccionar hasta 10 contactos desde mi agenda telefónica
**Para** definir quiénes recibirán mi señal de auxilio en caso de emergencia

**Requerimiento Padre:** RF-01

**Prioridad:** Alta
**Estimación:** 8 puntos

**Dependencias:** Ninguna

**Criterios de Aceptación:**
- [ ] La app solicita permiso `READ_CONTACTS` al primer inicio (junto con los demás permisos en cadena)
- [ ] El usuario puede buscar y seleccionar contactos desde la agenda del dispositivo
- [ ] Se muestra el nombre y número telefónico de cada contacto seleccionado
- [ ] El límite máximo es de 10 contactos; al alcanzarlo, se deshabilita la opción de agregar más
- [ ] El usuario puede eliminar contactos de la lista
- [ ] Los contactos seleccionados se guardan localmente y persisten al cerrar la app
- [ ] Si se revoca el permiso de contactos, la app muestra un mensaje recordatorio

---

### HU-002: Activación de emergencia con botón de pánico

**Como** usuario en situación de emergencia
**Quiero** presionar uno de los 3 botones (Extraviado, Atrapado, Herido)
**Para** que se active inmediatamente el protocolo de auxilio y se notifique a mis contactos

**Requerimiento Padre:** RF-02, RF-13

**Prioridad:** Alta
**Estimación:** 5 puntos

**Dependencias:** HU-001

**Criterios de Aceptación:**
- [ ] La pantalla principal muestra 3 botones grandes, claramente identificables: "Extraviado" (amarillo), "Atrapado" (naranja), "Herido" (rojo)
- [ ] Al presionar cualquier botón, el dispositivo vibra como confirmación
- [ ] Se muestra un diálogo de confirmación con contador regresivo de 10 segundos: "¿Estás seguro de activar la emergencia como [tipo]?"
- [ ] El diálogo incluye una barra de progreso que muestra el tiempo restante
- [ ] Si el usuario no interactúa en 10 segundos, la emergencia se activa automáticamente
- [ ] El botón para cancelar se llama **ABORTAR** y es visualmente prominente (rojo)
- [ ] Al presionar ABORTAR, se cancela la operación y se cierra el diálogo
- [ ] Al confirmar (automática o manualmente), se inicia el protocolo de emergencia
- [ ] El mensaje de auxilio varía según el botón presionado:
  - Extraviado: "Estoy extraviado, necesito ayuda. Mi ubicación: [coordenadas]"
  - Atrapado: "Estoy atrapado, necesito ayuda. Mi ubicación: [coordenadas]"
  - Herido: "Estoy herido, necesito ayuda médica urgente. Mi ubicación: [coordenadas]"

---

### HU-003: Envío de señal de auxilio a contactos

**Como** usuario que activó la emergencia
**Quiero** que se envíe mi ubicación a todos mis contactos de emergencia por SMS, WhatsApp y Telegram
**Para** que sepan dónde estoy y puedan ayudarme

**Requerimiento Padre:** RF-03, RF-11

**Prioridad:** Alta
**Estimación:** 13 puntos

**Dependencias:** HU-001, HU-002

**Criterios de Aceptación:**
- [ ] Al activarse la emergencia, se envía el mensaje de auxilio a los 10 contactos por los 3 canales disponibles
- [ ] **SMS:** Se envía automáticamente sin intervención del usuario
- [ ] **WhatsApp:** Se abre WhatsApp con el mensaje pre-cargado para cada contacto; el usuario debe presionar "Enviar" manualmente
- [ ] **Telegram:** Se envía automáticamente vía Bot API (sin intervención del usuario)
- [ ] Si un contacto no tiene WhatsApp instalado, se omite ese canal y se envía solo SMS
- [ ] Si un contacto no tiene Telegram, se omite ese canal y se envía solo SMS
- [ ] Se muestra un resumen de los envíos realizados (qué contactos y por qué canales)
- [ ] Los mensajes incluyen las coordenadas GPS actuales

---

### HU-004: Envío periódico de coordenadas GPS

**Como** usuario con emergencia activa
**Quiero** que la app obtenga y envíe mis coordenadas GPS cada N minutos (configurable)
**Para** que mis contactos puedan rastrear mi ubicación en tiempo real

**Requerimiento Padre:** RF-04, RF-05

**Prioridad:** Alta
**Estimación:** 8 puntos

**Dependencias:** HU-002

**Criterios de Aceptación:**
- [ ] Al activarse la emergencia, se enciende el GPS y se obtiene la primera coordenada
- [ ] La app envía la coordenada a los contactos inmediatamente y luego cada N minutos
- [ ] El intervalo N es configurable en la pantalla de ajustes (mínimo 1 minuto, valor por defecto: 5 minutos)
- [ ] Si el GPS no está disponible, se muestra un mensaje de error y se reintenta en el siguiente ciclo
- [ ] La coordenada incluye: latitud, longitud, y un enlace a Google Maps (ej: `https://maps.google.com/?q=lat,lng`)
- [ ] El envío periódico continúa hasta que el usuario cancele la emergencia
- [ ] La app funciona en segundo plano y con pantalla bloqueada (Foreground Service)

---

### HU-005: Notificación persistente y cancelación de emergencia

**Como** usuario con emergencia activa
**Quiero** ver una notificación persistente que me permita saber que la emergencia sigue activa y poder cancelarla
**Para** tener control sobre cuándo detener el envío de mi ubicación

**Requerimiento Padre:** RF-07, RF-08, RF-10

**Prioridad:** Alta
**Estimación:** 5 puntos

**Dependencias:** HU-002

**Criterios de Aceptación:**
- [ ] Mientras la emergencia está activa, se muestra una notificación persistente (no descartable) en la barra de estado
- [ ] La notificación muestra: "🚨 Emergencia activa - [Tipo]" y el tiempo transcurrido
- [ ] La notificación tiene una acción "Cancelar emergencia" que detiene el protocolo
- [ ] Al presionar "Cancelar", se muestra un diálogo de confirmación
- [ ] Al cancelar, se detiene el GPS, se cierra el Foreground Service y se elimina la notificación
- [ ] También se puede cancelar desde la pantalla principal de la app
- [ ] La app sigue funcionando aunque la pantalla esté bloqueada

---

### HU-006: Configuración de intervalo de envío

**Como** usuario de la aplicación
**Quiero** configurar el intervalo de tiempo entre envíos de coordenadas
**Para** balancear entre precisión de rastreo y consumo de batería

**Requerimiento Padre:** RF-05

**Prioridad:** Media
**Estimación:** 3 puntos

**Dependencias:** HU-004

**Criterios de Aceptación:**
- [ ] Existe una pantalla de configuración accesible desde el menú principal
- [ ] El usuario puede ajustar el intervalo mediante un selector numérico (minutos)
- [ ] El valor mínimo permitido es 1 minuto
- [ ] No hay límite máximo superior (pero se recomienda no más de 60 minutos)
- [ ] El valor se guarda localmente y persiste al cerrar la app
- [ ] El cambio de intervalo aplica al siguiente ciclo de envío (no interrumpe el actual)

---

### HU-007: Activación de ahorro de batería

**Como** usuario que activó la emergencia
**Quiero** que la app active el modo ahorro de batería automáticamente
**Para** maximizar la duración de la batería mientras estoy en emergencia

**Requerimiento Padre:** RF-06

**Prioridad:** Media
**Estimación:** 5 puntos

**Dependencias:** HU-002

**Criterios de Aceptación:**
- [ ] Al activarse la emergencia, la app intenta activar el ahorro de batería vía `PowerManager`
- [ ] Si el permiso `REQUEST_IGNORE_BATTERY_OPTIMIZATIONS` no está concedido, se solicita al usuario
- [ ] Si el método automático falla, se muestra un diálogo pidiendo al usuario que active manualmente el ahorro de batería desde ajustes del sistema
- [ ] Al cancelar la emergencia, se restaura la configuración de batería anterior (si es posible)

---

### HU-009: Pitido de localizador para localización por sonido

**Como** usuario en situación de emergencia
**Quiero** que mi dispositivo emita un pitido cada 10 segundos
**Para** que puedan localizarme por el sonido si estoy atrapado, inconsciente o no puedo responder

**Requerimiento Padre:** RF-14

**Prioridad:** Alta
**Estimación:** 3 puntos

**Dependencias:** HU-002

**Criterios de Aceptación:**
- [ ] Al activarse la emergencia, comienza un pitido periódico cada 10 segundos
- [ ] El pitido es lo suficientemente fuerte para ser escuchado desde lejos
- [ ] El pitido se detiene inmediatamente al cancelar la emergencia
- [ ] Si no hay archivo de sonido disponible, se usa el sonido de alerta del sistema como fallback
- [ ] El pitido continúa aunque la app esté en segundo plano o la pantalla bloqueada
- [ ] El pitido no interfiere con el envío de coordenadas

---

~~### HU-008: (Eliminada) Respaldo en la nube de la configuración~~

~~Historia de usuario eliminada. El almacenamiento es exclusivamente local.~~

---

## 8. Priorización MoSCoW

| Prioridad | Requisitos |
|-----------|------------|
| **Must Have** | RF-01, RF-02, RF-03, RF-04, RF-05, RF-07, RF-08, RF-10, RF-11, RF-13, RF-14, RNF-01, RNF-02, RNF-03, RNF-04, RNF-06 |
| **Should Have** | RF-06, RF-09, RNF-05 |
| **Could Have** | (ninguno) |
| **Won't Have** | RF-12 (Eliminado — almacenamiento exclusivamente local) |

---

## 9. Glosario

| Término | Definición |
|---------|------------|
| **Foreground Service** | Servicio de Android que se ejecuta en primer plano con una notificación persistente, evitando que el sistema lo mate. |
| **Intent** | Mecanismo de Android para iniciar actividades de otras aplicaciones. |
| **Bot API (Telegram)** | API HTTP que permite enviar mensajes automáticos a través de un bot de Telegram. |
| **wa.me** | Enlace/URI acortado de WhatsApp que abre la app con un número y mensaje pre-cargados. |
| **PowerManager** | API de Android para gestionar el estado de energía del dispositivo. |
| **DataStore** | Biblioteca de Jetpack para almacenamiento local de datos clave-valor (sucesor de SharedPreferences). |
| **API Level** | Nivel de API de Android que determina la compatibilidad de la app con versiones del sistema operativo. |
