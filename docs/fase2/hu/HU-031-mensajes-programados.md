# HU-031: Mensajes programados (crear, listar, cancelar)

**Como** usuario
**Quiero** programar el envío de un SMS para una fecha y hora futura
**Para** recordar cumpleaños, citas médicas o eventos importantes sin tener que acordarme de enviar el mensaje en el momento

**Requerimiento Padre:** REQ-F2-009 (Mensajes programados)

**Prioridad:** Media
**Esfuerzo:** XL (5 puntos)

**Dependencias:** HU-015 (Enviar SMS desde la app usando SmsManager)

**Criterios de Aceptación:**
- [ ] En la pantalla de conversación, el menú tiene una opción "Programar mensaje"
- [ ] También hay un acceso desde la bandeja de entrada: botón "Nuevo mensaje programado" (FAB secundario o en menú)
- [ ] Al seleccionar programar, se abre un diálogo/pantalla con:
  - Campo de texto para el mensaje
  - Selector de contacto (o se usa el contacto actual si se abre desde una conversación)
  - Selector de fecha (calendario)
  - Selector de hora (rueda horaria)
- [ ] La fecha/hora seleccionada debe ser futura (no se permite programar en el pasado)
- [ ] Al guardar, el mensaje programado se almacena en la BD local con estado "Pendiente"
- [ ] Existe una pantalla "Mensajes programados" accesible desde el menú principal que lista:
  - Todos los mensajes programados ordenados por fecha de envío
  - Cada item muestra: contacto, preview del mensaje, fecha/hora programada, estado (Pendiente/Enviado/Cancelado)
- [ ] Desde la lista, se puede cancelar un mensaje programado (con confirmación)
- [ ] Al llegar la fecha/hora programada:
  - El mensaje se envía automáticamente usando `SmsManager`
  - Si el envío falla, se marca como "Error" y se reintenta 2 veces con intervalo de 5 minutos
  - Si el envío es exitoso, se marca como "Enviado" y aparece en la conversación correspondiente
- [ ] Los mensajes programados persisten al reiniciar el dispositivo (se reprograman al iniciar la app)
- [ ] Si la app no es la SMS predeterminada, se muestra una advertencia al programar

**Nuevas dependencias:**
- `workmanager: ^0.5.2` (tareas en segundo plano para envío programado)
- O usar `android_alarm_manager` para programar alarmas exactas

**Capa técnica requerida:**
- **Data:** Nueva tabla `scheduled_messages` en Drift, nuevo DAO `ScheduledMessageDao`
- **Domain:** Nueva entidad `ScheduledMessage`, nuevo repositorio `ScheduledMessageRepository`
- **Presentation:** Nuevo provider `ScheduledMessageProvider`, nueva pantalla `ScheduledMessagesScreen`

**Notas técnicas:**
- `workmanager` es la opción recomendada para tareas periódicas en Flutter
- Para fecha/hora exacta, usar `android_alarm_manager` con `AlarmManager.setExact()`
- La tabla `scheduled_messages` debe tener: id, contactNumber, messageBody, scheduledAt, status (pending/sent/cancelled/error), createdAt
- Al iniciar la app, verificar mensajes programados cuya hora ya pasó y enviarlos
- Considerar notificación local 5 minutos antes del envío programado como recordatorio
