# HU-017: Botón de emergencia integrado en la bandeja (FAB)

**Como** usuario
**Quiero** tener el botón de emergencia siempre accesible desde la bandeja de entrada de SMS
**Para** poder activar una emergencia rápidamente sin salir de la app de SMS

**Requerimiento Padre:** REQ-001.5 (Emergencia automática)

**Prioridad:** Alta
**Esfuerzo:** 3 puntos

**Dependencias:** HU-009

**Criterios de Aceptación:**
- [ ] La pantalla `InboxScreen` tiene un `FloatingActionButton` rojo con icono de emergencia (SOS o teléfono)
- [ ] Al tocar el FAB, se abre el mismo flujo de confirmación de emergencia existente (diálogo de confirmación)
- [ ] El FAB está siempre visible, incluso cuando la lista está vacía
- [ ] El FAB tiene un tooltip "Emergencia"
- [ ] La navegación entre Inbox y MainScreen se maneja con un `BottomNavigationBar` con dos pestañas:
  - "Mensajes" (icono de chat) → InboxScreen
  - "Emergencia" (icono de alerta) → MainScreen (vista actual con botones de emergencia)
- [ ] El `BottomNavigationBar` se agrega a un nuevo `HomeScreen` que contiene ambas pantallas
- [ ] La ruta raíz `/` ahora apunta a `HomeScreen` en lugar de `MainScreen`
- [ ] La funcionalidad de emergencia existente (sonido, notificaciones, foreground service) sigue funcionando igual

**Notas técnicas:**
- Crear `HomeScreen` como un `Scaffold` con `BottomNavigationBar` y un `IndexedStack` para mantener el estado de ambas pantallas
- La ruta `/` ahora es `HomeScreen`, `/inbox` redirige a la pestaña de mensajes, `/emergency` a la pestaña de emergencia
- El FAB de emergencia en InboxScreen debe ser independiente del FAB de nueva conversación (usar un FAB rojo distintivo)
- Mantener la consistencia visual con el tema actual (Material Design 3)
