# HU-032: Bloqueo de números spam

**Como** usuario
**Quiero** bloquear números de teléfono específicos para no recibir sus mensajes
**Para** evitar spam, publicidad no deseada y acoso

**Requerimiento Padre:** REQ-F2-010 (Bloqueo de spam)

**Prioridad:** Media
**Esfuerzo:** M (2 puntos)

**Dependencias:** HU-009 (Pantalla de lista de conversaciones)

**Criterios de Aceptación:**
- [ ] Desde el menú contextual (long-press) de una conversación, hay opción "Bloquear número"
- [ ] También desde la pantalla de conversación: menú del AppBar → "Bloquear [contacto]"
- [ ] Al seleccionar bloquear, se muestra un diálogo de confirmación:
  - Título: "¿Bloquear [número]?"
  - Mensaje: "Los mensajes de este número se filtrarán automáticamente."
  - Botones: "Cancelar" y "Bloquear"
- [ ] Al confirmar, el número se agrega a la lista de bloqueados en la BD
- [ ] Los mensajes entrantes de números bloqueados:
  - No aparecen en la bandeja de entrada
  - No generan notificaciones
  - Se almacenan en una sección separada "Spam" o se descartan silenciosamente
- [ ] Existe una pantalla "Números bloqueados" accesible desde Configuración
- [ ] Desde la pantalla de bloqueados, se puede desbloquear un número
- [ ] Al desbloquear, los mensajes existentes de ese número no se recuperan (solo aplica a futuros)
- [ ] El bloqueo funciona a nivel de la app (no modifica el bloqueo del sistema Android)

**Capa técnica requerida:**
- **Data:** Nueva tabla `blocked_numbers` en Drift, nuevo DAO `BlockedNumberDao`
- **Domain:** Nueva entidad `BlockedNumber`, método `blockNumber` / `unblockNumber` / `isBlocked` en repositorio
- **Presentation:** Provider con lista de bloqueados, integración en InboxProvider para filtrar

**Notas técnicas:**
- Tabla `blocked_numbers`: id, phoneNumber, blockedAt, reason (opcional)
- El `SmsBroadcastReceiver` debe consultar la lista de bloqueados antes de procesar un SMS entrante
- Si el número está bloqueado, el mensaje se ignora (no se inserta en la BD ni se muestra notificación)
- Alternativa: almacenar mensajes bloqueados en una tabla separada para posible revisión futura
- Considerar importar/exportar lista de bloqueados junto con la copia de seguridad
