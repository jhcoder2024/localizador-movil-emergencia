# HU-013: Pantalla de conversación con burbujas de chat

**Como** usuario
**Quiero** ver una pantalla de chat con burbujas de mensajes estilo WhatsApp/Messenger
**Para** leer la conversación completa de forma clara y familiar

**Requerimiento Padre:** REQ-001.4 (Visor de conversación y envío)

**Prioridad:** Alta
**Esfuerzo:** 5 puntos

**Dependencias:** HU-012

**Criterios de Aceptación:**
- [ ] Existe `ConversationScreen` en `lib/presentation/screens/conversation_screen.dart`
- [ ] La pantalla recibe el `conversationId` como parámetro y carga los mensajes automáticamente
- [ ] Los mensajes se muestran en una `ListView` con burbujas de chat:
  - **Mensajes recibidos:** Burbuja gris claro alineada a la izquierda, con el texto y la hora
  - **Mensajes enviados:** Burbuja de color primario alineada a la derecha, con el texto y la hora
- [ ] Cada burbuja muestra:
  - El texto del mensaje
  - La hora en formato "h:mm AM/PM"
  - Para mensajes MMS con imagen, mostrar la imagen dentro de la burbuja (ver HU-021)
- [ ] La lista se desplaza automáticamente al último mensaje al abrir la conversación
- [ ] La lista se actualiza en tiempo real cuando llegan nuevos mensajes (Stream de Drift)
- [ ] El `AppBar` muestra el nombre del contacto (o número) y un avatar
- [ ] Si la conversación está vacía (recién creada), se muestra un mensaje de bienvenida
- [ ] Existe `ConversationProvider` en `lib/presentation/providers/conversation_provider.dart` que expone `List<SmsMessage>` y el estado de carga
- [ ] Los mensajes se marcan como leídos al abrir la pantalla (ver HU-008)

**Notas técnicas:**
- Usar `ListView.builder` con `reverse: true` para que el último mensaje esté al fondo
- La burbuja puede ser un `Container` con `BorderRadius` y `BoxDecoration`
- Para el scroll automático, usar `ScrollController` con `jumpTo(0)` si `reverse: true`
- El `ConversationProvider` debe suscribirse a `SmsInboxRepository.watchMessages(conversationId)`
- Registrar `ConversationProvider` (factory, no singleton) en `presentation_module.dart`
