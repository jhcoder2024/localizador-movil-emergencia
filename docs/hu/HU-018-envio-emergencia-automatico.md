# HU-018: Enviar SMS de emergencia automáticamente (sin abrir otra app)

**Como** usuario en emergencia
**Quiero** que al activar el botón de emergencia, los SMS se envíen automáticamente usando SmsManager
**Para** que mis contactos reciban mi ubicación sin que yo tenga que tocar "Enviar" en otra app

**Requerimiento Padre:** REQ-001.5 (Emergencia automática)

**Prioridad:** Alta
**Esfuerzo:** 5 puntos

**Dependencias:** HU-015, HU-017

**Criterios de Aceptación:**
- [ ] El flujo de emergencia existente (`EnviarUbicacionUseCase`) se actualiza para usar el nuevo método de envío directo (`SmsManager.sendTextMessage()`) en lugar de abrir la app de SMS nativa
- [ ] Si la app es la SMS predeterminada:
  - Los SMS se envían sin abrir ninguna otra app
  - No se muestra ningún diálogo de confirmación adicional
  - El mensaje de ubicación se envía a todos los contactos configurados
- [ ] Si la app NO es la SMS predeterminada:
  - Se muestra un diálogo: "Para enviar SMS automáticamente en emergencias, establece esta app como predeterminada"
  - Opciones: "Configurar ahora" (abre ajustes) o "Enviar manualmente" (abre app de SMS como antes)
  - Se guarda la preferencia para no preguntar de nuevo
- [ ] El envío periódico (cada N minutos) también usa el envío directo
- [ ] Los SMS de emergencia se guardan en la BD local como mensajes enviados (tipo `sent`) en la conversación con cada contacto
- [ ] Si el envío falla (error de red, SIM, etc.), se reintenta automáticamente 1 vez después de 5 segundos
- [ ] Si el reintento falla, se muestra una notificación persistente con el error y opción de re-enviar manualmente

**Notas técnicas:**
- Modificar `EnviarUbicacionUseCase` para que use `SmsRepository.enviarSms()` que ya intenta SmsManager primero
- El `SmsRepository` existente ya tiene la lógica de intentar SmsManager → fallback → abrir app. Asegurar que cuando es app default, el fallback no se ejecuta.
- Los SMS de emergencia deben persistir en la BD para que el usuario pueda ver el historial en la bandeja de entrada
- Considerar agregar un flag `esEmergencia` en `sms_messages` para identificar estos mensajes
