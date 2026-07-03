# HU-009: Pantalla de lista de conversaciones (Inbox)

**Como** usuario
**Quiero** ver una pantalla con la lista de todas mis conversaciones de SMS
**Para** seleccionar con quién quiero chatear

**Requerimiento Padre:** REQ-001.3 (Bandeja de entrada)

**Prioridad:** Alta
**Esfuerzo:** 5 puntos

**Dependencias:** HU-006

**Criterios de Aceptación:**
- [ ] Existe la pantalla `InboxScreen` en `lib/presentation/screens/inbox_screen.dart`
- [ ] La pantalla muestra una `ListView` con todas las conversaciones
- [ ] Cada elemento de la lista muestra: avatar/icono del contacto, nombre/remitente, preview del último mensaje, hora, badge de no leídos
- [ ] La lista se actualiza automáticamente cuando llegan nuevos SMS (gracias al Stream del repositorio)
- [ ] Si no hay conversaciones, se muestra un estado vacío con icono y texto ("No hay conversaciones")
- [ ] La pantalla tiene un `AppBar` con el título "Mensajes" y un icono de ajustes (que navega a `/config`)
- [ ] La pantalla tiene un `FloatingActionButton` con icono de lápiz (para nueva conversación — funcionalidad básica)
- [ ] La pantalla se integra en el router de GoRouter como ruta `/inbox`
- [ ] La pantalla principal (`MainScreen`) sigue siendo accesible desde un BottomNavigationBar o Drawer
- [ ] Se usa `Consumer` de Provider para escuchar cambios en el `InboxProvider`
- [ ] Existe `InboxProvider` en `lib/presentation/providers/inbox_provider.dart` que expone `List<Conversation>` y el estado de carga

**Notas técnicas:**
- La pantalla debe seguir el tema Material Design 3 existente
- Usar `ListTile` con `leading` para el avatar, `title` para el nombre, `subtitle` para el preview, `trailing` para la hora
- El badge de no leídos debe ser un `CircleAvatar` pequeño con el número
- El `InboxProvider` debe suscribirse a `SmsInboxRepository.watchConversations()`
- Registrar `InboxProvider` en `presentation_module.dart` y en los providers de `main.dart`
