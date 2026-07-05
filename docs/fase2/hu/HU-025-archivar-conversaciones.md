# HU-025: Archivar y desarchivar conversaciones

**Como** usuario
**Quiero** archivar conversaciones para ocultarlas de la bandeja principal sin eliminarlas
**Para** mantener ordenada mi bandeja de entrada sin perder mensajes importantes

**Requerimiento Padre:** REQ-F2-005 (Archivar / Eliminar)

**Prioridad:** Alta
**Esfuerzo:** M (2 puntos)

**Dependencias:** HU-009 (Pantalla de lista de conversaciones)

**Criterios de Aceptación:**
- [ ] Al hacer long-press en una conversación, aparece un menú contextual con opción "Archivar"
- [ ] También hay un icono de archivar en la barra superior de la conversación abierta
- [ ] Al archivar, la conversación desaparece de la bandeja principal sin mostrar notificación
- [ ] Las conversaciones archivadas no aparecen en los resultados de búsqueda general (opcional: sí aparecen con indicador)
- [ ] Existe una sección "Archivados" accesible desde el menú de navegación o desde un botón al final del inbox
- [ ] La sección de archivados muestra las conversaciones archivadas ordenadas por fecha del último mensaje
- [ ] Desde la sección de archivados, se puede desarchivar una conversación (long-press → "Desarchivar")
- [ ] Al recibir un nuevo mensaje de una conversación archivada, esta se desarchiva automáticamente y vuelve al inbox
- [ ] La base de datos se actualiza: campo `isArchived` en la tabla `conversations`

**Capa técnica requerida:**
- **Data:** Nuevo campo `isArchived` (booleano, default false) en la tabla `conversations` de Drift
- **Domain:** Método `archiveConversation` / `unarchiveConversation` en el repositorio
- **Presentation:** Provider con filtro de archivadas, nueva pantalla o sección de archivados

**Notas técnicas:**
- Migración de BD: ALTER TABLE conversations ADD COLUMN is_archived INTEGER NOT NULL DEFAULT 0
- El inbox principal debe filtrar `WHERE is_archived = 0`
- La sección de archivados filtra `WHERE is_archived = 1`
- Al recibir SMS entrante, si la conversación está archivada, hacer `UPDATE ... SET is_archived = 0`
