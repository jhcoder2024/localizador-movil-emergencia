# HU-012: Navegar al tocar una conversación

**Como** usuario
**Quiero** tocar una conversación en la lista y que me lleve a la pantalla de chat
**Para** leer los mensajes y responder

**Requerimiento Padre:** REQ-001.3 (Bandeja de entrada)

**Prioridad:** Alta
**Esfuerzo:** 2 puntos

**Dependencias:** HU-009

**Criterios de Aceptación:**
- [ ] Al tocar una conversación en la lista, se navega a la pantalla de chat (`ConversationScreen`) con el `conversationId` como parámetro
- [ ] La navegación usa GoRouter con ruta `/conversation/:id`
- [ ] Al navegar, los mensajes no leídos de esa conversación se marcan como leídos (ver HU-008)
- [ ] La transición de navegación es consistente con el estilo de la app (slide desde la derecha)
- [ ] El botón de retroceso en el AppBar de la pantalla de chat vuelve a la lista de conversaciones
- [ ] La pantalla de chat se crea como placeholder inicial (el contenido completo se desarrolla en HU-013)

**Notas técnicas:**
- Registrar la ruta en GoRouter:
  ```dart
  GoRoute(
    path: '/conversation/:id',
    builder: (context, state) => ConversationScreen(
      conversationId: state.pathParameters['id']!,
    ),
  )
  ```
- Pasar `conversationId` como parámetro de ruta, no como argumento
