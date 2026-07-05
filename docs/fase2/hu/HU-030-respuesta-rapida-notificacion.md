# HU-030: Respuesta rápida desde la notificación

**Como** usuario
**Quiero** responder a un SMS directamente desde la notificación sin abrir la app
**Para** ahorrar tiempo y responder rápidamente cuando estoy usando otras aplicaciones

**Requerimiento Padre:** REQ-F2-008 (Respuesta rápida)

**Prioridad:** Media
**Esfuerzo:** L (3 puntos)

**Dependencias:** HU-007 (Escuchar SMS entrantes con BroadcastReceiver), HU-013 (Pantalla de conversación con burbujas)

**Criterios de Aceptación:**
- [ ] Al recibir un SMS, la notificación incluye un campo de texto para responder directamente
- [ ] La notificación también tiene una acción "Responder" que abre el campo de texto inline
- [ ] Al escribir y enviar desde la notificación:
  - El SMS se envía usando `SmsManager`
  - La conversación se actualiza en la BD local
  - La notificación se actualiza para reflejar que se respondió
- [ ] La respuesta rápida funciona en Android 7.0+ (API 24+) usando `RemoteInput`
- [ ] Si la app no es la SMS predeterminada, la respuesta rápida muestra un mensaje indicando que no está disponible
- [ ] La notificación muestra un preview del mensaje recibido (primeros 100 caracteres)
- [ ] La notificación tiene acción "Marcar como leído" además de "Responder"
- [ ] Al marcar como leído, la notificación se descarta y el mensaje se marca como leído en la BD
- [ ] La respuesta rápida respeta el modo oscuro de la notificación (tema del sistema)

**Capa técnica requerida:**
- **Data:** El `SmsBroadcastReceiver` debe comunicarse con el servicio de notificaciones
- **Presentation:** Modificar `NotificationService` para incluir `RemoteInput` en las notificaciones de SMS entrantes

**Notas técnicas:**
- Usar `flutter_local_notifications` que ya está en el proyecto
- `RemoteInput` se configura en Android con:
  ```kotlin
  val remoteInput = RemoteInput.Builder("reply_key")
      .setLabel("Responder")
      .build()
  ```
- En Flutter, usar el plugin `flutter_local_notifications` con `replyAction` en la notificación
- El resultado del `RemoteInput` se recibe en un `BroadcastReceiver` que debe estar registrado en el manifiesto de Android
- Crear un `ReplyReceiver` nativo (Kotlin/Java) que reciba el input y lo pase a Flutter via MethodChannel
- Alternativa más simple: usar `Intent.ACTION_SENDTO` con `sms:` URI para abrir la app de SMS predeterminada (menos integrado pero más sencillo)
