# HU-027: Editor de texto enriquecido con emojis

**Como** usuario
**Quiero** tener un editor de mensajes con emojis y formato de texto básico
**Para** expresarme mejor en mis conversaciones SMS

**Requerimiento Padre:** REQ-F2-006 (Editor de texto enriquecido)

**Prioridad:** Alta
**Esfuerzo:** L (3 puntos)

**Dependencias:** HU-014 (Campo de texto y botón enviar SMS)

**Criterios de Aceptación:**
- [ ] El campo de texto en la pantalla de conversación tiene un botón de emoji al lado
- [ ] Al tocar el botón de emoji, se abre un panel/popup con el selector de emojis
- [ ] El selector de emojis incluye categorías: 😀 Smileys, 🐾 Animales, 🍔 Comida, ⚽ Deportes, 🚗 Viajes, 💡 Objetos, ❤️ Símbolos, 🏳️ Banderas
- [ ] Al seleccionar un emoji, se inserta en el campo de texto en la posición del cursor
- [ ] El panel de emojis se puede cerrar tocando fuera de él o con el botón de cerrar
- [ ] El campo de texto soporta formato básico (opcional, si el SMS lo permite):
  - Negrita, cursiva, tachado (se convierten a texto plano al enviar)
- [ ] El campo de texto se expande hasta 5 líneas máximo (evita que ocupe toda la pantalla)
- [ ] El botón de enviar se deshabilita si solo hay emojis/espacios (texto vacío)
- [ ] Los emojis se renderizan correctamente en las burbujas de chat (tanto enviados como recibidos)
- [ ] El rendimiento del selector de emojis es fluido (sin lag al abrir/cerrar)

**Nuevas dependencias:**
- `emoji_picker_flutter: ^2.0.0` (o similar)

**Notas técnicas:**
- Usar `emoji_picker_flutter` que es la librería más popular para Flutter
- El panel de emojis puede ser un `showModalBottomSheet` o un `AnimatedContainer` dentro de la misma pantalla
- Para formato de texto: SMS no soporta formato enriquecido nativamente, pero se puede mostrar visualmente en la app y convertir a texto plano al enviar
- Considerar usar `TextField` con `maxLines: 5` y `minLines: 1`
- Los emojis se almacenan como texto Unicode normal en la BD (no requieren tratamiento especial)
