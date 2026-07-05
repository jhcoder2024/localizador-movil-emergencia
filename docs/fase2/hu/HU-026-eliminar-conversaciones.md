# HU-026: Eliminar conversaciones con confirmación

**Como** usuario
**Quiero** eliminar conversaciones completas o mensajes individuales
**Para** liberar espacio y eliminar contenido que ya no necesito

**Requerimiento Padre:** REQ-F2-005 (Archivar / Eliminar)

**Prioridad:** Alta
**Esfuerzo:** S (1 punto)

**Dependencias:** HU-025 (Archivar conversaciones)

**Criterios de Aceptación:**
- [ ] Desde el menú contextual (long-press) de una conversación, hay opción "Eliminar"
- [ ] Desde la pantalla de conversación, hay opción "Eliminar conversación" en el menú del AppBar
- [ ] Al seleccionar eliminar, se muestra un diálogo de confirmación:
  - Título: "¿Eliminar conversación?"
  - Mensaje: "Se eliminarán todos los mensajes con [contacto]. Esta acción no se puede deshacer."
  - Botones: "Cancelar" (outlined) y "Eliminar" (rojo, destructivo)
- [ ] Al confirmar, se eliminan todos los mensajes de la conversación de la BD local
- [ ] Opcional: también se eliminan los SMS del ContentProvider del sistema (si la app es la predeterminada)
- [ ] La conversación desaparece de la bandeja de entrada inmediatamente
- [ ] También se puede eliminar un mensaje individual desde la conversación (long-press → "Eliminar")
- [ ] Al eliminar un mensaje individual, se muestra confirmación: "¿Eliminar este mensaje?"
- [ ] Los mensajes eliminados no se pueden recuperar (no hay papelera)

**Capa técnica requerida:**
- **Data:** Método `deleteConversation(int conversationId)` y `deleteMessage(int messageId)` en DAO
- **Domain:** Casos de uso `DeleteConversationUseCase` y `DeleteMessageUseCase`
- **Presentation:** Provider con métodos de eliminación, diálogos de confirmación

**Notas técnicas:**
- La eliminación de SMS del ContentProvider del sistema requiere permisos adicionales en Android 14+
- Si no se puede eliminar del ContentProvider, al menos eliminar de la BD local
- Usar transacciones Drift para eliminar en cascada (conversación → mensajes)
- Considerar usar `showDialog` con `AlertDialog` de M3 para el diálogo de confirmación
