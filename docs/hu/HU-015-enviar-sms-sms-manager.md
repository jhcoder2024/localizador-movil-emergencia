# HU-015: Enviar SMS desde la app usando SmsManager

**Como** usuario
**Quiero** que al tocar "Enviar", el SMS se envíe realmente usando SmsManager de Android
**Para** que el destinatario reciba mi mensaje

**Requerimiento Padre:** REQ-001.4 (Visor de conversación y envío)

**Prioridad:** Alta
**Esfuerzo:** 5 puntos

**Dependencias:** HU-014

**Criterios de Aceptación:**
- [ ] Existe un nuevo método en el MethodChannel (`sendSmsFromInbox`) que:
  - Usa `SmsManager.getDefault().sendTextMessage()` para enviar el SMS
  - Retorna `true` si el envío se inició correctamente
  - Retorna `false` si falló (permiso denegado, sin SIM, etc.)
- [ ] Si la app NO es la SMS predeterminada:
  - El envío puede fallar en Android 14+
  - Se muestra un diálogo al usuario: "Para enviar SMS directamente, establece esta app como predeterminada. ¿Quieres hacerlo ahora?"
  - Si acepta, se llama a `solicitarSerSmsDefault()` (ya implementado)
- [ ] Si la app SÍ es la SMS predeterminada:
  - El envío se realiza sin intervención del usuario
  - Se muestra un SnackBar "Mensaje enviado" al confirmar la entrega
- [ ] El resultado del envío se comunica de vuelta a Flutter:
  - `RESULT_OK` → marcar mensaje como enviado
  - `RESULT_ERROR_GENERIC` → marcar como fallido y mostrar error
- [ ] Se actualiza el `SmsBroadcastReceiver` para manejar `SMS_SENT` y comunicar el resultado a Flutter
- [ ] El mensaje enviado se inserta en la BD local y en el ContentProvider de Android (para consistencia)

**Notas técnicas:**
- El `SmsManager.sendTextMessage()` ya está implementado en `MainActivity.kt` pero solo se usa desde emergencia. Refactorizar para que también lo use el inbox.
- Para el PendingIntent de confirmación, usar el `SmsBroadcastReceiver` existente con acción `SMS_SENT`
- Insertar en el ContentProvider de Android:
  ```kotlin
  val values = ContentValues().apply {
    put(Telephony.Sms.ADDRESS, telefono)
    put(Telephony.Sms.BODY, mensaje)
    put(Telephony.Sms.TYPE, Telephony.Sms.MESSAGE_TYPE_SENT)
    put(Telephony.Sms.DATE, System.currentTimeMillis())
    put(Telephony.Sms.READ, 1)
  }
  contentResolver.insert(Telephony.Sms.CONTENT_URI, values)
  ```
- Esto asegura que si el usuario cambia de app SMS, los mensajes enviados desde nuestra app siguen siendo visibles
