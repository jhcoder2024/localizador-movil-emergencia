# HU-016: Actualizar conversación en tiempo real al enviar/recibir

**Como** usuario
**Quiero** que la conversación se actualice instantáneamente cuando envío o recibo un mensaje
**Para** tener una experiencia de chat fluida y en tiempo real

**Requerimiento Padre:** REQ-001.4 (Visor de conversación y envío)

**Prioridad:** Alta
**Esfuerzo:** 3 puntos

**Dependencias:** HU-015, HU-007

**Criterios de Aceptación:**
- [ ] Al enviar un mensaje (HU-015), el mensaje aparece inmediatamente en la conversación (optimistic update) antes de que el SMS se envíe realmente
- [ ] Al recibir un SMS (HU-007), el mensaje aparece automáticamente en la conversación abierta
- [ ] La lista de conversaciones (Inbox) se actualiza: la conversación activa sube al tope con el nuevo preview
- [ ] El contador de no leídos NO se incrementa si la conversación está abierta en ese momento
- [ ] Si el envío falla, el mensaje se marca visualmente como fallido (icono de error junto al mensaje)
- [ ] El usuario puede re-enviar un mensaje fallido tocando el icono de error
- [ ] Los mensajes enviados correctamente muestran un indicador de "enviado" (check simple) o "entregado" (doble check) — opcional para Fase 1

**Notas técnicas:**
- El optimistic update consiste en insertar el mensaje en la BD local inmediatamente con `estadoEnvio = "enviando"`
- Cuando el BroadcastReceiver confirma el envío, actualizar `estadoEnvio = "enviado"` o `"fallido"`
- Agregar columna `estadoEnvio` a `sms_messages` con valores: `sending`, `sent`, `failed`, `delivered`
- La reactividad de Drift (`watch()`) maneja la actualización automática de la UI
