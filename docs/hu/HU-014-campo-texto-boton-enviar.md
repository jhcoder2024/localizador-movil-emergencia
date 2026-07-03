# HU-014: Campo de texto y botón enviar SMS

**Como** usuario
**Quiero** tener un campo de texto en la parte inferior de la pantalla de chat con un botón de enviar
**Para** escribir y enviar mensajes de texto

**Requerimiento Padre:** REQ-001.4 (Visor de conversación y envío)

**Prioridad:** Alta
**Esfuerzo:** 3 puntos

**Dependencias:** HU-013

**Criterios de Aceptación:**
- [ ] En la parte inferior de `ConversationScreen` hay un `TextField` con:
  - Hint text: "Escribe un mensaje..."
  - Icono de adjuntar a la izquierda (sin funcionalidad aún — placeholder para Fase 2)
  - Botón de enviar (icono de avión de papel) a la derecha
- [ ] El botón de enviar está deshabilitado (gris) cuando el campo está vacío
- [ ] Al tocar "Enviar":
  - Se dispara el caso de uso de envío (HU-015)
  - El campo de texto se limpia
  - El mensaje aparece inmediatamente en la conversación (optimistic update)
- [ ] El campo de texto no pierde el foco al enviar (el usuario puede seguir escribiendo)
- [ ] El teclado no cubre el campo de texto (usar `resizeToAvoidBottomInset`)
- [ ] El campo de texto soporta múltiples líneas (hasta 5 líneas máximo, con scroll)
- [ ] Se muestra un indicador de error si el envío falla (SnackBar con "Error al enviar SMS")

**Notas técnicas:**
- Usar `Row` con `Expanded` para el TextField y un `IconButton` para enviar
- El TextField debe tener `maxLines: 5` y `textInputAction: TextInputAction.newline`
- Para el optimistic update, insertar el mensaje en la BD local inmediatamente (con tipo `sent`) y luego confirmar con el envío real
- Si el envío real falla, marcar el mensaje como fallido (agregar columna `estadoEnvio` a `sms_messages` o usar un flag)
