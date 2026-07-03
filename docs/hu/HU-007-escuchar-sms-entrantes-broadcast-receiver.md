# HU-007: Escuchar SMS entrantes con BroadcastReceiver

**Como** usuario
**Quiero** recibir los SMS en tiempo real dentro de la app sin tener que abrirla
**Para** estar al tanto de los mensajes que llegan

**Requerimiento Padre:** REQ-001.2 (Sincronización con ContentProvider)

**Prioridad:** Alta
**Esfuerzo:** 5 puntos

**Dependencias:** HU-005

**Criterios de Aceptación:**
- [ ] El `SmsBroadcastReceiver` existente en Kotlin se actualiza para:
  - Extraer el remitente, cuerpo del mensaje y timestamp del Intent
  - Enviar los datos del SMS recibido a Flutter a través de un EventChannel o MethodChannel
- [ ] Existe un `SmsReceiverService` en Dart que escucha los SMS entrantes desde el canal nativo
- [ ] Al recibir un SMS:
  - Se inserta en la BD local como mensaje tipo `received`
  - Se actualiza o crea la conversación correspondiente
  - Se incrementa el contador `noLeidos` de la conversación
- [ ] Si la app está en primer plano, la UI se actualiza automáticamente (gracias a los Stream de Drift)
- [ ] Si la app está en segundo plano, se muestra una notificación (usando `flutter_local_notifications`)
- [ ] El BroadcastReceiver tiene prioridad 1000 en el intent-filter (ya configurado en AndroidManifest)
- [ ] Se maneja el caso de SMS duplicados (mismo `id` de ContentProvider) — no se insertan duplicados
- [ ] El permiso `RECEIVE_SMS` se verifica y solicita si es necesario

**Notas técnicas:**
- El `SmsBroadcastReceiver` actual solo hace logging — hay que extenderlo para que comunique los datos a Flutter
- Usar `EventChannel` para comunicación continua (Flutter escucha eventos) en lugar de MethodChannel (request-response)
- El EventChannel debe registrarse con el nombre `com.example.localizador_movil_emergencia/sms_events`
- En Kotlin, extraer SMS del Intent:
  ```kotlin
  val pdus = intent.extras?.get("pdus") as? Array<*>
  // Iterar pdus, usar SmsMessage.createFromPdu() para cada uno
  ```
- Cuando la app es la SMS predeterminada, recibe `SMS_DELIVERED` en lugar de `SMS_RECEIVED` — manejar ambos
