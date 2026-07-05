# HU-024: Búsqueda de conversaciones y mensajes

**Como** usuario
**Quiero** buscar mensajes y conversaciones por texto
**Para** encontrar rápidamente información importante sin tener que revisar manualmente cada conversación

**Requerimiento Padre:** REQ-F2-004 (Búsqueda)

**Prioridad:** Alta
**Esfuerzo:** XL (5 puntos)

**Dependencias:** HU-009 (Pantalla de lista de conversaciones), HU-013 (Pantalla de conversación con burbujas)

**Criterios de Aceptación:**
- [ ] Hay un campo de búsqueda accesible desde la barra superior de la bandeja de entrada (icono de lupa)
- [ ] Al tocar la lupa, el AppBar se transforma en una barra de búsqueda con animación
- [ ] La búsqueda es incremental: los resultados se filtran mientras el usuario escribe
- [ ] La búsqueda busca en:
  - Nombre del contacto (remitente)
  - Número de teléfono
  - Contenido del mensaje
- [ ] Los resultados se muestran agrupados por conversación:
  - Cada resultado muestra: nombre del contacto, preview del mensaje con el término resaltado, fecha
  - Al tocar un resultado, se navega a la conversación en la posición del mensaje encontrado
- [ ] Si no hay resultados, se muestra un mensaje "Sin resultados" con icono ilustrativo
- [ ] La búsqueda tiene un botón "X" para limpiar el texto y volver al inbox
- [ ] La búsqueda funciona offline (sobre la base de datos local Drift)
- [ ] El rendimiento es aceptable: resultados en <500ms para 1000+ mensajes

**Capa técnica requerida:**
- **Data:** Nuevo método en `SmsDao` para búsqueda FTS (Full-Text Search) en Drift
- **Domain:** Nuevo `SearchMessagesUseCase` o método en `SmsInboxRepository`
- **Presentation:** Nuevo `SearchProvider` con estado de búsqueda, `SearchScreen` o integración en InboxScreen

**Notas técnicas:**
- Drift soporta FTS5 (Full-Text Search) — crear una tabla virtual FTS para búsqueda eficiente
- Alternativa: usar `LIKE %query%` para búsqueda simple si FTS5 es complejo de implementar
- Para resaltar términos: usar `RichText` con `TextSpan` y `HighlightPainter`
- Considerar debounce de 300ms para no saturar la BD en cada tecla
- La navegación al mensaje específico requiere pasar el `messageId` como parámetro de ruta
